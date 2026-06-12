import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/exception_relief_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_approval_guidance.dart';
import 'package:kaysir/features/finance/billing/models/relief_execution_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_impact_summary.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_approval_guidance_resolver.dart';
import 'package:kaysir/features/finance/billing/utils/relief_execution_plan_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';

void main() {
  test(
    'buildBillingExceptionReliefExecutionPlan groups controlled execution',
    () {
      final plan = buildBillingExceptionReliefExecutionPlan(
        guidance: _approvalGuidance(),
      );

      expect(
        plan.status,
        BillingExceptionReliefExecutionStatus.controlsRequired,
      );
      expect(plan.statusLabel, 'Controls required');
      expect(plan.stepCount, 7);
      expect(plan.requiredStepCount, 7);
      expect(plan.blockedStepCount, 0);
      expect(plan.phaseCount, 6);
      expect(
        plan.hasPhase(BillingExceptionReliefExecutionPhase.approval),
        isTrue,
      );
      expect(
        plan.hasPhase(BillingExceptionReliefExecutionPhase.forecast),
        isTrue,
      );
      expect(
        plan.hasPhase(BillingExceptionReliefExecutionPhase.application),
        isTrue,
      );
      expect(
        plan
            .stepsForPhase(BillingExceptionReliefExecutionPhase.application)
            .single
            .label,
        'Apply relief commands',
      );
    },
  );

  test(
    'buildBillingExceptionReliefExecutionPlan blocks unresolved guidance',
    () {
      final plan = buildBillingExceptionReliefExecutionPlan(
        guidance: _approvalGuidance(approvalGranted: false),
      );

      expect(plan.status, BillingExceptionReliefExecutionStatus.blocked);
      expect(plan.statusLabel, 'Blocked');
      expect(plan.stepCount, 1);
      expect(plan.blockedStepCount, 1);
      expect(
        plan.blockers,
        contains('Approval must be granted before relief is applied.'),
      );
      expect(
        plan.hasPhase(BillingExceptionReliefExecutionPhase.unblock),
        isTrue,
      );
    },
  );

  test(
    'buildBillingExceptionReliefExecutionPlan gates escalated execution',
    () {
      final plan = buildBillingExceptionReliefExecutionPlan(
        guidance: _approvalGuidance(escalationExposureThreshold: 30000),
      );

      expect(
        plan.status,
        BillingExceptionReliefExecutionStatus.escalationRequired,
      );
      expect(plan.statusLabel, 'Escalation required');
      expect(plan.stepCount, 8);
      expect(plan.blockedStepCount, 1);
      expect(
        plan
            .stepsForPhase(BillingExceptionReliefExecutionPhase.approval)
            .first
            .label,
        'Escalation review',
      );
      expect(
        plan
            .stepsForPhase(BillingExceptionReliefExecutionPhase.application)
            .single
            .isBlocked,
        isTrue,
      );
    },
  );
}

BillingExceptionReliefApprovalGuidance _approvalGuidance({
  bool approvalGranted = true,
  double escalationExposureThreshold = 50000,
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
