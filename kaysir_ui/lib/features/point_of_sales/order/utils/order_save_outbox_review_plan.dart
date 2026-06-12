import 'order_save_outbox_summary.dart';
import 'order_save_outbox_sync_behavior.dart';

class POSOrderSaveOutboxReviewPlan {
  final String title;
  final String guidanceMessage;
  final String retryNoticeMessage;

  const POSOrderSaveOutboxReviewPlan({
    required this.title,
    required this.guidanceMessage,
    required this.retryNoticeMessage,
  });

  factory POSOrderSaveOutboxReviewPlan.resolve({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
  }) {
    if (summary.failedCount > 0 && summary.pendingCount > 0) {
      return POSOrderSaveOutboxReviewPlan(
        title: 'Review failed saves first',
        guidanceMessage:
            '${summary.description}. Retry failed saves first, then run ${syncBehavior.syncActionLabel} for queued saves.',
        retryNoticeMessage:
            'Retry shown failed saves first. Queued saves stay ready for ${syncBehavior.syncActionLabel}.',
      );
    }

    if (summary.failedCount > 0) {
      return POSOrderSaveOutboxReviewPlan(
        title: 'Retry failed saves',
        guidanceMessage:
            '${summary.description}. Retry failed saves before closing this register.',
        retryNoticeMessage:
            'Retry only the failed saves currently shown by this filter.',
      );
    }

    return POSOrderSaveOutboxReviewPlan(
      title: 'Queue ready',
      guidanceMessage:
          '${summary.description}. Run ${syncBehavior.syncActionLabel} when this register is ready.',
      retryNoticeMessage: 'No failed saves are currently shown.',
    );
  }
}
