import 'package:flutter_test/flutter_test.dart';
import 'package:maqal/maqal.dart';
import 'package:maqal/maqal_platform_interface.dart';
import 'package:maqal/maqal_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMaqalPlatform
    with MockPlatformInterfaceMixin
    implements MaqalPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MaqalPlatform initialPlatform = MaqalPlatform.instance;

  test('$MethodChannelMaqal is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMaqal>());
  });

  test('getPlatformVersion', () async {
    Maqal maqalPlugin = Maqal();
    MockMaqalPlatform fakePlatform = MockMaqalPlatform();
    MaqalPlatform.instance = fakePlatform;

    expect(await maqalPlugin.getPlatformVersion(), '42');
  });
}
