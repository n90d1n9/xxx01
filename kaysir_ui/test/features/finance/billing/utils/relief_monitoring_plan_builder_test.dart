import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/exception_relief_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_approval_guidance.dart';
import 'package:kaysir/features/finance/billing/models/relief_execution_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_impact_summary.dart';
import 'package:kaysir/features/finance/billing/models/relief_monitoring_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_approval_guidance_resolver.dart';
import 'package:kaysir/features/finance/billing/utils/relief_execution_plan_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';
import 'package:kaysir/features/finance/billing/utils/relief_monitoring_plan_builder.dart';

void main() {
  test('buildBillingExceptionReliefMonitoringPlan builds active watch', () {
    final plan = buildBillingExceptionReliefMonitoringPlan(
      executionPlan: _executionPlan(),
    );

    expect(plan.status, BillingExceptionReliefMonitoringStatus.activeWatch);
    expect(plan.statusLabel, 'Active watch');
    expect(plan.checkpointCount, 7);
    expect(plan.requiredCheckpointCount, 7);
    expect(plan.blockedCheckpointCount, 0);
    expect(plan.monitoringWindowDays, 24);
    expect(
      plan.hasCheckpointKind(
        BillingExceptionReliefMonitoringCheckpointKind.cashForecastReview,
      ),
      isTrue,
    );
    expect(
      plan.hasCheckpointKind(
        BillingExceptionReliefMonitoringCheckpointKind.reliefCloseout,
      ),
      isTrue,
    );
    expect(
      plan
          .checkpointFor(
            BillingExceptionReliefMonitoringCheckpointKind.collectionsReview,
          )
          ?.dueInDays,
      11,
    );
  });

  test(
    'buildBillingExceptionReliefMonitoringPlan blocks unresolved execution',
    () {
      final plan = buildBillingExceptionReliefMonitoringPlan(
        executionPlan: _executionPlan(approvalGranted: false),
      );

      expect(plan.status, BillingExceptionReliefMonitoringStatus.blocked);
      expect(plan.statusLabel, 'Blocked');
      expect(plan.checkpointCount, 1);
      expect(plan.blockedCheckpointCount, 1);
      expect(
        plan.blockers,
        contains('Approval must be granted before relief is applied.'),
      );
      expect(
        plan.hasCheckpointKind(
          BillingExceptionReliefMonitoringCheckpointKind.unblock,
        ),
        isTrue,
      );
    },
  );

  test('buildBillingExceptionReliefMonitoringPlan adds escalation watch', () {
    final plan = buildBillingExceptionReliefMonitoringPlan(
      executionPlan: _executionPlan(escalationExposureThreshold: 30000),
    );

    expect(plan.status, BillingExceptionReliefMonitoringStatus.escalationWatch);
    expect(plan.statusLabel, 'Escalation watch');
    expect(plan.checkpointCount, 8);
    expect(plan.blockedCheckpointCount, 1);
    expect(
      plan.hasCheckpointKind(
        BillingExceptionReliefMonitoringCheckpointKind.escalationReview,
      ),
      isTrue,
    );
    expect(
      plan
          .checkpointFor(
            BillingExceptionReliefMonitoringCheckpointKind.executionStart,
          )
          ?.isBlocked,
      isTrue,
    );
  });
}

BillingExceptionReliefExecutionPlan _executionPlan({
  bool approvalGranted = true,
  double escalationExposureThreshold = 50000,
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
