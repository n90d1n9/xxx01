import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_promise_policy.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_fulfillment_promise_policy_notice.dart';

void main() {
  testWidgets(
    'OrderFulfillmentPromisePolicyNotice stays quiet without issues',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OrderFulfillmentPromisePolicyNotice(issues: [])),
        ),
      );

      expect(find.text('Promise policy needs review'), findsNothing);
    },
  );

  testWidgets('OrderFulfillmentPromisePolicyNotice renders policy issues', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderFulfillmentPromisePolicyNotice(
            issues: const [
              OrderFulfillmentPromisePolicyIssue(
                type:
                    OrderFulfillmentPromisePolicyIssueType
                        .nonPositiveWarningWindow,
                message: 'Warning window must be greater than zero.',
              ),
              OrderFulfillmentPromisePolicyIssue(
                type: OrderFulfillmentPromisePolicyIssueType.duplicateRuleId,
                message: 'Duplicate rule id "pickup" found.',
              ),
              OrderFulfillmentPromisePolicyIssue(
                type: OrderFulfillmentPromisePolicyIssueType.ruleWithoutMatcher,
                message: 'Rule must define a channel or fulfillment mode.',
              ),
              OrderFulfillmentPromisePolicyIssue(
                type: OrderFulfillmentPromisePolicyIssueType.blankRuleTargetId,
                message: 'Rule target id cannot be blank.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Promise policy needs review'), findsOneWidget);
    expect(
      find.text(
        '4 configuration issues can affect fulfillment targets for this workspace.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Warning window must be greater than zero.'),
      findsOneWidget,
    );
    expect(find.text('Duplicate rule id "pickup" found.'), findsOneWidget);
    expect(
      find.text('Rule must define a channel or fulfillment mode.'),
      findsOneWidget,
    );
    expect(find.text('Rule target id cannot be blank.'), findsNothing);
    expect(find.text('+1 more'), findsOneWidget);
  });
}
