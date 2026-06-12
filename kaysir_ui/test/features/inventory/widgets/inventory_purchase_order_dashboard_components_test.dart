import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_dashboard.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_dashboard_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('purchase order dashboard summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderDashboardSummaryGrid(
            summary: _dashboard.summary,
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Inventory Value'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.text('Receiving'), findsOneWidget);
  });

  testWidgets('purchase order dashboard grid renders panels and tiles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderDashboardGrid(dashboard: _dashboard),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsNWidgets(3));
    expect(find.byType(InventoryPurchaseOrderLowStockTile), findsNWidgets(2));
    expect(find.byType(InventoryPurchaseOrderMovementTile), findsNWidgets(2));
    expect(find.byType(InventoryPurchaseOrderReceivingTile), findsNWidgets(2));
    expect(find.text('Cable'), findsWidgets);
    expect(find.text('Sale'), findsOneWidget);
    expect(find.text('-2 units'), findsOneWidget);
    expect(find.text('PO-PENDING'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
  });

  testWidgets('purchase order dashboard panels show empty states', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const emptyDashboard = InventoryPurchaseOrderDashboard(
      summary: InventoryPurchaseOrderDashboardSummary(
        productCount: 0,
        lowStockProductCount: 0,
        totalInventoryValue: 0,
        onHandUnits: 0,
        receivingOrderCount: 0,
        receivingOrderValue: 0,
        recentMovementCount: 0,
      ),
      lowStockProducts: [],
      recentMovements: [],
      receivingOrders: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InventoryPurchaseOrderDashboardGrid(
              dashboard: emptyDashboard,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsNWidgets(3));
    expect(find.text('Stock coverage is healthy'), findsOneWidget);
    expect(find.text('No recent stock movements'), findsOneWidget);
    expect(find.text('No purchase orders waiting'), findsOneWidget);
  });
}

final _dashboard = buildInventoryPurchaseOrderDashboard(
  products: _products,
  stockMovements: _movements,
  purchaseOrders: _orders,
  asOfDate: DateTime(2026, 5, 31),
);

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100, currentStock: 8),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 20, currentStock: 3),
  Product(id: 'p3', name: 'Adapter', sku: 'AD-001', price: 5, currentStock: 0),
];

final _movements = [
  StockMovement(
    id: 'm1',
    productId: 'p2',
    quantity: 2,
    type: MovementType.sale,
    date: DateTime(2026, 5, 31),
    reference: 'SO-001',
  ),
  StockMovement(
    id: 'm2',
    productId: 'p3',
    quantity: 5,
    type: MovementType.purchase,
    date: DateTime(2026, 5, 30),
    reference: 'PO-001',
  ),
];

final _orders = [
  PurchaseOrder(
    id: 'PO-PENDING',
    vendorName: 'Jakarta Supply',
    orderDate: DateTime(2026, 5, 29),
    totalAmount: 50,
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
];
