import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final printerSettingsProvider =
    StateNotifierProvider<PrinterSettingsNotifier, PrinterSettings>((ref) {
      return PrinterSettingsNotifier();
    });

class PrinterSettings {
  final Map<String, String> keyboardShortcuts;
  final String printerType;
  final String printerAddress;
  final String receiptTemplate;
  // final ThemeData theme;

  PrinterSettings({
    required this.keyboardShortcuts,
    required this.printerType,
    required this.printerAddress,
    required this.receiptTemplate,
    //required this.theme,
  });
}

class PrinterSettingsNotifier {
  final Ref ref;

  PrinterSettingsNotifier(this.ref) : super(PrinterSettings.initial());

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
}

final hardwareSettingsProvider =
    StateNotifierProvider<HardwareSettingsNotifier, HardwareSettings>((ref) {
      return HardwareSettingsNotifier(ref);
    });

class HardwareSettingsNotifier extends StateNotifier<HardwareSettings> {
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
