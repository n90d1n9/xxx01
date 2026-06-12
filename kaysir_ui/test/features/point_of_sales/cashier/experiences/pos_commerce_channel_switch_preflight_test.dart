import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_preflight.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('switch preflight asks for delivery destination', () {
    final preflight = POSCommerceChannelSwitchPreflight.fromPlan(
      _plan(targetChannelId: 'delivery_app', order: _order()),
    );

    expect(preflight.hasRequirements, isTrue);
    expect(preflight.requirements, hasLength(1));
    expect(
      preflight.requirements.single.field,
      POSCommerceChannelSwitchPreflightField.destination,
    );
    expect(preflight.requirements.single.label, 'Delivery destination');
    expect(preflight.requirements.single.hintText, 'Address or delivery notes');
    expect(preflight.canConfirm, isFalse);
    expect(
      preflight.isSatisfiedBy(
        preflight.requirements.single.applyTo(
          preflight.context,
          'Jl. Merdeka 10',
        ),
      ),
      isTrue,
    );
    expect(preflight.searchTerms, contains('Delivery destination'));
  });

  test('switch preflight asks for pickup contact', () {
    final preflight = POSCommerceChannelSwitchPreflight.fromPlan(
      _plan(targetChannelId: 'web_store', order: _order()),
    );

    expect(preflight.hasRequirements, isTrue);
    expect(preflight.requirements, hasLength(1));
    expect(
      preflight.requirements.single.field,
      POSCommerceChannelSwitchPreflightField.contact,
    );
    expect(preflight.requirements.single.label, 'Pickup contact');
  });

  test('switch preflight hides missing, empty, and current orders', () {
    final currentPreflight = POSCommerceChannelSwitchPreflight.fromPlan(
      _plan(targetChannelId: 'in_store', order: _order()),
    );
    final missingOrderPreflight = POSCommerceChannelSwitchPreflight.fromPlan(
      _plan(targetChannelId: 'delivery_app'),
    );
    final emptyOrderPreflight = POSCommerceChannelSwitchPreflight.fromPlan(
      _plan(targetChannelId: 'delivery_app', order: _order(itemCount: 0)),
    );

    expect(currentPreflight.hasRequirements, isFalse);
    expect(missingOrderPreflight.hasRequirements, isFalse);
    expect(emptyOrderPreflight.hasRequirements, isFalse);
    expect(currentPreflight.canConfirm, isTrue);
    expect(missingOrderPreflight.canConfirm, isTrue);
    expect(emptyOrderPreflight.canConfirm, isTrue);
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

Order _order({int itemCount = 1}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      for (var index = 0; index < itemCount; index += 1)
        OrderItem(
          id: 'line_$index',
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
