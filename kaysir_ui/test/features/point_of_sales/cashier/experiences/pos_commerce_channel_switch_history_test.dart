import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('switch history records newest entries first and trims to limit', () {
    var history = POSCommerceChannelSwitchHistory.empty(limit: 2);

    history = history.record(
      _result(targetChannelId: 'web_store'),
      occurredAt: DateTime(2026, 6, 1, 9),
      sequence: 1,
    );
    history = history.record(
      _result(targetChannelId: 'delivery_app'),
      occurredAt: DateTime(2026, 6, 1, 10),
      sequence: 2,
    );
    history = history.record(
      _result(targetChannelId: 'phone_order'),
      occurredAt: DateTime(2026, 6, 1, 11),
      sequence: 3,
    );

    expect(history.entries, hasLength(2));
    expect(history.entries.first.summaryLabel, 'Switched to Phone order');
    expect(history.entries.last.summaryLabel, 'Switched to Delivery app');
    expect(history.changedCount, 2);
    expect(
      history.entries.map((entry) => entry.sequence),
      orderedEquals([3, 2]),
    );
  });

  test('switch history tracks attention and search terms', () {
    final history = POSCommerceChannelSwitchHistory.empty().record(
      _result(
        targetChannelId: 'delivery_app',
        order: _order(),
        resolvedFulfillmentContext: const POSOrderFulfillmentContext(
          mode: POSFulfillmentMode.delivery,
        ),
      ),
      occurredAt: DateTime(2026, 6, 1, 9),
      sequence: 1,
    );

    expect(history.attentionCount, 1);
    expect(history.latest?.requiresAttention, isTrue);
    expect(history.searchTerms, contains('requires attention'));
    expect(history.searchTerms, contains('Delivery address needed'));
  });

  test('switch history notifier records and clears entries', () {
    final notifier = POSCommerceChannelSwitchHistoryNotifier(
      clock: () => DateTime(2026, 6, 1, 9, 30),
      limit: 2,
    );
    final result = _result(targetChannelId: 'web_store');

    final entry = notifier.record(result);

    expect(entry.sequence, 1);
    expect(entry.result, same(result));
    expect(notifier.state.entries.single, same(entry));
    expect(notifier.state.latest?.occurredAt, DateTime(2026, 6, 1, 9, 30));

    notifier.clear();

    expect(notifier.state.isEmpty, isTrue);
  });
}

POSCommerceChannelSwitchResult _result({
  required String targetChannelId,
  POSOrderFulfillmentContext? resolvedFulfillmentContext,
  Order? order,
}) {
  final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
    'in_store',
  );
  final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
    targetChannelId,
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
    order: order,
  );

  return POSCommerceChannelSwitchResult.fromPlan(
    plan: plan,
    resolvedFulfillmentContext:
        resolvedFulfillmentContext ??
        POSOrderFulfillmentContext.forChannel(targetChannel),
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
    createdAt: DateTime(2026, 6, 1, 9),
    status: 'pending',
  );
}
