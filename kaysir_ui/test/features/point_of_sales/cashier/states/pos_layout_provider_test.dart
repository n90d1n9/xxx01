import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('auto layout resolves by available width', () {
    expect(
      resolvePOSLayoutStrategy(
        preference: POSLayoutPreference.auto,
        width: 500,
      ),
      POSLayoutStrategy.compact,
    );
    expect(
      resolvePOSLayoutStrategy(
        preference: POSLayoutPreference.auto,
        width: 900,
      ),
      POSLayoutStrategy.checkout,
    );
    expect(
      resolvePOSLayoutStrategy(
        preference: POSLayoutPreference.auto,
        width: 1280,
      ),
      POSLayoutStrategy.counter,
    );
  });

  test('explicit layout preference wins over viewport width', () {
    expect(
      resolvePOSLayoutStrategy(
        preference: POSLayoutPreference.counter,
        width: 480,
      ),
      POSLayoutStrategy.counter,
    );
    expect(
      resolvePOSLayoutStrategy(
        preference: POSLayoutPreference.compact,
        width: 1440,
      ),
      POSLayoutStrategy.compact,
    );
    expect(
      resolvePOSLayoutStrategy(
        preference: POSLayoutPreference.checkout,
        width: 1440,
      ),
      POSLayoutStrategy.checkout,
    );
  });

  test('layout strategy registry describes reusable layout contracts', () {
    final checkout = defaultPOSLayoutStrategyRegistry.specForStrategy(
      POSLayoutStrategy.checkout,
    );

    expect(checkout.id, 'checkout');
    expect(checkout.preference, POSLayoutPreference.checkout);
    expect(checkout.autoMinWidth, 720);
    expect(
      checkout.slots,
      containsAll([
        POSLayoutSlot.order,
        POSLayoutSlot.checkout,
        POSLayoutSlot.catalog,
      ]),
    );
    expect(checkout.slotSummary, 'Order + Checkout + Catalog');
    expect(checkout.traits, containsAll(['checkout-first', 'split-pane']));
  });

  test('default layout strategy registry validates cleanly', () {
    expect(defaultPOSLayoutStrategyRegistry.validate(), isEmpty);
    expect(defaultPOSLayoutStrategyRegistry.throwIfInvalid, returnsNormally);
  });

  test('layout strategy registry reports empty strategy catalogs', () {
    final registry = POSLayoutStrategyRegistry(strategies: const []);
    final issues = registry.validate();

    expect(
      issues.single.type,
      POSLayoutStrategyRegistryIssueType.emptyRegistry,
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('layout strategy registry reports invalid metadata', () {
    final registry = POSLayoutStrategyRegistry(
      strategies: const [
        POSLayoutStrategySpec(
          id: ' ',
          strategy: POSLayoutStrategy.compact,
          preference: POSLayoutPreference.compact,
          label: 'Compact',
          description: 'Invalid compact layout.',
          autoMinWidth: 0,
          slots: [],
          traits: ['touch-first', ' '],
        ),
        POSLayoutStrategySpec(
          id: 'dup',
          strategy: POSLayoutStrategy.checkout,
          preference: POSLayoutPreference.checkout,
          label: 'Checkout A',
          description: 'Invalid checkout layout.',
          autoMinWidth: 720,
          slots: [POSLayoutSlot.order],
        ),
        POSLayoutStrategySpec(
          id: 'dup',
          strategy: POSLayoutStrategy.checkout,
          preference: POSLayoutPreference.checkout,
          label: 'Checkout B',
          description: 'Duplicate checkout layout.',
          autoMinWidth: 960,
          slots: [POSLayoutSlot.catalog],
        ),
      ],
    );

    final issueTypes = registry.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSLayoutStrategyRegistryIssueType.blankStrategyId,
        POSLayoutStrategyRegistryIssueType.emptySlots,
        POSLayoutStrategyRegistryIssueType.blankTrait,
        POSLayoutStrategyRegistryIssueType.duplicateStrategyId,
        POSLayoutStrategyRegistryIssueType.duplicateStrategy,
        POSLayoutStrategyRegistryIssueType.duplicatePreference,
      ]),
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('layout strategy registry resolves auto from strategy metadata', () {
    expect(
      defaultPOSLayoutStrategyRegistry
          .resolve(preference: POSLayoutPreference.auto, width: 500)
          .strategy,
      POSLayoutStrategy.compact,
    );
    expect(
      defaultPOSLayoutStrategyRegistry
          .resolve(preference: POSLayoutPreference.auto, width: 900)
          .strategy,
      POSLayoutStrategy.checkout,
    );
    expect(
      defaultPOSLayoutStrategyRegistry
          .resolve(preference: POSLayoutPreference.auto, width: 1280)
          .strategy,
      POSLayoutStrategy.counter,
    );
    expect(defaultPOSLayoutStrategyRegistry.preferenceOptions, [
      POSLayoutPreference.auto,
      POSLayoutPreference.counter,
      POSLayoutPreference.compact,
      POSLayoutPreference.checkout,
    ]);
  });
}
