import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final cashSettingsProvider =
    StateNotifierProvider<CashSettingsNotifier, CashSettings>((ref) {
      return CashSettingsNotifier(ref);
    });

class CashSettings {
  final Map<String, String> keyboardShortcuts;
  final String printerType;
  final String printerAddress;
  final String receiptTemplate;
  // final ThemeData theme;

  CashSettings({
    required this.keyboardShortcuts,
    required this.printerType,
    required this.printerAddress,
    required this.receiptTemplate,
    //required this.theme,
  });

  static CashSettings initial() {
    return CashSettings(keyboardShortcuts: {}, printerType: '');
  }
}

class CashSettingsNotifier extends StateNotifier<CashSettingsNotifier> {
  final Ref ref;

  CashSettingsNotifier(this.ref) : super(CashSettings.initial());

  Future<void> testDevice(String id) async {
    // Implement device-specific testing logic
  }

  Future<void> updateCashDrawerSettings(CashDrawerSettings settings) async {
    final approved = await ref
        .read(supervisorProvider.notifier)
        .requestApproval(
          actionType: 'UPDATE_CASH_DRAWER_SETTINGS',
          reason: 'Updating cash drawer configuration',
          metadata: settings.toJson(),
        );

    if (approved) {
      state = state.copyWith(cashDrawerSettings: settings);
      await _saveSettings();
    }
  }
}

final hardwareSettingsProvider =
    StateNotifierProvider<HardwareSettingsNotifier, HardwareSettings>((ref) {
      return HardwareSettingsNotifier(ref);
    });

final hardwareConfigProvider =
    StateNotifierProvider<HardwareConfigNotifier, List<HardwareConfig>>((ref) {
      return HardwareConfigNotifier();
    });

final backupProvider = StateNotifierProvider<BackupNotifier, List<BackupData>>((
  ref,
) {
  return BackupNotifier();
});

// Hardware Configuration Notifier
class HardwareConfigNotifier extends StateNotifier<List<HardwareConfig>> {
  HardwareConfigNotifier() : super([]);

  Future<void> addDevice(HardwareConfig config) async {
    state = [...state, config];
  }

  Future<void> updateDevice(String id, Map<String, dynamic> settings) async {
    state = [
      for (final device in state)
        if (device.id == id)
          HardwareConfig(
            id: device.id,
            deviceName: device.deviceName,
            deviceType: device.deviceType,
            settings: settings,
            isEnabled: device.isEnabled,
            lastUpdated: DateTime.now(),
            lastUpdatedBy: 'current_user', // Replace with actual user
          )
        else
          device,
    ];
  }

  Future<void> testDevice(String id) async {
    // Implement device-specific testing logic
  }
}
