import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_dashboard.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryPurchaseOrderDashboard summarizes buying pressure', () {
    final dashboard = buildInventoryPurchaseOrderDashboard(
      products: _products,
      stockMovements: _movements,
      purchaseOrders: _orders,
      asOfDate: _asOf,
      recentMovementLimit: 2,
    );

    expect(dashboard.summary.productCount, 4);
    expect(dashboard.summary.lowStockProductCount, 3);
    expect(dashboard.summary.totalInventoryValue, 1100);
    expect(dashboard.summary.onHandUnits, 18);
    expect(dashboard.summary.receivingOrderCount, 2);
    expect(dashboard.summary.receivingOrderValue, 250);
    expect(dashboard.summary.recentMovementCount, 2);
    expect(dashboard.lowStockProducts.map((record) => record.id), [
      'p3',
      'p2',
      'p4',
    ]);
    expect(dashboard.recentMovements.map((record) => record.id), ['m3', 'm2']);
    expect(dashboard.receivingOrders.map((record) => record.id), [
      'PO-PENDING',
      'PO-CONFIRMED',
    ]);
  });

  test('movement labels and tones cover every movement type', () {
    expect(
      inventoryPurchaseOrderMovementTypeLabel(MovementType.receipt),
      'Receipt',
    );
    expect(
      inventoryPurchaseOrderMovementTypeLabel(MovementType.issue),
      'Issue',
    );
    expect(
      inventoryPurchaseOrderMovementTypeLabel(MovementType.stockOpname),
      'Stock opname',
    );
    expect(
      inventoryPurchaseOrderMovementTypeLabel(MovementType.purchase),
      'Purchase',
    );
    expect(inventoryPurchaseOrderMovementTypeLabel(MovementType.sale), 'Sale');
    expect(
      inventoryPurchaseOrderMovementTone(MovementType.sale),
      InventoryPurchaseOrderMovementTone.outbound,
    );
    expect(
      inventoryPurchaseOrderMovementTone(MovementType.purchase),
      InventoryPurchaseOrderMovementTone.inbound,
    );
    expect(
      inventoryPurchaseOrderMovementTone(MovementType.transfer),
      InventoryPurchaseOrderMovementTone.neutral,
    );

    final outbound = InventoryPurchaseOrderMovementRecord(
      movement: StockMovement(
        id: 'm-sale',
        productId: 'p1',
        quantity: 2,
        type: MovementType.sale,
        date: _asOf,
        reference: 'SO-001',
      ),
      product: _products.first,
    );
    final neutral = InventoryPurchaseOrderMovementRecord(
      movement: StockMovement(
        id: 'm-transfer',
        productId: 'p1',
        quantity: 1,
        type: MovementType.transfer,
        date: _asOf,
        reference: 'TR-001',
      ),
      product: _products.first,
    );

    expect(outbound.quantityLabel, '-2 units');
    expect(neutral.quantityLabel, '1 unit');
  });
}

final _asOf = DateTime(2026, 5, 31);

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    price: 100,
    currentStock: 10,
  ),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 20, currentStock: 3),
  Product(id: 'p3', name: 'Adapter', sku: 'AD-001', price: 5, currentStock: 0),
  Product(id: 'p4', name: 'Notebook', sku: 'NB-001', price: 8, currentStock: 5),
];

final _movements = [
  StockMovement(
    id: 'm1',
    productId: 'p1',
    quantity: 4,
    type: MovementType.purchase,
    date: DateTime(2026, 5, 28),
    reference: 'PO-OLD',
  ),
  StockMovement(
    id: 'm2',
    productId: 'p2',
    quantity: 2,
    type: MovementType.sale,
    date: DateTime(2026, 5, 30),
    reference: 'SO-001',
  ),
  StockMovement(
    id: 'm3',
    productId: 'p3',
    quantity: 1,
    type: MovementType.transfer,
    date: DateTime(2026, 5, 31),
    reference: 'TR-001',
  ),
];

final _orders = [
  PurchaseOrder(
    id: 'PO-PENDING',
    vendorName: 'Jakarta Supply',
    orderDate: DateTime(2026, 5, 29),
    totalAmount: 0,
    status: OrderStatus.pending,
    expectedDeliveryDate: DateTime(2026, 5, 30),
    items: [
      PurchaseOrderItem(id: 'i1', name: 'Adapter', quantity: 5, unitPrice: 10),
    ],
  ),
  PurchaseOrder(
    id: 'PO-CONFIRMED',
    supplierName: 'Network Partner',
    orderDate: DateTime(2026, 5, 28),
    totalAmount: 200,
    status: OrderStatus.confirmed,
    expectedDeliveryDate: DateTime(2026, 6, 5),
    items: [
      PurchaseOrderItem(id: 'i2', name: 'Router', quantity: 4, unitPrice: 50),
    ],
  ),
  PurchaseOrder(
    id: 'PO-RECEIVED',
    supplierName: 'Office Vendor',
    orderDate: DateTime(2026, 5, 20),
    totalAmount: 100,
    status: OrderStatus.received,
    expectedDeliveryDate: DateTime(2026, 5, 25),
    items: [
      PurchaseOrderItem(
        id: 'i3',
        name: 'Notebook',
        quantity: 8,
        unitPrice: 12.5,
      ),
    ],
  ),
];
