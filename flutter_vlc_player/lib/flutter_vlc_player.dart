import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player_platform_interface/enums/vlc_hardware_acceleration.dart';
import 'package:flutter_vlc_player_platform_interface/enums/vlc_media_event_type.dart';
import 'package:flutter_vlc_player_platform_interface/events/vlc_media_event.dart';
import 'package:flutter_vlc_player_platform_interface/vlc_player_platform_interface.dart';
import 'enums/playing_state.dart';
import 'vlc_app_life_cycle_observer.dart';
import 'vlc_player_value.dart';

final VlcPlayerPlatform _vlcPlayerPlatform = VlcPlayerPlatform.instance
// This will clear all open videos on the platform when a full restart is
// performed.
  ..init();

/// Controls a platform vlc player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The video is displayed in a Flutter app by creating a [VlcPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class VlcPlayerController extends ValueNotifier<VlcPlayerValue> {
  /// Constructs a [VlcPlayerController] playing a video from an local file.
  ///
  /// The name of the local file is given by the [dataSource] argument and must not be
  /// null.
  VlcPlayerController.local(
    this.dataSource, {
    this.hwAcc,
    this.autoPlay,
    this.options,
  })  : _isLocalMedia = true,
        super(VlcPlayerValue(duration: null));

  /// Constructs a [VlcPlayerController] playing a video from obtained from
  /// the network.
  ///
  /// The URI for the video is given by the [dataSource] argument and must not be
  /// null.
  VlcPlayerController.network(
    this.dataSource, {
    this.hwAcc,
    this.autoPlay,
    this.options,
  })  : _isLocalMedia = false,
        super(VlcPlayerValue(duration: null));

  /// The URI to the video file. This will be in different formats depending on
  /// the [DataSourceType] of the original video.
  final String dataSource;

  /// Set hardware acceleration for player. Default is Automatic.
  final HwAcc hwAcc;

  /// Adds options to vlc. For more [https://wiki.videolan.org/VLC_command-line_help] If nothing is provided,
  /// vlc will run without any options set.
  final List<String> options;

  /// The video should be played automatically.
  final bool autoPlay;

  bool _isLocalMedia;

  int _textureId;

  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  StreamSubscription<dynamic> _eventSubscription;
  VlcAppLifeCycleObserver _lifeCycleObserver;

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  @visibleForTesting
  int get textureId => _textureId;

  /// Attempts to open the given [url] and load metadata about the video.
  Future<void> initialize() async {
    _lifeCycleObserver = VlcAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();

    _textureId = await _vlcPlayerPlatform.create(
      uri: this.dataSource,
      isLocalMedia: _isLocalMedia,
      hwAcc: this.hwAcc ?? HwAcc.AUTO,
      autoPlay: this.autoPlay ?? true,
      options: this.options ?? [],
    );

    _creatingCompleter.complete(null);
    final Completer<void> initializingCompleter = Completer<void>();

    void eventListener(VlcMediaEvent event) {
      if (_isDisposed) {
        return;
      }
      switch (event.mediaEventType) {
        case VlcMediaEventType.opening:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: true,
            playingState: PlayingState.buffering,
          );
          break;

        case VlcMediaEventType.paused:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: false,
            playingState: PlayingState.paused,
          );
          break;

        case VlcMediaEventType.stopped:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: false,
            playingState: PlayingState.stopped,
          );
          break;

        case VlcMediaEventType.playing:
          value = value.copyWith(
            isPlaying: true,
            playingState: PlayingState.playing,
            duration: event.duration,
            size: event.size,
            playbackSpeed: event.playbackSpeed,
            audioTracksCount: event.audioTracksCount,
            activeAudioTrack: event.activeAudioTrack,
            spuTracksCount: event.spuTracksCount,
            activeSpuTrack: event.activeSpuTrack,
          );
          if (!initializingCompleter.isCompleted)
            initializingCompleter.complete(null);
          break;

        case VlcMediaEventType.ended:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: false,
            playingState: PlayingState.stopped,
            position: event.position,
          );
          break;

        // todo: maybe we need to separate buffering and time change event
        case VlcMediaEventType.buffering:
        case VlcMediaEventType.timeChanged:
          value = value.copyWith(
            position: event.position,
            playbackSpeed: event.playbackSpeed,
            bufferPercent: event.bufferPercent,
          );
          break;

        case VlcMediaEventType.mediaChanged:
          break;

        case VlcMediaEventType.unknown:
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
      value = VlcPlayerValue.erroneous(e.message);
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    _eventSubscription = _vlcPlayerPlatform
        .mediaEventsFor(_textureId)
        .listen(eventListener, onError: errorListener);
    return initializingCompleter.future;
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_isDisposed) {
        _isDisposed = true;
        await _eventSubscription?.cancel();
        await _vlcPlayerPlatform.dispose(_textureId);
      }
      _lifeCycleObserver.dispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  /// This stops playback and changes the URL. Once the new URL has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if setStreamUrl is called whilst media is playing, once the new
  /// URL has been loaded, the new stream will begin playing.)
  /// [uri] - the URL of the stream to start playing.
  /// [isLocalMedia] - Set true if the media url is on local storage.
  Future<void> setStreamUrl(String uri, {bool isLocalMedia}) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    bool wasPlaying = value.isPlaying;
    await _vlcPlayerPlatform.setStreamUrl(
      _textureId,
      uri,
      isLocalMedia: isLocalMedia ?? false,
    );
    if (wasPlaying) play();
    return;
  }

  /// Starts playing the video.
  ///
  /// This method returns a future that completes as soon as the "play" command
  /// has been sent to the platform, not when playback itself is totally
  /// finished.
  Future<void> play() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    await _vlcPlayerPlatform.play(_textureId);
    // This ensures that the correct playback speed is always applied when
    // playing back. This is necessary because we do not set playback speed
    // when paused.
    await setPlaybackSpeed(value.playbackSpeed);
  }

  /// Pauses the video.
  Future<void> pause() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    await _vlcPlayerPlatform.pause(_textureId);
  }

  /// stops the video.
  Future<void> stop() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    await _vlcPlayerPlatform.stop(_textureId);
  }

  /// Sets whether or not the video should loop after playing once.
  Future<void> setLooping(bool looping) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(isLooping: looping);
    await _vlcPlayerPlatform.setLooping(_textureId, looping);
  }

  /// Returns true if media is playing.
  Future<bool> isPlaying() async {
    return await _vlcPlayerPlatform.isPlaying(_textureId);
  }

  /// Set video timestamp in millisecond
  Future<void> setTime(int time) async {
    return await seekTo(Duration(milliseconds: time));
  }

  /// Sets the video's current timestamp to be at [moment]. The next
  /// time the video is played it will resume from the given [moment].
  ///
  /// If [moment] is outside of the video's full range it will be automatically
  /// and silently clamped.
  Future<void> seekTo(Duration position) async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    if (position > value.duration) {
      position = value.duration;
    } else if (position < const Duration()) {
      position = const Duration();
    }
    await _vlcPlayerPlatform.seekTo(_textureId, position);
  }

  /// Get the video timestamp in millisecond
  Future<int> getTime() async {
    Duration position = await getPosition();
    return position.inMilliseconds;
  }

  /// Returns the position in the current video.
  Future<Duration> getPosition() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    Duration position = await _vlcPlayerPlatform.getPosition(_textureId);
    value = value.copyWith(position: position);
    return position;
  }

  /// Sets the audio volume of
  ///
  /// [volume] indicates a value between 0 (silent) and 100 (full volume) on a
  /// linear scale.
  Future<void> setVolume(int volume) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(volume: volume.clamp(0, 100));
    await _vlcPlayerPlatform.setVolume(_textureId, value.volume);
  }

  /// Returns current vlc volume level.
  Future<int> getVolume() async {
    if (!value.initialized || _isDisposed) {
      return 0;
    }
    int volume = await _vlcPlayerPlatform.getVolume(_textureId);
    value = value.copyWith(volume: volume.clamp(0, 100));
    return volume;
  }

  /// Returns duration/length of loaded video
  Future<Duration> getDuration() async {
    if (!value.initialized || _isDisposed) {
      return Duration.zero;
    }
    Duration duration = await _vlcPlayerPlatform.getDuration(_textureId);
    value = value.copyWith(duration: duration);
    return duration;
  }

  /// Sets the playback speed.
  ///
  /// [speed] - the rate at which VLC should play media.
  /// For reference:
  /// 2.0 is double speed.
  /// 1.0 is normal speed.
  /// 0.5 is half speed.
  Future<void> setPlaybackSpeed(double speed) async {
    if (speed < 0) {
      throw ArgumentError.value(
        speed,
        'Negative playback speeds are not supported.',
      );
    } else if (speed == 0) {
      throw ArgumentError.value(
        speed,
        'Zero playback speed is not supported. Consider using [pause].',
      );
    }
    value = value.copyWith(playbackSpeed: speed);
    //
    if (!value.initialized || _isDisposed) {
      return;
    }
    // Setting the playback speed on iOS will trigger the video to play. We
    // prevent this from happening by not applying the playback speed until
    // the video is manually played from Flutter.
    if (!value.isPlaying) return;
    await _vlcPlayerPlatform.setPlaybackSpeed(
      _textureId,
      value.playbackSpeed,
    );
  }

  /// Returns the vlc playback speed.
  Future<double> getPlaybackSpeed() async {
    if (!value.initialized || _isDisposed) {
      return value.playbackSpeed;
    }
    //
    double speed = await _vlcPlayerPlatform.getPlaybackSpeed(_textureId);
    value = value.copyWith(playbackSpeed: speed);
    return speed;
  }

  /// Return the number of subtitle tracks (both embedded and inserted)
  Future<int> getSpuTracksCount() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int spuTracksCount = await _vlcPlayerPlatform.getSpuTracksCount(_textureId);
    value = value.copyWith(spuTracksCount: spuTracksCount);
    return spuTracksCount;
  }

  /// Return all subtitle tracks as array of <Int, String>
  /// The key parameter is the index of subtitle which is used for changing subtitle
  /// and the value is the display name of subtitle
  Future<Map<int, String>> getSpuTracks() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.getSpuTracks(_textureId);
  }

  /// Change active subtitle index (set -1 to disable subtitle).
  /// [spuTrackNumber] - the subtitle index obtained from getSpuTracks()
  Future<void> setSpuTrack(int spuTrackNumber) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    return await _vlcPlayerPlatform.setSpuTrack(_textureId, spuTrackNumber);
  }

  /// Returns active spu track index
  Future<int> getSpuTrack() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int activeSpuTrack = await _vlcPlayerPlatform.getSpuTrack(_textureId);
    value = value.copyWith(activeSpuTrack: activeSpuTrack);
    return activeSpuTrack;
  }

  /// [spuDelay] - the amount of time in milliseconds which vlc subtitle should be delayed.
  /// (both positive & negative value applicable)
  Future<void> setSpuDelay(int spuDelay) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(spuDelay: spuDelay);
    return await _vlcPlayerPlatform.setSpuDelay(_textureId, spuDelay);
  }

  /// Returns the amount of subtitle time delay.
  Future<int> getSpuDelay() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int spuDelay = await _vlcPlayerPlatform.getSpuDelay(_textureId);
    value = value.copyWith(spuDelay: spuDelay);
    return spuDelay;
  }

  /// Add extra subtitle to media.
  /// [uri] - URL of subtitle
  /// [isLocal] - Set true if subtitle is on local storage
  /// [isSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> addSubtitleTrack(
    String uri, {
    bool isLocal,
    bool isSelected,
  }) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    return await _vlcPlayerPlatform.addSubtitleTrack(
      _textureId,
      uri,
      isLocal: isLocal ?? false,
      isSelected: isSelected ?? true,
    );
  }

  /// Returns the number of audio tracks
  Future<int> getAudioTracksCount() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int audioTracksCount =
        await _vlcPlayerPlatform.getAudioTracksCount(_textureId);
    value = value.copyWith(audioTracksCount: audioTracksCount);
    return audioTracksCount;
  }

  /// Returns all audio tracks as array of <Int, String>
  /// The key parameter is the index of audio track which is used for changing audio
  /// and the value is the display name of audio
  Future<Map<int, String>> getAudioTracks() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.getAudioTracks(_textureId);
  }

  /// Returns active audio track index
  Future<int> getAudioTrack() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int activeAudioTrack = await _vlcPlayerPlatform.getAudioTrack(_textureId);
    value = value.copyWith(activeAudioTrack: activeAudioTrack);
    return activeAudioTrack;
  }

  /// Change active audio track index (set -1 to mute).
  /// [audioTrackNumber] - the audio track index obtained from getAudioTracks()
  Future<void> setAudioTrack(int audioTrackNumber) async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.setAudioTrack(_textureId, audioTrackNumber);
  }

  /// [audioDelay] - the amount of time in milliseconds which vlc audio should be delayed.
  /// (both positive & negative value appliable)
  Future<void> setAudioDelay(int audioDelay) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(audioDelay: audioDelay);
    return await _vlcPlayerPlatform.setAudioDelay(_textureId, audioDelay);
  }

  /// Returns the amount of audio track time delay in millisecond.
  Future<int> getAudioDelay() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int audioDelay = await _vlcPlayerPlatform.getAudioDelay(_textureId);
    value = value.copyWith(audioDelay: audioDelay);
    return audioDelay;
  }

  /// Returns the number of video tracks
  Future<int> getVideoTracksCount() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int videoTracksCount =
        await _vlcPlayerPlatform.getVideoTracksCount(_textureId);
    value = value.copyWith(videoTracksCount: videoTracksCount);
    return videoTracksCount;
  }

  /// Returns all video tracks as array of <Int, String>
  /// The key parameter is the index of video track and the value is the display name of video track
  Future<Map<int, String>> getVideoTracks() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.getVideoTracks(_textureId);
  }

  /// Change active video track index.
  /// [videoTrackNumber] - the video track index obtained from getVideoTracks()
  Future<void> setVideoTrack(int videoTrackNumber) async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.setVideoTrack(_textureId, videoTrackNumber);
  }

  /// Returns active video track index
  Future<int> getVideoTrack() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    int activeVideoTrack = await _vlcPlayerPlatform.getVideoTrack(_textureId);
    value = value.copyWith(activeVideoTrack: activeVideoTrack);
    return activeVideoTrack;
  }

  /// [scale] - the video scale value
  /// Set video scale
  Future<void> setVideoScale(double videoScale) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(videoScale: videoScale);
    return await _vlcPlayerPlatform.setVideoScale(_textureId, videoScale);
  }

  /// Returns video scale
  Future<double> getVideoScale() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    double videoScale = await _vlcPlayerPlatform.getVideoScale(_textureId);
    value = value.copyWith(videoScale: videoScale);
    return videoScale;
  }

  /// [aspectRatio] - the video aspect ratio like "16:9"
  ///
  /// Set video aspect ratio
  Future<void> setVideoAspectRatio(String aspectRatio) async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    return _vlcPlayerPlatform.setVideoAspectRatio(_textureId, aspectRatio);
  }

  /// Returns video aspect ratio in string format
  ///
  /// This is different from the aspectRatio property in video value "16:9"
  Future<String> getVideoAspectRatio() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return _vlcPlayerPlatform.getVideoAspectRatio(_textureId);
  }

  /// Returns binary data for a snapshot of the media at the current frame.
  ///
  Future<Uint8List> takeSnapshot() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.takeSnapshot(_textureId);
  }

  /// Start vlc cast discovery to find external display devices (chromecast)
  /// By setting serviceName, the vlc discovers renderer with that service
  Future<void> startRendererScanning({String rendererService}) async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.startRendererScanning(textureId,
        rendererService: rendererService ?? '');
  }

  /// Stop vlc cast and scan
  Future<void> stopRendererScanning() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.stopRendererScanning(textureId);
  }

  /// Returns all detected renderer devices as array of <String, String>
  /// The key parameter is the name of cast device and the value is the display name of cast device
  Future<Map<String, String>> getRendererDevices() async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.getRendererDevices(_textureId);
  }

  /// [castDevice] - name of renderer device
  /// Start vlc video casting to the selected device.
  /// Set null if you wanna stop video casting.
  Future<void> castToRenderer(String castDevice) async {
    if (!value.initialized || _isDisposed) {
      return null;
    }
    return await _vlcPlayerPlatform.castToRenderer(_textureId, castDevice);
  }
}

class VlcPlayer extends StatefulWidget {
  final VlcPlayerController controller;
  final double aspectRatio;
  final Widget placeholder;

  VlcPlayer({
    Key key,

    /// The [VlcPlayerController] responsible for the video being rendered in
    /// this widget.
    @required this.controller,

    /// The aspect ratio used to display the video.
    /// This MUST be provided, however it could simply be (parentWidth / parentHeight) - where parentWidth and
    /// parentHeight are the width and height of the parent perhaps as defined by a LayoutBuilder.
    @required this.aspectRatio,

    /// Before the platform view has initialized, this placeholder will be rendered instead of the video player.
    /// This can simply be a [CircularProgressIndicator] (see the example.)
    this.placeholder,
  }) : super(key: key);

  @override
  _VlcPlayerState createState() => _VlcPlayerState();
}

class _VlcPlayerState extends State<VlcPlayer> {
  _VlcPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  VoidCallback _listener;
  int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    // Need to listen for initialization events since the actual texture ID
    // becomes available after asynchronous initialization finishes.
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(VlcPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_listener);
      _textureId = widget.controller.textureId;
      widget.controller.addListener(_listener);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == null
        ? widget.placeholder ?? Container()
        : _vlcPlayerPlatform.buildView(_textureId);
  }
}
