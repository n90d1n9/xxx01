import '../models/order.dart';
import '../../cashier/utils/pos_formatters.dart';

enum POSOrderReadiness { empty, needsPayment, readyToComplete }

String shortPOSOrderId(String id) {
  final normalized = id.startsWith('temp_') ? id.substring(5) : id;
  if (normalized.length <= 6) return normalized;
  return normalized.substring(normalized.length - 6);
}

int totalPOSOrderItems(Order order) {
  return order.items.fold(0, (total, item) => total + item.quantity);
}

String posOrderSwitchSummary(Order order) {
  final lineCount = order.items.length;
  final itemCount = totalPOSOrderItems(order);
  final lineLabel = lineCount == 1 ? 'line' : 'lines';
  final itemLabel = itemCount == 1 ? 'item' : 'items';

  return '$lineCount $lineLabel, $itemCount $itemLabel, ${formatPOSCurrency(order.total)}';
}

POSOrderReadiness resolvePOSOrderReadiness(Order order) {
  if (order.items.isEmpty) return POSOrderReadiness.empty;
  if (order.isPaid) return POSOrderReadiness.readyToComplete;
  return POSOrderReadiness.needsPayment;
}

String posOrderReadinessLabel(Order order) {
  switch (resolvePOSOrderReadiness(order)) {
    case POSOrderReadiness.empty:
      return 'Build order';
    case POSOrderReadiness.needsPayment:
      return 'Payment due';
    case POSOrderReadiness.readyToComplete:
      return 'Ready to close';
  }
}
