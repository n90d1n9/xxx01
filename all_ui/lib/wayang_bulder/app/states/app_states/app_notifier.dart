import 'package:flutter_riverpod/legacy.dart';
import 'package:logging/logging.dart';
import '../../models/device_info.dart';
import 'app_state.dart';

final log = Logger('appProvider');

final appsProvider = StateNotifierProvider<AppNotifier, AppState>(
  (ref) => AppNotifier(),
);

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier()
      : super(AppState(
            hasFinishedGuide: false,
            hasOnboarding: false,
            deviceInfo: DeviceInfo(
              platform: PlatformInfo.android,
              brand: 'Android',
              systemVersion: '',
            )));

  Future<void> initDeviceInfo(DeviceInfo deviceInfo) async {
    state = state.copyWith(deviceInfo: deviceInfo);
  }
}
