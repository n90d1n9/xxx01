import '../../ecommerce/order/omni_channel/ecommerce_order_activity_action_handler.dart';
import '../../point_of_sales/cashier/omni_channel/pos_activity_action_handler.dart';
import 'services/omni_channel_activity_action_executor.dart';

/// Default activity action executor assembled from installed product modules.
final omniChannelDefaultActivityActionExecutor =
    OmniChannelActivityActionExecutor(
      handlers: [
        posActivityActionHandler,
        ecommerceOrderActivityActionHandler,
        omniChannelActivityNavigationActionHandler,
      ],
    );
