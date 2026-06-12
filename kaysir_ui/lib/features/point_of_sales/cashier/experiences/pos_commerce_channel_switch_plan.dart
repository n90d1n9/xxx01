import '../../order/models/order.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_switch_availability.dart';
import 'pos_order_fulfillment.dart';

enum POSCommerceChannelSwitchPlanActionRole {
  keepChannel,
  selectChannel,
  keepLayout,
  applyLayout,
  keepFulfillment,
  prepareFulfillment,
  reviewFulfillment,
}

class POSCommerceChannelSwitchPlanAction {
  final String id;
  final String label;
  final POSCommerceChannelSwitchPlanActionRole role;
  final bool requiresAttention;

  const POSCommerceChannelSwitchPlanAction({
    required this.id,
    required this.label,
    required this.role,
    this.requiresAttention = false,
  });
}

class POSCommerceChannelSwitchPlan {
  final POSCommerceChannelSwitchAvailability availability;
  final POSLayoutPreference targetLayoutPreference;
  final POSOrderFulfillmentContext targetFulfillmentContext;
  final List<POSCommerceChannelSwitchPlanAction> actions;

  POSCommerceChannelSwitchPlan({
    required this.availability,
    required this.targetLayoutPreference,
    required this.targetFulfillmentContext,
    required Iterable<POSCommerceChannelSwitchPlanAction> actions,
  }) : actions = List.unmodifiable(actions);

  factory POSCommerceChannelSwitchPlan.resolve({
    required POSCommerceChannel currentChannel,
    required POSCommerceChannel targetChannel,
    required POSLayoutPreference currentLayoutPreference,
    required POSOrderFulfillmentContext currentFulfillmentContext,
    required POSOrderFulfillmentContext targetFulfillmentContext,
    required Order? order,
  }) {
    final availability = POSCommerceChannelSwitchAvailability.evaluate(
      currentChannel: currentChannel,
      targetChannel: targetChannel,
      currentLayoutPreference: currentLayoutPreference,
      currentFulfillmentContext: currentFulfillmentContext,
      targetFulfillmentContext: targetFulfillmentContext,
      order: order,
    );

    return POSCommerceChannelSwitchPlan(
      availability: availability,
      targetLayoutPreference: targetChannel.preferredLayout,
      targetFulfillmentContext: targetFulfillmentContext,
      actions: _actionsFor(
        availability: availability,
        targetLayoutPreference: targetChannel.preferredLayout,
        targetFulfillmentContext: targetFulfillmentContext,
      ),
    );
  }

  factory POSCommerceChannelSwitchPlan.fromAvailability({
    required POSCommerceChannelSwitchAvailability availability,
    POSOrderFulfillmentContext? targetFulfillmentContext,
  }) {
    final resolvedTargetFulfillmentContext =
        targetFulfillmentContext ??
        availability.decision.targetFulfillmentReadiness?.context ??
        POSOrderFulfillmentContext.forChannel(availability.channel);

    return POSCommerceChannelSwitchPlan(
      availability: availability,
      targetLayoutPreference: availability.channel.preferredLayout,
      targetFulfillmentContext: resolvedTargetFulfillmentContext,
      actions: _actionsFor(
        availability: availability,
        targetLayoutPreference: availability.channel.preferredLayout,
        targetFulfillmentContext: resolvedTargetFulfillmentContext,
      ),
    );
  }

  POSCommerceChannel get currentChannel => availability.decision.currentChannel;

  POSCommerceChannel get targetChannel => availability.channel;

  POSLayoutPreference get currentLayoutPreference {
    return availability.decision.currentLayoutPreference;
  }

  POSOrderFulfillmentContext get currentFulfillmentContext {
    return availability.decision.currentFulfillmentContext;
  }

  POSOrderFulfillmentReadiness? get targetFulfillmentReadiness {
    return availability.decision.targetFulfillmentReadiness;
  }

  bool get isCurrent => availability.isCurrent;

  bool get needsConfirmation => availability.needsConfirmation;

  bool get hasActiveOrder => availability.decision.hasActiveOrder;

  bool get changesChannel => currentChannel.id != targetChannel.id;

  bool get changesLayout => currentLayoutPreference != targetLayoutPreference;

  bool get changesFulfillmentMode {
    return currentFulfillmentContext.mode != targetFulfillmentContext.mode;
  }

  bool get hasFulfillmentIssues {
    return targetFulfillmentReadiness?.issues.isNotEmpty ?? false;
  }

  bool get needsFulfillmentReview {
    return hasActiveOrder && (changesFulfillmentMode || hasFulfillmentIssues);
  }

  String get statusLabel => availability.statusLabel;

  String get title => availability.decision.title;

  String get message => availability.decision.message;

  String get confirmLabel => availability.decision.confirmLabel;

  String get impactLabel {
    if (isCurrent) return 'Current channel';

    final impacts = <String>['channel'];
    if (changesLayout) impacts.add('layout');
    if (changesFulfillmentMode || hasFulfillmentIssues) {
      impacts.add('fulfillment');
    }

    if (impacts.length == 1) return 'Switches channel';
    if (impacts.length == 2) {
      return 'Switches ${impacts.first} and ${impacts.last}';
    }

    return 'Switches ${impacts[0]}, ${impacts[1]}, and ${impacts[2]}';
  }

  static List<POSCommerceChannelSwitchPlanAction> _actionsFor({
    required POSCommerceChannelSwitchAvailability availability,
    required POSLayoutPreference targetLayoutPreference,
    required POSOrderFulfillmentContext targetFulfillmentContext,
  }) {
    final decision = availability.decision;
    if (availability.isCurrent) {
      return [
        POSCommerceChannelSwitchPlanAction(
          id: 'keep_channel',
          label: 'Keep ${decision.targetChannel.label}',
          role: POSCommerceChannelSwitchPlanActionRole.keepChannel,
        ),
      ];
    }

    final actions = <POSCommerceChannelSwitchPlanAction>[
      POSCommerceChannelSwitchPlanAction(
        id: 'select_channel',
        label: 'Switch to ${decision.targetChannel.label}',
        role: POSCommerceChannelSwitchPlanActionRole.selectChannel,
      ),
    ];

    if (decision.currentLayoutPreference == targetLayoutPreference) {
      actions.add(
        POSCommerceChannelSwitchPlanAction(
          id: 'keep_layout',
          label: 'Keep ${targetLayoutPreference.label} layout',
          role: POSCommerceChannelSwitchPlanActionRole.keepLayout,
        ),
      );
    } else {
      actions.add(
        POSCommerceChannelSwitchPlanAction(
          id: 'apply_layout',
          label: 'Use ${targetLayoutPreference.label} layout',
          role: POSCommerceChannelSwitchPlanActionRole.applyLayout,
        ),
      );
    }

    final firstIssue = decision.targetFulfillmentReadiness?.issues.firstOrNull;
    if (firstIssue != null) {
      actions.add(
        POSCommerceChannelSwitchPlanAction(
          id: 'review_fulfillment',
          label: firstIssue.label,
          role: POSCommerceChannelSwitchPlanActionRole.reviewFulfillment,
          requiresAttention: true,
        ),
      );
    } else if (decision.currentFulfillmentContext.mode !=
        targetFulfillmentContext.mode) {
      final role =
          decision.hasActiveOrder
              ? POSCommerceChannelSwitchPlanActionRole.reviewFulfillment
              : POSCommerceChannelSwitchPlanActionRole.prepareFulfillment;
      actions.add(
        POSCommerceChannelSwitchPlanAction(
          id:
              decision.hasActiveOrder
                  ? 'review_fulfillment'
                  : 'prepare_fulfillment',
          label:
              '${decision.hasActiveOrder ? 'Review' : 'Prepare'} '
              '${targetFulfillmentContext.mode.label} fulfillment',
          role: role,
          requiresAttention: decision.hasActiveOrder,
        ),
      );
    } else {
      actions.add(
        POSCommerceChannelSwitchPlanAction(
          id: 'keep_fulfillment',
          label: 'Keep ${targetFulfillmentContext.mode.label} fulfillment',
          role: POSCommerceChannelSwitchPlanActionRole.keepFulfillment,
        ),
      );
    }

    return actions;
  }
}
