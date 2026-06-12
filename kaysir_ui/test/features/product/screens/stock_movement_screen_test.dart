import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/screens/stock_movement_screen.dart';
import 'package:kaysir/features/product/states/product_provider.dart';
import 'package:kaysir/features/product/states/stock_movement_provider.dart';

void main() {
  testWidgets('stock movements render every movement type without crashing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockMovementsScreen());

    expect(find.text('Stock Movement Ledger'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Coffee'), findsWidgets);

    for (final type in MovementType.values) {
      expect(find.text(_movementTypeLabel(type)), findsAtLeastNWidgets(1));
    }
  });

  testWidgets('stock movements can search and filter ledger rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockMovementsScreen());

    await tester.enterText(find.byType(TextField), 'sku-2');
    await tester.pump();

    expect(find.text('Tea'), findsWidgets);
    expect(find.text('Coffee'), findsNothing);

    await tester.tap(find.text('All movement types'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sale').last);
    await tester.pumpAndSettle();

    expect(find.text('Sale'), findsAtLeastNWidgets(1));
    expect(find.text('No stock movements match this view'), findsNothing);
  });
}

Widget _stockMovementsScreen() {
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
        (ref) => _SeededStockMovements(_movements),
      ),
    ],
    child: const MaterialApp(home: StockMovementsScreen()),
  );
}

final _products = [
  Product(id: 'p1', name: 'Coffee', sku: 'SKU-1', category: 'Beverage'),
  Product(id: 'p2', name: 'Tea', sku: 'SKU-2', category: 'Beverage'),
];

final _movements = [
  for (final type in MovementType.values)
    StockMovement(
      id: type.name,
      productId: type == MovementType.sale ? 'p2' : 'p1',
      quantity: 3,
      type: type,
      date: DateTime(2026, 6, 2).add(Duration(minutes: type.index)),
      reference: type == MovementType.sale ? 'SALE-1' : 'REF-${type.name}',
    ),
];

String _movementTypeLabel(MovementType type) {
  switch (type) {
    case MovementType.receipt:
      return 'Receipt';
    case MovementType.issue:
      return 'Issue';
    case MovementType.transfer:
      return 'Transfer';
    case MovementType.adjustment:
      return 'Adjustment';
    case MovementType.stockOpname:
      return 'Stock opname';
    case MovementType.purchase:
      return 'Purchase';
    case MovementType.sale:
      return 'Sale';
    case MovementType.inbound:
      return 'Inbound';
    case MovementType.outbound:
      return 'Outbound';
  }
}

class _SeededStockMovements extends StockMovementsNotifier {
  _SeededStockMovements(List<StockMovement> movements) {
    state = movements;
  }
}
