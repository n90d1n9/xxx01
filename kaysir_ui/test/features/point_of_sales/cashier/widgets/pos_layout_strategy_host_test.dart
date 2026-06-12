import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_catalog_panel.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_slots.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_host.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layouts.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_sidebar.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('default layout renderer registry covers registered strategies', () {
    expect(defaultPOSLayoutStrategyRendererRegistry.missingStrategies, isEmpty);
    expect(defaultPOSLayoutStrategyRendererRegistry.validate(), isEmpty);
    expect(
      defaultPOSLayoutStrategyRendererRegistry.throwIfInvalid,
      returnsNormally,
    );

    expect(_buildDefault(POSLayoutStrategy.counter), isA<POSCounterLayout>());
    expect(_buildDefault(POSLayoutStrategy.compact), isA<POSCompactLayout>());
    expect(_buildDefault(POSLayoutStrategy.checkout), isA<POSCheckoutLayout>());
  });

  test('layout renderer registry reports missing strategy renderers', () {
    final registry = POSLayoutStrategyRendererRegistry(renderers: const []);

    expect(
      registry.missingStrategies,
      containsAll([
        POSLayoutStrategy.counter,
        POSLayoutStrategy.compact,
        POSLayoutStrategy.checkout,
      ]),
    );
    expect(
      () => registry.rendererFor(POSLayoutStrategy.counter),
      throwsStateError,
    );
    expect(
      registry.validate().map((issue) => issue.type),
      contains(POSLayoutStrategyRendererRegistryIssueType.missingRenderer),
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('layout renderer registry reports invalid renderer wiring', () {
    final registry = POSLayoutStrategyRendererRegistry(
      strategyRegistry: _compactAndCheckoutStrategies,
      renderers: const [
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.compact,
          builder: _fakeBuilder,
        ),
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.compact,
          builder: _fakeBuilder,
        ),
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.counter,
          builder: _fakeBuilder,
        ),
      ],
    );

    final issueTypes = registry.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSLayoutStrategyRendererRegistryIssueType.missingRenderer,
        POSLayoutStrategyRendererRegistryIssueType.duplicateRenderer,
        POSLayoutStrategyRendererRegistryIssueType.unknownStrategy,
      ]),
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('layout slot content builds reusable catalog and order surfaces', () {
    final slots = POSLayoutSlotContent(itemCount: 3, onProductSelected: (_) {});

    final catalog = slots.catalog(dense: true) as POSCatalogPanel;
    expect(catalog, isA<POSCatalogPanel>());
    expect(catalog.dense, isTrue);

    final order = slots.order(compact: true, edgeToEdge: true) as OrderSidebar;
    expect(order, isA<OrderSidebar>());
    expect(order.compact, isTrue);
    expect(order.edgeToEdge, isTrue);

    final catalogTab = slots.tabFor(POSLayoutSlot.catalog);
    expect(catalogTab.text, 'Products');

    final orderTab = slots.tabFor(POSLayoutSlot.order);
    expect(orderTab.text, 'Order');
  });

  testWidgets('layout strategy host delegates to registered renderer', (
    tester,
  ) async {
    Product? selectedProduct;
    final product = Product(id: 'coffee', name: 'Coffee', price: 30000);
    final registry = POSLayoutStrategyRendererRegistry(
      renderers: [
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.checkout,
          builder:
              (scope) => TextButton(
                onPressed: () => scope.onProductSelected(product),
                child: Text(
                  '${scope.spec.id}:${scope.itemCount}:${scope.slots.itemCount}',
                ),
              ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSLayoutStrategyHost(
            strategy: POSLayoutStrategy.checkout,
            itemCount: 7,
            onProductSelected: (product) => selectedProduct = product,
            registry: registry,
          ),
        ),
      ),
    );

    expect(find.text('checkout:7:7'), findsOneWidget);

    await tester.tap(find.text('checkout:7:7'));
    await tester.pumpAndSettle();

    expect(selectedProduct, product);
  });

  testWidgets('layout strategy host delegates to registered pack', (
    tester,
  ) async {
    final pack = POSLayoutStrategyPack.withRenderers(
      strategyRegistry: _packCheckoutStrategy,
      renderers: [
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.checkout,
          builder: (scope) => Text('${scope.spec.id}:${scope.itemCount}'),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSLayoutStrategyHost(
            strategy: POSLayoutStrategy.checkout,
            itemCount: 5,
            onProductSelected: (_) {},
            pack: pack,
          ),
        ),
      ),
    );

    expect(find.text('pack_checkout:5'), findsOneWidget);
  });
}

Widget _buildDefault(POSLayoutStrategy strategy) {
  final spec = defaultPOSLayoutStrategyRegistry.specForStrategy(strategy);
  return defaultPOSLayoutStrategyRendererRegistry
      .rendererFor(strategy)
      .build(
        POSLayoutStrategyBuildScope(
          spec: spec,
          itemCount: 1,
          onProductSelected: (_) {},
        ),
      );
}

const _compactAndCheckoutStrategies = POSLayoutStrategyRegistry(
  strategies: [
    POSLayoutStrategySpec(
      id: 'compact',
      strategy: POSLayoutStrategy.compact,
      preference: POSLayoutPreference.compact,
      label: 'Compact',
      description: 'Compact test layout.',
      autoMinWidth: 0,
      slots: [POSLayoutSlot.catalog],
    ),
    POSLayoutStrategySpec(
      id: 'checkout',
      strategy: POSLayoutStrategy.checkout,
      preference: POSLayoutPreference.checkout,
      label: 'Checkout',
      description: 'Checkout test layout.',
      autoMinWidth: 720,
      slots: [POSLayoutSlot.order],
    ),
  ],
);

const _packCheckoutStrategy = POSLayoutStrategyRegistry(
  strategies: [
    POSLayoutStrategySpec(
      id: 'pack_checkout',
      strategy: POSLayoutStrategy.checkout,
      preference: POSLayoutPreference.checkout,
      label: 'Pack Checkout',
      description: 'Pack-backed checkout layout.',
      autoMinWidth: 0,
      slots: [POSLayoutSlot.checkout],
    ),
  ],
);

Widget _fakeBuilder(POSLayoutStrategyBuildScope scope) {
  return const SizedBox.shrink();
}
