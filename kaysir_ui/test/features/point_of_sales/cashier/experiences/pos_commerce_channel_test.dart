import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('default commerce channel registry exposes omni-channel contracts', () {
    final registry = defaultPOSCommerceChannelRegistry;

    expect(registry.validate(), isEmpty);
    expect(registry.throwIfInvalid, returnsNormally);
    expect(registry.defaultChannel.id, 'in_store');
    expect(
      registry.channelIds,
      containsAll([
        'in_store',
        'kiosk',
        'mobile_pos',
        'web_store',
        'marketplace',
        'social_order',
        'delivery_app',
        'wholesale',
        'field_sales',
        'phone_order',
        'table_service',
      ]),
    );

    final webStore = registry.channelForId('web_store');
    expect(webStore.preferredLayout, POSLayoutPreference.checkout);
    expect(webStore.supportsFulfillment(POSFulfillmentMode.shipment), isTrue);
    expect(
      webStore.supportsCapability(
        POSCommerceChannelCapability.inventoryReservation,
      ),
      isTrue,
    );
    expect(webStore.fulfillmentSummary, contains('Shipment'));
    expect(webStore.capabilitySummary, contains('Inventory reservation'));
  });

  test('registry can query channels by capability and fulfillment mode', () {
    final registry = defaultPOSCommerceChannelRegistry;

    final schedulableChannels = registry.channelsForCapability(
      POSCommerceChannelCapability.orderScheduling,
    );
    expect(
      schedulableChannels.map((channel) => channel.id),
      containsAll(['field_sales', 'phone_order']),
    );

    final deliveryChannels = registry.channelsForFulfillment(
      POSFulfillmentMode.delivery,
    );
    expect(
      deliveryChannels.map((channel) => channel.id),
      containsAll([
        'web_store',
        'marketplace',
        'social_order',
        'delivery_app',
        'wholesale',
        'phone_order',
      ]),
    );
  });

  test('commerce channel registry reports invalid metadata', () {
    final registry = POSCommerceChannelRegistry(
      defaultChannelId: 'missing',
      channels: const [
        POSCommerceChannel(
          id: ' ',
          kind: POSCommerceChannelKind.inStore,
          label: '',
          description: 'Invalid channel.',
          preferredLayout: POSLayoutPreference.auto,
          fulfillmentModes: [],
          capabilities: [],
          traits: [' '],
        ),
        POSCommerceChannel(
          id: 'dup',
          kind: POSCommerceChannelKind.kiosk,
          label: 'Duplicate A',
          description: 'Invalid duplicate.',
          preferredLayout: POSLayoutPreference.compact,
          fulfillmentModes: [POSFulfillmentMode.pickup],
          capabilities: [POSCommerceChannelCapability.payments],
        ),
        POSCommerceChannel(
          id: 'dup',
          kind: POSCommerceChannelKind.mobilePOS,
          label: 'Duplicate B',
          description: 'Invalid duplicate.',
          preferredLayout: POSLayoutPreference.compact,
          fulfillmentModes: [POSFulfillmentMode.immediateHandoff],
          capabilities: [POSCommerceChannelCapability.payments],
        ),
      ],
    );

    final issueTypes = registry.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSCommerceChannelRegistryIssueType.blankChannelId,
        POSCommerceChannelRegistryIssueType.blankLabel,
        POSCommerceChannelRegistryIssueType.emptyFulfillmentModes,
        POSCommerceChannelRegistryIssueType.emptyCapabilities,
        POSCommerceChannelRegistryIssueType.blankTrait,
        POSCommerceChannelRegistryIssueType.duplicateChannelId,
        POSCommerceChannelRegistryIssueType.missingDefaultChannel,
      ]),
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('commerce channel providers select and fallback channels', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(posCommerceChannelProvider).id, 'in_store');

    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'web_store';
    expect(container.read(posCommerceChannelProvider).id, 'web_store');

    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'not_registered';
    expect(container.read(posCommerceChannelProvider).id, 'in_store');
    expect(container.read(posCommerceChannelRegistryIssuesProvider), isEmpty);
  });

  test('commerce channel switch controller applies preferred layout', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(
      posCommerceChannelSwitchControllerProvider,
    );

    controller.apply(controller.channelFor('web_store'));
    expect(container.read(posCommerceChannelProvider).id, 'web_store');
    expect(
      container.read(posLayoutPreferenceProvider),
      POSLayoutPreference.checkout,
    );

    controller.apply(
      controller.channelFor('mobile_pos'),
      applyPreferredLayout: false,
    );
    expect(container.read(posCommerceChannelProvider).id, 'mobile_pos');
    expect(
      container.read(posLayoutPreferenceProvider),
      POSLayoutPreference.checkout,
    );
  });

  test('commerce channel switch controller applies resolved plans', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(
      posCommerceChannelSwitchControllerProvider,
    );
    final targetChannel = controller.channelFor('delivery_app');
    final plan = POSCommerceChannelSwitchPlan.resolve(
      currentChannel: controller.currentChannel,
      targetChannel: targetChannel,
      currentLayoutPreference: controller.currentLayoutPreference,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        controller.currentChannel,
      ),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        targetChannel,
      ),
      order: null,
    );

    final result = controller.applyPlan(plan);

    expect(container.read(posCommerceChannelProvider).id, 'delivery_app');
    expect(
      container.read(posLayoutPreferenceProvider),
      POSLayoutPreference.checkout,
    );
    expect(result.summaryLabel, 'Switched to Delivery app');
    expect(
      container.read(posCommerceChannelSwitchResultProvider),
      same(result),
    );
    final history = container.read(posCommerceChannelSwitchHistoryProvider);
    expect(history.entries, hasLength(1));
    expect(history.entries.single.result, same(result));
    expect(history.latest?.summaryLabel, 'Switched to Delivery app');
  });

  test('commerce channel switch result uses target fulfillment drafts', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(currentOrderProvider.notifier).restoreOrder(_activeOrder());

    final controller = container.read(
      posCommerceChannelSwitchControllerProvider,
    );
    final targetChannel = controller.channelFor('delivery_app');
    final draftKey = posOrderFulfillmentDraftKey('order_1', targetChannel.id);
    container.read(posOrderFulfillmentDraftsProvider.notifier).state = {
      draftKey: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
        destination: 'Jl. Merdeka 10',
      ),
    };
    final plan = POSCommerceChannelSwitchPlan.resolve(
      currentChannel: controller.currentChannel,
      targetChannel: targetChannel,
      currentLayoutPreference: controller.currentLayoutPreference,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        controller.currentChannel,
      ),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        targetChannel,
      ),
      order: container.read(currentOrderProvider),
    );

    final result = controller.applyPlan(plan);

    expect(container.read(posCommerceChannelProvider).id, 'delivery_app');
    expect(result.completedRequirementCount, 1);
    expect(result.resolvedFulfillmentContext.destination, 'Jl. Merdeka 10');
    expect(result.requiresAttention, isFalse);
    expect(
      result.items.map((item) => item.label),
      contains('Delivery destination completed'),
    );
    expect(
      result.items
          .where(
            (item) =>
                item.role ==
                POSCommerceChannelSwitchResultItemRole.completedRequirement,
          )
          .single
          .message,
      'Jl. Merdeka 10',
    );
  });
}

Order _activeOrder() {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}
