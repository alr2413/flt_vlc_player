import 'package:flutter/widgets.dart';
import 'package:flutter_vlc_player_platform_interface/vlc_player_platform_interface.dart';

final VlcPlayerPlatform _vlcPlayerPlatform = VlcPlayerPlatform.instance;

class VlcPlayerController {
  final String url;
  VlcPlayerController(this.url);

  int _textureId;

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  @visibleForTesting
  int get textureId => _textureId;

  /// Attempts to open the given [dataSource] and load metadata about the video.
  Future<void> initialize() async {
    _textureId = await _vlcPlayerPlatform.create("");
    return;
  }
}
