import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_payment_scope.dart';
import 'order_status.dart';

enum OrderAttentionSeverity { info, warning, critical }

enum OrderAttentionScope { all, actionable, highPriority, clear }

extension OrderAttentionScopeLabel on OrderAttentionScope {
  String get label {
    return switch (this) {
      OrderAttentionScope.all => 'All',
      OrderAttentionScope.actionable => 'Actionable',
      OrderAttentionScope.highPriority => 'High priority',
      OrderAttentionScope.clear => 'Clear',
    };
  }
}

class OrderAttentionSignal {
  final String key;
  final String title;
  final String description;
  final OrderAttentionSeverity severity;

  const OrderAttentionSignal({
    required this.key,
    required this.title,
    required this.description,
    required this.severity,
  });
}

List<OrderAttentionSignal> ecommerceOrderAttentionSignals(
  pos_order.Order order,
) {
  final status = normalizeOrderStatus(order.status);
  if (status == 'completed' || status == 'cancelled') return const [];

  final signals = <OrderAttentionSignal>[];
  final fulfillment = order.fulfillment;

  if (!order.isPaid) {
    signals.add(
      const OrderAttentionSignal(
        key: 'payment_open',
        title: 'Payment open',
        description: 'Collect or confirm payment before fulfillment closes.',
        severity: OrderAttentionSeverity.warning,
      ),
    );
  } else if (ecommerceOrderUsesExternalSettlement(order)) {
    signals.add(
      const OrderAttentionSignal(
        key: 'settlement_review',
        title: 'Settlement review',
        description: 'Match the channel settlement with the ecommerce order.',
        severity: OrderAttentionSeverity.info,
      ),
    );
  }

  if (status == 'pending') {
    signals.add(
      const OrderAttentionSignal(
        key: 'needs_acceptance',
        title: 'Needs acceptance',
        description: 'Confirm stock and start the fulfillment workflow.',
        severity: OrderAttentionSeverity.warning,
      ),
    );
  }

  if (status == 'ready') {
    signals.add(
      OrderAttentionSignal(
        key: 'handoff_waiting',
        title: 'Handoff waiting',
        description: _handoffDescription(fulfillment?.fulfillmentModeKey),
        severity: OrderAttentionSeverity.warning,
      ),
    );
  }

  if (fulfillment == null) {
    signals.add(
      const OrderAttentionSignal(
        key: 'fulfillment_missing',
        title: 'Fulfillment missing',
        description:
            'Assign a channel and fulfillment mode to route the order.',
        severity: OrderAttentionSeverity.critical,
      ),
    );
    return List.unmodifiable(signals);
  }

  final modeKey = fulfillment.fulfillmentModeKey.trim().toLowerCase();
  final needsDestination = modeKey == 'delivery' || modeKey == 'shipment';
  final needsContact =
      modeKey == 'delivery' || modeKey == 'pickup' || modeKey == 'shipment';

  if (needsDestination && fulfillment.destination.trim().isEmpty) {
    signals.add(
      OrderAttentionSignal(
        key: 'destination_missing',
        title: 'Destination missing',
        description:
            modeKey == 'shipment'
                ? 'Add the shipping destination before carrier handoff.'
                : 'Add the delivery destination before courier assignment.',
        severity: OrderAttentionSeverity.critical,
      ),
    );
  }

  if (needsContact && fulfillment.contactName.trim().isEmpty) {
    signals.add(
      const OrderAttentionSignal(
        key: 'contact_missing',
        title: 'Customer contact missing',
        description: 'Add a customer contact for handoff confirmation.',
        severity: OrderAttentionSeverity.warning,
      ),
    );
  }

  return List.unmodifiable(signals);
}

bool ecommerceOrderNeedsAttention(pos_order.Order order) {
  return ecommerceOrderAttentionSignals(
    order,
  ).any((signal) => signal.severity != OrderAttentionSeverity.info);
}

bool ecommerceOrderHasCriticalAttention(pos_order.Order order) {
  return ecommerceOrderAttentionSignals(
    order,
  ).any((signal) => signal.severity == OrderAttentionSeverity.critical);
}

bool matchesOrderAttentionScope(
  pos_order.Order order,
  OrderAttentionScope scope,
) {
  return switch (scope) {
    OrderAttentionScope.all => true,
    OrderAttentionScope.actionable => ecommerceOrderNeedsAttention(order),
    OrderAttentionScope.highPriority => ecommerceOrderHasCriticalAttention(
      order,
    ),
    OrderAttentionScope.clear => !ecommerceOrderNeedsAttention(order),
  };
}

String _handoffDescription(String? fulfillmentModeKey) {
  return switch (fulfillmentModeKey?.trim().toLowerCase()) {
    'delivery' => 'Assign or notify the courier for delivery pickup.',
    'pickup' => 'Notify the customer that the order is ready to collect.',
    'shipment' => 'Move the parcel to carrier pickup or dispatch.',
    _ => 'Complete the final handoff for this order.',
  };
}
