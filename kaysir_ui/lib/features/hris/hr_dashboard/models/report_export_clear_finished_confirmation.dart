import 'report_export_queue_summary.dart';

class ReportExportClearFinishedConfirmation {
  final int readyCount;
  final int failedCount;

  const ReportExportClearFinishedConfirmation({
    required this.readyCount,
    required this.failedCount,
  });

  factory ReportExportClearFinishedConfirmation.fromSummary(
    ReportExportQueueSummary summary,
  ) {
    return ReportExportClearFinishedConfirmation(
      readyCount: summary.readyCount,
      failedCount: summary.failedCount,
    );
  }

  int get finishedCount => readyCount + failedCount;

  String get title => 'Clear finished exports?';

  String get primaryMessage {
    return 'This removes ${_counted('finished export', finishedCount)} from '
        'the recent queue.';
  }

  String get statusBreakdown {
    final parts = [
      if (readyCount > 0) _counted('ready export', readyCount),
      if (failedCount > 0) _counted('failed export', failedCount),
    ];

    return 'Includes ${parts.join(' and ')}. Active exports stay visible.';
  }

  String get confirmLabel => 'Clear ${_counted('export', finishedCount)}';
}

String _counted(String noun, int count) {
  if (count == 1) return '1 $noun';
  return '$count ${noun}s';
}
