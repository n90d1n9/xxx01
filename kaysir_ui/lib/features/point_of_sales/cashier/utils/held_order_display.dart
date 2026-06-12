import '../states/held_order_provider.dart';
import 'pos_formatters.dart';

List<HeldOrder> sortHeldOrdersForPOS(List<HeldOrder> heldOrders) {
  final sorted = [...heldOrders];
  sorted.sort((a, b) => b.heldAt.compareTo(a.heldAt));
  return sorted;
}

String heldOrderTimeLabel(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String heldOrderAgeLabel(DateTime heldAt, DateTime now) {
  final elapsed = now.difference(heldAt);
  if (elapsed.inMinutes < 1) return 'Just now';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes} min ago';
  if (elapsed.inDays < 1) return '${elapsed.inHours} hr ago';
  return '${elapsed.inDays} day${elapsed.inDays == 1 ? '' : 's'} ago';
}

String heldOrderSummaryLabel(HeldOrder heldOrder) {
  final itemCount = heldOrder.itemCount;
  final itemLabel = itemCount == 1 ? 'item' : 'items';
  return '$itemCount $itemLabel | ${formatPOSCurrency(heldOrder.order.total)}';
}
