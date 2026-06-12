import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_status.dart';

class OrderStatusAction {
  final OrderStatusOption status;
  final String label;
  final String description;

  const OrderStatusAction({
    required this.status,
    required this.label,
    this.description = '',
  });

  String get value => status.value;
  OrderStatusTone get tone => status.tone;
}

enum OrderLifecycleStepState { completed, current, upcoming }

class OrderLifecycleStep {
  final OrderStatusOption status;
  final String label;
  final String description;
  final OrderLifecycleStepState state;

  const OrderLifecycleStep({
    required this.status,
    required this.label,
    required this.state,
    this.description = '',
  });

  String get value => status.value;
  OrderStatusTone get tone => status.tone;
}

class OrderLifecyclePolicy {
  final String id;
  final String label;
  final List<String> timelineStatuses;
  final Map<String, List<String>> transitions;
  final Map<String, String> actionLabels;
  final Map<String, String> actionDescriptions;
  final Map<String, String> timelineLabels;
  final Map<String, String> timelineDescriptions;

  const OrderLifecyclePolicy({
    required this.id,
    required this.label,
    required this.transitions,
    this.timelineStatuses = const [
      'pending',
      'processing',
      'ready',
      'completed',
    ],
    this.actionLabels = const {},
    this.actionDescriptions = const {},
    this.timelineLabels = const {},
    this.timelineDescriptions = const {},
  });

  bool canTransition({required String from, required String to}) {
    final current = normalizeOrderStatus(from);
    final next = normalizeOrderStatus(to);
    if (current == next) return true;

    return transitions[current]?.contains(next) ?? false;
  }

  List<OrderStatusAction> actionsFor(String status) {
    final current = normalizeOrderStatus(status);
    final nextStatuses = transitions[current] ?? const <String>[];

    return List.unmodifiable(
      nextStatuses.map((statusValue) {
        final option = ecommerceOrderStatusFor(statusValue);

        return OrderStatusAction(
          status: option,
          label: actionLabels[option.value] ?? option.label,
          description: actionDescriptions[option.value] ?? '',
        );
      }),
    );
  }

  List<OrderLifecycleStep> timelineFor(String status) {
    final current = normalizeOrderStatus(status);
    final currentIndex = timelineStatuses.indexOf(current);

    if (currentIndex == -1) {
      final option = ecommerceOrderStatusFor(current);
      return [
        OrderLifecycleStep(
          status: option,
          label: timelineLabels[option.value] ?? option.label,
          description:
              timelineDescriptions[option.value] ??
              'This order is outside the standard fulfillment timeline.',
          state: OrderLifecycleStepState.current,
        ),
      ];
    }

    return List.unmodifiable(
      timelineStatuses.map((statusValue) {
        final stepIndex = timelineStatuses.indexOf(statusValue);
        final option = ecommerceOrderStatusFor(statusValue);

        return OrderLifecycleStep(
          status: option,
          label: timelineLabels[option.value] ?? option.label,
          description: timelineDescriptions[option.value] ?? '',
          state:
              stepIndex < currentIndex
                  ? OrderLifecycleStepState.completed
                  : stepIndex == currentIndex
                  ? OrderLifecycleStepState.current
                  : OrderLifecycleStepState.upcoming,
        );
      }),
    );
  }
}

const _standardTransitions = <String, List<String>>{
  'pending': ['processing', 'cancelled'],
  'processing': ['ready', 'cancelled'],
  'ready': ['completed', 'cancelled'],
  'completed': [],
  'cancelled': [],
};

const ecommerceDefaultOrderLifecyclePolicy = OrderLifecyclePolicy(
  id: 'standard',
  label: 'Standard fulfillment',
  transitions: _standardTransitions,
  actionLabels: {
    'processing': 'Start processing',
    'ready': 'Mark ready',
    'completed': 'Complete order',
    'cancelled': 'Cancel order',
  },
  actionDescriptions: {
    'processing': 'Move the order into active preparation.',
    'ready': 'Mark the order as ready for its fulfillment handoff.',
    'completed': 'Close the order after handoff or delivery.',
    'cancelled': 'Cancel the order before it is closed.',
  },
  timelineLabels: {
    'pending': 'New order',
    'processing': 'Processing',
    'ready': 'Ready',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  },
  timelineDescriptions: {
    'pending': 'Waiting for staff confirmation.',
    'processing': 'Being prepared by the team.',
    'ready': 'Ready for fulfillment handoff.',
    'completed': 'Fulfillment is closed.',
    'cancelled': 'Order has been stopped before closeout.',
  },
);

const ecommerceDeliveryOrderLifecyclePolicy = OrderLifecyclePolicy(
  id: 'delivery',
  label: 'Delivery fulfillment',
  transitions: _standardTransitions,
  actionLabels: {
    'processing': 'Accept order',
    'ready': 'Ready for courier',
    'completed': 'Complete delivery',
    'cancelled': 'Cancel order',
  },
  actionDescriptions: {
    'processing': 'Accept the remote order for preparation.',
    'ready': 'Confirm the package is ready for courier pickup.',
    'completed': 'Close the order once delivery is fulfilled.',
    'cancelled': 'Cancel the order before fulfillment closes.',
  },
  timelineLabels: {
    'pending': 'New order',
    'processing': 'Preparing',
    'ready': 'Courier ready',
    'completed': 'Delivered',
    'cancelled': 'Cancelled',
  },
  timelineDescriptions: {
    'pending': 'Waiting for acceptance.',
    'processing': 'Kitchen or packing team is preparing the order.',
    'ready': 'Package is ready for courier pickup.',
    'completed': 'Delivery has been fulfilled.',
    'cancelled': 'Delivery order has been cancelled.',
  },
);

const ecommercePickupOrderLifecyclePolicy = OrderLifecyclePolicy(
  id: 'pickup',
  label: 'Pickup fulfillment',
  transitions: _standardTransitions,
  actionLabels: {
    'processing': 'Prepare order',
    'ready': 'Ready for pickup',
    'completed': 'Collected',
    'cancelled': 'Cancel order',
  },
  actionDescriptions: {
    'processing': 'Move the order into staff preparation.',
    'ready': 'Mark it ready for the customer to collect.',
    'completed': 'Close the order after customer pickup.',
    'cancelled': 'Cancel the pickup order.',
  },
  timelineLabels: {
    'pending': 'New order',
    'processing': 'Preparing',
    'ready': 'Pickup ready',
    'completed': 'Collected',
    'cancelled': 'Cancelled',
  },
  timelineDescriptions: {
    'pending': 'Waiting for pickup confirmation.',
    'processing': 'Team is preparing the pickup order.',
    'ready': 'Ready for customer collection.',
    'completed': 'Customer has collected the order.',
    'cancelled': 'Pickup order has been cancelled.',
  },
);

const ecommerceShipmentOrderLifecyclePolicy = OrderLifecyclePolicy(
  id: 'shipment',
  label: 'Shipment fulfillment',
  transitions: _standardTransitions,
  actionLabels: {
    'processing': 'Pack order',
    'ready': 'Ready to ship',
    'completed': 'Shipped',
    'cancelled': 'Cancel order',
  },
  actionDescriptions: {
    'processing': 'Move the order into packing.',
    'ready': 'Mark the parcel ready for shipment.',
    'completed': 'Close the order after carrier handoff.',
    'cancelled': 'Cancel the shipment order.',
  },
  timelineLabels: {
    'pending': 'New order',
    'processing': 'Packing',
    'ready': 'Ready to ship',
    'completed': 'Shipped',
    'cancelled': 'Cancelled',
  },
  timelineDescriptions: {
    'pending': 'Waiting for shipment confirmation.',
    'processing': 'Parcel is being packed.',
    'ready': 'Parcel is ready for carrier handoff.',
    'completed': 'Carrier handoff is complete.',
    'cancelled': 'Shipment order has been cancelled.',
  },
);

const ecommerceWholesaleOrderLifecyclePolicy = OrderLifecyclePolicy(
  id: 'wholesale',
  label: 'Wholesale fulfillment',
  transitions: _standardTransitions,
  actionLabels: {
    'processing': 'Confirm order',
    'ready': 'Stage fulfillment',
    'completed': 'Close order',
    'cancelled': 'Cancel order',
  },
  actionDescriptions: {
    'processing': 'Confirm the B2B order for handling.',
    'ready': 'Mark stock as staged for agreed fulfillment.',
    'completed': 'Close the wholesale order.',
    'cancelled': 'Cancel the wholesale order.',
  },
  timelineLabels: {
    'pending': 'New order',
    'processing': 'Confirmed',
    'ready': 'Staged',
    'completed': 'Closed',
    'cancelled': 'Cancelled',
  },
  timelineDescriptions: {
    'pending': 'Waiting for account confirmation.',
    'processing': 'Wholesale order is confirmed for handling.',
    'ready': 'Stock is staged for the agreed fulfillment path.',
    'completed': 'Wholesale order is closed.',
    'cancelled': 'Wholesale order has been cancelled.',
  },
);

OrderLifecyclePolicy ecommerceOrderLifecyclePolicyFor(pos_order.Order order) {
  final fulfillment = order.fulfillment;
  final channelId = fulfillment?.commerceChannelId.trim();
  final modeKey = fulfillment?.fulfillmentModeKey.trim();

  if (channelId == 'wholesale') return ecommerceWholesaleOrderLifecyclePolicy;
  if (channelId == 'delivery_app') return ecommerceDeliveryOrderLifecyclePolicy;

  return switch (modeKey) {
    'delivery' => ecommerceDeliveryOrderLifecyclePolicy,
    'pickup' => ecommercePickupOrderLifecyclePolicy,
    'shipment' => ecommerceShipmentOrderLifecyclePolicy,
    _ => ecommerceDefaultOrderLifecyclePolicy,
  };
}

List<OrderStatusAction> ecommerceOrderAvailableStatusActions(
  pos_order.Order order,
) {
  return ecommerceOrderLifecyclePolicyFor(order).actionsFor(order.status);
}

bool canTransitionOrderStatus(pos_order.Order order, String nextStatus) {
  return ecommerceOrderLifecyclePolicyFor(
    order,
  ).canTransition(from: order.status, to: nextStatus);
}

List<OrderLifecycleStep> ecommerceOrderLifecycleSteps(pos_order.Order order) {
  return ecommerceOrderLifecyclePolicyFor(order).timelineFor(order.status);
}
