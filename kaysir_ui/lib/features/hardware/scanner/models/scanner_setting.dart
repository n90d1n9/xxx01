class ScannerSettings{
  ScannerSettings({
    required String deviceName,
    required String connectionType,
    required String port,
    required bool continuousScan,
    required int scanTimeout,
    required List<String> supportedFormats,
    required Map<String, dynamic> customSettings,
  });
}
