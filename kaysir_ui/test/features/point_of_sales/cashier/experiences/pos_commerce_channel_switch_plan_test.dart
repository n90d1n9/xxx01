import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('commerce channel switch plan keeps current channel as a no-op', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('in_store');

    final plan = POSCommerceChannelSwitchPlan.resolve(
      currentChannel: channel,
      targetChannel: channel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      order: null,
    );

    expect(plan.isCurrent, isTrue);
    expect(plan.needsConfirmation, isFalse);
    expect(plan.changesChannel, isFalse);
    expect(plan.changesLayout, isFalse);
    expect(plan.changesFulfillmentMode, isFalse);
    expect(plan.impactLabel, 'Current channel');
    expect(
      plan.actions.single.role,
      POSCommerceChannelSwitchPlanActionRole.keepChannel,
    );
    expect(plan.actions.single.label, 'Keep In-store');
  });

  test('commerce channel switch plan describes active order impact', () {
    final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'in_store',
    );
    final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
      'delivery_app',
    );

    final plan = POSCommerceChannelSwitchPlan.resolve(
      currentChannel: currentChannel,
      targetChannel: targetChannel,
      currentLayoutPreference: POSLayoutPreference.auto,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        currentChannel,
      ),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        targetChannel,
      ),
      order: _order(),
    );

    expect(plan.isCurrent, isFalse);
    expect(plan.needsConfirmation, isTrue);
    expect(plan.changesChannel, isTrue);
    expect(plan.changesLayout, isTrue);
    expect(plan.changesFulfillmentMode, isTrue);
    expect(plan.hasFulfillmentIssues, isTrue);
    expect(plan.needsFulfillmentReview, isTrue);
    expect(plan.targetLayoutPreference, POSLayoutPreference.checkout);
    expect(plan.impactLabel, 'Switches channel, layout, and fulfillment');
    expect(
      plan.actions.map((action) => action.label),
      containsAll([
        'Switch to Delivery app',
        'Use Checkout layout',
        'Delivery address needed',
      ]),
    );
    expect(
      plan.actions.last.role,
      POSCommerceChannelSwitchPlanActionRole.reviewFulfillment,
    );
    expect(plan.actions.last.requiresAttention, isTrue);
  });
}

Order _order() {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
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
