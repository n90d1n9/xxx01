import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/relief_impact_summary.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_approval_guidance_resolver.dart';
import 'package:kaysir/features/finance/billing/utils/relief_execution_plan_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';
import 'package:kaysir/features/finance/billing/widgets/relief_execution_plan_panel.dart';

void main() {
  testWidgets('BillingExceptionReliefExecutionPlanPanel renders handoff', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingExceptionReliefExecutionPlanPanel(
        plan: buildBillingExceptionReliefExecutionPlan(
          guidance: resolveBillingExceptionReliefApprovalGuidance(
            summary: _impactSummary(approvalGranted: true),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-exception-relief-execution-plan')),
      findsOneWidget,
    );
    expect(find.text('Execution handoff'), findsOneWidget);
    expect(find.text('Controls required'), findsOneWidget);
    expect(find.text('Required steps'), findsOneWidget);
    expect(find.text('Finance owner sign-off'), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
    expect(find.text('Treasury'), findsOneWidget);
    expect(find.text('Apply relief commands'), findsOneWidget);
    expect(find.text('Billing operations'), findsOneWidget);
  });

  testWidgets('BillingExceptionReliefExecutionPlanPanel renders blockers', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingExceptionReliefExecutionPlanPanel(
        plan: buildBillingExceptionReliefExecutionPlan(
          guidance: resolveBillingExceptionReliefApprovalGuidance(
            summary: _impactSummary(),
          ),
        ),
      ),
    );

    expect(find.text('Execution handoff'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Resolve blockers'), findsOneWidget);
    expect(
      find.text('Approval must be granted before relief is applied.'),
      findsOneWidget,
    );
  });
}

BillingExceptionReliefImpactSummary _impactSummary({
  bool approvalGranted = false,
}) {
  final plan = planBillingExceptionRelief(
    config: constructionBillingPolicyConfig(),
    kind: BillingExceptionEventKind.forceMajeure,
    affectedInvoiceCount: 12,
    openAmount: 42600,
    reliefDurationDays: 21,
    approvalGranted: approvalGranted,
    evidenceCaptured: true,
  );

  return summarizeBillingExceptionReliefImpact(
    packet: buildBillingExceptionReliefApplicationPacket(
      plan: plan,
      requestedBy: 'Ops lead',
      requestedAt: DateTime.utc(2026, 1, 15, 9),
    ),
  );
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(980, 820);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: SizedBox(width: 760, child: child)),
      ),
    ),
  );
}
