import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_action_state.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/models/relief_impact_summary.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_approval_guidance_resolver.dart';
import 'package:kaysir/features/finance/billing/utils/relief_execution_plan_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_follow_up_work_items.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';
import 'package:kaysir/features/finance/billing/utils/relief_monitoring_plan_builder.dart';
import 'package:kaysir/features/finance/billing/widgets/follow_up_work_queue_panel.dart';

void main() {
  testWidgets('BillingFollowUpWorkQueuePanel renders ready work', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingFollowUpWorkQueuePanel(
        queue: buildReliefMonitoringFollowUpWorkQueue(
          plan: buildBillingExceptionReliefMonitoringPlan(
            executionPlan: buildBillingExceptionReliefExecutionPlan(
              guidance: resolveBillingExceptionReliefApprovalGuidance(
                summary: _impactSummary(approvalGranted: true),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-follow-up-work-queue-panel')),
      findsOneWidget,
    );
    expect(find.text('Follow-up queue'), findsOneWidget);
    expect(find.text('Exception relief'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Owners'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Execution start'), findsOneWidget);
    expect(find.text('Cash forecast review'), findsOneWidget);
    expect(find.text('Customer success'), findsOneWidget);
  });

  testWidgets('BillingFollowUpWorkQueuePanel renders blocked work', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingFollowUpWorkQueuePanel(
        queue: buildReliefMonitoringFollowUpWorkQueue(
          plan: buildBillingExceptionReliefMonitoringPlan(
            executionPlan: buildBillingExceptionReliefExecutionPlan(
              guidance: resolveBillingExceptionReliefApprovalGuidance(
                summary: _impactSummary(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Follow-up queue'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('Resolve execution blockers'), findsOneWidget);
    expect(
      find.text('Approval must be granted before relief is applied.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingFollowUpWorkQueuePanel renders disabled action state', (
    tester,
  ) async {
    BillingFollowUpWorkItem? selectedItem;

    await _pumpPanel(
      tester,
      BillingFollowUpWorkQueuePanel(
        queue: _actionQueue(),
        actionStateBuilder:
            (_) => const BillingFollowUpWorkActionState(
              label: 'Resolve blocker',
              isEnabled: false,
              disabledReason: 'Waiting for policy approval.',
            ),
        onItemSelected: (item) {
          selectedItem = item;
        },
      ),
    );

    expect(find.text('Resolve blocker'), findsOneWidget);
    expect(find.byIcon(Icons.lock_clock_outlined), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    await tester.longPress(find.text('Resolve blocker'));
    await tester.pumpAndSettle();

    expect(find.text('Waiting for policy approval.'), findsOneWidget);

    await tester.tap(find.text('Manual action review'));
    await tester.pump();

    expect(selectedItem?.id, 'manual-action');
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

BillingFollowUpWorkQueue _actionQueue() {
  return BillingFollowUpWorkQueue(
    title: 'Manual queue',
    sourceLabel: 'Manual work',
    items: [
      BillingFollowUpWorkItem(
        id: 'manual-action',
        source: BillingFollowUpWorkSource.external,
        priority: BillingFollowUpWorkPriority.high,
        status: BillingFollowUpWorkStatus.ready,
        title: 'Manual action review',
        description: 'Review a domain-specific approval before opening.',
        ownerRole: 'Billing operator',
        dueInDays: 0,
        tags: const ['Approval'],
      ),
    ],
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
