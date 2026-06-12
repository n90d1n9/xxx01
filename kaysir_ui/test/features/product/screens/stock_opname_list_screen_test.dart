import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/screens/stock_opname_list_screen.dart';
import 'package:kaysir/features/product/states/product_provider.dart';

void main() {
  testWidgets('stock opname list uses product module routes safely', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnameApp());

    expect(find.text('Stock Opname'), findsOneWidget);
    expect(find.text('Stock Count Board'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Matched'), findsOneWidget);
    expect(find.text('+3'), findsOneWidget);

    await tester.tap(find.byTooltip('Scan product'));
    await tester.pumpAndSettle();

    expect(find.text('Scan route reached'), findsOneWidget);
  });

  testWidgets('stock opname board searches and filters product counts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnameApp());

    await tester.enterText(find.byType(TextField), 'tea');
    await tester.pump();

    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Coffee'), findsNothing);
    expect(find.text('Dates'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Variance'));
    await tester.pump();

    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Coffee'), findsNothing);
    expect(find.text('Dates'), findsNothing);
  });

  testWidgets('stock opname board opens product catalog route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnameApp());

    await tester.tap(find.byTooltip('Open Coffee'));
    await tester.pumpAndSettle();

    expect(find.text('Catalog route reached'), findsOneWidget);
  });

  testWidgets('stock opname board opens count capture for a product', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_stockOpnameApp());

    await tester.tap(find.byTooltip('Capture count for Coffee'));
    await tester.pumpAndSettle();

    expect(find.text('Scan route reached'), findsOneWidget);
    expect(find.text('p1'), findsOneWidget);
  });
}

Widget _stockOpnameApp() {
  final router = GoRouter(
    initialLocation: ProductRoutes.stockOpnamePath,
    routes: [
      GoRoute(
        path: ProductRoutes.stockOpnamePath,
        builder: (context, state) => const StockOpnameListScreen(),
      ),
      GoRoute(
        path: ProductRoutes.scanProductPath,
        builder:
            (context, state) => Column(
              children: [
                const Text('Scan route reached'),
                Text(
                  state.uri.queryParameters[ProductRoutes
                          .scanProductQueryKey] ??
                      '',
                ),
              ],
            ),
      ),
      GoRoute(
        path: ProductRoutes.discrepancyReportPath,
        builder: (context, state) => const Text('Report route reached'),
      ),
      GoRoute(
        path: ProductRoutes.catalogPath,
        builder: (context, state) => const Text('Catalog route reached'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      productsProvider.overrideWith(
        (ref) => ProductsNotifier(
          ref,
          initialProducts: [
            Product(id: 'p1', name: 'Coffee', sku: 'CF-1', systemStock: 4),
            Product(
              id: 'p2',
              name: 'Tea',
              sku: 'TE-1',
              actualStock: 7,
              systemStock: 4,
            ),
            Product(
              id: 'p3',
              name: 'Dates',
              sku: 'DT-1',
              actualStock: 5,
              systemStock: 5,
            ),
          ],
          loadOnStart: false,
        ),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}
