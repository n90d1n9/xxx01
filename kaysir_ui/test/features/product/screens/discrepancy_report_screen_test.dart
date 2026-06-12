import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/screens/discrepancey_report_screen.dart';
import 'package:kaysir/features/product/states/product_provider.dart';

void main() {
  testWidgets('discrepancy report renders pending and variance review items', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_discrepancyReportApp());

    expect(find.text('Discrepancy Report'), findsOneWidget);
    expect(find.text('Variance Review'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('+3'), findsOneWidget);
    expect(find.text('Dates'), findsNothing);
  });

  testWidgets('discrepancy report searches and opens catalog route', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_discrepancyReportApp());

    await tester.enterText(find.byType(TextField), 'tea');
    await tester.pump();

    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Coffee'), findsNothing);

    await tester.tap(find.byTooltip('Open Tea'));
    await tester.pumpAndSettle();

    expect(find.text('Catalog route reached'), findsOneWidget);
  });

  testWidgets('discrepancy report opens the count queue route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_discrepancyReportApp());

    await tester.tap(find.byTooltip('Open count queue'));
    await tester.pumpAndSettle();

    expect(find.text('Stock opname route reached'), findsOneWidget);
  });

  testWidgets('discrepancy report opens count capture for a review item', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_discrepancyReportApp());

    await tester.tap(find.byTooltip('Capture count for Tea'));
    await tester.pumpAndSettle();

    expect(find.text('Scan route reached'), findsOneWidget);
    expect(find.text('p2'), findsOneWidget);
    expect(find.text('discrepancy_report'), findsOneWidget);
  });
}

Widget _discrepancyReportApp() {
  final router = GoRouter(
    initialLocation: ProductRoutes.discrepancyReportPath,
    routes: [
      GoRoute(
        path: ProductRoutes.discrepancyReportPath,
        builder: (context, state) => const DiscrepancyReportScreen(),
      ),
      GoRoute(
        path: ProductRoutes.catalogPath,
        builder: (context, state) => const Text('Catalog route reached'),
      ),
      GoRoute(
        path: ProductRoutes.stockOpnamePath,
        builder: (context, state) => const Text('Stock opname route reached'),
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
                Text(
                  state.uri.queryParameters[ProductRoutes
                          .scanProductReturnTargetQueryKey] ??
                      '',
                ),
              ],
            ),
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
