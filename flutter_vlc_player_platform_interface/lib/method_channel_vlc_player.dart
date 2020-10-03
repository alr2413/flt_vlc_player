import 'dart:async';
import 'dart:typed_data';

import 'package:cryptoutils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'enums/vlc_hardware_acceleration.dart';
import 'enums/vlc_media_event_type.dart';
import 'events/vlc_cast_event.dart';
import 'events/vlc_media_event.dart';

import 'messages.dart';
import 'vlc_player_platform_interface.dart';

/// An implementation of [VlcPlayerPlatform] that uses method channels.
class MethodChannelVlcPlayer extends VlcPlayerPlatform {
  VlcPlayerApi _api = VlcPlayerApi();

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('flutter_video_plugin/getVideoEvents_$textureId');
  }

  @override
  Future<void> init() {
    return _api.initialize();
  }

  @override
  Future<int> create({
    @required String uri,
    bool isLocalMedia,
    bool autoPlay,
    HwAcc hwAcc,
    List<String> options,
    String subtitleUrl,
    bool isLocalSubtitle,
    bool isSubtitleSelected,
  }) async {
    CreateMessage message = CreateMessage();
    message.uri = uri;
    message.hwAcc = hwAcc.index ?? HwAcc.AUTO.index;
    message.isLocalMedia = isLocalMedia ?? true;
    message.autoPlay = autoPlay ?? true;
    message.options = options ?? [];
    TextureMessage response = await _api.create(message);
    return response.textureId;
  }

  @override
  Future<void> dispose(int textureId) {
    return _api.dispose(TextureMessage()..textureId = textureId);
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

  @override
  Stream<VlcMediaEvent> mediaEventsFor(int textureId) {
    return _eventChannelFor(textureId).receiveBroadcastStream().map(
      (dynamic event) {
        final Map<dynamic, dynamic> map = event;
        //
        switch (map['event']) {
          case 'initialized':
            return VlcMediaEvent(
              mediaEventType: VlcMediaEventType.INITIALIZED,
              duration: Duration(milliseconds: map['duration']),
              size: Size(
                map['width']?.toDouble() ?? 0.0,
                map['height']?.toDouble() ?? 0.0,
              ),
              playbackSpeed: map['playbackSpeed'] ?? 1.0,
              aspectRatio: map['ratio'] ?? 0.0,
              audioTracksCount: map['audioTracksCount'] ?? 1,
              activeAudioTrack: map['activeAudioTrack'] ?? 0,
              spuTracksCount: map['spuTracksCount'] ?? 0,
              activeSpuTrack: map['activeSpuTrack'] ?? -1,
            );

          case 'buffering':
            return VlcMediaEvent(
              mediaEventType: VlcMediaEventType.BUFFERING,
              bufferPercent: map['percent'],
            );

          case 'playing':
            return VlcMediaEvent(
              mediaEventType: VlcMediaEventType.PLAYING,
              duration: Duration(milliseconds: map['duration']),
              size: Size(
                map['width']?.toDouble() ?? 0.0,
                map['height']?.toDouble() ?? 0.0,
              ),
              playbackSpeed: map['playbackSpeed'] ?? 1.0,
              aspectRatio: map['ratio'] ?? 0.0,
              audioTracksCount: map['audioTracksCount'] ?? 1,
              activeAudioTrack: map['activeAudioTrack'] ?? 0,
              spuTracksCount: map['spuTracksCount'] ?? 0,
              activeSpuTrack: map['activeSpuTrack'] ?? -1,
            );

          case 'paused':
            return VlcMediaEvent(mediaEventType: VlcMediaEventType.PAUSED);

          case 'stopped':
            return VlcMediaEvent(mediaEventType: VlcMediaEventType.STOPPED);

          case 'timeChanged':
            return VlcMediaEvent(
              mediaEventType: VlcMediaEventType.TIME_CHANGED,
              position: Duration(milliseconds: map['position']),
            );

          case 'error':
            return VlcMediaEvent(mediaEventType: VlcMediaEventType.ERROR);

          default:
            return VlcMediaEvent(mediaEventType: VlcMediaEventType.UNKNOWN);
        }
      },
    );
  }

  @override
  Future<void> setStreamUrl(
    int textureId,
    String uri, {
    bool isLocalMedia,
  }) async {
    SetMediaMessage message = SetMediaMessage();
    message.textureId = textureId;
    message.uri = uri;
    message.isLocalMedia = isLocalMedia ?? false;
    return await _api.setStreamUrl(message);
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    return _api.setLooping(LoopingMessage()
      ..textureId = textureId
      ..isLooping = looping);
  }

  @override
  Future<void> play(int textureId) async {
    return await _api.play(TextureMessage()..textureId = textureId);
  }

  @override
  Future<void> pause(int textureId) async {
    return await _api.pause(TextureMessage()..textureId = textureId);
  }

  @override
  Future<void> stop(int textureId) async {
    return await _api.stop(TextureMessage()..textureId = textureId);
  }

  @override
  Future<bool> isPlaying(int textureId) async {
    BooleanMessage response =
        await _api.isPlaying(TextureMessage()..textureId = textureId);
    return response.result;
  }

  @override
  Future<void> setTime(int textureId, Duration position) {
    return _api.seekTo(PositionMessage()
      ..textureId = textureId
      ..position = position.inMilliseconds);
  }

  @override
  Future<void> seekTo(int textureId, Duration position) {
    return _api.seekTo(PositionMessage()
      ..textureId = textureId
      ..position = position.inMilliseconds);
  }

  @override
  Future<Duration> getTime(int textureId) async {
    PositionMessage response =
        await _api.position(TextureMessage()..textureId = textureId);
    return Duration(milliseconds: response.position);
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    PositionMessage response =
        await _api.position(TextureMessage()..textureId = textureId);
    return Duration(milliseconds: response.position);
  }

  @override
  Future<Duration> getDuration(int textureId) async {
    DurationMessage response =
        await _api.duration(TextureMessage()..textureId = textureId);
    return Duration(milliseconds: response.duration);
  }

  @override
  Future<void> setVolume(int textureId, int volume) async {
    return await _api.setVolume(VolumeMessage()
      ..textureId = textureId
      ..volume = volume);
  }

  @override
  Future<int> getVolume(int textureId) async {
    VolumeMessage response =
        await _api.getVolume(TextureMessage()..textureId = textureId);
    return response.volume;
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    assert(speed > 0);
    return await _api.setPlaybackSpeed(PlaybackSpeedMessage()
      ..textureId = textureId
      ..speed = speed);
  }

  @override
  Future<double> getPlaybackSpeed(int textureId) async {
    PlaybackSpeedMessage response =
        await _api.getPlaybackSpeed(TextureMessage()..textureId = textureId);
    return response.speed;
  }

  @override
  Future<int> getSpuTracksCount(int textureId) async {
    TrackCountMessage response =
        await _api.getSpuTracksCount(TextureMessage()..textureId = textureId);
    return response.count;
  }

  @override
  Future<Map<int, String>> getSpuTracks(int textureId) async {
    SpuTracksMessage response =
        await _api.getSpuTracks(TextureMessage()..textureId = textureId);
    return response.subtitles.cast<int, String>();
  }

  @override
  Future<int> getSpuTrack(int textureId) async {
    SpuTrackMessage response =
        await _api.getSpuTrack(TextureMessage()..textureId = textureId);
    return response.spuTrackNumber;
  }

  @override
  Future<void> setSpuTrack(int textureId, int spuTrackNumber) async {
    return await _api.setSpuTrack(SpuTrackMessage()
      ..textureId = textureId
      ..spuTrackNumber = spuTrackNumber);
  }

  @override
  Future<void> setSpuDelay(int textureId, int delay) async {
    return await _api.setSpuDelay(DelayMessage()
      ..textureId = textureId
      ..delay = delay);
  }

  @override
  Future<int> getSpuDelay(int textureId) async {
    DelayMessage response =
        await _api.getSpuDelay(TextureMessage()..textureId = textureId);
    return response.delay;
  }

  @override
  Future<void> addSubtitleTrack(
    int textureId,
    String subtitleUri, {
    bool isLocalSubtitle,
    bool isSubtitleSelected,
  }) async {
    AddSubtitleMessage message = AddSubtitleMessage();
    message.textureId = textureId;
    message.uri = subtitleUri;
    message.isLocal = isLocalSubtitle;
    message.isSelected = isSubtitleSelected;
    return await _api.addSubtitleTrack(message);
  }

  @override
  Future<int> getAudioTracksCount(int textureId) async {
    TrackCountMessage response =
        await _api.getAudioTracksCount(TextureMessage()..textureId = textureId);
    return response.count;
  }

  @override
  Future<Map<int, String>> getAudioTracks(int textureId) async {
    AudioTracksMessage response =
        await _api.getAudioTracks(TextureMessage()..textureId = textureId);
    return response.audios.cast<int, String>();
  }

  @override
  Future<int> getAudioTrack(int textureId) async {
    AudioTrackMessage response =
        await _api.getAudioTrack(TextureMessage()..textureId = textureId);
    return response.audioTrackNumber;
  }

  @override
  Future<void> setAudioTrack(int textureId, int audioTrackNumber) async {
    return await _api.setAudioTrack(AudioTrackMessage()
      ..textureId = textureId
      ..audioTrackNumber = audioTrackNumber);
  }

  @override
  Future<void> setAudioDelay(int textureId, int delay) async {
    return await _api.setAudioDelay(DelayMessage()
      ..textureId = textureId
      ..delay = delay);
  }

  @override
  Future<int> getAudioDelay(int textureId) async {
    DelayMessage response =
        await _api.getAudioDelay(TextureMessage()..textureId = textureId);
    return response.delay;
  }

  @override
  Future<int> getVideoTracksCount(int textureId) async {
    TrackCountMessage response =
        await _api.getVideoTracksCount(TextureMessage()..textureId = textureId);
    return response.count;
  }

  @override
  Future<Map<int, String>> getVideoTracks(int textureId) async {
    VideoTracksMessage response =
        await _api.getVideoTracks(TextureMessage()..textureId = textureId);
    return response.videos.cast<int, String>();
  }

  @override
  Future<dynamic> getCurrentVideoTrack(int textureId) async {
    return await _api.getVideoTrack(TextureMessage()..textureId = textureId);
    // todo: change dynamic to appropriate value
  }

  @override
  Future<int> getVideoTrack(int textureId) async {
    VideoTrackMessage response =
        await _api.getVideoTrack(TextureMessage()..textureId = textureId);
    return response.videoTrackNumber;
  }

  @override
  Future<void> setVideoScale(int textureId, double scale) async {
    return await _api.setVideoScale(VideoScaleMessage()
      ..textureId = textureId
      ..scale = scale);
  }

  @override
  Future<double> getVideoScale(int textureId) async {
    VideoScaleMessage response =
        await _api.getVideoScale(TextureMessage()..textureId = textureId);
    return response.scale;
  }

  @override
  Future<void> setVideoAspectRatio(int textureId, String aspect) async {
    return await _api.setVideoAspectRatio(VideoAspectRatioMessage()
      ..textureId = textureId
      ..aspectRatio = aspect);
  }

  @override
  Future<String> getVideoAspectRatio(int textureId) async {
    VideoAspectRatioMessage response =
        await _api.getVideoAspectRatio(TextureMessage()..textureId = textureId);
    return response.aspectRatio;
  }

  @override
  Future<Uint8List> takeSnapshot(int textureId) async {
    SnapshotMessage response =
        await _api.takeSnapshot(TextureMessage()..textureId = textureId);
    var base64String = response.snapshot;
    Uint8List imageBytes = CryptoUtils.base64StringToBytes(base64String);
    return imageBytes;
  }

  @override
  Future<void> startCastDiscovery(int textureId, {String serviceName}) async {
    return await _api.startCastDiscovery(CastDiscoveryMessage()
      ..textureId = textureId
      ..serviceName = serviceName ?? '');
  }

  @override
  Future<void> stopCastDiscovery(int textureId) async {
    return await _api
        .stopCastDiscovery(TextureMessage()..textureId = textureId);
  }

  @override
  Future<Map<String, String>> getCastDevices(int textureId) async {
    CastDevicesMessage response =
        await _api.getCastDevices(TextureMessage()..textureId = textureId);
    return response.castDevices.cast<String, String>();
  }

  @override
  Future<void> startCasting(int textureId, String castDevice) async {
    return await _api.startCasting(CastDeviceMessage()
      ..textureId = textureId
      ..castDevice = castDevice);
  }

  @override
  Stream<VlcCastEvent> castEventsFor(int textureId) {
    // TODO: implement castEventsFor
    throw ('castEventsFor channel not implemented');
  }
}
