import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_capability.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/policy_exception_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/policy_exception_decision_panel.dart';

void main() {
  testWidgets('BillingPolicyExceptionDecisionPanel renders ready plan', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingPolicyExceptionDecisionPanel(
        plan: planBillingPolicyException(
          config: constructionBillingPolicyConfig(),
          kind: BillingExceptionEventKind.forceMajeure,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-policy-exception-plan-forceMajeure')),
      findsOneWidget,
    );
    expect(find.text('Force majeure'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Pause due dates'), findsOneWidget);
    expect(find.text('Suspend dunning'), findsOneWidget);
    expect(find.text('Waive late fees'), findsOneWidget);
    expect(
      find.text('Requires approval and evidence before relief is applied.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingPolicyExceptionDecisionPanel renders blocked plan', (
    tester,
  ) async {
    final config = constructionBillingPolicyConfig().disable(
      BillingPolicyCapabilityId.paymentReschedule,
    );

    await _pumpPanel(
      tester,
      BillingPolicyExceptionDecisionPanel(
        plan: planBillingPolicyException(
          config: config,
          kind: BillingExceptionEventKind.forceMajeure,
        ),
      ),
    );

    expect(find.text('Needs capability'), findsOneWidget);
    expect(find.text('Reschedule payments'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('billing-policy-effect-reschedulePayments')),
      findsOneWidget,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(900, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: SizedBox(width: 620, child: child)),
      ),
    ),
  );
}
