import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_worksheet_filter.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/stockopname.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/stockopname_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/stockopname_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_opname_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('stock opname page composes modern count workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnamePage());
    await tester.pumpAndSettle();

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryStockOpnameSummary), findsOneWidget);
    expect(find.byType(InventoryStockOpnameControls), findsOneWidget);
    expect(find.byType(InventoryStockOpnamePanel), findsOneWidget);
    expect(find.text('Stock Opname'), findsWidgets);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Count Worksheet'), findsOneWidget);
  });

  testWidgets('stock opname page uses shared inventory navigation drawer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnamePage());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.stockOpname,
      ),
    );
  });

  testWidgets('stock opname page blocks save until setup is valid', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final stockOpnameNotifier = _SeededStockOpnames(const []);

    await tester.pumpWidget(
      _stockOpnamePage(stockOpnameNotifier: stockOpnameNotifier),
    );
    await tester.pumpAndSettle();

    await _tapCompleteCount(tester);
    await tester.pumpAndSettle();

    expect(stockOpnameNotifier.stockOpnames, isEmpty);
    expect(find.text('Enter who conducted the stock opname.'), findsWidgets);
  });

  testWidgets('stock opname page blocks blank actual count before audit', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final inventoryNotifier = _SeededInventoryItems(_inventoryItems());
    final stockOpnameNotifier = _SeededStockOpnames(const []);

    await tester.pumpWidget(
      _stockOpnamePage(
        inventoryNotifier: inventoryNotifier,
        stockOpnameNotifier: stockOpnameNotifier,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-conducted-by')),
      'Nina',
    );
    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '',
    );
    await _tapCompleteCount(tester);
    await tester.pumpAndSettle();

    expect(stockOpnameNotifier.stockOpnames, isEmpty);
    expect(inventoryNotifier.items.first.currentQuantity, 5);
    expect(find.text('Enter a whole number'), findsWidgets);
    expect(
      find.text('Stock opname completed and inventory updated'),
      findsNothing,
    );
  });

  testWidgets('stock opname page surfaces draft banner review action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnamePage());
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockOpnameDraftStatusBanner), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '',
    );
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockOpnameDraftStatusBanner), findsOneWidget);
    expect(find.text('Fix count input before saving'), findsOneWidget);
    expect(find.text('1 invalid input'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Fix first input'));
    await tester.pumpAndSettle();

    expect(
      find.text('Review the invalid count input before saving'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '7',
    );
    await tester.pumpAndSettle();

    expect(find.text('Unsaved count sheet changes'), findsOneWidget);
    expect(find.text('1 edited line'), findsOneWidget);

    expect(
      find.widgetWithText(TextButton, 'Review first change'),
      findsOneWidget,
    );
  });

  testWidgets('stock opname page filters worksheet rows', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnamePage());
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockOpnameWorksheetToolbar), findsOneWidget);
    expect(find.text('2 of 2 lines'), findsOneWidget);

    await tester.enterText(_worksheetSearchField(), 'Cable');
    await tester.pumpAndSettle();

    expect(_worksheetLineText('Cable'), findsOneWidget);
    expect(_worksheetLineText('Laptop'), findsNothing);
    expect(find.text('1 of 2 lines'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Clear'));
    await tester.pumpAndSettle();

    await tester.tap(_worksheetSortField());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product A-Z').last);
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(_worksheetLineText('Cable')).dy,
      lessThan(tester.getTopLeft(_worksheetLineText('Laptop')).dy),
    );

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '7',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(InventoryStockOpnameWorksheetToolbar),
        matching: find.text('Edited'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_worksheetLineText('Laptop'), findsOneWidget);
    expect(_worksheetLineText('Cable'), findsNothing);
    expect(find.text('1 of 2 lines'), findsOneWidget);
  });

  testWidgets('stock opname page confirms before resetting dirty count sheet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnamePage());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '7',
    );
    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-notes-i1')),
      'Shelf recount',
    );
    await _tapWorksheetResetCount(tester);
    await tester.pumpAndSettle();

    expect(find.text('Reset count sheet?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keep editing'));
    await tester.pumpAndSettle();

    expect(
      _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
      '7',
    );
    expect(
      _editableTextValue(tester, const ValueKey('stock-opname-notes-i1')),
      'Shelf recount',
    );

    await _tapWorksheetResetCount(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reset count'));
    await tester.pumpAndSettle();

    expect(
      _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
      '5',
    );
    expect(
      _editableTextValue(tester, const ValueKey('stock-opname-notes-i1')),
      isEmpty,
    );
    expect(find.text('Count sheet reset to system quantities'), findsOneWidget);
  });

  testWidgets('stock opname page confirms before switching dirty warehouse', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnamePage());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '7',
    );

    await _chooseWarehouse(tester, 'North Warehouse');

    expect(find.text('Switch warehouse?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keep editing'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);

    await _chooseWarehouse(tester, 'North Warehouse');
    await tester.tap(find.widgetWithText(FilledButton, 'Switch warehouse'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsNothing);
    expect(find.text('Cable'), findsNothing);
    expect(find.text('No stock lines to count'), findsOneWidget);
  });

  testWidgets('stock opname page nudges actual counts from worksheet rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnamePage());
    await tester.pumpAndSettle();

    final increaseCount = find.byTooltip('Increase count for Laptop');
    final decreaseCount = find.byTooltip('Decrease count for Laptop');

    await tester.ensureVisible(increaseCount);
    await tester.pumpAndSettle();
    await tester.tap(increaseCount);
    await tester.pumpAndSettle();

    expect(
      _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
      '6',
    );
    expect(find.text('Unsaved count sheet changes'), findsOneWidget);

    await tester.ensureVisible(decreaseCount);
    await tester.pumpAndSettle();
    await tester.tap(decreaseCount);
    await tester.pumpAndSettle();
    await tester.ensureVisible(decreaseCount);
    await tester.pumpAndSettle();
    await tester.tap(decreaseCount);
    await tester.pumpAndSettle();

    expect(
      _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
      '4',
    );

    final matchVisible = find.widgetWithText(OutlinedButton, 'Match visible');
    await tester.ensureVisible(matchVisible);
    await tester.pumpAndSettle();
    await tester.tap(matchVisible);
    await tester.pumpAndSettle();

    expect(
      _editableTextValue(tester, const ValueKey('stock-opname-actual-i1')),
      '5',
    );
    expect(find.text('Unsaved count sheet changes'), findsNothing);
  });

  testWidgets('stock opname page completes count and applies inventory audit', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final inventoryNotifier = _SeededInventoryItems(_inventoryItems());
    final movementNotifier = _SeededMovements(const []);
    final stockOpnameNotifier = _SeededStockOpnames(const []);

    await tester.pumpWidget(
      _stockOpnamePage(
        inventoryNotifier: inventoryNotifier,
        movementNotifier: movementNotifier,
        stockOpnameNotifier: stockOpnameNotifier,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-conducted-by')),
      'Nina',
    );
    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-actual-i1')),
      '7',
    );
    await tester.enterText(
      find.byKey(const ValueKey('stock-opname-notes-i1')),
      'Shelf recount',
    );
    await _tapCompleteCount(tester);
    await tester.pumpAndSettle();

    expect(inventoryNotifier.items.first.currentQuantity, 7);
    expect(stockOpnameNotifier.stockOpnames, hasLength(1));
    expect(
      stockOpnameNotifier.stockOpnames.single.status,
      StockOpnameStatus.completed,
    );
    expect(stockOpnameNotifier.stockOpnames.single.conductedBy, 'Nina');
    expect(movementNotifier.movements, hasLength(1));
    expect(movementNotifier.movements.single.type, MovementType.stockOpname);
    expect(movementNotifier.movements.single.quantity, 2);
    expect(movementNotifier.movements.single.notes, 'Shelf recount');
    expect(
      find.text('Stock opname completed and inventory updated'),
      findsOneWidget,
    );
  });
}

Future<void> _chooseWarehouse(WidgetTester tester, String warehouseName) async {
  await tester.tap(find.byKey(const ValueKey('stock-opname-warehouse-w1')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(warehouseName).last);
  await tester.pumpAndSettle();
}

Future<void> _tapWorksheetResetCount(WidgetTester tester) async {
  final resetButton = find.widgetWithText(OutlinedButton, 'Reset count').last;
  await _scrollToWorksheetFooterAction(tester, resetButton);
  await tester.tap(resetButton);
}

Future<void> _tapCompleteCount(WidgetTester tester) async {
  final completeButton = find.widgetWithText(FilledButton, 'Complete count');
  await _scrollToWorksheetFooterAction(tester, completeButton);
  await tester.tap(completeButton);
}

Future<void> _scrollToWorksheetFooterAction(
  WidgetTester tester,
  Finder action,
) async {
  final pageList = find.byType(ListView);
  expect(pageList, findsOneWidget);

  await tester.drag(pageList, const Offset(0, -900));
  await tester.pumpAndSettle();
  await tester.ensureVisible(action);
  await tester.pumpAndSettle();
}

Finder _worksheetSearchField() {
  return find.descendant(
    of: find.byType(InventoryStockOpnameWorksheetToolbar),
    matching: find.byType(TextField),
  );
}

Finder _worksheetSortField() {
  return find.descendant(
    of: find.byType(InventoryStockOpnameWorksheetToolbar),
    matching: find.byType(AppSelectField<InventoryStockOpnameWorksheetSort>),
  );
}

Finder _worksheetLineText(String text) {
  return find.descendant(
    of: find.byType(InventoryStockOpnameLineTile),
    matching: find.text(text),
  );
}

String _editableTextValue(WidgetTester tester, Key fieldKey) {
  final finder = find.descendant(
    of: find.byKey(fieldKey),
    matching: find.byType(EditableText),
  );
  expect(finder, findsOneWidget);
  return tester.widget<EditableText>(finder).controller.text;
}

Widget _stockOpnamePage({
  _SeededInventoryItems? inventoryNotifier,
  _SeededMovements? movementNotifier,
  _SeededStockOpnames? stockOpnameNotifier,
}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products())),
      warehousesProvider.overrideWith(
        (ref) => _SeededWarehouses(_warehouses()),
      ),
      inventoryItemsProvider.overrideWith(
        (ref) => inventoryNotifier ?? _SeededInventoryItems(_inventoryItems()),
      ),
      inventoryMovementsProvider.overrideWith(
        (ref) => movementNotifier ?? _SeededMovements(const []),
      ),
      stockOpnameProvider.overrideWith(
        (ref) => stockOpnameNotifier ?? _SeededStockOpnames(const []),
      ),
    ],
    child: const MaterialApp(home: StockOpnamePage()),
  );
}

List<Product> _products() {
  return [
    Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
    Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 25),
  ];
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}

List<InventoryItem> _inventoryItems() {
  return [
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
      currentQuantity: 12,
      reorderPoint: 4,
      reorderQuantity: 10,
    ),
  ];
}

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}

class _SeededInventoryItems extends InventoryItemsNotifier {
  _SeededInventoryItems(List<InventoryItem> items) {
    state = items;
  }

  List<InventoryItem> get items => state;
}

class _SeededMovements extends InventoryMovementsNotifier {
  _SeededMovements(List<InventoryMovement> movements) {
    state = movements;
  }

  List<InventoryMovement> get movements => state;
}

class _SeededStockOpnames extends StockOpnameNotifier {
  _SeededStockOpnames(List<StockOpname> stockOpnames) {
    state = stockOpnames;
  }

  List<StockOpname> get stockOpnames => state;
}
