import 'report_export_queue_filter.dart';
import 'report_export_queue_summary.dart';

enum ReportExportQueueHealthTone { attention, ready, active, clear }

class ReportExportQueueHealthInsight {
  final ReportExportQueueHealthTone tone;
  final String label;
  final String headline;
  final String detail;
  final ReportExportQueueFilter? suggestedFilter;
  final String? actionLabel;

  const ReportExportQueueHealthInsight({
    required this.tone,
    required this.label,
    required this.headline,
    required this.detail,
    this.suggestedFilter,
    this.actionLabel,
  });

  factory ReportExportQueueHealthInsight.fromSummary(
    ReportExportQueueSummary summary,
  ) {
    if (summary.failedCount > 0) {
      return ReportExportQueueHealthInsight(
        tone: ReportExportQueueHealthTone.attention,
        label: 'Attention',
        headline:
            '${_countedExport(summary.failedCount, 'failed')} ${_verb(summary.failedCount, singular: 'needs', plural: 'need')} retry',
        detail:
            'Review failed files before downloading or clearing the rest of the queue.',
        suggestedFilter: ReportExportQueueFilter.failed,
        actionLabel: 'Review failed',
      );
    }

    if (summary.readyCount > 0) {
      return ReportExportQueueHealthInsight(
        tone: ReportExportQueueHealthTone.ready,
        label: 'Downloadable',
        headline:
            '${_countedExport(summary.readyCount, 'completed')} ${_verb(summary.readyCount, singular: 'is', plural: 'are')} ready to download',
        detail:
            'Download completed files while they are still inside the retention window.',
        suggestedFilter: ReportExportQueueFilter.ready,
        actionLabel: 'View ready',
      );
    }

    if (summary.activeCount > 0) {
      return ReportExportQueueHealthInsight(
        tone: ReportExportQueueHealthTone.active,
        label: 'Processing',
        headline:
            '${_countedExport(summary.activeCount, 'active')} ${_verb(summary.activeCount, singular: 'is', plural: 'are')} still generating',
        detail:
            'Keep the queue visible; completed files will move into the ready state automatically.',
        suggestedFilter: ReportExportQueueFilter.active,
        actionLabel: 'View progress',
      );
    }

    return const ReportExportQueueHealthInsight(
      tone: ReportExportQueueHealthTone.clear,
      label: 'Clear',
      headline: 'Export queue is empty',
      detail:
          'New report packages will appear here after they are submitted for generation.',
    );
  }
}

String _countedExport(int count, String descriptor) {
  return '$count $descriptor ${count == 1 ? 'export' : 'exports'}';
}

String _verb(int count, {required String singular, required String plural}) {
  return count == 1 ? singular : plural;
}
