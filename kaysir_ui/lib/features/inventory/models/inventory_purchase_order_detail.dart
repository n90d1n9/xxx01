import '../../ecommerce/order/order.dart';
import '../utils/inventory_label_utils.dart';
import 'inventory_purchase_order_workspace.dart';
import 'purchase_order.dart';
import 'purchase_order_item.dart';

class InventoryPurchaseOrderDetail {
  const InventoryPurchaseOrderDetail({
    required this.record,
    required this.items,
    required this.notes,
  });

  final InventoryPurchaseOrderRecord record;
  final List<InventoryPurchaseOrderDetailItem> items;
  final String? notes;

  PurchaseOrder get order => record.order;

  String get id => record.id;

  String get supplierLabel => record.supplierLabel;

  String get statusLabel => record.statusLabel;

  OrderStatus get status => record.status;

  DateTime get orderDate => record.orderDate;

  DateTime? get expectedDeliveryDate => record.expectedDeliveryDate;

  int get totalUnits => record.totalUnits;

  int get itemCount => record.itemCount;

  double get totalAmount => record.totalAmount;

  bool get isOverdue => record.isOverdue;

  bool get canReceive => status == OrderStatus.confirmed;

  bool get canCancel =>
      status != OrderStatus.received &&
      status != OrderStatus.completed &&
      status != OrderStatus.cancelled;

  bool get isClosed =>
      status == OrderStatus.received ||
      status == OrderStatus.completed ||
      status == OrderStatus.cancelled;

  String get receivingGuidance {
    if (canReceive) return 'Ready to receive into inventory.';
    if (status == OrderStatus.pending) {
      return 'Confirm this purchase order before receiving stock.';
    }
    if (isClosed) return 'This purchase order is closed.';
    return 'Review supplier commitment before receiving stock.';
  }
}

class InventoryPurchaseOrderDetailItem {
  const InventoryPurchaseOrderDetailItem({
    required this.item,
    required this.lineNumber,
  });

  final PurchaseOrderItem item;
  final int lineNumber;

  String get id => item.id;

  String get name => inventoryItemNameLabel(item.name);

  String get skuLabel => inventorySkuLabel(item.sku);

  int get quantity => item.quantity;

  double get unitPrice => item.unitPrice;

  double get total => item.total;
}

InventoryPurchaseOrderDetail buildInventoryPurchaseOrderDetail({
  required PurchaseOrder order,
  required DateTime asOfDate,
}) {
  final record =
      buildInventoryPurchaseOrderRecords(
        orders: [order],
        asOfDate: asOfDate,
      ).single;
  final notes = order.notes?.trim();

  return InventoryPurchaseOrderDetail(
    record: record,
    notes: notes == null || notes.isEmpty ? null : notes,
    items: [
      for (var index = 0; index < order.items.length; index += 1)
        InventoryPurchaseOrderDetailItem(
          item: order.items[index],
          lineNumber: index + 1,
        ),
    ],
  );
}
