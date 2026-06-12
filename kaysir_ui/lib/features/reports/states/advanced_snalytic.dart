import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final advancedReportsProvider =
    StateNotifierProvider<AdvancedReportsNotifier, ReportState>((ref) {
      final reportService = ref.watch(reportServiceProvider);
      final analyticsService = ref.watch(analyticsServiceProvider);
      return AdvancedReportsNotifier(reportService, analyticsService);
    });

class AdvancedReportsNotifier extends StateNotifier<ReportState> {
  final ReportService _reportService;
  final AnalyticsService _analyticsService;

  AdvancedReportsNotifier(this._reportService, this._analyticsService)
    : super(ReportState.initial());

  Future<void> generateReport({
    required DateTime startDate,
    required DateTime endDate,
    required List<String> metrics,
    String? storeId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _reportService.generateReport(
        startDate: startDate,
        endDate: endDate,
        metrics: metrics,
        storeId: storeId,
      );

      await _analyticsService.trackReportGeneration(metrics);

      state = state.copyWith(
        reports: [...state.reports, report],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> exportReport(String reportId, ExportFormat format) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = state.reports.firstWhere((r) => r.id == reportId);
      final exportPath = await _reportService.exportReport(report, format);

      state = state.copyWith(
        isLoading: false,
        metadata: state.metadata.copyWith(lastExportPath: exportPath),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
