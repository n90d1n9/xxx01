import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/screens/add_edit_product_screen.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/product_provider.dart';
import 'package:kaysir/features/product/states/stock_movement_provider.dart';

void main() {
  testWidgets('add edit product screen saves active pack fields', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AddEditProductScreen()),
      ),
    );

    expect(find.text('Product setup sections'), findsOneWidget);
    expect(find.text('Identity'), findsWidgets);
    expect(find.text('Commercial'), findsWidgets);
    expect(find.text('Pack extensions'), findsWidgets);
    expect(find.text('13 fields'), findsOneWidget);
    expect(find.text('8 required fields'), findsOneWidget);
    expect(find.text('8 required missing'), findsWidgets);
    expect(find.text('Required field guide'), findsOneWidget);
    expect(find.text('Next required field'), findsOneWidget);
    expect(find.text('Product Name'), findsWidgets);
    expect(find.text('Product still needs required data'), findsOneWidget);
    expect(
      find.text('Complete Product Name in Identity before saving.'),
      findsOneWidget,
    );
    expect(find.text('Review Product Name'), findsNWidgets(3));
    expect(find.text('0/8 ready'), findsNWidgets(2));
    expect(find.text('Grocery Fresh Goods data'), findsOneWidget);
    expect(find.text('6 groups'), findsOneWidget);
    expect(find.text('Scan readiness'), findsWidgets);
    expect(find.text('Freshness queue'), findsWidgets);
    expect(find.text('1 missing required'), findsWidgets);
    expect(find.text('0/1 required'), findsWidgets);
    expect(find.text('Review Expiry date'), findsNWidgets(2));
    expect(find.text('Review Batch number'), findsNWidgets(2));
    expect(find.text('Expiry date'), findsOneWidget);
    expect(find.text('Batch number'), findsOneWidget);
    expect(find.byTooltip('Show Scan readiness fields'), findsOneWidget);
    expect(find.byTooltip('Show Stock tracking fields'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Spinach');
    await tester.enterText(fields.at(1), 'SP-001');
    await tester.enterText(fields.at(2), 'Fresh');
    await tester.enterText(fields.at(3), '12');
    await tester.enterText(fields.at(4), '8');
    await tester.enterText(fields.at(5), 'Leafy greens');

    await _showGroup(tester, 'Scan readiness');
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-barcode')),
      '8990001',
    );
    await _showGroup(tester, 'Stock tracking');
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-unit')),
      'kg',
    );
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-expiry_date')),
      '2026-07-01',
    );
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-batch_number')),
      'B-01',
    );
    await tester.pump();
    expect(find.text('Ready to save'), findsOneWidget);
    expect(find.text('Required field guide'), findsNothing);
    expect(find.text('Ready to add product'), findsOneWidget);
    expect(find.text('All required product data is complete.'), findsOneWidget);
    expect(find.text('1/1 required'), findsWidgets);
    await _showGroup(tester, 'Weighted inventory');
    final weightedUnitField = find.byKey(
      const ValueKey('product-pack-field-weighted_unit'),
    );
    await tester.ensureVisible(weightedUnitField);
    await tester.pumpAndSettle();
    await tester.tap(weightedUnitField);
    await tester.pump();
    await _showGroup(tester, 'Freshness queue');
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-shelf_life_days')),
      '5',
    );
    final freshnessStatusField = find.byKey(
      const ValueKey('product-pack-field-freshness_status'),
    );
    await tester.ensureVisible(freshnessStatusField);
    await tester.pumpAndSettle();
    await tester.tap(freshnessStatusField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monitor').last);
    await tester.pumpAndSettle();

    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    final product = container.read(productsProvider).products!.single;
    expect(product.name, 'Spinach');
    expect(product.barcode, '8990001');
    expect(product.unit, 'kg');
    expect(product.customAttributes, {
      'expiry_date': '2026-07-01',
      'batch_number': 'B-01',
      'weighted_unit': 'true',
      'shelf_life_days': '5',
      'freshness_status': 'Monitor',
    });
    expect(container.read(stockMovementsProvider).single.quantity, 8);
  });

  testWidgets('add edit product screen validates required pack fields', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AddEditProductScreen()),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Spinach');
    await tester.enterText(fields.at(1), 'SP-001');
    await tester.enterText(fields.at(2), 'Fresh');
    await tester.enterText(fields.at(3), '12');
    await tester.enterText(fields.at(4), '8');
    await tester.enterText(fields.at(5), 'Leafy greens');

    await _tapSubmit(tester);
    await tester.pump();

    expect(find.text('Please enter expiry date'), findsOneWidget);
    expect(find.text('Please enter batch number'), findsOneWidget);
    expect(container.read(productsProvider).products, isEmpty);
  });

  testWidgets('add edit product screen blocks invalid pack readiness', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = _container();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AddEditProductScreen()),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Spinach');
    await tester.enterText(fields.at(1), 'SP-001');
    await tester.enterText(fields.at(2), 'Fresh');
    await tester.enterText(fields.at(3), '12');
    await tester.enterText(fields.at(4), '8');
    await tester.enterText(fields.at(5), 'Leafy greens');
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-expiry_date')),
      'soon',
    );
    await tester.enterText(
      find.byKey(const ValueKey('product-pack-field-batch_number')),
      'B-01',
    );
    await tester.pump();

    expect(find.text('Review product data'), findsOneWidget);
    expect(
      find.text('Fix Expiry date in Pack extensions before saving.'),
      findsOneWidget,
    );
    expect(find.text('Needs review'), findsWidgets);
    expect(find.text('Review Expiry date'), findsWidgets);
    expect(find.text('Ready to add product'), findsNothing);

    await _tapSubmit(tester);
    await tester.pump();

    expect(find.text('Please enter a valid expiry date'), findsOneWidget);
    expect(container.read(productsProvider).products, isEmpty);
  });

  testWidgets(
    'add edit product screen opens optional pack groups from guidance',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(920, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _container();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AddEditProductScreen()),
        ),
      );

      expect(find.text('Shelf life'), findsNothing);
      expect(find.byTooltip('Show Freshness queue fields'), findsOneWidget);

      final freshnessQueueRow = find.text('Freshness queue').first;
      await tester.ensureVisible(freshnessQueueRow);
      await tester.pumpAndSettle();
      await tester.tap(freshnessQueueRow);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Hide Freshness queue fields'), findsOneWidget);
      expect(find.text('Shelf life'), findsOneWidget);
      expect(find.text('Freshness status'), findsOneWidget);
    },
  );
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final submitButton = find.widgetWithText(FilledButton, 'Add product');
  await tester.drag(
    find.byKey(const ValueKey('product-form-scroll-view')),
    const Offset(0, -1800),
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(submitButton);
  await tester.pumpAndSettle();
  await tester.tap(submitButton);
}

Future<void> _showGroup(WidgetTester tester, String groupTitle) async {
  final showButton = find.byTooltip('Show $groupTitle fields');
  if (showButton.evaluate().isEmpty) return;

  await tester.ensureVisible(showButton);
  await tester.pumpAndSettle();
  await tester.tap(showButton);
  await tester.pumpAndSettle();
}

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [
      productsProvider.overrideWith(
        (ref) => ProductsNotifier(
          ref,
          initialProducts: const [],
          loadOnStart: false,
        ),
      ),
      stockMovementsProvider.overrideWith((ref) => _EmptyStockMovements()),
      productManagementPacksProvider.overrideWithValue([
        coreProductManagementPack,
        groceryFreshGoodsProductManagementPack,
      ]),
      _memoryPreferencesRepositoryOverride(),
    ],
  );

  container
      .read(productManagementPackIdProvider.notifier)
      .selectPack(ProductManagementPackId.groceryFreshGoods);

  return container;
}

dynamic _memoryPreferencesRepositoryOverride() {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
  );
}

class _EmptyStockMovements extends StockMovementsNotifier {
  _EmptyStockMovements() {
    state = const <StockMovement>[];
  }
}
