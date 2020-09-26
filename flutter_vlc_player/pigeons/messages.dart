import 'package:pigeon/pigeon_lib.dart';

class TextureMessage {
  int textureId;
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

class CreateMessage {
  String asset;
  String uri;
  String packageName;
  String formatHint;
}

class MixWithOthersMessage {
  bool mixWithOthers;
}

@HostApi(dartHostTestHandler: 'TestHostVlcPlayerApi')
abstract class VlcPlayerApi {
  void initialize();
  TextureMessage create(CreateMessage msg);
  void dispose(TextureMessage msg);
  void setLooping(LoopingMessage msg);
  void setVolume(VolumeMessage msg);
  void setPlaybackSpeed(PlaybackSpeedMessage msg);
  void play(TextureMessage msg);
  PositionMessage position(TextureMessage msg);
  void seekTo(PositionMessage msg);
  void pause(TextureMessage msg);
  // void setMixWithOthers(MixWithOthersMessage msg);
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
