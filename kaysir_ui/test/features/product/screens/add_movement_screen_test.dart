import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/screens/add_movement_screen.dart';
import 'package:kaysir/features/product/states/product_provider.dart';
import 'package:kaysir/features/product/states/stock_movement_provider.dart';

void main() {
  testWidgets('add stock movement screen searches product actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_addStockMovementScreen());

    expect(find.text('Stock Action Picker'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Tea'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tea-1');
    await tester.pump();

    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Coffee'), findsNothing);
  });

  testWidgets('add stock movement screen records stock through dialog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_addStockMovementScreen());

    await tester.tap(find.byTooltip('Add stock for Tea'));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), 'RESTOCK-TEA');
    await tester.enterText(fields.at(2), 'Morning count');
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(ElevatedButton, 'Add Stock'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('6 units'), findsOneWidget);
  });
}

Widget _addStockMovementScreen() {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith(
        (ref) => ProductsNotifier(
          ref,
          initialProducts: _products,
          loadOnStart: false,
        ),
      ),
      stockMovementsProvider.overrideWith(
        (ref) => _SeededStockMovements(const []),
      ),
    ],
    child: const MaterialApp(home: AddStockMovementScreen()),
  );
}

final _products = [
  Product(
    id: 'coffee',
    name: 'Coffee',
    sku: 'COF-1',
    category: 'Beverage',
    currentStock: 8,
  ),
  Product(
    id: 'tea',
    name: 'Tea',
    sku: 'TEA-1',
    category: 'Beverage',
    currentStock: 0,
  ),
];

class _SeededStockMovements extends StockMovementsNotifier {
  _SeededStockMovements(List<StockMovement> movements) {
    state = movements;
  }
}
