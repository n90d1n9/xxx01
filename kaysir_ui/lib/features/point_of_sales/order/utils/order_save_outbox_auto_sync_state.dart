import 'order_save_outbox_sync.dart';

enum POSOrderSaveOutboxAutoSyncPhase {
  idle,
  skipped,
  running,
  completed,
  failed,
}

enum POSOrderSaveOutboxAutoSyncSkipReason {
  disabled,
  syncRunning,
  belowThreshold,
  cooldown,
}

class POSOrderSaveOutboxAutoSyncState {
  final POSOrderSaveOutboxAutoSyncPhase phase;
  final POSOrderSaveOutboxAutoSyncSkipReason? skipReason;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final POSOrderSaveOutboxSyncResult? result;
  final Object? error;
  final int workCount;

  const POSOrderSaveOutboxAutoSyncState._({
    required this.phase,
    this.skipReason,
    this.startedAt,
    this.finishedAt,
    this.result,
    this.error,
    this.workCount = 0,
  });

  const POSOrderSaveOutboxAutoSyncState.idle()
    : this._(phase: POSOrderSaveOutboxAutoSyncPhase.idle);

  const POSOrderSaveOutboxAutoSyncState.skipped({
    required POSOrderSaveOutboxAutoSyncSkipReason reason,
    required DateTime finishedAt,
    int workCount = 0,
  }) : this._(
         phase: POSOrderSaveOutboxAutoSyncPhase.skipped,
         skipReason: reason,
         finishedAt: finishedAt,
         workCount: workCount,
       );

  const POSOrderSaveOutboxAutoSyncState.running({
    required DateTime startedAt,
    required int workCount,
  }) : this._(
         phase: POSOrderSaveOutboxAutoSyncPhase.running,
         startedAt: startedAt,
         workCount: workCount,
       );

  const POSOrderSaveOutboxAutoSyncState.completed({
    required POSOrderSaveOutboxSyncResult result,
    required DateTime startedAt,
    required DateTime finishedAt,
    required int workCount,
  }) : this._(
         phase: POSOrderSaveOutboxAutoSyncPhase.completed,
         startedAt: startedAt,
         finishedAt: finishedAt,
         result: result,
         workCount: workCount,
       );

  const POSOrderSaveOutboxAutoSyncState.failed({
    required Object error,
    required DateTime startedAt,
    required DateTime finishedAt,
    required int workCount,
  }) : this._(
         phase: POSOrderSaveOutboxAutoSyncPhase.failed,
         startedAt: startedAt,
         finishedAt: finishedAt,
         error: error,
         workCount: workCount,
       );

  bool get isRunning => phase == POSOrderSaveOutboxAutoSyncPhase.running;

  bool get shouldSurface => phase != POSOrderSaveOutboxAutoSyncPhase.idle;

  String get title {
    switch (phase) {
      case POSOrderSaveOutboxAutoSyncPhase.idle:
        return 'Auto-sync ready';
      case POSOrderSaveOutboxAutoSyncPhase.skipped:
        return 'Auto-sync skipped';
      case POSOrderSaveOutboxAutoSyncPhase.running:
        return 'Auto-sync running';
      case POSOrderSaveOutboxAutoSyncPhase.completed:
        return result?.hasFailures == true
            ? 'Auto-sync needs attention'
            : 'Auto-sync completed';
      case POSOrderSaveOutboxAutoSyncPhase.failed:
        return 'Auto-sync failed';
    }
  }

  String get operatorMessage {
    switch (phase) {
      case POSOrderSaveOutboxAutoSyncPhase.idle:
        return 'Auto-sync is waiting for completed orders.';
      case POSOrderSaveOutboxAutoSyncPhase.skipped:
        return _skipMessage();
      case POSOrderSaveOutboxAutoSyncPhase.running:
        return _workMessage('Submitting');
      case POSOrderSaveOutboxAutoSyncPhase.completed:
        final lastResult = result;
        if (lastResult == null || lastResult.submitted == 0) {
          return 'Auto-sync found no queued order saves to submit.';
        }
        final noun = lastResult.sent == 1 ? 'order' : 'orders';
        if (lastResult.hasFailures) {
          return '${lastResult.sent} $noun synced; ${lastResult.remainingFailed} still need attention.';
        }
        return '${lastResult.sent} $noun synced automatically.';
      case POSOrderSaveOutboxAutoSyncPhase.failed:
        return 'Automatic sync could not finish: ${error ?? 'Unknown error'}.';
    }
  }

  String _skipMessage() {
    switch (skipReason) {
      case POSOrderSaveOutboxAutoSyncSkipReason.disabled:
        return 'This POS mode keeps order sync under operator control.';
      case POSOrderSaveOutboxAutoSyncSkipReason.syncRunning:
        return 'A sync is already running, so this completion joined the existing queue.';
      case POSOrderSaveOutboxAutoSyncSkipReason.belowThreshold:
        return 'Queued work is below the auto-sync threshold for this mode.';
      case POSOrderSaveOutboxAutoSyncSkipReason.cooldown:
        return 'Auto-sync is cooling down briefly before another background run.';
      case null:
        return 'Auto-sync did not start for this completion.';
    }
  }

  String _workMessage(String verb) {
    final noun = workCount == 1 ? 'order save' : 'order saves';
    return '$verb $workCount queued $noun in the background.';
  }
}
