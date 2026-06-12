import '../../ecommerce/order/omni_channel/ecommerce_order_activity_action_contributor.dart';
import '../../point_of_sales/cashier/omni_channel/pos_activity_action_contributor.dart';
import 'models/omni_channel_activity.dart';
import 'models/omni_channel_activity_action.dart';

/// Default activity action registry assembled from installed product modules.
const omniChannelDefaultActivityActionRegistry =
    OmniChannelActivityActionRegistry(
      contributors: [
        posActivityActionContributor,
        ecommerceOrderActivityActionContributor,
      ],
      contributorDescriptors: [
        OmniChannelActivityActionContributorDescriptor(
          id: 'point_of_sales',
          label: 'Point of sale actions',
          description: 'Cashier, sync, and counter recovery actions',
        ),
        OmniChannelActivityActionContributorDescriptor(
          id: 'ecommerce',
          label: 'Ecommerce actions',
          description: 'Order, channel, fulfillment, and commerce actions',
        ),
      ],
    );

/// Resolves the primary action from the default omni-channel registry.
OmniChannelActivityAction? omniChannelActivityActionFor(
  OmniChannelActivityEntry entry,
) {
  return omniChannelDefaultActivityActionRegistry.primaryActionFor(entry);
}

/// Resolves all actions from the default omni-channel registry.
List<OmniChannelActivityAction> omniChannelActivityActionsFor(
  OmniChannelActivityEntry entry,
) {
  return omniChannelDefaultActivityActionRegistry.actionsFor(entry);
}
