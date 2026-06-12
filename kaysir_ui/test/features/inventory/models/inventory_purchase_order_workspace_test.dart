import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_saved_view.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_workspace.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';

void main() {
  test('buildInventoryPurchaseOrderRecords enriches and sorts orders', () {
    final records = buildInventoryPurchaseOrderRecords(
      orders: _orders,
      asOfDate: _asOf,
    );

    expect(records.map((record) => record.id), [
      'PO-OVERDUE',
      'PO-FUTURE',
      'PO-RECEIVED',
      'PO-CANCELLED',
    ]);
    expect(records.first.supplierLabel, 'Jakarta Supply');
    expect(records.first.totalAmount, 35);
    expect(records.first.totalUnits, 5);
    expect(records.first.statusLabel, 'Pending');
    expect(records.first.isOverdue, isTrue);
    expect(records[2].supplierLabel, 'Unknown supplier');
  });

  test('summarizeInventoryPurchaseOrderRecords totals operational status', () {
    final summary = summarizeInventoryPurchaseOrderRecords(
      buildInventoryPurchaseOrderRecords(orders: _orders, asOfDate: _asOf),
    );

    expect(summary.orderCount, 4);
    expect(summary.activeCount, 2);
    expect(summary.needsReceivingCount, 2);
    expect(summary.receivedCount, 1);
    expect(summary.cancelledCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.totalUnits, 18);
    expect(summary.totalOrderedValue, 385);
    expect(summary.openValue, 235);
    expect(summary.receivedValue, 100);
  });

  test('buildInventoryPurchaseOrderScheduleBuckets groups receiving work', () {
    final records = buildInventoryPurchaseOrderRecords(
      orders: [..._orders, ..._scheduleOrders],
      asOfDate: _asOf,
    );
    final buckets = buildInventoryPurchaseOrderScheduleBuckets(records);

    InventoryPurchaseOrderScheduleBucketSummary bucket(
      InventoryPurchaseOrderScheduleBucket value,
    ) {
      return buckets.singleWhere((bucket) => bucket.bucket == value);
    }

    expect(bucket(InventoryPurchaseOrderScheduleBucket.overdue).count, 1);
    expect(bucket(InventoryPurchaseOrderScheduleBucket.overdue).totalUnits, 5);
    expect(bucket(InventoryPurchaseOrderScheduleBucket.overdue).totalValue, 35);
    expect(bucket(InventoryPurchaseOrderScheduleBucket.dueToday).count, 1);
    expect(bucket(InventoryPurchaseOrderScheduleBucket.dueToday).totalUnits, 7);
    expect(bucket(InventoryPurchaseOrderScheduleBucket.nextSevenDays).count, 1);
    expect(bucket(InventoryPurchaseOrderScheduleBucket.later).count, 1);
    expect(bucket(InventoryPurchaseOrderScheduleBucket.unscheduled).count, 1);
  });

  test('filterInventoryPurchaseOrderRecords applies query and status', () {
    final records = buildInventoryPurchaseOrderRecords(
      orders: _orders,
      asOfDate: _asOf,
    );

    expect(
      filterInventoryPurchaseOrderRecords(
        records: records,
        query: 'router',
        filter: InventoryPurchaseOrderFilter.all,
      ).map((record) => record.id),
      ['PO-FUTURE'],
    );
    expect(
      filterInventoryPurchaseOrderRecords(
        records: records,
        query: 'chair',
        filter: InventoryPurchaseOrderFilter.needsReceiving,
      ),
      isEmpty,
    );
    expect(
      filterInventoryPurchaseOrderRecords(
        records: records,
        query: '',
        filter: InventoryPurchaseOrderFilter.overdue,
      ).single.id,
      'PO-OVERDUE',
    );
    expect(
      filterInventoryPurchaseOrderRecords(
        records: records,
        query: '',
        filter: InventoryPurchaseOrderFilter.received,
      ).single.id,
      'PO-RECEIVED',
    );
  });

  test('sortInventoryPurchaseOrderRecords supports queue sort modes', () {
    final records = buildInventoryPurchaseOrderRecords(
      orders: _orders,
      asOfDate: _asOf,
    );

    expect(
      sortInventoryPurchaseOrderRecords(
        records: records,
        sort: InventoryPurchaseOrderSort.urgency,
      ).map((record) => record.id),
      ['PO-OVERDUE', 'PO-FUTURE', 'PO-RECEIVED', 'PO-CANCELLED'],
    );
    expect(
      sortInventoryPurchaseOrderRecords(
        records: records,
        sort: InventoryPurchaseOrderSort.newestOrder,
      ).map((record) => record.id),
      ['PO-FUTURE', 'PO-OVERDUE', 'PO-RECEIVED', 'PO-CANCELLED'],
    );
    expect(
      sortInventoryPurchaseOrderRecords(
        records: records,
        sort: InventoryPurchaseOrderSort.valueHigh,
      ).map((record) => record.id),
      ['PO-FUTURE', 'PO-RECEIVED', 'PO-CANCELLED', 'PO-OVERDUE'],
    );
  });

  test('purchase order saved views match queue controls', () {
    expect(
      matchingInventoryPurchaseOrderSavedView(
        query: '',
        filter: InventoryPurchaseOrderFilter.needsReceiving,
        sort: InventoryPurchaseOrderSort.expectedDate,
      )?.id,
      'receiving-now',
    );
    expect(
      matchingInventoryPurchaseOrderSavedView(
        query: '',
        filter: InventoryPurchaseOrderFilter.overdue,
        sort: InventoryPurchaseOrderSort.urgency,
      )?.id,
      'overdue-first',
    );
    expect(
      matchingInventoryPurchaseOrderSavedView(
        query: '',
        filter: InventoryPurchaseOrderFilter.all,
        sort: InventoryPurchaseOrderSort.valueHigh,
      )?.id,
      'highest-value',
    );
    expect(
      matchingInventoryPurchaseOrderSavedView(
        query: 'manual',
        filter: InventoryPurchaseOrderFilter.all,
        sort: InventoryPurchaseOrderSort.urgency,
      ),
      isNull,
    );
    expect(
      inventoryPurchaseOrderSavedViewControlLabels(
        inventoryPurchaseOrderSavedViews.first,
      ),
      ['Status: Receiving', 'Sort: Expected date'],
    );
    expect(
      inventoryPurchaseOrderSavedViewControlLabels(
        inventoryPurchaseOrderSavedViews[2],
      ),
      ['Status: Overdue'],
    );
  });

  test('purchase order labels cover all status and filter values', () {
    expect(inventoryPurchaseOrderStatusLabel(OrderStatus.draft), 'Draft');
    expect(inventoryPurchaseOrderStatusLabel(OrderStatus.pending), 'Pending');
    expect(
      inventoryPurchaseOrderStatusLabel(OrderStatus.confirmed),
      'Confirmed',
    );
    expect(inventoryPurchaseOrderStatusLabel(OrderStatus.received), 'Received');
    expect(
      inventoryPurchaseOrderStatusLabel(OrderStatus.completed),
      'Completed',
    );
    expect(
      inventoryPurchaseOrderStatusLabel(OrderStatus.cancelled),
      'Cancelled',
    );

    expect(
      inventoryPurchaseOrderFilterLabel(
        InventoryPurchaseOrderFilter.needsReceiving,
      ),
      'Receiving',
    );
    expect(
      inventoryPurchaseOrderFilterLabel(InventoryPurchaseOrderFilter.overdue),
      'Overdue',
    );
    expect(
      inventoryPurchaseOrderSortLabel(InventoryPurchaseOrderSort.valueHigh),
      'Highest value',
    );
  });
}

final _asOf = DateTime(2026, 5, 31);

final _orders = [
  PurchaseOrder(
    id: 'PO-OVERDUE',
    vendorName: 'Jakarta Supply',
    orderDate: DateTime(2026, 5, 26),
    totalAmount: 0,
    status: OrderStatus.pending,
    expectedDeliveryDate: DateTime(2026, 5, 30),
    items: [
      PurchaseOrderItem(
        id: 'i1',
        name: 'Adapter',
        quantity: 2,
        unitPrice: 10,
        sku: 'AD-001',
      ),
      PurchaseOrderItem(
        id: 'i2',
        name: 'Cable',
        quantity: 3,
        unitPrice: 5,
        sku: 'CB-001',
      ),
    ],
  ),
  PurchaseOrder(
    id: 'PO-FUTURE',
    supplierName: 'Network Partner',
    orderDate: DateTime(2026, 5, 28),
    totalAmount: 200,
    status: OrderStatus.confirmed,
    expectedDeliveryDate: DateTime(2026, 6, 5),
    items: [
      PurchaseOrderItem(
        id: 'i3',
        name: 'Router',
        quantity: 4,
        unitPrice: 50,
        sku: 'RTR-001',
      ),
    ],
  ),
  PurchaseOrder(
    id: 'PO-RECEIVED',
    supplierName: ' ',
    orderDate: DateTime(2026, 5, 20),
    totalAmount: 100,
    status: OrderStatus.received,
    expectedDeliveryDate: DateTime(2026, 5, 25),
    items: [
      PurchaseOrderItem(
        id: 'i4',
        name: 'Notebook',
        quantity: 8,
        unitPrice: 12.5,
      ),
    ],
  ),
  PurchaseOrder(
    id: 'PO-CANCELLED',
    supplierName: 'Office Vendor',
    orderDate: DateTime(2026, 5, 18),
    totalAmount: 50,
    status: OrderStatus.cancelled,
    expectedDeliveryDate: DateTime(2026, 5, 21),
    items: [
      PurchaseOrderItem(id: 'i5', name: 'Chair', quantity: 1, unitPrice: 50),
    ],
  ),
];

final _scheduleOrders = [
  PurchaseOrder(
    id: 'PO-TODAY',
    supplierName: 'Same Day Supply',
    orderDate: DateTime(2026, 5, 29),
    totalAmount: 70,
    status: OrderStatus.confirmed,
    expectedDeliveryDate: _asOf,
    items: [
      PurchaseOrderItem(id: 'i6', name: 'Scanner', quantity: 7, unitPrice: 10),
    ],
  ),
  PurchaseOrder(
    id: 'PO-LATER',
    supplierName: 'Long Lead Vendor',
    orderDate: DateTime(2026, 5, 25),
    totalAmount: 90,
    status: OrderStatus.pending,
    expectedDeliveryDate: DateTime(2026, 6, 15),
    items: [
      PurchaseOrderItem(id: 'i7', name: 'Shelf', quantity: 9, unitPrice: 10),
    ],
  ),
  PurchaseOrder(
    id: 'PO-NO-ETA',
    supplierName: 'Manual Supplier',
    orderDate: DateTime(2026, 5, 30),
    totalAmount: 30,
    status: OrderStatus.pending,
    items: [
      PurchaseOrderItem(id: 'i8', name: 'Label', quantity: 3, unitPrice: 10),
    ],
  ),
];
