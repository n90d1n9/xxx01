// services/report_generation_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/report_configuration.dart';
import '../model/report_data.dart';
import 'data_processing_provider.dart';
import 'database_provider.dart';

class ReportGenerationService {
  final Ref ref;

  ReportGenerationService(this.ref);

  Future<ReportData?> generateReport(ReportConfiguration config) async {
    try {
      final startTime = DateTime.now();
      final db = ref.read(databaseProvider);
      final dataProcessingService = ref.read(dataProcessingServiceProvider);

      final rows = await db.queryData(config);
      final summary = dataProcessingService.calculateSummary(rows, config);
      final groupedData = dataProcessingService.groupData(rows, config);
      final executionTime = DateTime.now().difference(startTime);

      return ReportData(
        rows: rows,
        summary: summary,
        groupedData: groupedData,
        totalCount: rows.length,
        generatedAt: DateTime.now(),
        executionTime: executionTime,
      );
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }
}

final reportGenerationServiceProvider = Provider<ReportGenerationService>((
  ref,
) {
  return ReportGenerationService(ref);
});
