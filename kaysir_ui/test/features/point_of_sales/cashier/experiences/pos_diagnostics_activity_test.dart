import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_diagnostics_activity.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_activity.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('diagnostics activity combines channel switches and outbox events', () {
    final snapshot = POSDiagnosticsActivitySnapshot.fromSources(
      switchHistory: POSCommerceChannelSwitchHistory.empty().record(
        _result(targetChannelId: 'delivery_app'),
        occurredAt: DateTime(2026, 6, 1, 9),
        sequence: 1,
      ),
      switchActionHistory: POSSwitchActionHistory.empty().record(
        const POSSwitchActionResult.applied(
          kind: POSSwitchActionKind.runtimePack,
          targetId: 'online_pack',
          targetLabel: 'Online Pack',
        ),
        occurredAt: DateTime(2026, 6, 1, 11),
        sequence: 1,
      ),
      outbox: POSOrderSaveOutbox(const <POSOrderSaveOutboxEntry>[], [
        POSOrderSaveOutboxActivity(
          type: POSOrderSaveOutboxActivityType.sent,
          occurredAt: DateTime(2026, 6, 1, 10),
          orderId: 'order_123456',
        ),
      ]),
    );

    expect(snapshot.entries, hasLength(3));
    expect(snapshot.entries.first.title, 'Applied Runtime pack: Online Pack');
    expect(snapshot.channelSwitchCount, 1);
    expect(snapshot.switchActionCount, 1);
    expect(snapshot.orderSyncCount, 1);
    expect(snapshot.attentionCount, 0);
    expect(snapshot.reviewCount, 0);
  });

  test('diagnostics activity searches and filters attention events', () {
    final snapshot = POSDiagnosticsActivitySnapshot.fromSources(
      switchHistory: POSCommerceChannelSwitchHistory.empty().record(
        _result(
          targetChannelId: 'delivery_app',
          order: _order(),
          resolvedFulfillmentContext: const POSOrderFulfillmentContext(
            mode: POSFulfillmentMode.delivery,
          ),
        ),
        occurredAt: DateTime(2026, 6, 1, 9),
        sequence: 1,
      ),
      switchActionHistory: POSSwitchActionHistory.empty().record(
        const POSSwitchActionResult.blocked(
          kind: POSSwitchActionKind.runtimePack,
          targetId: 'no_payment_pack',
          targetLabel: 'No Payment Pack',
          reason: 'Finish current order first',
        ),
        occurredAt: DateTime(2026, 6, 1, 11),
        sequence: 1,
      ),
      outbox: POSOrderSaveOutbox(const [], [
        POSOrderSaveOutboxActivity(
          type: POSOrderSaveOutboxActivityType.failed,
          occurredAt: DateTime(2026, 6, 1, 10),
          orderId: 'order_123456',
          message: 'Network down',
        ),
      ]),
    );

    final attention = snapshot.apply(
      const POSDiagnosticsActivityFilter(
        status: POSDiagnosticsActivityFilterStatus.attention,
      ),
    );
    final network = snapshot.apply(
      const POSDiagnosticsActivityFilter(query: 'network'),
    );
    final channel = snapshot.apply(
      const POSDiagnosticsActivityFilter(
        status: POSDiagnosticsActivityFilterStatus.channelSwitches,
      ),
    );
    final switches = snapshot.apply(
      const POSDiagnosticsActivityFilter(
        status: POSDiagnosticsActivityFilterStatus.switchActions,
      ),
    );

    expect(attention, hasLength(3));
    expect(network.single.title, 'Order #123456 failed');
    expect(
      channel.single.title,
      'Switched to Delivery app; order stayed active',
    );
    expect(switches.single.title, 'Blocked Runtime pack: No Payment Pack');
    expect(
      switches.single.detail,
      'Runtime pack switch blocked: Finish current order first.',
    );
    expect(
      switches.single.supportSummary,
      'Blocked Runtime pack: No Payment Pack - Finish current order first.',
    );
    expect(snapshot.attentionEntries, hasLength(3));
    expect(snapshot.reviewEntries, isEmpty);
    expect(snapshot.countsForQuery('delivery').channelSwitches, 1);
    expect(snapshot.countsForQuery('delivery').orderSync, 0);
    expect(snapshot.countsForQuery('runtime').switchActions, 1);
  });

  test('diagnostics activity treats cancelled switch attempts as review', () {
    final snapshot = POSDiagnosticsActivitySnapshot.fromSources(
      switchHistory: POSCommerceChannelSwitchHistory.empty(),
      switchActionHistory: POSSwitchActionHistory.empty().record(
        const POSSwitchActionResult.cancelled(
          kind: POSSwitchActionKind.commerceChannel,
          targetId: 'web_store',
          targetLabel: 'Web store',
          reason: 'Keep current order?',
        ),
        occurredAt: DateTime(2026, 6, 1, 11),
        sequence: 1,
      ),
      outbox: POSOrderSaveOutbox(const [], const []),
    );

    final review = snapshot.apply(
      const POSDiagnosticsActivityFilter(
        status: POSDiagnosticsActivityFilterStatus.review,
      ),
    );

    expect(snapshot.attentionCount, 0);
    expect(snapshot.reviewCount, 1);
    expect(review.single.title, 'Cancelled Commerce channel: Web store');
    expect(
      review.single.detail,
      'Commerce channel switch cancelled: Keep current order?',
    );
    expect(
      review.single.supportSummary,
      'Cancelled Commerce channel: Web store - Keep current order?',
    );
    expect(snapshot.countsForQuery('web').review, 1);
    expect(POSDiagnosticsActivityFilterStatus.review.label, 'Review');
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
