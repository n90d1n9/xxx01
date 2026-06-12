import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/inventory_valuation_screen.dart';
import 'package:kaysir/features/inventory/widgets/inventory_valuation_report_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  setUp(_mockClipboard);
  tearDown(_clearClipboardMock);

  testWidgets('valuation report page composes modern valuation workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_valuationPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryValuationSummaryGrid), findsOneWidget);
    expect(find.byType(InventoryValuationPanel), findsOneWidget);
    expect(find.text('Inventory Valuation Report'), findsWidgets);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.textContaining('No SKU'), findsOneWidget);
    expect(find.textContaining('Uncategorized'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsWidgets);
    expect(find.text(r'$500.00'), findsOneWidget);
  });

  testWidgets('valuation report export action copies CSV to clipboard', (
    tester,
  ) async {
    await tester.pumpWidget(_valuationPage());

    await tester.tap(find.byTooltip('Export valuation report'));
    await tester.pumpAndSettle();

    expect(find.textContaining('inventory-valuation-'), findsOneWidget);
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

Widget _valuationPage() {
  return MaterialApp(
    home: InventoryValuationReportPage(
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
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
      ],
      inventoryItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 5,
          reorderPoint: 2,
          reorderQuantity: 8,
        ),
        InventoryItem(
          id: 'i2',
          productId: 'p2',
          warehouseId: 'w1',
          currentQuantity: 2,
          reorderPoint: 1,
          reorderQuantity: 4,
        ),
      ],
    ),
  );
}
