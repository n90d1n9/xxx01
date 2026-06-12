import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/stock_movement_report_page.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_movement_report_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  setUp(_mockClipboard);
  tearDown(_clearClipboardMock);

  testWidgets('stock movement report composes modern movement workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_movementReportPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(
      find.byType(InventoryStockMovementReportSummaryGrid),
      findsOneWidget,
    );
    expect(find.byType(InventoryStockMovementReportFilters), findsOneWidget);
    expect(find.byType(InventoryStockMovementReportPanel), findsOneWidget);
    expect(find.text('Stock Movement Report'), findsWidgets);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNWidgets(2));
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Purchase'), findsOneWidget);
    expect(find.text('Sale'), findsOneWidget);
  });

  testWidgets('stock movement report export action copies CSV to clipboard', (
    tester,
  ) async {
    await tester.pumpWidget(_movementReportPage());

    await tester.tap(find.byTooltip('Export movement report'));
    await tester.pumpAndSettle();

    expect(find.textContaining('stock-movement-'), findsOneWidget);
    expect(find.textContaining('copied to clipboard (3 rows)'), findsOneWidget);
  });
}

void _mockClipboard() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
}

void _clearClipboardMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null);
}

Widget _movementReportPage() {
  return MaterialApp(
    home: StockMovementReportPage(
      products: [
        Product(
          id: 'p1',
          name: 'Laptop',
          sku: 'LT-001',
          category: 'Electronics',
          price: 100,
        ),
        Product(
          id: 'p2',
          name: 'Cable',
          sku: 'CB-001',
          category: 'Accessories',
          price: 25,
        ),
      ],
      warehouses: [
        Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
      ],
      movements: [
        InventoryMovement(
          id: 'm1',
          productId: 'p2',
          sourceWarehouseId: 'w1',
          destinationWarehouseId: 'w2',
          quantity: 4,
          type: MovementType.transfer,
          date: DateTime(2026, 5, 31, 9),
          reference: 'TRF-001',
        ),
        InventoryMovement(
          id: 'm2',
          productId: 'p1',
          sourceWarehouseId: 'w1',
          quantity: 5,
          type: MovementType.purchase,
          date: DateTime(2026, 5, 30, 8),
          reference: 'PO-001',
        ),
        InventoryMovement(
          id: 'm3',
          productId: 'p1',
          sourceWarehouseId: 'w1',
          quantity: 2,
          type: MovementType.sale,
          date: DateTime(2026, 5, 29, 8),
          reference: 'SO-001',
        ),
      ],
    ),
  );
}
