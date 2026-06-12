import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_host.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack_provider.dart';

void main() {
  test('default layout strategy pack validates cleanly', () {
    final validation = defaultPOSLayoutStrategyPack.validate();

    expect(validation.isValid, isTrue);
    expect(validation.issueCount, 0);
    expect(defaultPOSLayoutStrategyPack.throwIfInvalid, returnsNormally);
    expect(
      defaultPOSLayoutStrategyPack
          .resolve(preference: POSLayoutPreference.auto, width: 1280)
          .strategy,
      POSLayoutStrategy.counter,
    );
  });

  test('layout strategy pack validates renderers against pack strategies', () {
    final pack = POSLayoutStrategyPack(
      strategyRegistry: _checkoutOnlyStrategies,
      rendererRegistry: POSLayoutStrategyRendererRegistry(
        renderers: const [
          POSLayoutStrategyRenderer(
            strategy: POSLayoutStrategy.compact,
            builder: _fakeBuilder,
          ),
        ],
      ),
    );

    final validation = pack.validate();
    final rendererIssueTypes = validation.rendererIssues.map(
      (issue) => issue.type,
    );

    expect(validation.isValid, isFalse);
    expect(
      rendererIssueTypes,
      containsAll([
        POSLayoutStrategyRendererRegistryIssueType.missingRenderer,
        POSLayoutStrategyRendererRegistryIssueType.unknownStrategy,
      ]),
    );
    expect(pack.throwIfInvalid, throwsStateError);
  });

  test('layout strategy pack builds renderers with pack-local specs', () {
    final pack = POSLayoutStrategyPack(
      strategyRegistry: _checkoutOnlyStrategies,
      rendererRegistry: POSLayoutStrategyRendererRegistry(
        renderers: const [
          POSLayoutStrategyRenderer(
            strategy: POSLayoutStrategy.checkout,
            builder: _specIdBuilder,
          ),
        ],
      ),
    );

    final widget = pack.build(
      strategy: POSLayoutStrategy.checkout,
      itemCount: 1,
      onProductSelected: (_) {},
    );

    expect(widget, isA<Text>());
    expect((widget as Text).data, 'custom_checkout');
  });

  test('layout strategy pack provider can be overridden by products', () {
    final pack = POSLayoutStrategyPack.withRenderers(
      strategyRegistry: _checkoutOnlyStrategies,
      renderers: const [
        POSLayoutStrategyRenderer(
          strategy: POSLayoutStrategy.checkout,
          builder: _specIdBuilder,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [posLayoutStrategyPackProvider.overrideWithValue(pack)],
    );
    addTearDown(container.dispose);

    expect(container.read(posLayoutStrategyPackProvider), same(pack));
    expect(
      container.read(posLayoutStrategyPackValidationProvider).isValid,
      isTrue,
    );
    expect(
      container
          .read(posLayoutStrategyPackProvider)
          .resolve(preference: POSLayoutPreference.auto, width: 480)
          .strategy,
      POSLayoutStrategy.checkout,
    );
  });
}

const _checkoutOnlyStrategies = POSLayoutStrategyRegistry(
  strategies: [
    POSLayoutStrategySpec(
      id: 'custom_checkout',
      strategy: POSLayoutStrategy.checkout,
      preference: POSLayoutPreference.checkout,
      label: 'Custom Checkout',
      description: 'Product-specific checkout layout.',
      autoMinWidth: 0,
      slots: [POSLayoutSlot.checkout],
    ),
  ],
);

Widget _fakeBuilder(POSLayoutStrategyBuildScope scope) {
  return const SizedBox.shrink();
}

Widget _specIdBuilder(POSLayoutStrategyBuildScope scope) {
  return Text(scope.spec.id);
}
