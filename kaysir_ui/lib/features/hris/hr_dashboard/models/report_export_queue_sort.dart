import 'report_generation_job.dart';

enum ReportExportQueueSort {
  newest('Newest first'),
  oldest('Oldest first'),
  attention('Needs attention');

  final String label;

  const ReportExportQueueSort(this.label);

  List<ReportGenerationJob> apply(Iterable<ReportGenerationJob> jobs) {
    final sorted = jobs.toList();
    sorted.sort(compare);
    return sorted;
  }

  int compare(ReportGenerationJob a, ReportGenerationJob b) {
    return switch (this) {
      ReportExportQueueSort.newest => _compareNewest(a, b),
      ReportExportQueueSort.oldest => _compareOldest(a, b),
      ReportExportQueueSort.attention => _compareAttention(a, b),
    };
  }
}

int _compareNewest(ReportGenerationJob a, ReportGenerationJob b) {
  final compared = b.requestedAt.compareTo(a.requestedAt);
  if (compared != 0) return compared;

  return a.id.compareTo(b.id);
}

int _compareOldest(ReportGenerationJob a, ReportGenerationJob b) {
  final compared = a.requestedAt.compareTo(b.requestedAt);
  if (compared != 0) return compared;

  return a.id.compareTo(b.id);
}

int _compareAttention(ReportGenerationJob a, ReportGenerationJob b) {
  final priority = _statusPriority(a).compareTo(_statusPriority(b));
  if (priority != 0) return priority;

  return _compareNewest(a, b);
}

int _statusPriority(ReportGenerationJob job) {
  return switch (job.status) {
    ReportGenerationStatus.failed => 0,
    ReportGenerationStatus.queued || ReportGenerationStatus.generating => 1,
    ReportGenerationStatus.ready => 2,
  };
}
