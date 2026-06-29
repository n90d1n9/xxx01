import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/data_type.dart';
import '../model/report_configuration.dart';
import '../model/report_data.dart';
import '../service/export_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());
final exportServiceWrapperProvider = Provider<ExportServiceWrapper>((ref) {
  return ExportServiceWrapper(ref);
});

class ExportServiceWrapper {
  final Ref ref;

  ExportServiceWrapper(this.ref);

  Future<bool> exportReport(
    ReportConfiguration config,
    ReportData data,
    ExportFormat format,
  ) async {
    final exportService = ref.read(exportServiceProvider);

    switch (format) {
      case ExportFormat.pdf:
        return await exportService.exportToPDF(config, data);
      case ExportFormat.excel:
        return await exportService.exportToExcel(config, data);
      case ExportFormat.csv:
        return await exportService.exportToCSV(config, data);
      case ExportFormat.json:
        return await exportService.exportToJSON(config, data);
      default:
        return false;
    }
  }
}
