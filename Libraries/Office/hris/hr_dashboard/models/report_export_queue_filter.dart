import 'report_generation_job.dart';
import 'report_export_queue_summary.dart';

enum ReportExportQueueFilter {
  all('All exports', 'All'),
  ready('Ready exports', 'Ready'),
  active('In progress', 'In progress'),
  failed('Needs retry', 'Needs retry');

  final String label;
  final String shortLabel;

  const ReportExportQueueFilter(this.label, this.shortLabel);

  bool accepts(ReportGenerationJob job) {
    return switch (this) {
      ReportExportQueueFilter.all => true,
      ReportExportQueueFilter.ready =>
        job.status == ReportGenerationStatus.ready,
      ReportExportQueueFilter.active => job.status.isActive,
      ReportExportQueueFilter.failed =>
        job.status == ReportGenerationStatus.failed,
    };
  }

  List<ReportGenerationJob> apply(Iterable<ReportGenerationJob> jobs) {
    return jobs.where(accepts).toList(growable: false);
  }

  int countIn(ReportExportQueueSummary summary) {
    return switch (this) {
      ReportExportQueueFilter.all => summary.total,
      ReportExportQueueFilter.ready => summary.readyCount,
      ReportExportQueueFilter.active => summary.activeCount,
      ReportExportQueueFilter.failed => summary.failedCount,
    };
  }

  bool isAvailableIn(ReportExportQueueSummary summary) {
    return this == ReportExportQueueFilter.all || countIn(summary) > 0;
  }

  static ReportExportQueueFilter normalize({
    required ReportExportQueueFilter selected,
    required ReportExportQueueSummary summary,
  }) {
    if (!summary.hasMultipleStatusGroups) return ReportExportQueueFilter.all;
    if (selected.isAvailableIn(summary)) return selected;

    return ReportExportQueueFilter.all;
  }

  String emptyMessage() {
    return switch (this) {
      ReportExportQueueFilter.all => 'No exports tracked yet',
      ReportExportQueueFilter.ready => 'No ready exports yet',
      ReportExportQueueFilter.active => 'No reports in progress',
      ReportExportQueueFilter.failed => 'No exports need retry',
    };
  }
}
