class ExportUtils {
  static Future<void> exportToCsv({
    required List<List<dynamic>> rows,
    required String fileName,
  }) async {
    // This would be implemented with a CSV export package
    // Implementation depends on platform (web, mobile, desktop)
    // For example, using csv and path_provider packages
  }

  static Future<void> generatePdfReport({
    required List<List<dynamic>> data,
    required String title,
    required String fileName,
  }) async {
    // This would be implemented with a PDF generation package
    // Implementation depends on platform (web, mobile, desktop)
    // For example, using pdf package
  }
}
