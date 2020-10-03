import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'enums/vlc_hardware_acceleration.dart';
import 'events/vlc_cast_event.dart';
import 'events/vlc_media_event.dart';

import 'method_channel_vlc_player.dart';

/// The interface that implementations of vlc must implement.
///
/// Platform implementations should extend this class rather than implement it as `vlc`
/// does not consider newly added methods to be breaking changes.
abstract class VlcPlayerPlatform {
  /// Only mock implementations should set this to true.
  ///
  /// Mockito mocks are implementing this class with `implements` which is forbidden for anything
  /// other than mocks (see class docs). This property provides a backdoor for mockito mocks to
  /// skip the verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  static VlcPlayerPlatform _instance = MethodChannelVlcPlayer();

  /// The default instance of [VlcPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelVlcPlayer].
  static VlcPlayerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [VlcPlayerPlatform] when they register themselves.
  static set instance(VlcPlayerPlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  /// This method makes sure that VlcPlayer isn't implemented with `implements`.
  ///
  /// See class doc for more details on why implementing this class is forbidden.
  ///
  /// This private method is called by the instance setter, which fails if the class is
  /// implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  /// Initializes the platform interface and disposes all existing players.
  ///
  /// This method is called when the plugin is first initialized
  /// and on every full restart.
  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Clears one video.
  Future<void> dispose(int textureId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  /// Creates an instance of a vlc player and returns its textureId.
  Future<int> create({
    @required String uri,
    bool isLocalMedia,
    bool autoPlay,
    HwAcc hwAcc,
    List<String> options,
  }) {
    throw UnimplementedError('create() has not been implemented.');
  }

  /// Returns a widget displaying the video with a given textureID.
  Widget buildView(int textureId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  /// Returns a Stream of [VlcMediaEvent]s.
  Stream<VlcMediaEvent> mediaEventsFor(int textureId) {
    throw UnimplementedError('mediaEventsFor() has not been implemented.');
  }

  /// Set/Change video streaming url
  Future<void> setStreamUrl(
    int textureId,
    String uri, {
    bool isLocalMedia,
  }) {
    throw UnimplementedError('setStreamUrl() has not been implemented.');
  }

  /// Sets the looping attribute of the video.
  Future<void> setLooping(int textureId, bool looping) {
    throw UnimplementedError('setLooping() has not been implemented.');
  }

  /// Starts the video playback.
  Future<void> play(int textureId) {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// Pauses the video playback.
  Future<void> pause(int textureId) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  /// Stops the video playback.
  Future<void> stop(int textureId) {
    throw UnimplementedError('stop() has not been implemented.');
  }

  /// Returns true if media is playing.
  Future<bool> isPlaying(int textureId) {
    throw UnimplementedError('isPlaying() has not been implemented.');
  }

  /// Same as seekTo
  /// Sets the video position to a [Duration] from the start.
  Future<void> setTime(int textureId, Duration position) {
    throw UnimplementedError('setTime() has not been implemented.');
  }

  /// Sets the video position to a [Duration] from the start.
  Future<void> seekTo(int textureId, Duration position) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  /// Same as getPosition
  /// Gets the video position as [Duration] from the start.
  Future<Duration> getTime(int textureId) {
    throw UnimplementedError('getTime() has not been implemented.');
  }

  /// Gets the video position as [Duration] from the start.
  Future<Duration> getPosition(int textureId) {
    throw UnimplementedError('getPosition() has not been implemented.');
  }

  /// Returns duration/length of loaded video in milliseconds.
  Future<Duration> getDuration(int textureId) {
    throw UnimplementedError('getDuration() has not been implemented.');
  }

  /// Sets the volume to a range between 0 and 100.
  Future<void> setVolume(int textureId, int volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  /// Returns current vlc volume level within a range between 0 and 100.
  Future<int> getVolume(int textureId) {
    throw UnimplementedError('getVolume() has not been implemented.');
  }

  /// Sets the playback speed to a [speed] value indicating the playback rate.
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  /// Returns the vlc playback speed.
  Future<double> getPlaybackSpeed(int textureId) {
    throw UnimplementedError('getPlaybackSpeed() has not been implemented.');
  }

  /// Return the number of subtitle tracks (both embedded and inserted)
  Future<int> getSpuTracksCount(int textureId) {
    throw UnimplementedError('getSpuTracksCount() has not been implemented.');
  }

  /// Return all subtitle tracks as array of <Int, String>
  /// The key parameter is the index of subtitle which is used for changing subtitle and the value is the display name of subtitle
  Future<Map<int, String>> getSpuTracks(int textureId) {
    throw UnimplementedError('getSpuTracks() has not been implemented.');
  }

  /// Change active subtitle index (set -1 to disable subtitle).
  /// [spuTrackNumber] - the subtitle index obtained from getSpuTracks()
  Future<void> setSpuTrack(int textureId, int spuTrackNumber) {
    throw UnimplementedError('setSpuTrack() has not been implemented.');
  }

  /// Returns the selected spu track index
  Future<int> getSpuTrack(int textureId) {
    throw UnimplementedError('getSpuTrack() has not been implemented.');
  }

  /// [delay] - the amount of time in milliseconds which vlc subtitle should be delayed.
  /// (support both positive & negative delay value)
  Future<void> setSpuDelay(int textureId, int delay) {
    throw UnimplementedError('setSpuDelay() has not been implemented.');
  }

  /// Returns the amount of subtitle time delay.
  Future<int> getSpuDelay(int textureId) {
    throw UnimplementedError('getSpuDelay() has not been implemented.');
  }

  /// Add extra subtitle to media.
  /// [subtitleUrl] - URL of subtitle
  /// [isLocalSubtitle] - Set true if subtitle is on local storage
  /// [isSubtitleSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> addSubtitleTrack(
    int textureId,
    String subtitleUri, {
    bool isLocalSubtitle,
    bool isSubtitleSelected,
  }) {
    throw UnimplementedError('addSubtitleTrack() has not been implemented.');
  }

  /// Returns the number of audio tracks
  Future<int> getAudioTracksCount(int textureId) {
    throw UnimplementedError('getAudioTracksCount() has not been implemented.');
  }

  /// Returns all audio tracks as array of <Int, String>
  /// The key parameter is the index of audio track which is used for changing audio and the value is the display name of audio
  Future<Map<int, String>> getAudioTracks(int textureId) {
    throw UnimplementedError('getAudioTracks() has not been implemented.');
  }

  /// Returns selected audio track index
  Future<int> getAudioTrack(int textureId) {
    throw UnimplementedError('getAudioTrack() has not been implemented.');
  }

  /// Change active audio track index (set -1 to mute).
  /// [audioTrackNumber] - the audio track index obtained from getAudioTracks()
  Future<void> setAudioTrack(int textureId, int audioTrackNumber) {
    throw UnimplementedError('setAudioTrack() has not been implemented.');
  }

  /// [delay] - the amount of time in milliseconds which vlc audio should be delayed.
  /// (support both positive & negative value)
  Future<void> setAudioDelay(int textureId, int delay) {
    throw UnimplementedError('setAudioDelay() has not been implemented.');
  }

  /// Returns the amount of audio track time delay.
  Future<int> getAudioDelay(int textureId) {
    throw UnimplementedError('getAudioDelay() has not been implemented.');
  }

  /// Returns the number of video tracks
  Future<int> getVideoTracksCount(int textureId) {
    throw UnimplementedError('getVideoTracksCount() has not been implemented.');
  }

  /// Returns all video tracks as array of <Int, String>
  /// The key parameter is the index of video track and the value is the display name of video track
  Future<Map<int, String>> getVideoTracks(int textureId) {
    throw UnimplementedError('getVideoTracks() has not been implemented.');
  }

  /// Returns an object which contains information about current video track
  Future<dynamic> getCurrentVideoTrack(int textureId) {
    throw UnimplementedError(
        'getCurrentVideoTrack() has not been implemented.');
  }

  /// Returns selected video track index
  Future<int> getVideoTrack(int textureId) {
    throw UnimplementedError('getVideoTrack() has not been implemented.');
  }

  /// [scale] - the video scale value
  /// Set video scale
  Future<void> setVideoScale(int textureId, double scale) {
    throw UnimplementedError('setVideoScale() has not been implemented.');
  }

  /// Returns video scale
  Future<double> getVideoScale(int textureId) {
    throw UnimplementedError('getVideoScale() has not been implemented.');
  }

  /// [aspect] - the video apect ratio like "16:9"
  /// Set video aspect ratio
  Future<void> setVideoAspectRatio(int textureId, String aspect) {
    throw UnimplementedError('setVideoAspectRatio() has not been implemented.');
  }

  /// Returns video aspect ratio
  Future<String> getVideoAspectRatio(int textureId) {
    throw UnimplementedError('getVideoAspectRatio() has not been implemented.');
  }

  /// Returns binary data for a snapshot of the media at the current frame.
  Future<Uint8List> takeSnapshot(int textureId) {
    throw UnimplementedError('takeSnapshot() has not been implemented.');
  }

  /// Start vlc cast discovery to find external display devices (chromecast)
  Future<void> startCastDiscovery(int textureId, {String serviceName}) {
    throw UnimplementedError('startCastDiscovery() has not been implemented.');
  }

  /// Stop vlc cast and cast discovery
  Future<void> stopCastDiscovery(int textureId) {
    throw UnimplementedError('stopCastDiscovery() has not been implemented.');
  }

  /// Returns all detected cast devices as array of <String, String>
  /// The key parameter is the name of cast device and the value is the display name of cast device
  Future<Map<String, String>> getCastDevices(int textureId) {
    throw UnimplementedError('getCastDevices() has not been implemented.');
  }

  /// [castDevice] - name of cast device
  /// Start vlc video casting to the selected device. Set null if you wanna to stop video casting.
  Future<void> startCasting(int textureId, String castDevice) {
    throw UnimplementedError('startCasting() has not been implemented.');
  }

  /// Returns a Stream of [VlcCastEvent]s.
  Stream<VlcCastEvent> castEventsFor(int textureId) {
    throw UnimplementedError('castEventsFor() has not been implemented.');
  }
}
