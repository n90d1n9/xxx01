import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_detail.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';

void main() {
  test('buildInventoryPurchaseOrderDetail enriches order and line items', () {
    final detail = buildInventoryPurchaseOrderDetail(
      order: _confirmedOrder,
      asOfDate: DateTime(2026, 5, 31),
    );

    expect(detail.id, 'PO-DETAIL');
    expect(detail.supplierLabel, 'Jakarta Supply');
    expect(detail.statusLabel, 'Confirmed');
    expect(detail.totalAmount, 75);
    expect(detail.totalUnits, 5);
    expect(detail.itemCount, 2);
    expect(detail.notes, 'Deliver before noon');
    expect(detail.canReceive, isTrue);
    expect(detail.canCancel, isTrue);
    expect(detail.isClosed, isFalse);
    expect(detail.receivingGuidance, 'Ready to receive into inventory.');
    expect(detail.items.map((item) => item.lineNumber), [1, 2]);
    expect(detail.items.first.skuLabel, 'AD-001');
    expect(detail.items.last.skuLabel, 'No SKU');
  });

  test('purchase order detail reports closed and pending action states', () {
    final pending = buildInventoryPurchaseOrderDetail(
      order: _confirmedOrder.copyWith(status: OrderStatus.pending),
      asOfDate: DateTime(2026, 5, 31),
    );
    final received = buildInventoryPurchaseOrderDetail(
      order: _confirmedOrder.copyWith(status: OrderStatus.received),
      asOfDate: DateTime(2026, 5, 31),
    );

    expect(pending.canReceive, isFalse);
    expect(pending.canCancel, isTrue);
    expect(
      pending.receivingGuidance,
      'Confirm this purchase order before receiving stock.',
    );
    expect(received.canReceive, isFalse);
    expect(received.canCancel, isFalse);
    expect(received.isClosed, isTrue);
    expect(received.receivingGuidance, 'This purchase order is closed.');
  });
}

final _confirmedOrder = PurchaseOrder(
  id: 'PO-DETAIL',
  vendorName: 'Jakarta Supply',
  orderDate: DateTime(2026, 5, 28),
  totalAmount: 0,
  status: OrderStatus.confirmed,
  expectedDeliveryDate: DateTime(2026, 6, 2),
  notes: ' Deliver before noon ',
  items: [
    PurchaseOrderItem(
      id: 'i1',
      name: 'Adapter',
      quantity: 3,
      unitPrice: 15,
      sku: 'AD-001',
    ),
    PurchaseOrderItem(id: 'i2', name: 'Cable', quantity: 2, unitPrice: 15),
  ],
);
