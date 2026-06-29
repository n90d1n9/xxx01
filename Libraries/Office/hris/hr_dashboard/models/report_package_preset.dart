import 'report_generation_request.dart';

enum ReportPackagePreset {
  brief(
    'Brief',
    includeExecutiveSummary: true,
    includeTrendCharts: false,
    includeRawData: false,
  ),
  analysis(
    'Analysis',
    includeExecutiveSummary: true,
    includeTrendCharts: true,
    includeRawData: false,
  ),
  audit(
    'Audit',
    includeExecutiveSummary: true,
    includeTrendCharts: true,
    includeRawData: true,
  ),
  data(
    'Data',
    includeExecutiveSummary: false,
    includeTrendCharts: false,
    includeRawData: true,
  );

  final String label;
  final bool includeExecutiveSummary;
  final bool includeTrendCharts;
  final bool includeRawData;

  const ReportPackagePreset(
    this.label, {
    required this.includeExecutiveSummary,
    required this.includeTrendCharts,
    required this.includeRawData,
  });

  ReportGenerationRequest applyTo(ReportGenerationRequest request) {
    return request.copyWith(
      includeExecutiveSummary: includeExecutiveSummary,
      includeTrendCharts: includeTrendCharts,
      includeRawData: includeRawData,
    );
  }

  bool matches(ReportGenerationRequest request) {
    return request.includeExecutiveSummary == includeExecutiveSummary &&
        request.includeTrendCharts == includeTrendCharts &&
        request.includeRawData == includeRawData;
  }

  static ReportPackagePreset? fromRequest(ReportGenerationRequest request) {
    for (final preset in ReportPackagePreset.values) {
      if (preset.matches(request)) return preset;
    }

    return null;
  }
}
