import '../../order/models/order.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_switch_guard.dart';
import 'pos_order_fulfillment.dart';

enum POSCommerceChannelSwitchAvailabilityStatus { current, available, confirm }

class POSCommerceChannelSwitchAvailability {
  final POSCommerceChannelSwitchDecision decision;

  const POSCommerceChannelSwitchAvailability({required this.decision});

  factory POSCommerceChannelSwitchAvailability.evaluate({
    required POSCommerceChannel currentChannel,
    required POSCommerceChannel targetChannel,
    required POSLayoutPreference currentLayoutPreference,
    required POSOrderFulfillmentContext currentFulfillmentContext,
    required POSOrderFulfillmentContext targetFulfillmentContext,
    required Order? order,
  }) {
    return POSCommerceChannelSwitchAvailability(
      decision: POSCommerceChannelSwitchGuard.evaluate(
        currentChannel: currentChannel,
        targetChannel: targetChannel,
        currentLayoutPreference: currentLayoutPreference,
        currentFulfillmentContext: currentFulfillmentContext,
        targetFulfillmentContext: targetFulfillmentContext,
        order: order,
      ),
    );
  }

  POSCommerceChannel get channel => decision.targetChannel;

  POSCommerceChannelSwitchAvailabilityStatus get status {
    if (decision.isCurrentChannel) {
      return POSCommerceChannelSwitchAvailabilityStatus.current;
    }
    if (decision.needsConfirmation) {
      return POSCommerceChannelSwitchAvailabilityStatus.confirm;
    }

    return POSCommerceChannelSwitchAvailabilityStatus.available;
  }

  bool get isCurrent {
    return status == POSCommerceChannelSwitchAvailabilityStatus.current;
  }

  bool get needsConfirmation {
    return status == POSCommerceChannelSwitchAvailabilityStatus.confirm;
  }

  String get statusLabel => decision.statusLabel;
}
