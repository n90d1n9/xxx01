import 'order_save_outbox_sync.dart';
import 'order_save_outbox_error_copy.dart';

enum POSOrderSaveOutboxSyncPhase { idle, running, completed, failed }

class POSOrderSaveOutboxSyncState {
  final POSOrderSaveOutboxSyncPhase phase;
  final POSOrderSaveOutboxSyncResult? lastResult;
  final String? lastError;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const POSOrderSaveOutboxSyncState({
    required this.phase,
    this.lastResult,
    this.lastError,
    this.startedAt,
    this.finishedAt,
  });

  const POSOrderSaveOutboxSyncState.idle()
    : phase = POSOrderSaveOutboxSyncPhase.idle,
      lastResult = null,
      lastError = null,
      startedAt = null,
      finishedAt = null;

  factory POSOrderSaveOutboxSyncState.running({required DateTime startedAt}) {
    return POSOrderSaveOutboxSyncState(
      phase: POSOrderSaveOutboxSyncPhase.running,
      startedAt: startedAt,
    );
  }

  factory POSOrderSaveOutboxSyncState.completed({
    required POSOrderSaveOutboxSyncResult result,
    required DateTime startedAt,
    required DateTime finishedAt,
  }) {
    return POSOrderSaveOutboxSyncState(
      phase: POSOrderSaveOutboxSyncPhase.completed,
      lastResult: result,
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
  }

  factory POSOrderSaveOutboxSyncState.failed({
    required Object error,
    required DateTime startedAt,
    required DateTime finishedAt,
  }) {
    return POSOrderSaveOutboxSyncState(
      phase: POSOrderSaveOutboxSyncPhase.failed,
      lastError: friendlyPOSOrderSyncFailureMessage(error),
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
  }

  bool get isRunning => phase == POSOrderSaveOutboxSyncPhase.running;

  bool get hasResult => lastResult != null;

  bool get hasFailures {
    final result = lastResult;
    return lastError != null || (result != null && result.hasFailures);
  }

  String get operatorMessage {
    switch (phase) {
      case POSOrderSaveOutboxSyncPhase.idle:
        return 'Order sync is idle';
      case POSOrderSaveOutboxSyncPhase.running:
        return 'Syncing queued orders';
      case POSOrderSaveOutboxSyncPhase.failed:
        return 'Unable to sync queued orders: ${lastError ?? 'Unknown error'}';
      case POSOrderSaveOutboxSyncPhase.completed:
        final result = lastResult;
        if (result == null) return 'Order sync completed';
        if (result.hasFailures) {
          return 'Order sync needs attention: ${result.remainingFailed} failed';
        }
        if (result.sent == 0) return 'No queued orders to sync';
        final noun = result.sent == 1 ? 'order' : 'orders';
        return '${result.sent} $noun synced';
    }
  }
}
