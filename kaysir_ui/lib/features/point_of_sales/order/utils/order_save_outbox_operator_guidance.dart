import 'order_save_outbox_auto_sync_state.dart';
import 'order_save_outbox_review_plan.dart';
import 'order_save_outbox_summary.dart';
import 'order_save_outbox_sync_behavior.dart';
import 'order_save_outbox_sync_state.dart';

enum POSOrderSaveOutboxGuidanceTone { info, success, warning, danger }

class POSOrderSaveOutboxOperatorGuidance {
  final POSOrderSaveOutboxGuidanceTone tone;
  final String title;
  final String message;

  const POSOrderSaveOutboxOperatorGuidance({
    required this.tone,
    required this.title,
    required this.message,
  });

  factory POSOrderSaveOutboxOperatorGuidance.resolve({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxAutoSyncState autoSyncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
  }) {
    if (syncState.isRunning) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.info,
        title: 'Sync in progress',
        message: '${syncState.operatorMessage}. Keep the queue open.',
      );
    }

    if (syncState.phase == POSOrderSaveOutboxSyncPhase.failed) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.danger,
        title: 'Sync failed',
        message: syncState.operatorMessage,
      );
    }

    if (summary.failedCount > 0) {
      final reviewPlan = POSOrderSaveOutboxReviewPlan.resolve(
        summary: summary,
        syncBehavior: syncBehavior,
      );
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.danger,
        title: reviewPlan.title,
        message: reviewPlan.guidanceMessage,
      );
    }

    if (summary.pendingCount > 0) {
      return _queuedGuidance(
        summary: summary,
        autoSyncState: autoSyncState,
        syncBehavior: syncBehavior,
      );
    }

    if (syncState.phase == POSOrderSaveOutboxSyncPhase.completed) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone:
            syncState.hasFailures
                ? POSOrderSaveOutboxGuidanceTone.warning
                : POSOrderSaveOutboxGuidanceTone.success,
        title:
            syncState.hasFailures ? 'Sync needs attention' : 'Sync completed',
        message: syncState.operatorMessage,
      );
    }

    if (autoSyncState.phase == POSOrderSaveOutboxAutoSyncPhase.failed) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.danger,
        title: autoSyncState.title,
        message: 'Latest background run: ${autoSyncState.operatorMessage}',
      );
    }

    if (autoSyncState.phase == POSOrderSaveOutboxAutoSyncPhase.completed) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone:
            autoSyncState.result?.hasFailures == true
                ? POSOrderSaveOutboxGuidanceTone.warning
                : POSOrderSaveOutboxGuidanceTone.success,
        title: autoSyncState.title,
        message: 'Latest background run: ${autoSyncState.operatorMessage}',
      );
    }

    if (summary.sentCount > 0) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.success,
        title: 'Queue synced',
        message:
            '${summary.description}. ${syncBehavior.clearSentActionLabel} when review is complete.',
      );
    }

    return const POSOrderSaveOutboxOperatorGuidance(
      tone: POSOrderSaveOutboxGuidanceTone.info,
      title: 'Queue ready',
      message: 'Completed orders will appear here when they need sync.',
    );
  }

  static POSOrderSaveOutboxOperatorGuidance _queuedGuidance({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxAutoSyncState autoSyncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
  }) {
    if (autoSyncState.isRunning) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.info,
        title: autoSyncState.title,
        message: '${summary.description}. ${autoSyncState.operatorMessage}',
      );
    }

    if (autoSyncState.phase == POSOrderSaveOutboxAutoSyncPhase.failed) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.danger,
        title: autoSyncState.title,
        message: '${summary.description}. ${autoSyncState.operatorMessage}',
      );
    }

    if (autoSyncState.phase == POSOrderSaveOutboxAutoSyncPhase.skipped) {
      return _skippedQueuedGuidance(
        summary: summary,
        autoSyncState: autoSyncState,
        syncBehavior: syncBehavior,
      );
    }

    if (syncBehavior.autoSyncAfterCompletion) {
      return POSOrderSaveOutboxOperatorGuidance(
        tone: POSOrderSaveOutboxGuidanceTone.info,
        title: 'Background sync armed',
        message:
            '${summary.description}. Auto-sync will submit eligible saves for this mode.',
      );
    }

    return POSOrderSaveOutboxOperatorGuidance(
      tone: POSOrderSaveOutboxGuidanceTone.warning,
      title: 'Manual sync required',
      message:
          '${summary.description}. Run ${syncBehavior.syncActionLabel} when this register is ready.',
    );
  }

  static POSOrderSaveOutboxOperatorGuidance _skippedQueuedGuidance({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxAutoSyncState autoSyncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
  }) {
    switch (autoSyncState.skipReason) {
      case POSOrderSaveOutboxAutoSyncSkipReason.disabled:
        return POSOrderSaveOutboxOperatorGuidance(
          tone: POSOrderSaveOutboxGuidanceTone.warning,
          title: 'Manual sync required',
          message:
              '${summary.description}. Run ${syncBehavior.syncActionLabel} when this register is ready.',
        );
      case POSOrderSaveOutboxAutoSyncSkipReason.syncRunning:
        return POSOrderSaveOutboxOperatorGuidance(
          tone: POSOrderSaveOutboxGuidanceTone.info,
          title: 'Sync already running',
          message: '${summary.description}. ${autoSyncState.operatorMessage}',
        );
      case POSOrderSaveOutboxAutoSyncSkipReason.belowThreshold:
        return POSOrderSaveOutboxOperatorGuidance(
          tone: POSOrderSaveOutboxGuidanceTone.info,
          title: 'Waiting for more queued work',
          message: '${summary.description}. ${autoSyncState.operatorMessage}',
        );
      case POSOrderSaveOutboxAutoSyncSkipReason.cooldown:
        return POSOrderSaveOutboxOperatorGuidance(
          tone: POSOrderSaveOutboxGuidanceTone.warning,
          title: 'Auto-sync paused briefly',
          message: '${summary.description}. ${autoSyncState.operatorMessage}',
        );
      case null:
        return POSOrderSaveOutboxOperatorGuidance(
          tone: POSOrderSaveOutboxGuidanceTone.warning,
          title: 'Queued saves waiting',
          message:
              '${summary.description}. Run ${syncBehavior.syncActionLabel} when this register is ready.',
        );
    }
  }
}
