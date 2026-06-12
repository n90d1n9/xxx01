import 'report_generation_job.dart';

class ReportExportQueueSummary {
  final int total;
  final int readyCount;
  final int activeCount;
  final int failedCount;

  const ReportExportQueueSummary({
    required this.total,
    required this.readyCount,
    required this.activeCount,
    required this.failedCount,
  });

  factory ReportExportQueueSummary.fromJobs(
    Iterable<ReportGenerationJob> jobs,
  ) {
    var total = 0;
    var readyCount = 0;
    var activeCount = 0;
    var failedCount = 0;

    for (final job in jobs) {
      total++;
      switch (job.status) {
        case ReportGenerationStatus.ready:
          readyCount++;
        case ReportGenerationStatus.failed:
          failedCount++;
        case ReportGenerationStatus.queued:
        case ReportGenerationStatus.generating:
          activeCount++;
      }
    }

    return ReportExportQueueSummary(
      total: total,
      readyCount: readyCount,
      activeCount: activeCount,
      failedCount: failedCount,
    );
  }

  bool get hasActiveExports => activeCount > 0;

  int get downloadableCount => readyCount;

  bool get hasDownloadableExports => downloadableCount > 0;

  String get downloadReadyLabel =>
      _countedLabel('Download ready', downloadableCount);

  bool get hasFailedExports => failedCount > 0;

  String get retryFailedLabel => _countedLabel('Retry failed', failedCount);

  int get finishedCount => readyCount + failedCount;

  bool get hasFinishedExports => finishedCount > 0;

  String get clearFinishedLabel =>
      _countedLabel('Clear finished', finishedCount);

  int get statusGroupCount {
    return [
      readyCount,
      activeCount,
      failedCount,
    ].where((count) => count > 0).length;
  }

  bool get hasMultipleStatusGroups => statusGroupCount > 1;

  String get trackedLabel => '$total tracked';
}

String _countedLabel(String label, int count) => '$label ($count)';
