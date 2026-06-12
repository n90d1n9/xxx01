import 'package:logging/logging.dart';
import 'package:sembast/sembast.dart';
import 'local_storage_service.dart';

final _logger = Logger('MessageOutbox');

class OutboxItem {
  final String clientMessageId;
  final String roomId;
  final Map<String, dynamic> payload; // Original message JSON
  final DateTime queuedAt;
  final int retryCount;
  final String? lastError;
  final DateTime? nextRetryAt;

  OutboxItem({
    required this.clientMessageId,
    required this.roomId,
    required this.payload,
    required this.queuedAt,
    this.retryCount = 0,
    this.lastError,
    this.nextRetryAt,
  });

  Map<String, dynamic> toJson() => {
    'clientMessageId': clientMessageId,
    'roomId': roomId,
    'payload': payload,
    'queuedAt': queuedAt.toIso8601String(),
    'retryCount': retryCount,
    'lastError': lastError,
    'nextRetryAt': nextRetryAt?.toIso8601String(),
  };

  factory OutboxItem.fromJson(Map<String, dynamic> json) => OutboxItem(
    clientMessageId: json['clientMessageId'] as String,
    roomId: json['roomId'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    queuedAt: DateTime.parse(json['queuedAt'] as String),
    retryCount: json['retryCount'] as int? ?? 0,
    lastError: json['lastError'] as String?,
    nextRetryAt: json['nextRetryAt'] != null
        ? DateTime.parse(json['nextRetryAt'] as String)
        : null,
  );
}

typedef MessageSender =
    Future<void> Function(String roomId, Map<String, dynamic> payload);

class MessageOutbox {
  static final _store = stringMapStoreFactory.store('outbox_store');
  static const int maxRetries =
      10; // Increased max retries for exponential backoff
  static const String _pendingE2eeSentinel = 'PENDING_E2EE_SESSION';

  /// Enqueue a message to the outbox
  static Future<void> enqueue(
    String roomId,
    Map<String, dynamic> payload,
  ) async {
    final clientMessageId = payload['clientMessageId'] as String?;
    if (clientMessageId == null || clientMessageId.isEmpty) {
      _logger.warning('Skipping enqueue: no clientMessageId found in payload.');
      return;
    }

    final db = await LocalDBService.getDatabase();
    final item = OutboxItem(
      clientMessageId: clientMessageId,
      roomId: roomId,
      payload: payload,
      queuedAt: DateTime.now(),
      nextRetryAt: DateTime.now(), // Ready immediately
    );
    await _store.record(clientMessageId).put(db, item.toJson());
    _logger.fine('Message $clientMessageId enqueued for room $roomId');
  }

  /// Drain outbox for a specific room or all rooms if roomId is null
  static Future<void> drain(MessageSender sender, {String? roomId}) async {
    final pending = roomId != null
        ? await getPending(roomId)
        : await _getAllPending();

    final now = DateTime.now();

    for (final item in pending) {
      if (item.retryCount >= maxRetries) continue;

      // Check if item is ready for retry based on backoff
      if (item.nextRetryAt != null && item.nextRetryAt!.isAfter(now)) {
        continue;
      }

      try {
        await sender(item.roomId, item.payload);
        await markSent(item.clientMessageId);
      } catch (e) {
        _logger.warning(
          'Failed to send outbox item ${item.clientMessageId}: $e',
        );
        await markFailed(item.clientMessageId, e);
      }
    }
  }

  /// Mark a message as successfully sent (remove from outbox)
  static Future<void> markSent(String clientMessageId) async {
    final db = await LocalDBService.getDatabase();
    await _store.record(clientMessageId).delete(db);
    _logger.fine(
      'Message $clientMessageId marked as sent (removed from outbox)',
    );
  }

  /// Mark a message as failed and schedule next retry
  static Future<void> markFailed(String clientMessageId, Object error) async {
    final db = await LocalDBService.getDatabase();
    final record = _store.record(clientMessageId);
    final data = await record.get(db);
    if (data != null) {
      final item = OutboxItem.fromJson(data);
      final errorText = error.toString();

      // Special case: strict E2EE flow may intentionally "hold" an outbox item
      // until the peer key/session becomes available. In that case we must NOT
      // treat it as a real failure, and must NOT remove it from the outbox.
      // Otherwise messages can be dropped even though they were never sent.
      if (errorText.contains(_pendingE2eeSentinel)) {
        final updated = OutboxItem(
          clientMessageId: item.clientMessageId,
          roomId: item.roomId,
          payload: item.payload,
          queuedAt: item.queuedAt,
          retryCount: item.retryCount, // do not increment
          lastError: null, // keep UI in "sending/queued" state
          nextRetryAt: DateTime.now().add(const Duration(seconds: 2)),
        );
        await record.put(db, updated.toJson());
        _logger.fine(
          'Message $clientMessageId pending E2EE session. Holding for retry.',
        );
        return;
      }

      final newRetryCount = item.retryCount + 1;

      if (newRetryCount >= maxRetries) {
        _logger.severe(
          'Message $clientMessageId hit max retries ($maxRetries). Abandoning.',
        );
        // Optional: Notify user or move to "failed" store
        return;
      }

      final backoff = _calculateBackoff(newRetryCount);
      final nextRetry = DateTime.now().add(backoff);

      final updated = OutboxItem(
        clientMessageId: item.clientMessageId,
        roomId: item.roomId,
        payload: item.payload,
        queuedAt: item.queuedAt,
        retryCount: newRetryCount,
        lastError: errorText,
        nextRetryAt: nextRetry,
      );
      await record.put(db, updated.toJson());
      _logger.info(
        'Message $clientMessageId failed. Retry $newRetryCount scheduled for $nextRetry',
      );
    }
  }

  static Duration _calculateBackoff(int retryCount) {
    // 1s, 2s, 4s, 8s, 16s, 32s, 64s, up to 5 min
    final seconds = (1 << (retryCount - 1)).clamp(1, 300);
    return Duration(seconds: seconds);
  }

  /// Get pending messages for a specific room
  static Future<List<OutboxItem>> getPending(String roomId) async {
    final db = await LocalDBService.getDatabase();
    final records = await _store.find(
      db,
      finder: Finder(filter: Filter.equals('roomId', roomId)),
    );
    final items = records.map((r) => OutboxItem.fromJson(r.value)).toList();
    items.sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    return items;
  }

  static Future<List<OutboxItem>> _getAllPending() async {
    final db = await LocalDBService.getDatabase();
    final records = await _store.find(db);
    final items = records.map((r) => OutboxItem.fromJson(r.value)).toList();
    items.sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    return items;
  }

  static Future<Map<String, OutboxItem>> latestPendingByRoom() async {
    final pending = await _getAllPending();
    final latest = <String, OutboxItem>{};
    for (final item in pending) {
      final existing = latest[item.roomId];
      if (existing == null || item.queuedAt.isAfter(existing.queuedAt)) {
        latest[item.roomId] = item;
      }
    }
    return latest;
  }

  /// Remove all queued items for a specific room
  static Future<void> clearRoom(String roomId) async {
    final db = await LocalDBService.getDatabase();
    final finder = Finder(filter: Filter.equals('roomId', roomId));
    await _store.delete(db, finder: finder);
    _logger.fine('Cleared outbox items for room $roomId');
  }

  /// Remove all queued items across all rooms
  static Future<void> clearAll() async {
    final db = await LocalDBService.getDatabase();
    await _store.delete(db);
    _logger.fine('Cleared outbox items for all rooms');
  }

  /// Force retry all items immediately (ignoring nextRetryAt)
  static Future<void> forceRetry(MessageSender sender) async {
    final pending = await _getAllPending();
    for (final item in pending) {
      try {
        await sender(item.roomId, item.payload);
        await markSent(item.clientMessageId);
      } catch (e) {
        await markFailed(item.clientMessageId, e);
      }
    }
  }

  /// Normal retry (respecting nextRetryAt)
  static Future<void> retryFailed(MessageSender sender) async {
    await drain(sender);
  }
}
