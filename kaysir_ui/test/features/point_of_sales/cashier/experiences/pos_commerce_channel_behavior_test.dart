import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channel_behaviors.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';

void main() {
  test('default behavior registry covers every built-in channel', () {
    final registry = defaultPOSCommerceChannelBehaviorRegistry;

    expect(
      registry.validate(
        commerceChannelRegistry: defaultPOSCommerceChannelRegistry,
      ),
      isEmpty,
    );
    expect(
      registry.channelIds,
      unorderedEquals(defaultPOSCommerceChannelRegistry.channelIds),
    );
    expect(
      registry.isValid(
        commerceChannelRegistry: defaultPOSCommerceChannelRegistry,
      ),
      isTrue,
    );
    expect(
      () => registry.throwIfInvalid(
        commerceChannelRegistry: defaultPOSCommerceChannelRegistry,
      ),
      returnsNormally,
    );
  });

  test('behavior profiles describe channel-specific modules and traits', () {
    final registry = defaultPOSCommerceChannelBehaviorRegistry;
    final deliveryApp = registry.profileForChannel('delivery_app');

    expect(
      deliveryApp.supportsModule(
        POSCommerceChannelBehaviorModules.deliveryAggregator,
      ),
      isTrue,
    );
    expect(
      deliveryApp.supportsModule(
        POSCommerceChannelBehaviorModules.deliveryFulfillment,
      ),
      isTrue,
    );
    expect(deliveryApp.hasTrait('courier'), isTrue);
    expect(deliveryApp.searchTerms, contains('delivery_aggregator'));
    expect(
      registry.modulesForChannel('delivery_app'),
      contains(POSCommerceChannelBehaviorModules.inventoryReservation),
    );
  });

  test('registry can discover reusable behavior module adoption', () {
    final registry = defaultPOSCommerceChannelBehaviorRegistry;

    expect(
      registry.channelIdsForModule(
        POSCommerceChannelBehaviorModules.inventoryReservation,
      ),
      containsAll(['web_store', 'delivery_app', 'field_sales', 'wholesale']),
    );
    expect(
      registry
          .profilesForModuleId('pickup_queue')
          .map((profile) => profile.channelId),
      containsAll(['kiosk', 'web_store', 'phone_order']),
    );
  });

  test('behavior registry reports invalid profiles and modules', () {
    const invalidModule = POSCommerceChannelBehaviorModule(
      id: ' ',
      label: ' ',
      description: 'Invalid behavior module.',
      area: POSCommerceChannelBehaviorArea.orderCapture,
      traits: [' '],
    );
    final registry = POSCommerceChannelBehaviorRegistry(
      profiles: [
        POSCommerceChannelBehaviorProfile(channelId: ' ', modules: const []),
        POSCommerceChannelBehaviorProfile(
          channelId: 'duplicate',
          modules: const [
            POSCommerceChannelBehaviorModules.counterCheckout,
            POSCommerceChannelBehaviorModules.counterCheckout,
          ],
          traits: const [' '],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'duplicate',
          modules: const [invalidModule],
        ),
      ],
    );

    final issueTypes = registry.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSCommerceChannelBehaviorRegistryIssueType.blankChannelId,
        POSCommerceChannelBehaviorRegistryIssueType.duplicateChannelId,
        POSCommerceChannelBehaviorRegistryIssueType.emptyModules,
        POSCommerceChannelBehaviorRegistryIssueType.blankModuleId,
        POSCommerceChannelBehaviorRegistryIssueType.blankModuleLabel,
        POSCommerceChannelBehaviorRegistryIssueType.duplicateModuleId,
        POSCommerceChannelBehaviorRegistryIssueType.blankTrait,
      ]),
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('behavior registry validates coverage against a channel registry', () {
    final webStore = defaultPOSCommerceChannelRegistry.channelForId(
      'web_store',
    );
    final channelRegistry = POSCommerceChannelRegistry(
      defaultChannelId: webStore.id,
      channels: [webStore],
    );
    final behaviorRegistry = POSCommerceChannelBehaviorRegistry(
      profiles: [
        POSCommerceChannelBehaviorProfile(
          channelId: 'in_store',
          modules: const [POSCommerceChannelBehaviorModules.counterCheckout],
        ),
      ],
    );

    final issues = behaviorRegistry.validate(
      commerceChannelRegistry: channelRegistry,
    );

    expect(
      issues.map((issue) => issue.type),
      contains(
        POSCommerceChannelBehaviorRegistryIssueType.missingChannelBehavior,
      ),
    );
    expect(issues.single.channelId, 'web_store');
  });
}
