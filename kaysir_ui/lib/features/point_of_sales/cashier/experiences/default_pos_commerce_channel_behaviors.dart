import 'pos_commerce_channel_behavior.dart';

final defaultPOSCommerceChannelBehaviorRegistry =
    POSCommerceChannelBehaviorRegistry(
      profiles: [
        POSCommerceChannelBehaviorProfile(
          channelId: 'in_store',
          modules: [
            POSCommerceChannelBehaviorModules.counterCheckout,
            POSCommerceChannelBehaviorModules.immediateFulfillment,
            POSCommerceChannelBehaviorModules.offlineCapture,
          ],
          traits: ['counter', 'terminal-bound', 'walk-in'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'kiosk',
          modules: [
            POSCommerceChannelBehaviorModules.selfServiceFlow,
            POSCommerceChannelBehaviorModules.pickupQueue,
            POSCommerceChannelBehaviorModules.immediateFulfillment,
          ],
          traits: ['self-service', 'public-screen', 'guided'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'mobile_pos',
          modules: [
            POSCommerceChannelBehaviorModules.staffAssistedSelling,
            POSCommerceChannelBehaviorModules.immediateFulfillment,
            POSCommerceChannelBehaviorModules.pickupQueue,
            POSCommerceChannelBehaviorModules.offlineCapture,
          ],
          traits: ['portable', 'staff-assisted', 'line-busting'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'web_store',
          modules: [
            POSCommerceChannelBehaviorModules.ownedOnlineOrder,
            POSCommerceChannelBehaviorModules.pickupQueue,
            POSCommerceChannelBehaviorModules.deliveryFulfillment,
            POSCommerceChannelBehaviorModules.shipmentFulfillment,
            POSCommerceChannelBehaviorModules.inventoryReservation,
          ],
          traits: ['owned-online', 'async-order', 'customer-account'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'marketplace',
          modules: [
            POSCommerceChannelBehaviorModules.marketplacePolicy,
            POSCommerceChannelBehaviorModules.deliveryFulfillment,
            POSCommerceChannelBehaviorModules.shipmentFulfillment,
            POSCommerceChannelBehaviorModules.inventoryReservation,
            POSCommerceChannelBehaviorModules.accountPricing,
          ],
          traits: ['third-party', 'fees', 'policy-bound'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'social_order',
          modules: [
            POSCommerceChannelBehaviorModules.conversationOrder,
            POSCommerceChannelBehaviorModules.pickupQueue,
            POSCommerceChannelBehaviorModules.deliveryFulfillment,
            POSCommerceChannelBehaviorModules.scheduledFulfillment,
          ],
          traits: ['conversation-led', 'assisted', 'manual-confirmation'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'delivery_app',
          modules: [
            POSCommerceChannelBehaviorModules.deliveryAggregator,
            POSCommerceChannelBehaviorModules.deliveryFulfillment,
            POSCommerceChannelBehaviorModules.inventoryReservation,
            POSCommerceChannelBehaviorModules.accountPricing,
          ],
          traits: ['aggregator', 'courier', 'prep-time'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'wholesale',
          modules: [
            POSCommerceChannelBehaviorModules.accountPricing,
            POSCommerceChannelBehaviorModules.staffAssistedSelling,
            POSCommerceChannelBehaviorModules.pickupQueue,
            POSCommerceChannelBehaviorModules.deliveryFulfillment,
            POSCommerceChannelBehaviorModules.shipmentFulfillment,
            POSCommerceChannelBehaviorModules.scheduledFulfillment,
            POSCommerceChannelBehaviorModules.inventoryReservation,
          ],
          traits: ['b2b', 'price-list', 'account-managed'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'field_sales',
          modules: [
            POSCommerceChannelBehaviorModules.routeSelling,
            POSCommerceChannelBehaviorModules.staffAssistedSelling,
            POSCommerceChannelBehaviorModules.deliveryFulfillment,
            POSCommerceChannelBehaviorModules.scheduledFulfillment,
            POSCommerceChannelBehaviorModules.offlineCapture,
            POSCommerceChannelBehaviorModules.inventoryReservation,
          ],
          traits: ['route-based', 'mobile-stock', 'scheduled'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'phone_order',
          modules: [
            POSCommerceChannelBehaviorModules.phoneAssistedOrder,
            POSCommerceChannelBehaviorModules.pickupQueue,
            POSCommerceChannelBehaviorModules.deliveryFulfillment,
            POSCommerceChannelBehaviorModules.scheduledFulfillment,
          ],
          traits: ['assisted-remote', 'manual-confirmation', 'callback-ready'],
        ),
        POSCommerceChannelBehaviorProfile(
          channelId: 'table_service',
          modules: [
            POSCommerceChannelBehaviorModules.tableServiceLifecycle,
            POSCommerceChannelBehaviorModules.tableFulfillment,
            POSCommerceChannelBehaviorModules.counterCheckout,
          ],
          traits: ['dine-in', 'seat-aware', 'course-staging'],
        ),
      ],
    );
