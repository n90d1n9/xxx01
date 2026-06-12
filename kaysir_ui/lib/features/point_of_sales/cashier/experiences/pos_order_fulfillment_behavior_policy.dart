import '../../order/models/order.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_behavior.dart';
import 'pos_order_fulfillment.dart';

enum POSOrderFulfillmentBehaviorHintTone { neutral, positive, warning }

class POSOrderFulfillmentBehaviorHint {
  final String id;
  final String label;
  final String message;
  final POSOrderFulfillmentBehaviorHintTone tone;

  const POSOrderFulfillmentBehaviorHint({
    required this.id,
    required this.label,
    required this.message,
    this.tone = POSOrderFulfillmentBehaviorHintTone.neutral,
  });
}

abstract final class POSOrderFulfillmentBehaviorPolicy {
  static List<POSOrderFulfillmentIssue> issuesFor({
    required Order order,
    required POSCommerceChannel channel,
    required POSOrderFulfillmentContext context,
    required POSCommerceChannelBehaviorProfile? behaviorProfile,
  }) {
    if (behaviorProfile == null || order.items.isEmpty) return const [];

    if (_requiresSchedule(behaviorProfile, context.mode) &&
        context.scheduleLabel.trim().isEmpty) {
      return const [
        POSOrderFulfillmentIssue(
          type: POSOrderFulfillmentIssueType.missingSchedule,
          label: 'Schedule needed',
          message:
              'Add a fulfillment schedule for this channel before closing.',
        ),
      ];
    }

    return const [];
  }

  static List<POSOrderFulfillmentBehaviorHint> hintsFor({
    required POSCommerceChannel channel,
    required POSOrderFulfillmentContext context,
    required POSCommerceChannelBehaviorProfile? behaviorProfile,
  }) {
    if (behaviorProfile == null) return const [];

    final hints = <POSOrderFulfillmentBehaviorHint>[];

    if (_requiresSchedule(behaviorProfile, context.mode)) {
      final hasSchedule = context.scheduleLabel.trim().isNotEmpty;
      hints.add(
        POSOrderFulfillmentBehaviorHint(
          id: 'schedule_required',
          label: hasSchedule ? 'Scheduled' : 'Schedule required',
          message:
              hasSchedule
                  ? 'This channel will close with a fulfillment schedule.'
                  : 'This channel expects a pickup, delivery, or service schedule.',
          tone:
              hasSchedule
                  ? POSOrderFulfillmentBehaviorHintTone.positive
                  : POSOrderFulfillmentBehaviorHintTone.warning,
        ),
      );
    }

    if (behaviorProfile.supportsModule(
      POSCommerceChannelBehaviorModules.deliveryAggregator,
    )) {
      hints.add(
        const POSOrderFulfillmentBehaviorHint(
          id: 'courier_handoff',
          label: 'Courier handoff',
          message: 'Coordinate prep timing and courier pickup before closeout.',
          tone: POSOrderFulfillmentBehaviorHintTone.warning,
        ),
      );
    }

    if (behaviorProfile.supportsModule(
      POSCommerceChannelBehaviorModules.marketplacePolicy,
    )) {
      hints.add(
        const POSOrderFulfillmentBehaviorHint(
          id: 'platform_policy',
          label: 'Platform policy',
          message: 'Check platform fees, policy, and reconciliation details.',
        ),
      );
    }

    if (behaviorProfile.supportsModule(
      POSCommerceChannelBehaviorModules.inventoryReservation,
    )) {
      hints.add(
        const POSOrderFulfillmentBehaviorHint(
          id: 'stock_reserved',
          label: 'Stock reserved',
          message: 'Keep stock reserved until fulfillment is confirmed.',
        ),
      );
    }

    if (behaviorProfile.supportsModule(
      POSCommerceChannelBehaviorModules.offlineCapture,
    )) {
      hints.add(
        const POSOrderFulfillmentBehaviorHint(
          id: 'offline_ready',
          label: 'Offline-ready',
          message: 'Order capture can continue during unstable connectivity.',
          tone: POSOrderFulfillmentBehaviorHintTone.positive,
        ),
      );
    }

    if (behaviorProfile.supportsModule(
      POSCommerceChannelBehaviorModules.accountPricing,
    )) {
      hints.add(
        const POSOrderFulfillmentBehaviorHint(
          id: 'account_terms',
          label: 'Account terms',
          message: 'Confirm account pricing or channel-specific terms.',
        ),
      );
    }

    if (behaviorProfile.supportsModule(
      POSCommerceChannelBehaviorModules.tableServiceLifecycle,
    )) {
      hints.add(
        const POSOrderFulfillmentBehaviorHint(
          id: 'table_lifecycle',
          label: 'Table lifecycle',
          message: 'Keep table state aligned with service and closeout.',
        ),
      );
    }

    return List.unmodifiable(hints);
  }

  static bool _requiresSchedule(
    POSCommerceChannelBehaviorProfile behaviorProfile,
    POSFulfillmentMode mode,
  ) {
    if (!behaviorProfile.supportsModule(
      POSCommerceChannelBehaviorModules.scheduledFulfillment,
    )) {
      return false;
    }

    switch (mode) {
      case POSFulfillmentMode.pickup:
      case POSFulfillmentMode.delivery:
      case POSFulfillmentMode.preorder:
      case POSFulfillmentMode.fieldDelivery:
        return true;
      case POSFulfillmentMode.immediateHandoff:
      case POSFulfillmentMode.shipment:
      case POSFulfillmentMode.tableService:
        return false;
    }
  }
}
