import 'order_save_outbox_review_plan.dart';
import 'order_save_outbox_summary.dart';
import 'order_save_outbox_sync_behavior.dart';
import 'order_save_outbox_sync_state.dart';

class POSOrderSaveOutboxActionState {
  final String label;
  final String? disabledReason;
  final bool busy;
  final bool visible;
  final int affectedCount;

  const POSOrderSaveOutboxActionState({
    required this.label,
    this.disabledReason,
    this.busy = false,
    this.visible = true,
    this.affectedCount = 0,
  });

  bool get isEnabled => visible && disabledReason == null && !busy;

  String get tooltip => disabledReason ?? label;
}

class POSOrderSaveOutboxActions {
  final POSOrderSaveOutboxActionState syncNow;
  final POSOrderSaveOutboxActionState clearSent;
  final POSOrderSaveOutboxActionState retryShown;
  final POSOrderSaveOutboxReviewPlan reviewPlan;

  const POSOrderSaveOutboxActions({
    required this.syncNow,
    required this.clearSent,
    required this.retryShown,
    required this.reviewPlan,
  });

  factory POSOrderSaveOutboxActions.resolve({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
    int retryableShownCount = 0,
    bool hasSyncHandler = false,
    bool hasClearSentHandler = false,
    bool hasRetryShownHandler = false,
  }) {
    final reviewPlan = POSOrderSaveOutboxReviewPlan.resolve(
      summary: summary,
      syncBehavior: syncBehavior,
    );

    return POSOrderSaveOutboxActions(
      syncNow: _syncNow(
        summary: summary,
        syncState: syncState,
        syncBehavior: syncBehavior,
        hasHandler: hasSyncHandler,
      ),
      clearSent: _clearSent(
        summary: summary,
        syncState: syncState,
        syncBehavior: syncBehavior,
        hasHandler: hasClearSentHandler,
      ),
      retryShown: _retryShown(
        syncState: syncState,
        syncBehavior: syncBehavior,
        shownCount: retryableShownCount,
        hasHandler: hasRetryShownHandler,
      ),
      reviewPlan: reviewPlan,
    );
  }

  String get retryShownNoticeTitle {
    final noun = retryShown.affectedCount == 1 ? 'save' : 'saves';
    return '${retryShown.affectedCount} failed $noun shown';
  }

  String get retryShownNoticeMessage {
    return reviewPlan.retryNoticeMessage;
  }

  static POSOrderSaveOutboxActionState _syncNow({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
    required bool hasHandler,
  }) {
    if (syncState.isRunning) {
      return const POSOrderSaveOutboxActionState(
        label: 'Syncing',
        busy: true,
        disabledReason: 'Order sync is already running.',
      );
    }
    if (!hasHandler) {
      return POSOrderSaveOutboxActionState(
        label: syncBehavior.syncActionLabel,
        disabledReason: 'Sync is not available in this view.',
      );
    }
    if (!summary.canSync) {
      return POSOrderSaveOutboxActionState(
        label: syncBehavior.syncActionLabel,
        disabledReason: 'No queued or failed saves are ready to sync.',
      );
    }
    return POSOrderSaveOutboxActionState(
      label: syncBehavior.syncActionLabel,
      affectedCount: summary.pendingCount + summary.failedCount,
    );
  }

  static POSOrderSaveOutboxActionState _clearSent({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
    required bool hasHandler,
  }) {
    if (!hasHandler) {
      return POSOrderSaveOutboxActionState(
        label: syncBehavior.clearSentActionLabel,
        disabledReason: 'Submitted saves cannot be cleared from this view.',
      );
    }
    if (syncState.isRunning) {
      return POSOrderSaveOutboxActionState(
        label: syncBehavior.clearSentActionLabel,
        disabledReason:
            'Finish the current sync before clearing submitted saves.',
      );
    }
    if (summary.sentCount == 0) {
      return POSOrderSaveOutboxActionState(
        label: syncBehavior.clearSentActionLabel,
        disabledReason: 'No submitted saves are ready to clear.',
      );
    }
    return POSOrderSaveOutboxActionState(
      label: syncBehavior.clearSentActionLabel,
      affectedCount: summary.sentCount,
    );
  }

  static POSOrderSaveOutboxActionState _retryShown({
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
    required int shownCount,
    required bool hasHandler,
  }) {
    if (!hasHandler || shownCount == 0) {
      return POSOrderSaveOutboxActionState(
        label: syncBehavior.retryShownActionLabel,
        visible: false,
      );
    }
    if (syncState.isRunning) {
      return POSOrderSaveOutboxActionState(
        label: 'Syncing',
        busy: true,
        affectedCount: shownCount,
        disabledReason: 'Finish the current sync before retrying shown saves.',
      );
    }
    return POSOrderSaveOutboxActionState(
      label: syncBehavior.retryShownActionLabel,
      affectedCount: shownCount,
    );
  }
}
