import 'package:pigeon/pigeon_lib.dart';

class TextureMessage {
  int textureId;
}

class CreateMessage {
  String uri;
  bool isLocalMedia;
  bool autoPlay;
  int hwAcc;
  List<String> options;
}

class SetMediaMessage {
  int textureId;
  String uri;
  bool isLocalMedia;
}

class BooleanMessage {
  int textureId;
  bool result;
}

class LoopingMessage {
  int textureId;
  bool isLooping;
}

class VolumeMessage {
  int textureId;
  int volume;
}

class PlaybackSpeedMessage {
  int textureId;
  double speed;
}

class PositionMessage {
  int textureId;
  int position;
}

class DurationMessage {
  int textureId;
  int duration;
}

class DelayMessage {
  int textureId;
  int delay;
}

class TrackCountMessage {
  int textureId;
  int count;
}

class SnapshotMessage {
  int textureId;
  String snapshot;
}

class SpuTracksMessage {
  int textureId;
  Map subtitles;
}

class SpuTrackMessage {
  int textureId;
  int spuTrackNumber;
}

class AddSubtitleMessage {
  int textureId;
  String uri;
  bool isLocal;
  bool isSelected;
}

class AudioTracksMessage {
  int textureId;
  Map audios;
}

class AudioTrackMessage {
  int textureId;
  int audioTrackNumber;
}

class VideoTracksMessage {
  int textureId;
  Map videos;
}

class VideoTrackMessage {
  int textureId;
  int videoTrackNumber;
}

class VideoScaleMessage {
  int textureId;
  double scale;
}

class VideoAspectRatioMessage {
  int textureId;
  String aspectRatio;
}

class CastDiscoveryMessage {
  int textureId;
  String serviceName;
}

class CastDevicesMessage {
  int textureId;
  Map castDevices;
}

class CastDeviceMessage {
  int textureId;
  String castDevice;
}

@HostApi(dartHostTestHandler: 'TestHostVlcPlayerApi')
abstract class VlcPlayerApi {
  void initialize();
  TextureMessage create(CreateMessage msg);
  void dispose(TextureMessage msg);
  // general
  void setStreamUrl(SetMediaMessage msg);
  void setLooping(LoopingMessage msg);
  void play(TextureMessage msg);
  void pause(TextureMessage msg);
  void stop(TextureMessage msg);
  BooleanMessage isPlaying(TextureMessage msg);
  void setTime(PositionMessage msg);
  void seekTo(PositionMessage msg);
  PositionMessage position(TextureMessage msg);
  DurationMessage duration(TextureMessage msg);
  void setVolume(VolumeMessage msg);
  VolumeMessage getVolume(TextureMessage msg);
  void setPlaybackSpeed(PlaybackSpeedMessage msg);
  PlaybackSpeedMessage getPlaybackSpeed(TextureMessage msg);
  SnapshotMessage takeSnapshot(TextureMessage msg);
  // captions & subtitles
  TrackCountMessage getSpuTracksCount(TextureMessage msg);
  SpuTracksMessage getSpuTracks(TextureMessage msg);
  SpuTrackMessage getSpuTrack(TextureMessage msg);
  void setSpuTrack(SpuTrackMessage msg);
  void setSpuDelay(DelayMessage msg);
  DelayMessage getSpuDelay(TextureMessage msg);
  void addSubtitleTrack(AddSubtitleMessage msg);
  // audios
  TrackCountMessage getAudioTracksCount(TextureMessage msg);
  AudioTracksMessage getAudioTracks(TextureMessage msg);
  AudioTrackMessage getAudioTrack(TextureMessage msg);
  void setAudioTrack(AudioTrackMessage msg);
  void setAudioDelay(DelayMessage msg);
  DelayMessage getAudioDelay(TextureMessage msg);
  // videos
  TrackCountMessage getVideoTracksCount(TextureMessage msg);
  VideoTracksMessage getVideoTracks(TextureMessage msg);
  VideoTrackMessage getCurrentVideoTrack(TextureMessage msg); // todo
  VideoTrackMessage getVideoTrack(TextureMessage msg); // todo
  void setVideoScale(VideoScaleMessage msg);
  VideoScaleMessage getVideoScale(TextureMessage msg);
  void setVideoAspectRatio(VideoAspectRatioMessage msg);
  VideoAspectRatioMessage getVideoAspectRatio(TextureMessage msg);
  // casts
  void startCastDiscovery(CastDiscoveryMessage msg);
  void stopCastDiscovery(TextureMessage msg);
  CastDevicesMessage getCastDevices(TextureMessage msg);
  void startCasting(CastDeviceMessage msg);
}

void configurePigeon(PigeonOptions opts) {
  opts.dartOut = '../flutter_vlc_player_platform_interface/lib/messages.dart';
  opts.objcHeaderOut = 'ios/Classes/messages.h';
  opts.objcSourceOut = 'ios/Classes/messages.m';
  opts.objcOptions.prefix = '';
  opts.javaOut =
      'android/src/main/java/software/solid/fluttervlcplayer/Messages.java';
  opts.javaOptions.package = 'software.solid.fluttervlcplayer';
}
