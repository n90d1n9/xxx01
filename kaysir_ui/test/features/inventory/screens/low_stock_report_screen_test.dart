import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/low_stock_report_screen.dart';
import 'package:kaysir/features/inventory/widgets/inventory_low_stock_report_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  setUp(_mockClipboard);
  tearDown(_clearClipboardMock);

  testWidgets('low stock report composes modern report workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_lowStockReportPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryLowStockReportSummaryGrid), findsOneWidget);
    expect(find.byType(InventoryLowStockReportPanel), findsOneWidget);
    expect(find.text('Low Stock Report'), findsWidgets);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.textContaining('No SKU'), findsOneWidget);
    expect(find.textContaining('Uncategorized'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsWidgets);
  });

  testWidgets('low stock report export action copies CSV to clipboard', (
    tester,
  ) async {
    await tester.pumpWidget(_lowStockReportPage());

    await tester.tap(find.byTooltip('Export low stock report'));
    await tester.pumpAndSettle();

    expect(find.textContaining('low-stock-'), findsOneWidget);
    expect(find.textContaining('copied to clipboard (2 rows)'), findsOneWidget);
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

Widget _lowStockReportPage() {
  return MaterialApp(
    home: LowStockReportPage(
      products: [
        Product(
          id: 'p1',
          name: 'Laptop',
          sku: 'LT-001',
          category: 'Electronics',
          price: 100,
        ),
        Product(id: 'p2', name: 'Cable', price: 25),
      ],
      lowStockItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 0,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: 'i2',
          productId: 'p2',
          warehouseId: 'w1',
          currentQuantity: 3,
          reorderPoint: 5,
          reorderQuantity: 4,
        ),
      ],
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
      ],
    ),
  );
}
