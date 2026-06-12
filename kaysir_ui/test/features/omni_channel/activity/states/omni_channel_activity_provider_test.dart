import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment.dart';
import 'package:kaysir/features/ecommerce/order/cart_item.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/ecommerce/order/states/order_provider.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_triage.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_action_registry_provider.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_provider.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_registry_diagnostics_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('omni-channel activity provider starts empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final feed = container.read(omniChannelActivityFeedProvider);
    final insight = container.read(omniChannelActivityInsightProvider);

    expect(feed.isEmpty, isTrue);
    expect(insight.headline, 'No omni-channel activity yet');
    expect(container.read(omniChannelAttentionActivityProvider), isEmpty);
    expect(container.read(omniChannelReviewActivityProvider), isEmpty);
  });

  test('omni-channel activity provider includes ecommerce orders', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

    final order = container
        .read(ecommerceOrdersProvider.notifier)
        .addOrder(
          [CartItem(product: product, quantity: 1)],
          PaymentMethod.card,
          createdAt: DateTime(2026, 6, 1, 11),
          fulfillment: const FulfillmentSelection.pickup(
            contactName: 'Amina',
            scheduleLabel: 'Today 16:00',
          ),
        );

    final feed = container.read(omniChannelActivityFeedProvider);
    final insight = container.read(omniChannelActivityInsightProvider);

    expect(feed.orderCount, 1);
    expect(insight.severity, OmniChannelActivitySeverity.review);
    expect(
      container
          .read(
            omniChannelActivityTriageQueueProvider(
              const OmniChannelActivityFilter(),
            ),
          )
          .reviewCount,
      1,
    );
    expect(feed.entries.single.sourceId, 'ecommerce');
    expect(feed.entries.single.orderId, order.id);
    expect(feed.entries.single.channelId, 'web_store');
    expect(container.read(omniChannelActivityForOrderProvider(order.id)), [
      feed.entries.single,
    ]);
    expect(container.read(omniChannelActivityForChannelProvider('web_store')), [
      feed.entries.single,
    ]);
  });

  test('omni-channel activity provider accepts triage dimension overrides', () {
    final container = ProviderContainer(
      overrides: [
        omniChannelActivityTriageDimensionDefinitionsProvider.overrideWithValue(
          [_orderTriageDefinition],
        ),
      ],
    );
    addTearDown(container.dispose);
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

    final order = container
        .read(ecommerceOrdersProvider.notifier)
        .addOrder(
          [CartItem(product: product, quantity: 1)],
          PaymentMethod.card,
          createdAt: DateTime(2026, 6, 1, 11),
          fulfillment: const FulfillmentSelection.pickup(),
        );

    final queue = container.read(
      omniChannelActivityTriageQueueProvider(const OmniChannelActivityFilter()),
    );

    expect(queue.groups.single.dimension.key, 'order');
    expect(queue.groups.single.id, order.id);
    expect(queue.groups.single.reviewCount, 1);
  });

  test('omni-channel activity provider switches triage queue density', () {
    final container = ProviderContainer(
      overrides: [
        omniChannelActivityFeedProvider.overrideWithValue(_triageFeed()),
      ],
    );
    addTearDown(container.dispose);

    container.read(omniChannelActivityTriageQueueLimitProvider.notifier).state =
        2;

    final compactQueue = container.read(
      omniChannelActivityTriageQueueProvider(const OmniChannelActivityFilter()),
    );

    expect(compactQueue.visibleGroupCount, 2);
    expect(compactQueue.totalGroupCount, 5);
    expect(compactQueue.hiddenGroupCount, 3);

    container.read(omniChannelActivityTriageQueueLimitProvider.notifier).state =
        null;

    final expandedQueue = container.read(
      omniChannelActivityTriageQueueProvider(const OmniChannelActivityFilter()),
    );

    expect(expandedQueue.visibleGroupCount, 5);
    expect(expandedQueue.totalGroupCount, 5);
    expect(expandedQueue.hiddenGroupCount, 0);
  });

  test('omni-channel activity provider exposes registry diagnostics', () {
    final container = ProviderContainer(
      overrides: [
        omniChannelActivityFeedProvider.overrideWithValue(_triageFeed()),
        omniChannelActivityActionRegistryProvider.overrideWithValue(
          OmniChannelActivityActionRegistry(
            contributors: [_providerDiagnosticActionContributor],
            contributorDescriptors: const [
              OmniChannelActivityActionContributorDescriptor(
                id: 'provider_diagnostics',
                label: 'Provider diagnostics',
                description: 'Provider diagnostics actions',
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final diagnostics = container.read(
      omniChannelActivityRegistryDiagnosticsProvider,
    );

    expect(diagnostics.summaryLabel, '3 dimensions / 1 action contributor');
    expect(diagnostics.activeDimensionCount, 3);
    expect(diagnostics.activeActionContributorCount, 1);
    expect(diagnostics.actionContributors.single.label, 'Provider diagnostics');
    expect(diagnostics.activeActionCount, 1);
    expect(diagnostics.actions.single.label, 'Inspect activity');
    expect(diagnostics.actions.single.eventCount, 2);
  });

  test('omni-channel activity provider includes POS switch diagnostics', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(posSwitchActionHistoryProvider.notifier)
        .record(
          const POSSwitchActionResult.blocked(
            kind: POSSwitchActionKind.runtimePack,
            targetId: 'no_payment_pack',
            targetLabel: 'No Payment Pack',
            reason: 'Finish current order first',
          ),
        );

    final feed = container.read(omniChannelActivityFeedProvider);
    final attention = container.read(omniChannelAttentionActivityProvider);
    final insight = container.read(omniChannelActivityInsightProvider);

    expect(feed.switchActionCount, 1);
    expect(feed.attentionCount, 1);
    expect(insight.severity, OmniChannelActivitySeverity.attention);
    expect(attention.single.kind, OmniChannelActivityKind.switchAction);
    expect(attention.single.sourceId, 'point_of_sales');
    expect(attention.single.supportSummary, contains('Finish current order'));
  });

  test('omni-channel activity provider filters and counts scoped activity', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

    final order = container
        .read(ecommerceOrdersProvider.notifier)
        .addOrder(
          [CartItem(product: product, quantity: 1)],
          PaymentMethod.card,
          createdAt: DateTime(2026, 6, 1, 11),
          fulfillment: const FulfillmentSelection.pickup(
            contactName: 'Amina',
            scheduleLabel: 'Today 16:00',
          ),
        );
    final filter = OmniChannelActivityFilter(
      channelId: 'web_store',
      orderId: order.id,
      status: OmniChannelActivityFilterStatus.orders,
    );

    final filtered = container.read(
      omniChannelFilteredActivityProvider(filter),
    );
    final counts = container.read(
      omniChannelActivityFilterCountsProvider(filter),
    );

    expect(filtered.map((entry) => entry.orderId), [order.id]);
    expect(counts.all, 1);
    expect(counts.orders, 1);
    expect(counts.countFor(OmniChannelActivityFilterStatus.orders), 1);
  });
}

OmniChannelActivityFeed _triageFeed() {
  return OmniChannelActivityFeed(
    entries: [
      OmniChannelActivityEntry(
        id: 'pos-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 12),
        title: 'POS sync failed',
        detail: 'Marketplace order failed to sync.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'web_store',
        channelLabel: 'Web store',
        orderId: 'POS-1',
      ),
      OmniChannelActivityEntry(
        id: 'ecommerce-review',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11),
        title: 'Marketplace pickup review',
        detail: 'Pickup capacity needs review.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-1',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
      ),
    ],
  );
}

Iterable<OmniChannelActivityAction> _providerDiagnosticActionContributor(
  OmniChannelActivityEntry entry,
) sync* {
  yield const OmniChannelActivityAction(
    id: 'inspect-activity',
    label: 'Inspect activity',
    location: '/activity',
    tooltip: 'Inspect activity',
    intent: OmniChannelActivityActionIntent.inspect,
  );
}

final _orderTriageDefinition = OmniChannelActivityTriageDimensionDefinition(
  dimension: const OmniChannelActivityTriageDimension(
    key: 'order',
    label: 'Order',
    sortOrder: 0,
  ),
  resolve: (entry) {
    final orderId = entry.orderId?.trim();
    if (orderId == null || orderId.isEmpty) return null;

    return OmniChannelActivityTriageValue(id: orderId, label: orderId);
  },
  applyFilter:
      ({
        required OmniChannelActivityFilter baseFilter,
        required String id,
        required OmniChannelActivityFilterStatus status,
      }) => baseFilter.copyWith(status: status, orderId: id),
  isSelected:
      ({
        required OmniChannelActivityFilter filter,
        required String id,
        required OmniChannelActivityFilterStatus status,
      }) => filter.status == status && filter.orderId == id,
);
