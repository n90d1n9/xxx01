import 'order_save_outbox.dart';

enum POSOrderSaveOutboxHealth { ready, queued, syncing, failed }

class POSOrderSaveOutboxSummary {
  final POSOrderSaveOutboxHealth health;
  final int pendingCount;
  final int sendingCount;
  final int failedCount;
  final int sentCount;
  final int totalCount;

  const POSOrderSaveOutboxSummary({
    required this.health,
    required this.pendingCount,
    required this.sendingCount,
    required this.failedCount,
    required this.sentCount,
    required this.totalCount,
  });

  const POSOrderSaveOutboxSummary.empty()
    : health = POSOrderSaveOutboxHealth.ready,
      pendingCount = 0,
      sendingCount = 0,
      failedCount = 0,
      sentCount = 0,
      totalCount = 0;

  factory POSOrderSaveOutboxSummary.fromOutbox(POSOrderSaveOutbox outbox) {
    final failedCount = outbox.failedCount;
    final sendingCount = outbox.sendingCount;
    final pendingCount = outbox.pendingCount;
    final sentCount = outbox.sentCount;

    final health =
        failedCount > 0
            ? POSOrderSaveOutboxHealth.failed
            : sendingCount > 0
            ? POSOrderSaveOutboxHealth.syncing
            : pendingCount > 0
            ? POSOrderSaveOutboxHealth.queued
            : POSOrderSaveOutboxHealth.ready;

    return POSOrderSaveOutboxSummary(
      health: health,
      pendingCount: pendingCount,
      sendingCount: sendingCount,
      failedCount: failedCount,
      sentCount: sentCount,
      totalCount: outbox.entries.length,
    );
  }

  bool get hasUnsentWork => pendingCount + sendingCount + failedCount > 0;

  int get attentionCount => pendingCount + sendingCount + failedCount;

  bool get canSync => pendingCount + failedCount > 0;

  bool get shouldSurface => hasUnsentWork;

  String get label {
    switch (health) {
      case POSOrderSaveOutboxHealth.failed:
        return '${_formatCount(failedCount)} failed';
      case POSOrderSaveOutboxHealth.syncing:
        return '${_formatCount(sendingCount)} syncing';
      case POSOrderSaveOutboxHealth.queued:
        return '${_formatCount(pendingCount)} queued';
      case POSOrderSaveOutboxHealth.ready:
        return 'Synced';
    }
  }

  String get description {
    switch (health) {
      case POSOrderSaveOutboxHealth.failed:
        return _joinParts([
          _orders(failedCount, 'failed'),
          if (pendingCount > 0) _orders(pendingCount, 'queued'),
        ]);
      case POSOrderSaveOutboxHealth.syncing:
        return _joinParts([
          _orders(sendingCount, 'syncing'),
          if (pendingCount > 0) _orders(pendingCount, 'queued'),
        ]);
      case POSOrderSaveOutboxHealth.queued:
        return _orders(pendingCount, 'waiting to sync');
      case POSOrderSaveOutboxHealth.ready:
        if (sentCount == 0) return 'All order saves are submitted';
        return _orders(sentCount, 'synced');
    }
  }

  String _orders(int count, String status) {
    final noun = count == 1 ? 'order' : 'orders';
    return '$count $noun $status';
  }

  String _formatCount(int count) => count.toString();

  String _joinParts(List<String> parts) {
    return parts.where((part) => part.isNotEmpty).join(' | ');
  }
}
