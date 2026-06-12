import 'order_display.dart';
import 'order_save_outbox_activity.dart';
import 'order_save_outbox_error_copy.dart';

class POSOrderSaveOutboxActivityDisplay {
  final String title;
  final String detail;
  final String timeLabel;

  const POSOrderSaveOutboxActivityDisplay({
    required this.title,
    required this.detail,
    required this.timeLabel,
  });

  factory POSOrderSaveOutboxActivityDisplay.fromActivity(
    POSOrderSaveOutboxActivity activity,
  ) {
    final orderLabel = _orderLabel(activity);
    return POSOrderSaveOutboxActivityDisplay(
      title: _title(activity, orderLabel),
      detail: _detail(activity, orderLabel),
      timeLabel: _clockLabel(activity.occurredAt),
    );
  }
}

List<POSOrderSaveOutboxActivity> latestPOSOrderSaveOutboxActivity(
  Iterable<POSOrderSaveOutboxActivity> activity, {
  int limit = 5,
}) {
  final next = [...activity];
  next.sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
  return List.unmodifiable(next.take(limit));
}

String _title(POSOrderSaveOutboxActivity activity, String? orderLabel) {
  switch (activity.type) {
    case POSOrderSaveOutboxActivityType.queued:
      return '${orderLabel ?? 'Order'} queued';
    case POSOrderSaveOutboxActivityType.sending:
      return '${orderLabel ?? 'Order'} syncing';
    case POSOrderSaveOutboxActivityType.sent:
      return '${orderLabel ?? 'Order'} synced';
    case POSOrderSaveOutboxActivityType.failed:
      return '${orderLabel ?? 'Order'} failed';
    case POSOrderSaveOutboxActivityType.retried:
      return '${orderLabel ?? 'Order'} retried';
    case POSOrderSaveOutboxActivityType.removed:
      return '${orderLabel ?? 'Order'} removed';
    case POSOrderSaveOutboxActivityType.clearedSent:
      return 'Synced saves cleared';
  }
}

String _detail(POSOrderSaveOutboxActivity activity, String? orderLabel) {
  switch (activity.type) {
    case POSOrderSaveOutboxActivityType.queued:
      return 'Ready to submit when sync runs.';
    case POSOrderSaveOutboxActivityType.sending:
      return 'Submitting saved order payload.';
    case POSOrderSaveOutboxActivityType.sent:
      return 'Order save was accepted by the service.';
    case POSOrderSaveOutboxActivityType.failed:
      final message = activity.message;
      if (message == null || message.trim().isEmpty) {
        return 'Save attempt failed.';
      }
      return friendlyPOSOrderSaveFailureMessage(message);
    case POSOrderSaveOutboxActivityType.retried:
      return 'Moved back to queued for another sync attempt.';
    case POSOrderSaveOutboxActivityType.removed:
      return '${orderLabel ?? 'Order'} was removed from the queue.';
    case POSOrderSaveOutboxActivityType.clearedSent:
      final count = activity.count ?? 0;
      final noun = count == 1 ? 'synced save' : 'synced saves';
      return count > 0
          ? '$count $noun removed from the queue.'
          : 'Queue cleaned up.';
  }
}

String? _orderLabel(POSOrderSaveOutboxActivity activity) {
  final orderId = activity.orderId;
  if (orderId != null && orderId.trim().isNotEmpty) {
    return 'Order #${shortPOSOrderId(orderId)}';
  }

  return null;
}

String _clockLabel(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
