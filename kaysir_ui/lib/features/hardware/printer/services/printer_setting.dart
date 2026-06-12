class PrinterSettings{
  PrinterSettings({
    required String printerName,
    required String connectionType,
    required String address,
    required int port,
    required String paperSize,
    required bool autoCut,
    required int characterWidth,
    required Map<String, dynamic> customSettings,
  });
}
