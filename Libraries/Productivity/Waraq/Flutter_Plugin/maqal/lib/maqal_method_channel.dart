import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'maqal_platform_interface.dart';

/// An implementation of [MaqalPlatform] that uses method channels.
class MethodChannelMaqal extends MaqalPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('maqal');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
