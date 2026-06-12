import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/screens/scan_product_screen.dart';
import 'package:kaysir/features/product/states/product_provider.dart';

void main() {
  testWidgets('scan product saves count and returns to product stock opname', (
    tester,
  ) async {
    late ProductsNotifier notifier;

    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _scanProductApp(
        onNotifierReady: (nextNotifier) => notifier = nextNotifier,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'p1');
    await tester.enterText(find.byType(TextFormField).at(1), '6');
    await tester.pump();

    expect(find.text('Count preview'), findsOneWidget);
    expect(find.text('Actual 6'), findsOneWidget);
    expect(find.text('Diff +2'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Cycle count');
    await tester.tap(find.widgetWithText(FilledButton, 'Save count'));
    await tester.pumpAndSettle();

    final product = notifier.state.products!.firstWhere(
      (product) => product.id == 'p1',
    );
    expect(product.actualStock, 6);
    expect(product.notes, 'Cycle count');
    expect(find.text('Stock opname route reached'), findsOneWidget);
  });

  testWidgets('scan product resolves barcode and saves the matched product', (
    tester,
  ) async {
    late ProductsNotifier notifier;

    await tester.binding.setSurfaceSize(const Size(1000, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _scanProductApp(
        onNotifierReady: (nextNotifier) => notifier = nextNotifier,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '123456');
    await tester.enterText(find.byType(TextFormField).at(1), '9');
    await tester.tap(find.widgetWithText(FilledButton, 'Save count'));
    await tester.pumpAndSettle();

    final tea = notifier.state.products!.firstWhere(
      (product) => product.id == 'p2',
    );
    expect(tea.actualStock, 9);
    expect(find.text('Stock opname route reached'), findsOneWidget);
  });

  testWidgets('scan product can select a suggestion before saving', (
    tester,
  ) async {
    late ProductsNotifier notifier;

    await tester.binding.setSurfaceSize(const Size(1000, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _scanProductApp(
        onNotifierReady: (nextNotifier) => notifier = nextNotifier,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'snack');
    await tester.pump();
    await tester.tap(find.byTooltip('Select Dates'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), '11');
    await tester.tap(find.widgetWithText(FilledButton, 'Save count'));
    await tester.pumpAndSettle();

    final dates = notifier.state.products!.firstWhere(
      (product) => product.id == 'p3',
    );
    expect(dates.actualStock, 11);
    expect(find.text('Stock opname route reached'), findsOneWidget);
  });

  testWidgets('scan product can start with a route-selected product', (
    tester,
  ) async {
    late ProductsNotifier notifier;

    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _scanProductApp(
        initialLocation: ProductRoutes.scanProductUri(query: 'TE-1'),
        onNotifierReady: (nextNotifier) => notifier = nextNotifier,
      ),
    );

    expect(find.text('Tea'), findsWidgets);

    await tester.enterText(find.byType(TextFormField).at(1), '10');
    await tester.tap(find.widgetWithText(FilledButton, 'Save count'));
    await tester.pumpAndSettle();

    final tea = notifier.state.products!.firstWhere(
      (product) => product.id == 'p2',
    );
    expect(tea.actualStock, 10);
    expect(find.text('Stock opname route reached'), findsOneWidget);
  });

  testWidgets('scan product can return to discrepancy review after saving', (
    tester,
  ) async {
    late ProductsNotifier notifier;

    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _scanProductApp(
        initialLocation: ProductRoutes.scanProductUri(
          query: 'TE-1',
          returnTarget: ProductScanReturnTarget.discrepancyReport,
        ),
        onNotifierReady: (nextNotifier) => notifier = nextNotifier,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(1), '12');
    await tester.tap(find.widgetWithText(FilledButton, 'Save count'));
    await tester.pumpAndSettle();

    final tea = notifier.state.products!.firstWhere(
      (product) => product.id == 'p2',
    );
    expect(tea.actualStock, 12);
    expect(find.text('Discrepancy report route reached'), findsOneWidget);
  });
}

Widget _scanProductApp({
  String initialLocation = ProductRoutes.scanProductPath,
  required ValueChanged<ProductsNotifier> onNotifierReady,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: ProductRoutes.scanProductPath,
        builder:
            (context, state) => ScanProductScreen(
              initialQuery:
                  state.uri.queryParameters[ProductRoutes
                      .scanProductQueryKey] ??
                  '',
              returnTarget: productScanReturnTargetFromQuery(
                state.uri.queryParameters[ProductRoutes
                    .scanProductReturnTargetQueryKey],
              ),
            ),
      ),
      GoRoute(
        path: ProductRoutes.stockOpnamePath,
        builder: (context, state) => const Text('Stock opname route reached'),
      ),
      GoRoute(
        path: ProductRoutes.discrepancyReportPath,
        builder:
            (context, state) => const Text('Discrepancy report route reached'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) {
        final notifier = ProductsNotifier(
          ref,
          initialProducts: [
            Product(
              id: 'p1',
              name: 'Coffee',
              sku: 'CF-1',
              category: 'Beverage',
              systemStock: 4,
            ),
            Product(
              id: 'p2',
              name: 'Tea',
              sku: 'TE-1',
              barcode: '123456',
              category: 'Beverage',
              systemStock: 4,
            ),
            Product(
              id: 'p3',
              name: 'Dates',
              sku: 'DT-1',
              category: 'Snack',
              systemStock: 2,
            ),
          ],
          loadOnStart: false,
        );
        onNotifierReady(notifier);
        return notifier;
      }),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}
