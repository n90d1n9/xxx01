import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/exception_relief_plan.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/models/relief_approval_guidance.dart';
import 'package:kaysir/features/finance/billing/models/relief_execution_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_impact_summary.dart';
import 'package:kaysir/features/finance/billing/models/relief_monitoring_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_approval_guidance_resolver.dart';
import 'package:kaysir/features/finance/billing/utils/relief_execution_plan_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_follow_up_work_items.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';
import 'package:kaysir/features/finance/billing/utils/relief_monitoring_plan_builder.dart';

void main() {
  test('buildReliefMonitoringFollowUpWorkQueue builds ready queue', () {
    final queue = buildReliefMonitoringFollowUpWorkQueue(
      plan: _monitoringPlan(),
    );

    expect(queue.title, 'Relief follow-up queue');
    expect(queue.sourceLabel, 'Exception relief');
    expect(queue.totalCount, 7);
    expect(queue.readyCount, 3);
    expect(queue.blockedCount, 0);
    expect(queue.scheduledCount, 4);
    expect(queue.ownerCount, 7);
    expect(queue.workWindowDays, 24);
    expect(queue.headlineLabel, '3 ready items');
    expect(queue.items.first.title, 'Execution start');
    expect(queue.items.first.status, BillingFollowUpWorkStatus.ready);
    expect(queue.items.first.priority, BillingFollowUpWorkPriority.high);
    expect(
      queue.itemsForOwner('Treasury').single.title,
      'Cash forecast review',
    );
  });

  test('buildReliefMonitoringFollowUpWorkQueue preserves blockers', () {
    final queue = buildReliefMonitoringFollowUpWorkQueue(
      plan: _monitoringPlan(approvalGranted: false),
    );

    expect(queue.totalCount, 1);
    expect(queue.blockedCount, 1);
    expect(queue.readyCount, 0);
    expect(queue.headlineLabel, '1 blocked item');
    expect(queue.items.single.status, BillingFollowUpWorkStatus.blocked);
    expect(queue.items.single.priority, BillingFollowUpWorkPriority.urgent);
    expect(queue.items.single.title, 'Resolve execution blockers');
    expect(
      queue.blockers,
      contains('Approval must be granted before relief is applied.'),
    );
  });

  test(
    'buildReliefMonitoringFollowUpWorkQueue ranks escalation work first',
    () {
      final queue = buildReliefMonitoringFollowUpWorkQueue(
        plan: _monitoringPlan(escalationExposureThreshold: 30000),
      );

      expect(queue.totalCount, 8);
      expect(queue.blockedCount, 1);
      expect(queue.items.first.title, 'Execution start');
      expect(queue.items.first.status, BillingFollowUpWorkStatus.blocked);
      expect(
        queue.items.any((item) => item.title == 'Escalation review'),
        isTrue,
      );
    },
  );
}

BillingExceptionReliefMonitoringPlan _monitoringPlan({
  bool approvalGranted = true,
  double escalationExposureThreshold = 50000,
}) {
  return buildBillingExceptionReliefMonitoringPlan(
    executionPlan: _executionPlan(
      approvalGranted: approvalGranted,
      escalationExposureThreshold: escalationExposureThreshold,
    ),
  );
}

BillingExceptionReliefExecutionPlan _executionPlan({
  required bool approvalGranted,
  required double escalationExposureThreshold,
}) {
  return buildBillingExceptionReliefExecutionPlan(
    guidance: _approvalGuidance(
      approvalGranted: approvalGranted,
      escalationExposureThreshold: escalationExposureThreshold,
    ),
  );
}

BillingExceptionReliefApprovalGuidance _approvalGuidance({
  required bool approvalGranted,
  required double escalationExposureThreshold,
}) {
  return resolveBillingExceptionReliefApprovalGuidance(
    summary: _impactSummary(approvalGranted: approvalGranted),
    escalationExposureThreshold: escalationExposureThreshold,
  );
}

BillingExceptionReliefImpactSummary _impactSummary({
  required bool approvalGranted,
}) {
  return summarizeBillingExceptionReliefImpact(
    packet: buildBillingExceptionReliefApplicationPacket(
      plan: _reliefPlan(approvalGranted: approvalGranted),
      requestedBy: 'Ops lead',
      requestedAt: DateTime.utc(2026, 1, 15, 9),
    ),
  );
}

BillingExceptionReliefPlan _reliefPlan({required bool approvalGranted}) {
  return planBillingExceptionRelief(
    config: constructionBillingPolicyConfig(),
    kind: BillingExceptionEventKind.forceMajeure,
    affectedInvoiceCount: 12,
    openAmount: 42600,
    reliefDurationDays: 21,
    approvalGranted: approvalGranted,
    evidenceCaptured: true,
  );
}
