import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../enums/vlc_player_state.dart';

import '../vlc_player_platform_interface.dart';

/// An implementation of [VlcPlayerPlatform] that uses method channels.
class MethodChannelVlcPlayer extends VlcPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannelFor(int textureId) {
    return MethodChannel('flutter_video_plugin/getVideoView$textureId');
  }

  /// The event channel used to interact with the native platform.
  @visibleForTesting
  EventChannel eventChannelFor(int textureId) {
    return EventChannel('flutter_video_plugin/getVideoEvents$textureId');
  }

  // Future<void> play() async {
  //   await channel.invokeMethod('setPlaybackState', {
  //     'playbackState': 'play',
  //   });
  // }

  // /// Stream variable for storing vlc player state.
  // Stream<VlcPlayerState> _onVlcPlayerStateChanged;

  // /// Event channel for getting vlc player change state.
  // Stream<VlcPlayerState> onVlcPlayerStateChanged() {
  //   if (_onVlcPlayerStateChanged == null) {
  //     _onVlcPlayerStateChanged = eventChannel
  //         .receiveBroadcastStream()
  //         .map((dynamic event) => _parseVlcPlayerState(event));
  //   }
  //   return _onVlcPlayerStateChanged;
  // }
}

/// Method for parsing vlc player state.
// VlcPlayerState _parseVlcPlayerState(String state) {}
