import 'billing_cart_item.dart';
import 'billing_invoice_line_item.dart';

class BillingCheckoutRequest {
  final String tenantId;
  final String tenantName;
  final List<CartItem> items;
  final List<BillingInvoiceLineItem> lineItems;
  final double total;

  BillingCheckoutRequest({
    required this.tenantId,
    required this.tenantName,
    required Iterable<CartItem> items,
    required this.total,
    Iterable<BillingInvoiceLineItem> lineItems = const [],
  }) : items = List.unmodifiable(items),
       lineItems = List.unmodifiable(lineItems);

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  bool get hasLineItems => lineItems.isNotEmpty;
}

class BillingCheckoutReceipt {
  final String id;
  final String tenantId;
  final String tenantName;
  final double total;
  final int itemCount;
  final DateTime createdAt;

  const BillingCheckoutReceipt({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.total,
    required this.itemCount,
    required this.createdAt,
  });
}
