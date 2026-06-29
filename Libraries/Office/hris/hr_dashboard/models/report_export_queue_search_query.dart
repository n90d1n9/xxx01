import 'report_export_compliance_summary.dart';
import 'report_generation_job.dart';

class ReportExportQueueSearchQuery {
  final String value;

  const ReportExportQueueSearchQuery(this.value);

  String get displayValue => value.trim();

  String get normalized => displayValue.toLowerCase();

  bool get isActive => normalized.isNotEmpty;

  List<ReportGenerationJob> apply(Iterable<ReportGenerationJob> jobs) {
    if (!isActive) return jobs.toList(growable: false);

    final tokens = normalized.split(RegExp(r'\s+'));
    return [
      for (final job in jobs)
        if (_matchesAll(job, tokens)) job,
    ];
  }

  String emptyMessage() {
    if (displayValue.isEmpty) return 'No exports tracked yet';

    return 'No exports match "$displayValue"';
  }
}

bool _matchesAll(ReportGenerationJob job, List<String> tokens) {
  final searchable = _searchableText(job);
  return tokens.every(searchable.contains);
}

String _searchableText(ReportGenerationJob job) {
  final complianceSummary = ReportExportComplianceSummary.fromRequest(
    report: job.report,
    request: job.request,
  );

  return [
    job.id,
    job.fileName,
    job.report.name,
    job.report.description,
    job.status.label,
    job.request.period.label,
    job.request.department.label,
    job.request.format.label,
    job.request.format.extension,
    job.request.contentSummary,
    complianceSummary.label,
  ].join(' ').toLowerCase();
}
