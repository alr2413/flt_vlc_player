import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vlc_platform_interface/enums/vlc_player_state.dart';
import 'package:vlc_platform_interface/method_channel/method_channel_vlc_player.dart';

/// The interface that implementations of vlc must implement.
///
/// Platform implementations should extend this class rather than implement it as `vlc`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [VlcPlatform] methods.
abstract class VlcPlayerPlatform extends PlatformInterface {
  /// Constructs a VlcPlatform.
  VlcPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static VlcPlayerPlatform _instance = MethodChannelVlcPlayer();

  /// The default instance of [VlcPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelVlcPlayer].
  static VlcPlayerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [VlcPlayerPlatform] when they register themselves.
  static set instance(VlcPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the battery level from device.
  Future<void> play() {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// gets vlc player state
  Stream<VlcPlayerState> onVlcPlayerStateChanged() {
    throw UnimplementedError(
        'onVlcPlayerStateChanged() has not been implemented.');
  }
}
