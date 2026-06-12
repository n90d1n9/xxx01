import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channel_behaviors.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_behavior_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('behavior policy requires schedules for scheduled pickup channels', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId(
      'phone_order',
    );
    final profile = defaultPOSCommerceChannelBehaviorRegistry.profileForChannel(
      channel.id,
    );
    final order = _order(customer: _customer());
    const context = POSOrderFulfillmentContext(mode: POSFulfillmentMode.pickup);

    final issues = POSOrderFulfillmentBehaviorPolicy.issuesFor(
      order: order,
      channel: channel,
      context: context,
      behaviorProfile: profile,
    );
    final hints = POSOrderFulfillmentBehaviorPolicy.hintsFor(
      channel: channel,
      context: context,
      behaviorProfile: profile,
    );

    expect(issues.single.type, POSOrderFulfillmentIssueType.missingSchedule);
    expect(hints.first.label, 'Schedule required');
    expect(hints.first.tone, POSOrderFulfillmentBehaviorHintTone.warning);
  });

  test('behavior policy accepts scheduled channel closeout once scheduled', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId(
      'phone_order',
    );
    final profile = defaultPOSCommerceChannelBehaviorRegistry.profileForChannel(
      channel.id,
    );
    const context = POSOrderFulfillmentContext(
      mode: POSFulfillmentMode.pickup,
      scheduleLabel: 'Tomorrow 10:00',
    );

    final issues = POSOrderFulfillmentBehaviorPolicy.issuesFor(
      order: _order(customer: _customer()),
      channel: channel,
      context: context,
      behaviorProfile: profile,
    );
    final hints = POSOrderFulfillmentBehaviorPolicy.hintsFor(
      channel: channel,
      context: context,
      behaviorProfile: profile,
    );

    expect(issues, isEmpty);
    expect(hints.first.label, 'Scheduled');
    expect(hints.first.tone, POSOrderFulfillmentBehaviorHintTone.positive);
  });

  test('behavior policy surfaces aggregator and reservation hints', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId(
      'delivery_app',
    );
    final profile = defaultPOSCommerceChannelBehaviorRegistry.profileForChannel(
      channel.id,
    );

    final hints = POSOrderFulfillmentBehaviorPolicy.hintsFor(
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
      ),
      behaviorProfile: profile,
    );

    expect(
      hints.map((hint) => hint.label),
      containsAll(['Courier handoff', 'Stock reserved', 'Account terms']),
    );
  });
}

Order _order({Customer? customer}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    customer: customer,
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}

Customer _customer() {
  return Customer(
    id: 'customer_1',
    name: 'Aisyah',
    phone: '08123456789',
    email: 'aisyah@example.com',
    loyaltyPoints: 10,
  );
}
