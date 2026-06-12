import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/exception_relief_plan.dart';
import 'package:kaysir/features/finance/billing/models/relief_approval_guidance.dart';
import 'package:kaysir/features/finance/billing/models/relief_impact_summary.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/exception_relief_planner.dart';
import 'package:kaysir/features/finance/billing/utils/relief_application_packet_builder.dart';
import 'package:kaysir/features/finance/billing/utils/relief_approval_guidance_resolver.dart';
import 'package:kaysir/features/finance/billing/utils/relief_impact_analyzer.dart';

void main() {
  test('resolveBillingExceptionReliefApprovalGuidance recommends controls', () {
    final guidance = resolveBillingExceptionReliefApprovalGuidance(
      summary: _readyImpactSummary(),
    );

    expect(
      guidance.decision,
      BillingExceptionReliefApprovalDecision.approveWithControls,
    );
    expect(guidance.statusLabel, 'Approve with controls');
    expect(guidance.primaryActionLabel, 'Assign controls');
    expect(guidance.requiredActionCount, 6);
    expect(
      guidance.hasActionKind(
        BillingExceptionReliefApprovalActionKind.financeOwnerSignOff,
      ),
      isTrue,
    );
    expect(
      guidance.hasActionKind(
        BillingExceptionReliefApprovalActionKind.updateCashForecast,
      ),
      isTrue,
    );
    expect(
      guidance.hasActionKind(
        BillingExceptionReliefApprovalActionKind.prepareRecoverySchedule,
      ),
      isTrue,
    );
  });

  test('resolveBillingExceptionReliefApprovalGuidance escalates exposure', () {
    final guidance = resolveBillingExceptionReliefApprovalGuidance(
      summary: _readyImpactSummary(),
      escalationExposureThreshold: 30000,
    );

    expect(guidance.decision, BillingExceptionReliefApprovalDecision.escalate);
    expect(guidance.statusLabel, 'Escalate');
    expect(
      guidance.reasons,
      contains('Deferred exposure exceeds the escalation threshold.'),
    );
  });

  test(
    'resolveBillingExceptionReliefApprovalGuidance blocks unresolved relief',
    () {
      final summary = summarizeBillingExceptionReliefImpact(
        packet: buildBillingExceptionReliefApplicationPacket(
          plan: planBillingExceptionRelief(
            config: constructionBillingPolicyConfig(),
            kind: BillingExceptionEventKind.forceMajeure,
            affectedInvoiceCount: 12,
            openAmount: 42600,
            reliefDurationDays: 21,
            evidenceCaptured: true,
          ),
          requestedBy: 'Ops lead',
          requestedAt: DateTime.utc(2026, 1, 15, 9),
        ),
      );
      final guidance = resolveBillingExceptionReliefApprovalGuidance(
        summary: summary,
      );

      expect(guidance.isBlocked, isTrue);
      expect(guidance.statusLabel, 'Blocked');
      expect(guidance.requiredActionCount, 1);
      expect(
        guidance.hasActionKind(
          BillingExceptionReliefApprovalActionKind.resolveBlockers,
        ),
        isTrue,
      );
      expect(
        guidance.reasons,
        contains('Approval must be granted before relief is applied.'),
      );
    },
  );
}

BillingExceptionReliefImpactSummary _readyImpactSummary() {
  return summarizeBillingExceptionReliefImpact(
    packet: buildBillingExceptionReliefApplicationPacket(
      plan: _readyReliefPlan(),
      requestedBy: 'Ops lead',
      requestedAt: DateTime.utc(2026, 1, 15, 9),
    ),
  );
}

BillingExceptionReliefPlan _readyReliefPlan() {
  return planBillingExceptionRelief(
    config: constructionBillingPolicyConfig(),
    kind: BillingExceptionEventKind.forceMajeure,
    affectedInvoiceCount: 12,
    openAmount: 42600,
    reliefDurationDays: 21,
    approvalGranted: true,
    evidenceCaptured: true,
  );
}
