import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'maqal_method_channel.dart';

abstract class MaqalPlatform extends PlatformInterface {
  /// Constructs a MaqalPlatform.
  MaqalPlatform() : super(token: _token);

  static final Object _token = Object();

  static MaqalPlatform _instance = MethodChannelMaqal();

  /// The default instance of [MaqalPlatform] to use.
  ///
  /// Defaults to [MethodChannelMaqal].
  static MaqalPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MaqalPlatform] when
  /// they register themselves.
  static set instance(MaqalPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
