import 'order_save_outbox_auto_sync_state.dart';
import 'order_save_outbox_freshness.dart';
import 'order_save_outbox_summary.dart';
import 'order_save_outbox_sync_behavior.dart';
import 'order_save_outbox_sync_state.dart';

enum POSOrderSaveOutboxStatusIntent {
  ready,
  queued,
  syncing,
  failed,
  agingQueued,
  staleQueued,
  staleFailed,
}

enum POSOrderSaveOutboxStatusActionKind { sync, review }

class POSOrderSaveOutboxStatusPresentation {
  final bool shouldSurface;
  final bool canPress;
  final bool isBusy;
  final String label;
  final String tooltip;
  final POSOrderSaveOutboxStatusIntent intent;

  const POSOrderSaveOutboxStatusPresentation({
    required this.shouldSurface,
    required this.canPress,
    required this.isBusy,
    required this.label,
    required this.tooltip,
    required this.intent,
  });

  factory POSOrderSaveOutboxStatusPresentation.resolve({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxAutoSyncState autoSyncState,
    required POSOrderSaveOutboxFreshnessState freshnessState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
    bool hasAction = false,
    POSOrderSaveOutboxStatusActionKind actionKind =
        POSOrderSaveOutboxStatusActionKind.sync,
  }) {
    final shouldSurface =
        summary.shouldSurface ||
        syncState.isRunning ||
        freshnessState.shouldSurface;
    final canPress = _canPress(
      actionKind: actionKind,
      hasAction: hasAction,
      shouldSurface: shouldSurface,
      summary: summary,
      syncState: syncState,
    );
    final baseTooltip = _baseTooltip(
      actionKind: actionKind,
      canPress: canPress,
      summary: summary,
      syncState: syncState,
      syncBehavior: syncBehavior,
    );

    return POSOrderSaveOutboxStatusPresentation(
      shouldSurface: shouldSurface,
      canPress: canPress,
      isBusy: syncState.isRunning,
      label: _label(
        summary: summary,
        syncState: syncState,
        freshnessState: freshnessState,
      ),
      tooltip: _tooltipWithSignals(
        baseTooltip: baseTooltip,
        autoSyncState: autoSyncState,
        freshnessState: freshnessState,
      ),
      intent: _intent(
        summary: summary,
        syncState: syncState,
        freshnessState: freshnessState,
      ),
    );
  }

  static bool _canPress({
    required POSOrderSaveOutboxStatusActionKind actionKind,
    required bool hasAction,
    required bool shouldSurface,
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
  }) {
    if (!hasAction) return false;

    switch (actionKind) {
      case POSOrderSaveOutboxStatusActionKind.sync:
        return !syncState.isRunning && summary.canSync;
      case POSOrderSaveOutboxStatusActionKind.review:
        return shouldSurface;
    }
  }

  static String _baseTooltip({
    required POSOrderSaveOutboxStatusActionKind actionKind,
    required bool canPress,
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxSyncBehavior syncBehavior,
  }) {
    final baseTooltip =
        syncState.isRunning
            ? syncState.operatorMessage
            : '${syncBehavior.queueTitle}: ${summary.description}';
    if (!canPress) return baseTooltip;

    switch (actionKind) {
      case POSOrderSaveOutboxStatusActionKind.sync:
        return '$baseTooltip. Tap to sync.';
      case POSOrderSaveOutboxStatusActionKind.review:
        return '$baseTooltip. Tap to review.';
    }
  }

  static String _label({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxFreshnessState freshnessState,
  }) {
    if (syncState.isRunning) return 'Syncing';
    if (freshnessState.level == POSOrderSaveOutboxFreshnessLevel.stale) {
      return 'Stale';
    }
    if (freshnessState.level == POSOrderSaveOutboxFreshnessLevel.aging &&
        summary.health == POSOrderSaveOutboxHealth.queued) {
      return 'Aging';
    }
    return summary.label;
  }

  static String _tooltipWithSignals({
    required String baseTooltip,
    required POSOrderSaveOutboxAutoSyncState autoSyncState,
    required POSOrderSaveOutboxFreshnessState freshnessState,
  }) {
    return [
      baseTooltip,
      if (autoSyncState.shouldSurface)
        'Auto-sync: ${autoSyncState.operatorMessage}',
      if (freshnessState.shouldSurface) 'Freshness: ${freshnessState.message}',
    ].join(' ');
  }

  static POSOrderSaveOutboxStatusIntent _intent({
    required POSOrderSaveOutboxSummary summary,
    required POSOrderSaveOutboxSyncState syncState,
    required POSOrderSaveOutboxFreshnessState freshnessState,
  }) {
    if (syncState.isRunning) return POSOrderSaveOutboxStatusIntent.syncing;
    if (freshnessState.level == POSOrderSaveOutboxFreshnessLevel.stale) {
      return freshnessState.hasStaleFailed
          ? POSOrderSaveOutboxStatusIntent.staleFailed
          : POSOrderSaveOutboxStatusIntent.staleQueued;
    }
    if (freshnessState.level == POSOrderSaveOutboxFreshnessLevel.aging &&
        summary.health == POSOrderSaveOutboxHealth.queued) {
      return POSOrderSaveOutboxStatusIntent.agingQueued;
    }

    switch (summary.health) {
      case POSOrderSaveOutboxHealth.ready:
        return POSOrderSaveOutboxStatusIntent.ready;
      case POSOrderSaveOutboxHealth.queued:
        return POSOrderSaveOutboxStatusIntent.queued;
      case POSOrderSaveOutboxHealth.syncing:
        return POSOrderSaveOutboxStatusIntent.syncing;
      case POSOrderSaveOutboxHealth.failed:
        return POSOrderSaveOutboxStatusIntent.failed;
    }
  }
}
