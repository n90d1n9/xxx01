import 'report_type.dart';

enum ReportPeriod {
  last30Days('Last 30 days'),
  lastQuarter('Last Quarter'),
  lastYear('Last Year'),
  yearToDate('Year to Date');

  final String label;

  const ReportPeriod(this.label);
}

enum ReportDepartmentScope {
  all('All Departments'),
  sales('Sales'),
  marketing('Marketing'),
  engineering('Engineering'),
  hr('HR'),
  finance('Finance');

  final String label;

  const ReportDepartmentScope(this.label);
}

enum ReportFileFormat {
  pdf('PDF', 'pdf'),
  excel('Excel', 'xlsx'),
  csv('CSV', 'csv');

  final String label;
  final String extension;

  const ReportFileFormat(this.label, this.extension);
}

class ReportGenerationRequest {
  final ReportPeriod period;
  final ReportDepartmentScope department;
  final ReportFileFormat format;
  final bool includeExecutiveSummary;
  final bool includeTrendCharts;
  final bool includeRawData;

  const ReportGenerationRequest({
    this.period = ReportPeriod.last30Days,
    this.department = ReportDepartmentScope.all,
    this.format = ReportFileFormat.pdf,
    this.includeExecutiveSummary = true,
    this.includeTrendCharts = true,
    this.includeRawData = false,
  });

  String get scopeLabel => department.label;

  bool get hasSelectedContent {
    return includeExecutiveSummary || includeTrendCharts || includeRawData;
  }

  String? get validationMessage {
    return hasSelectedContent ? null : 'Select at least one report section';
  }

  List<String> get contentLabels {
    return [
      if (includeExecutiveSummary) 'Executive summary',
      if (includeTrendCharts) 'Trend charts',
      if (includeRawData) 'Raw data export',
    ];
  }

  String get contentSummary {
    if (contentLabels.isEmpty) return 'No package sections selected';

    return contentLabels.join(' + ');
  }

  ReportGenerationRequest copyWith({
    ReportPeriod? period,
    ReportDepartmentScope? department,
    ReportFileFormat? format,
    bool? includeExecutiveSummary,
    bool? includeTrendCharts,
    bool? includeRawData,
  }) {
    return ReportGenerationRequest(
      period: period ?? this.period,
      department: department ?? this.department,
      format: format ?? this.format,
      includeExecutiveSummary:
          includeExecutiveSummary ?? this.includeExecutiveSummary,
      includeTrendCharts: includeTrendCharts ?? this.includeTrendCharts,
      includeRawData: includeRawData ?? this.includeRawData,
    );
  }

  String exportFileNameFor(ReportType report) {
    final reportSlug = _slug(report.name);
    final departmentSlug = _slug(department.label);
    final periodSlug = _slug(period.label);

    return '$reportSlug-$departmentSlug-$periodSlug.${format.extension}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReportGenerationRequest &&
            other.period == period &&
            other.department == department &&
            other.format == format &&
            other.includeExecutiveSummary == includeExecutiveSummary &&
            other.includeTrendCharts == includeTrendCharts &&
            other.includeRawData == includeRawData;
  }

  @override
  int get hashCode {
    return Object.hash(
      period,
      department,
      format,
      includeExecutiveSummary,
      includeTrendCharts,
      includeRawData,
    );
  }
}

String _slug(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
