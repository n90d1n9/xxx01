import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/screens/add_edit_product_screen.dart';
import 'package:kaysir/features/product/screens/product_detail_screen.dart';
import 'package:kaysir/features/product/states/product_provider.dart';
import 'package:kaysir/features/product/states/stock_movement_provider.dart';

void main() {
  testWidgets(
    'product detail renders local product data and all movement types',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(920, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_productDetailScreen());
      await tester.pumpAndSettle();

      expect(find.text('Draft Product'), findsOneWidget);
      expect(find.text('Uncategorized'), findsOneWidget);
      expect(find.text('No SKU'), findsOneWidget);
      expect(find.text('No product description yet.'), findsOneWidget);
      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('-2 units'), findsOneWidget);
      expect(find.text('Purchase'), findsOneWidget);
      expect(find.text('+5 units'), findsOneWidget);
    },
  );

  testWidgets('product detail edit action opens the add edit product form', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productDetailScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit product'));
    await tester.pumpAndSettle();

    expect(find.byType(AddEditProductScreen), findsOneWidget);
    expect(find.text('Edit Product'), findsOneWidget);
    expect(find.text('Update product'), findsOneWidget);
  });

  testWidgets('product detail refreshes after editing local product state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productDetailScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit product'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Finished Product');
    await tester.enterText(fields.at(1), 'FP-001');
    await tester.enterText(fields.at(2), 'Managed');
    await tester.enterText(fields.at(3), '15');
    await tester.enterText(fields.at(5), 'Ready for sale');

    await tester.tap(find.widgetWithText(FilledButton, 'Update product'));
    await tester.pumpAndSettle();

    expect(find.byType(AddEditProductScreen), findsNothing);
    expect(find.text('Finished Product'), findsOneWidget);
    expect(find.text('Managed'), findsOneWidget);
    expect(find.text('SKU: FP-001'), findsOneWidget);
    expect(find.text('Ready for sale'), findsOneWidget);
    expect(find.text('\$15.00'), findsOneWidget);
    expect(find.text('Draft Product'), findsNothing);
  });

  testWidgets(
    'product detail stock action updates stock and movement history',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(920, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_productDetailScreen());
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Add Stock'));
      await tester.pumpAndSettle();

      final fields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), '4');
      await tester.enterText(fields.at(1), 'RESTOCK');
      await tester.enterText(fields.at(2), 'Cycle count');
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.widgetWithText(ElevatedButton, 'Add Stock'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('+4 units'), findsOneWidget);
      expect(find.textContaining('RESTOCK'), findsOneWidget);
    },
  );
}

Widget _productDetailScreen() {
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
    child: const MaterialApp(home: ProductDetailScreen(productId: 'p1')),
  );
}

final _products = [
  Product(id: 'p1', name: 'Draft Product', price: 10, currentStock: 3),
];

final _movements = [
  StockMovement(
    id: 'm1',
    productId: 'p1',
    quantity: 2,
    type: MovementType.sale,
    date: DateTime(2026, 6, 2),
    reference: 'SALE',
  ),
  StockMovement(
    id: 'm2',
    productId: 'p1',
    quantity: 5,
    type: MovementType.purchase,
    date: DateTime(2026, 6, 1),
    reference: 'PO',
  ),
];

class _SeededStockMovements extends StockMovementsNotifier {
  _SeededStockMovements(List<StockMovement> movements) {
    state = movements;
  }
}
