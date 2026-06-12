import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_promise.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('classifies promise pressure across visible active orders', () {
    final now = DateTime(2026, 5, 31, 12);

    final summary = OrderFulfillmentPromiseSummary.fromOrders(
      now: now,
      orders: [
        _order(
          id: 'blocked',
          createdAt: now.subtract(const Duration(minutes: 10)),
          paid: false,
          destination: '',
        ),
        _order(
          id: 'over',
          channelId: 'delivery_app',
          channelLabel: 'Delivery app',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        _order(id: 'due', createdAt: now.subtract(const Duration(minutes: 50))),
        _order(
          id: 'ready',
          status: 'ready',
          fulfillmentModeKey: 'pickup',
          fulfillmentModeLabel: 'Pickup',
          createdAt: now.subtract(const Duration(minutes: 20)),
        ),
        _order(
          id: 'track',
          fulfillmentModeKey: 'shipment',
          fulfillmentModeLabel: 'Shipment',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        _order(
          id: 'closed',
          status: 'completed',
          createdAt: now.subtract(const Duration(hours: 4)),
        ),
      ],
    );

    expect(summary.activeOrderCount, 5);
    expect(summary.terminalOrderCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.overTargetCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.readyHandoffCount, 1);
    expect(summary.onTrackCount, 1);
    expect(summary.title, 'Promise blockers need clearing');
    expect(summary.tone, OrderFulfillmentPromiseTone.danger);
    expect(summary.nextPromiseDueLabel, '10m');

    final bands = {for (final band in summary.bands) band.id: band};
    expect(bands['blocked']?.count, 1);
    expect(bands['over_target']?.count, 1);
    expect(bands['due_soon']?.detail, contains('Inside next 15m'));
  });

  test('terminal-only workspace reports closed promise pressure', () {
    final now = DateTime(2026, 5, 31, 12);

    final summary = OrderFulfillmentPromiseSummary.fromOrders(
      now: now,
      orders: [
        _order(
          id: 'closed',
          status: 'completed',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        _order(
          id: 'cancelled',
          status: 'cancelled',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
    );

    expect(summary.activeOrderCount, 0);
    expect(summary.terminalOrderCount, 2);
    expect(summary.title, 'Fulfillment promises are closed');
    expect(summary.nextPromiseDueLabel, 'No active target');
    expect(summary.tone, OrderFulfillmentPromiseTone.success);
  });

  test('delivery app target is tighter than standard delivery target', () {
    final now = DateTime(2026, 5, 31, 12);

    final deliveryApp = OrderFulfillmentPromiseSummary.fromOrders(
      now: now,
      orders: [
        _order(
          id: 'courier',
          channelId: 'delivery_app',
          channelLabel: 'Delivery app',
          createdAt: now.subtract(const Duration(minutes: 40)),
        ),
      ],
    );
    final ownedDelivery = OrderFulfillmentPromiseSummary.fromOrders(
      now: now,
      orders: [
        _order(
          id: 'owned',
          channelId: 'web_store',
          channelLabel: 'Web store',
          createdAt: now.subtract(const Duration(minutes: 40)),
        ),
      ],
    );

    expect(deliveryApp.overTargetCount, 1);
    expect(ownedDelivery.overTargetCount, 0);
    expect(ownedDelivery.dueSoonCount, 0);
    expect(ownedDelivery.onTrackCount, 1);
  });

  test('custom promise rules can override product-specific targets', () {
    final now = DateTime(2026, 5, 31, 12);
    final policy = OrderFulfillmentPromisePolicy.withRules(
      warningWindow: const Duration(minutes: 20),
      rules: const [
        OrderFulfillmentPromiseRule(
          id: 'priority_social_pickup',
          label: 'Priority social pickup',
          channelId: 'social_order',
          fulfillmentModeKey: 'pickup',
          target: OrderFulfillmentPromiseTarget(
            id: 'priority_pickup',
            label: 'Priority pickup',
            duration: Duration(minutes: 25),
          ),
        ),
      ],
    );

    final summary = OrderFulfillmentPromiseSummary.fromOrders(
      now: now,
      policy: policy,
      orders: [
        _order(
          id: 'social',
          channelId: 'social_order',
          channelLabel: 'Social order',
          fulfillmentModeKey: 'pickup',
          fulfillmentModeLabel: 'Pickup',
          createdAt: now.subtract(const Duration(minutes: 30)),
        ),
      ],
    );

    expect(summary.overTargetCount, 1);
    expect(summary.title, 'Fulfillment promises are over target');
  });

  test(
    'promise policy prefers channel and mode rules over generic mode rules',
    () {
      final now = DateTime(2026, 5, 31, 12);
      const policy = OrderFulfillmentPromisePolicy();
      final marketplaceShipment = _order(
        id: 'marketplace',
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        fulfillmentModeKey: 'shipment',
        fulfillmentModeLabel: 'Shipment',
        createdAt: now,
      );
      final webShipment = _order(
        id: 'web',
        channelId: 'web_store',
        channelLabel: 'Web store',
        fulfillmentModeKey: 'shipment',
        fulfillmentModeLabel: 'Shipment',
        createdAt: now,
      );

      expect(policy.ruleFor(marketplaceShipment)?.id, 'marketplace_shipment');
      expect(
        policy.targetFor(marketplaceShipment).duration,
        const Duration(hours: 12),
      );
      expect(policy.ruleFor(webShipment)?.id, 'shipment');
      expect(policy.targetFor(webShipment).duration, const Duration(days: 1));
    },
  );

  test('promise policy validation catches unsafe product overrides', () {
    const policy = OrderFulfillmentPromisePolicy(
      warningWindow: Duration.zero,
      defaultTarget: OrderFulfillmentPromiseTarget(
        id: '',
        label: '',
        duration: Duration.zero,
      ),
      rules: [
        OrderFulfillmentPromiseRule(
          id: 'duplicate',
          label: 'First pickup',
          fulfillmentModeKey: 'pickup',
          target: OrderFulfillmentPromiseTarget(
            id: 'pickup_a',
            label: 'Pickup A',
            duration: Duration(minutes: 10),
          ),
        ),
        OrderFulfillmentPromiseRule(
          id: 'duplicate',
          label: 'Second pickup',
          fulfillmentModeKey: 'pickup',
          target: OrderFulfillmentPromiseTarget(
            id: 'pickup_b',
            label: 'Pickup B',
            duration: Duration(minutes: 15),
          ),
        ),
        OrderFulfillmentPromiseRule(
          id: '',
          label: '',
          target: OrderFulfillmentPromiseTarget(
            id: '',
            label: '',
            duration: Duration.zero,
          ),
        ),
      ],
    );

    final issues = policy.validate();
    final issueTypes = issues.map((issue) => issue.type).toSet();

    expect(policy.isValid, isFalse);
    expect(
      issueTypes,
      containsAll({
        OrderFulfillmentPromisePolicyIssueType.nonPositiveWarningWindow,
        OrderFulfillmentPromisePolicyIssueType.blankDefaultTargetId,
        OrderFulfillmentPromisePolicyIssueType.blankDefaultTargetLabel,
        OrderFulfillmentPromisePolicyIssueType.nonPositiveDefaultTargetDuration,
        OrderFulfillmentPromisePolicyIssueType.duplicateRuleId,
        OrderFulfillmentPromisePolicyIssueType.duplicateRuleMatcher,
        OrderFulfillmentPromisePolicyIssueType.blankRuleId,
        OrderFulfillmentPromisePolicyIssueType.blankRuleLabel,
        OrderFulfillmentPromisePolicyIssueType.ruleWithoutMatcher,
        OrderFulfillmentPromisePolicyIssueType.blankRuleTargetId,
        OrderFulfillmentPromisePolicyIssueType.blankRuleTargetLabel,
        OrderFulfillmentPromisePolicyIssueType.nonPositiveRuleTargetDuration,
      }),
    );
    expect(() => policy.throwIfInvalid(), throwsA(isA<StateError>()));
  });
}

Order _order({
  required String id,
  required DateTime createdAt,
  String status = 'processing',
  bool paid = true,
  String channelId = 'web_store',
  String channelLabel = 'Web store',
  String fulfillmentModeKey = 'delivery',
  String fulfillmentModeLabel = 'Delivery',
  String destination = 'Jl. Sudirman 2',
  String contactName = 'Amina',
}) {
  final product = Product(id: '$id-product', name: 'Coffee', price: 50000);

  return Order(
    id: id,
    items: [
      OrderItem(
        id: '$id-line',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments:
        paid
            ? [
              Payment(
                id: '$id-payment',
                amount: product.price,
                method: 'Card',
                timestamp: createdAt,
                reference: '$id-ref',
                isComplete: true,
              ),
            ]
            : const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: createdAt,
    status: status,
    fulfillment: OrderFulfillmentSnapshot(
      commerceChannelId: channelId,
      commerceChannelLabel: channelLabel,
      fulfillmentModeKey: fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentModeLabel,
      contactName: contactName,
      destination: destination,
      statusLabel: paid ? 'Paid' : 'Unpaid',
      summaryLabel: fulfillmentModeLabel,
    ),
  );
}
