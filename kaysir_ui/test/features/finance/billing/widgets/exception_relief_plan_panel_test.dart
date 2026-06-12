import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/exception_relief_plan_panel.dart';

void main() {
  testWidgets('BillingExceptionReliefPlanPanel renders governance blockers', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingExceptionReliefPlanPanel(
        plan: planBillingExceptionRelief(
          config: constructionBillingPolicyConfig(),
          kind: BillingExceptionEventKind.forceMajeure,
          affectedInvoiceCount: 12,
          openAmount: 42600,
          reliefDurationDays: 21,
          evidenceCaptured: true,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-exception-relief-plan-forceMajeure')),
      findsOneWidget,
    );
    expect(find.text('Force majeure relief plan'), findsOneWidget);
    expect(find.text('Needs governance'), findsOneWidget);
    expect(find.text('Exposure'), findsOneWidget);
    expect(find.text(r'$42,600.00'), findsOneWidget);
    expect(find.text('Submit approval'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(
      find.text('Approval must be granted before relief is applied.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingExceptionReliefPlanPanel renders ready workflows', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingExceptionReliefPlanPanel(
        plan: planBillingExceptionRelief(
          config: constructionBillingPolicyConfig(),
          kind: BillingExceptionEventKind.forceMajeure,
          affectedInvoiceCount: 2,
          openAmount: 900,
          reliefDurationDays: 7,
          approvalGranted: true,
          evidenceCaptured: true,
        ),
      ),
    );

    expect(find.text('Force majeure relief plan'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Pause due dates'), findsOneWidget);
    expect(find.text('Capture evidence'), findsOneWidget);
    expect(find.text('Done'), findsWidgets);
    expect(
      find.text('Approval must be granted before relief is applied.'),
      findsNothing,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: SizedBox(width: 660, child: child)),
      ),
    ),
  );
}
