import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../ecommerce/order/states/order_provider.dart';
import '../../../point_of_sales/cashier/experiences/pos_commerce_channel_switch_history.dart';
import '../../../point_of_sales/cashier/experiences/pos_diagnostics_activity.dart';
import '../../../point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import '../../../point_of_sales/order/states/order_save_outbox_provider.dart';
import '../adapters/ecommerce_order_omni_activity_adapter.dart';
import '../adapters/pos_diagnostics_omni_activity_adapter.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_filter.dart';
import '../models/omni_channel_activity_insight.dart';
import '../models/omni_channel_activity_module_manifest.dart';
import '../models/omni_channel_activity_scope.dart';
import '../models/omni_channel_activity_triage.dart';

final omniChannelActivityFeedProvider = Provider<OmniChannelActivityFeed>((
  ref,
) {
  final posActivity = POSDiagnosticsActivitySnapshot.fromSources(
    switchHistory: ref.watch(posCommerceChannelSwitchHistoryProvider),
    switchActionHistory: ref.watch(posSwitchActionHistoryProvider),
    outbox: ref.watch(posOrderSaveOutboxProvider),
  );
  final ecommerceOrders = ref.watch(ecommerceOrdersProvider);

  return posActivity.toOmniChannelActivityFeed(
    additionalEntries: [
      for (final order in ecommerceOrders) order.toEcommerceOrderActivity(),
    ],
  );
});

final omniChannelAttentionActivityProvider =
    Provider<List<OmniChannelActivityEntry>>((ref) {
      return ref.watch(omniChannelActivityFeedProvider).attentionEntries;
    });

final omniChannelReviewActivityProvider =
    Provider<List<OmniChannelActivityEntry>>((ref) {
      return ref.watch(omniChannelActivityFeedProvider).reviewEntries;
    });

final omniChannelActivityInsightProvider = Provider<OmniChannelActivityInsight>(
  (ref) {
    return OmniChannelActivityInsight.fromFeed(
      ref.watch(omniChannelActivityFeedProvider),
    );
  },
);

final omniChannelFilteredActivityProvider =
    Provider.family<List<OmniChannelActivityEntry>, OmniChannelActivityFilter>((
      ref,
      filter,
    ) {
      return ref.watch(omniChannelActivityFeedProvider).apply(filter);
    });

final omniChannelActivityFilterCountsProvider =
    Provider.family<OmniChannelActivityFilterCounts, OmniChannelActivityFilter>(
      (ref, filter) {
        return ref.watch(omniChannelActivityFeedProvider).countsFor(filter);
      },
    );

final omniChannelActivityScopeOptionsProvider = Provider.family<
  OmniChannelActivityScopeOptions,
  OmniChannelActivityFilter
>((ref, filter) {
  return ref.watch(omniChannelActivityFeedProvider).scopeOptionsFor(filter);
});

final omniChannelActivityTriageDimensionDefinitionsProvider =
    Provider<List<OmniChannelActivityTriageDimensionDefinition>>((ref) {
      return defaultOmniChannelActivityTriageDimensionDefinitions;
    });

/// Product modules currently contributing to the shared activity center.
final omniChannelActivityModuleManifestsProvider =
    Provider<List<OmniChannelActivityModuleManifest>>((ref) {
      return defaultOmniChannelActivityModuleManifests;
    });

/// Default POS and ecommerce module manifests used by activity diagnostics.
final defaultOmniChannelActivityModuleManifests =
    List<OmniChannelActivityModuleManifest>.unmodifiable([
      OmniChannelActivityModuleManifest(
        id: 'point_of_sales',
        label: 'Point of sale',
        description: 'Cashier, sync recovery, and counter channel activity.',
        activitySourceIds: const ['point_of_sales'],
        actionContributorIds: const ['point_of_sales'],
        triageDimensionKeys: const [
          OmniChannelActivityTriageDimension.sourceKey,
          OmniChannelActivityTriageDimension.channelKey,
          OmniChannelActivityTriageDimension.fulfillmentKey,
        ],
        businessModelKeys: const [
          OmniChannelActivityBusinessModelKey.pointOfSales,
          OmniChannelActivityBusinessModelKey.kiosk,
        ],
        routePath: '/cashier',
      ),
      OmniChannelActivityModuleManifest(
        id: 'ecommerce',
        label: 'Ecommerce',
        description: 'Online, marketplace, delivery, and order activity.',
        activitySourceIds: const ['ecommerce'],
        actionContributorIds: const ['ecommerce'],
        triageDimensionKeys: const [
          OmniChannelActivityTriageDimension.sourceKey,
          OmniChannelActivityTriageDimension.channelKey,
          OmniChannelActivityTriageDimension.fulfillmentKey,
        ],
        businessModelKeys: const [
          OmniChannelActivityBusinessModelKey.ecommerce,
          OmniChannelActivityBusinessModelKey.marketplace,
          OmniChannelActivityBusinessModelKey.delivery,
          OmniChannelActivityBusinessModelKey.wholesale,
        ],
        routePath: '/commerce/orders',
      ),
    ]);

/// Display limit for triage queues; null means every ranked queue is visible.
final omniChannelActivityTriageQueueLimitProvider = StateProvider<int?>((ref) {
  return defaultOmniChannelActivityTriageGroupLimit;
});

final omniChannelActivityTriageQueueProvider =
    Provider.family<OmniChannelActivityTriageQueue, OmniChannelActivityFilter>((
      ref,
      filter,
    ) {
      final limit = ref.watch(omniChannelActivityTriageQueueLimitProvider);

      return ref
          .watch(omniChannelActivityFeedProvider)
          .triageQueueFor(
            filter,
            dimensions: ref.watch(
              omniChannelActivityTriageDimensionDefinitionsProvider,
            ),
            limit: limit,
          );
    });

final omniChannelActivityForOrderProvider =
    Provider.family<List<OmniChannelActivityEntry>, String>((ref, orderId) {
      return ref.watch(omniChannelActivityFeedProvider).forOrder(orderId);
    });

final omniChannelActivityForChannelProvider =
    Provider.family<List<OmniChannelActivityEntry>, String>((ref, channelId) {
      return ref.watch(omniChannelActivityFeedProvider).forChannel(channelId);
    });
