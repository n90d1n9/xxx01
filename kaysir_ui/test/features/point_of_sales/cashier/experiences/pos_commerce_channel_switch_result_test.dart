import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('switch result reports preserved, changed, and completed details', () {
    final plan = _plan(targetChannelId: 'delivery_app', order: _order());

    final result = POSCommerceChannelSwitchResult.fromPlan(
      plan: plan,
      resolvedFulfillmentContext: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
        destination: 'Jl. Merdeka 10',
      ),
    );

    expect(result.changesChannel, isTrue);
    expect(result.changesLayout, isTrue);
    expect(result.changesFulfillmentMode, isTrue);
    expect(result.activeOrderPreserved, isTrue);
    expect(result.requiresAttention, isFalse);
    expect(result.completedRequirementCount, 1);
    expect(
      result.summaryLabel,
      'Switched to Delivery app with 1 fulfillment detail',
    );
    expect(
      result.items.map((item) => item.label),
      containsAll([
        'Channel switched to Delivery app',
        'Layout changed to Checkout',
        'Order stayed active',
        'Fulfillment changed to Delivery',
        'Delivery destination completed',
      ]),
    );
    expect(result.searchTerms, contains('Jl. Merdeka 10'));
  });

  test('switch result keeps unresolved requirements actionable', () {
    final plan = _plan(targetChannelId: 'delivery_app', order: _order());

    final result = POSCommerceChannelSwitchResult.fromPlan(
      plan: plan,
      resolvedFulfillmentContext: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
      ),
    );

    expect(result.completedRequirementCount, 0);
    expect(result.requiresAttention, isTrue);
    expect(
      result.items.map((item) => item.label),
      contains('Delivery address needed'),
    );
    expect(
      result.items
          .where(
            (item) =>
                item.role ==
                POSCommerceChannelSwitchResultItemRole.unresolvedRequirement,
          )
          .single
          .message,
      'Add a delivery destination before closing.',
    );
  });

  test('switch result reports current channel as preserved', () {
    final plan = _plan(targetChannelId: 'in_store');

    final result = POSCommerceChannelSwitchResult.fromPlan(
      plan: plan,
      resolvedFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        plan.targetChannel,
      ),
    );

    expect(result.hasChanges, isFalse);
    expect(result.summaryLabel, 'In-store already active');
    expect(
      result.items.map((item) => item.label),
      containsAll([
        'Channel kept as In-store',
        'Layout kept as Auto',
        'Fulfillment kept as Immediate handoff',
      ]),
    );
  });
}

POSCommerceChannelSwitchPlan _plan({
  required String targetChannelId,
  Order? order,
}) {
  final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
    'in_store',
  );
  final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
    targetChannelId,
  );

  return POSCommerceChannelSwitchPlan.resolve(
    currentChannel: currentChannel,
    targetChannel: targetChannel,
    currentLayoutPreference: POSLayoutPreference.auto,
    currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
      currentChannel,
    ),
    targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
      targetChannel,
    ),
    order: order,
  );
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
