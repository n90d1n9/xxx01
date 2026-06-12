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
import 'package:kaysir/features/finance/billing/utils/relief_monitoring_plan_builder.dart';
import 'package:kaysir/features/finance/billing/widgets/relief_monitoring_plan_panel.dart';

void main() {
  testWidgets('BillingExceptionReliefMonitoringPlanPanel renders checkpoints', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingExceptionReliefMonitoringPlanPanel(
        plan: buildBillingExceptionReliefMonitoringPlan(
          executionPlan: buildBillingExceptionReliefExecutionPlan(
            guidance: resolveBillingExceptionReliefApprovalGuidance(
              summary: _impactSummary(approvalGranted: true),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-exception-relief-monitoring-plan')),
      findsOneWidget,
    );
    expect(find.text('Monitoring plan'), findsOneWidget);
    expect(find.text('Active watch'), findsOneWidget);
    expect(find.text('Window'), findsOneWidget);
    expect(find.text('24d'), findsOneWidget);
    expect(find.text('Cash forecast review'), findsOneWidget);
    expect(find.text('Collections pause review'), findsOneWidget);
    expect(find.text('Customer follow-up'), findsOneWidget);
    expect(find.text('Relief closeout'), findsOneWidget);
    expect(find.text('Treasury'), findsOneWidget);
  });

  testWidgets('BillingExceptionReliefMonitoringPlanPanel renders blockers', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingExceptionReliefMonitoringPlanPanel(
        plan: buildBillingExceptionReliefMonitoringPlan(
          executionPlan: buildBillingExceptionReliefExecutionPlan(
            guidance: resolveBillingExceptionReliefApprovalGuidance(
              summary: _impactSummary(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Monitoring plan'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Resolve execution blockers'), findsOneWidget);
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
