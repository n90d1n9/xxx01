import 'order_payload_envelope.dart';
import 'order_save_outbox.dart';

typedef POSOrderEnvelopeSender =
    Future<void> Function(POSOrderPayloadEnvelope envelope);
typedef POSOrderSyncClock = DateTime Function();

abstract class POSOrderSaveOutboxSyncPort {
  POSOrderSaveOutbox get snapshot;

  void retryFailed(String idempotencyKey);

  void markSending(String idempotencyKey, {DateTime? attemptedAt});

  void markSent(String idempotencyKey, {DateTime? sentAt});

  void markFailed(String idempotencyKey, Object error, {DateTime? failedAt});
}

class POSOrderSaveOutboxSyncResult {
  final int submitted;
  final int sent;
  final int failed;
  final int skipped;
  final int remainingPending;
  final int remainingFailed;

  const POSOrderSaveOutboxSyncResult({
    required this.submitted,
    required this.sent,
    required this.failed,
    required this.skipped,
    required this.remainingPending,
    required this.remainingFailed,
  });

  bool get hasFailures => failed > 0 || remainingFailed > 0;

  bool get hasRemainingWork => remainingPending + remainingFailed > 0;

  bool get madeProgress => submitted > 0 || skipped > 0;

  static POSOrderSaveOutboxSyncResult empty(POSOrderSaveOutbox outbox) {
    return POSOrderSaveOutboxSyncResult(
      submitted: 0,
      sent: 0,
      failed: 0,
      skipped: 0,
      remainingPending: outbox.pendingCount,
      remainingFailed: outbox.failedCount,
    );
  }
}

class POSOrderSaveOutboxSyncController {
  final POSOrderSaveOutboxSyncPort outbox;
  final POSOrderEnvelopeSender sender;
  final POSOrderSyncClock _clock;

  POSOrderSaveOutboxSyncController({
    required this.outbox,
    required this.sender,
    POSOrderSyncClock? clock,
  }) : _clock = clock ?? DateTime.now;

  Future<POSOrderSaveOutboxSyncResult> drain({
    int limit = 20,
    bool retryFailed = true,
    bool continueOnError = true,
  }) async {
    if (limit <= 0) {
      return POSOrderSaveOutboxSyncResult.empty(outbox.snapshot);
    }

    var submitted = 0;
    var sent = 0;
    var failed = 0;
    var skipped = 0;
    final visitedKeys = <String>{};

    while (submitted + skipped < limit) {
      final entry = _nextRunnableEntry(
        outbox.snapshot,
        visitedKeys: visitedKeys,
        retryFailed: retryFailed,
      );
      if (entry == null) break;

      final idempotencyKey = entry.idempotencyKey;
      visitedKeys.add(idempotencyKey);

      if (entry.status == POSOrderSaveOutboxStatus.failed) {
        outbox.retryFailed(idempotencyKey);
      }
      outbox.markSending(idempotencyKey, attemptedAt: _clock());

      final sendingEntry = outbox.snapshot.entryFor(idempotencyKey);
      if (sendingEntry == null ||
          sendingEntry.status != POSOrderSaveOutboxStatus.sending) {
        skipped++;
        continue;
      }

      submitted++;
      try {
        await sender(sendingEntry.envelope);
        outbox.markSent(idempotencyKey, sentAt: _clock());
        sent++;
      } catch (error) {
        outbox.markFailed(idempotencyKey, error, failedAt: _clock());
        failed++;
        if (!continueOnError) break;
      }
    }

    final snapshot = outbox.snapshot;
    return POSOrderSaveOutboxSyncResult(
      submitted: submitted,
      sent: sent,
      failed: failed,
      skipped: skipped,
      remainingPending: snapshot.pendingCount,
      remainingFailed: snapshot.failedCount,
    );
  }

  POSOrderSaveOutboxEntry? _nextRunnableEntry(
    POSOrderSaveOutbox snapshot, {
    required Set<String> visitedKeys,
    required bool retryFailed,
  }) {
    for (final entry in snapshot.entries) {
      if (visitedKeys.contains(entry.idempotencyKey)) continue;
      if (entry.status == POSOrderSaveOutboxStatus.pending) return entry;
      if (retryFailed && entry.status == POSOrderSaveOutboxStatus.failed) {
        return entry;
      }
    }

    return null;
  }
}
