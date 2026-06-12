import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_promise_policy.dart';
import 'package:kaysir/features/ecommerce/order/states/order_fulfillment_promise_policy_provider.dart';

void main() {
  test('promise policy provider exposes the default ecommerce policy', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final policy = container.read(
      ecommerceOrderFulfillmentPromisePolicyProvider,
    );

    expect(policy.warningWindow, const Duration(minutes: 15));
    expect(policy.rules.map((rule) => rule.id), contains('delivery_app'));
    expect(
      policy.rules.map((rule) => rule.id),
      contains('marketplace_shipment'),
    );
    expect(
      container.read(ecommerceOrderFulfillmentPromisePolicyIssuesProvider),
      isEmpty,
    );
  });

  test('promise policy provider can be overridden by product lines', () {
    const customPolicy = OrderFulfillmentPromisePolicy(
      warningWindow: Duration(minutes: 5),
      rules: [
        OrderFulfillmentPromiseRule(
          id: 'espresso_bar_pickup',
          label: 'Espresso bar pickup',
          fulfillmentModeKey: 'pickup',
          target: OrderFulfillmentPromiseTarget(
            id: 'espresso_pickup',
            label: 'Espresso pickup',
            duration: Duration(minutes: 8),
          ),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        ecommerceOrderFulfillmentPromisePolicyProvider.overrideWithValue(
          customPolicy,
        ),
      ],
    );
    addTearDown(container.dispose);

    final policy = container.read(
      ecommerceOrderFulfillmentPromisePolicyProvider,
    );

    expect(policy.warningWindow, const Duration(minutes: 5));
    expect(policy.rules.single.id, 'espresso_bar_pickup');
    expect(policy.rules.single.target.duration, const Duration(minutes: 8));
  });

  test('promise policy issues provider follows overridden policies', () {
    const customPolicy = OrderFulfillmentPromisePolicy(
      warningWindow: Duration.zero,
      rules: [
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
    final container = ProviderContainer(
      overrides: [
        ecommerceOrderFulfillmentPromisePolicyProvider.overrideWithValue(
          customPolicy,
        ),
      ],
    );
    addTearDown(container.dispose);

    final issues = container.read(
      ecommerceOrderFulfillmentPromisePolicyIssuesProvider,
    );

    expect(issues, isNotEmpty);
    expect(
      issues.map((issue) => issue.type),
      contains(OrderFulfillmentPromisePolicyIssueType.nonPositiveWarningWindow),
    );
    expect(
      issues.map((issue) => issue.type),
      contains(OrderFulfillmentPromisePolicyIssueType.blankRuleId),
    );
  });
}
