import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../hris/approval/states/supervisor_provider.dart';
import '../../cashdrawer/models/cashdrawer.dart';
import '../../printer/services/printer_setting.dart';

final hardwareSettingsProvider =
    StateNotifierProvider<HardwareSettingsNotifier, HardwareSettings>((ref) {
      return HardwareSettingsNotifier(ref);
    });

class HardwareSettingsNotifier extends StateNotifier<HardwareSettings> {
  final Ref ref;

  HardwareSettingsNotifier(this.ref) : super(HardwareSettings.initial());

  Future<void> updatePrinterSettings(PrinterSettings settings) async {
    final approved = await ref
        .read(supervisorProvider.notifier)
        .requestApproval(
          actionType: 'UPDATE_PRINTER_SETTINGS',
          reason: 'Updating printer configuration',
          metadata: settings.toJson(),
        );

    if (approved) {
      state = state.copyWith(printerSettings: settings);
      await _saveSettings();
    }
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

  Future<void> updateScannerSettings(ScannerSettings settings) async {
    final approved = await ref
        .read(supervisorProvider.notifier)
        .requestApproval(
          actionType: 'UPDATE_SCANNER_SETTINGS',
          reason: 'Updating scanner configuration',
          metadata: settings.toJson(),
        );

    if (approved) {
      state = state.copyWith(scannerSettings: settings);
      await _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    // Implementation for saving settings to local storage or server
  }
}
