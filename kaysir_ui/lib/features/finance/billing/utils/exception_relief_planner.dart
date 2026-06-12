import '../models/billing_exception_event.dart';
import '../models/billing_policy_capability.dart';
import '../models/billing_policy_config.dart';
import '../models/exception_relief_plan.dart';
import '../models/policy_exception_plan.dart';
import 'policy_exception_planner.dart';

/// Builds an operational relief workflow for an active exception condition.
BillingExceptionReliefPlan planBillingExceptionRelief({
  required BillingPolicyConfig config,
  required BillingExceptionEventKind kind,
  required int affectedInvoiceCount,
  required double openAmount,
  required int reliefDurationDays,
  bool approvalGranted = false,
  bool evidenceCaptured = false,
}) {
  final policyPlan = planBillingPolicyException(config: config, kind: kind);
  final actions = <BillingExceptionReliefAction>[
    for (final decision in policyPlan.effectDecisions)
      if (!_isGovernanceEffect(decision.effect))
        _reliefActionForEffect(
          decision: decision,
          affectedInvoiceCount: affectedInvoiceCount,
          reliefDurationDays: reliefDurationDays,
        ),
  ];

  final approvalDecision = policyPlan.decisionFor(
    BillingExceptionPolicyEffect.requireApproval,
  );
  final evidenceDecision = policyPlan.decisionFor(
    BillingExceptionPolicyEffect.requireEvidence,
  );

  if (evidenceDecision != null) {
    actions.add(
      BillingExceptionReliefAction(
        kind: BillingExceptionReliefActionKind.captureEvidence,
        label: BillingExceptionReliefActionKind.captureEvidence.label,
        description:
            'Attach event evidence before sensitive billing relief is applied.',
        effect: BillingExceptionPolicyEffect.requireEvidence,
        requiredCapabilityIds: evidenceDecision.requiredCapabilityIds,
        missingCapabilityIds: evidenceDecision.missingCapabilityIds,
        completed: evidenceCaptured,
      ),
    );
  }
  if (approvalDecision != null) {
    actions.add(
      BillingExceptionReliefAction(
        kind: BillingExceptionReliefActionKind.requestApproval,
        label: BillingExceptionReliefActionKind.requestApproval.label,
        description:
            'Route the relief plan for approval before balances are changed.',
        effect: BillingExceptionPolicyEffect.requireApproval,
        requiredCapabilityIds: approvalDecision.requiredCapabilityIds,
        missingCapabilityIds: approvalDecision.missingCapabilityIds,
        completed: approvalGranted,
      ),
    );
  }

  return BillingExceptionReliefPlan(
    policyPlan: policyPlan,
    affectedInvoiceCount: affectedInvoiceCount,
    openAmount: openAmount,
    reliefDurationDays: reliefDurationDays,
    approvalGranted: approvalGranted,
    evidenceCaptured: evidenceCaptured,
    actions: actions,
    issues: _reliefIssues(
      policyPlan: policyPlan,
      affectedInvoiceCount: affectedInvoiceCount,
      openAmount: openAmount,
      reliefDurationDays: reliefDurationDays,
      approvalDecision: approvalDecision,
      evidenceDecision: evidenceDecision,
      approvalGranted: approvalGranted,
      evidenceCaptured: evidenceCaptured,
      operationalActionCount:
          actions.where((action) => !action.isGovernance).length,
    ),
  );
}

List<BillingExceptionReliefIssue> _reliefIssues({
  required BillingPolicyExceptionPlan policyPlan,
  required int affectedInvoiceCount,
  required double openAmount,
  required int reliefDurationDays,
  required BillingPolicyExceptionEffectDecision? approvalDecision,
  required BillingPolicyExceptionEffectDecision? evidenceDecision,
  required bool approvalGranted,
  required bool evidenceCaptured,
  required int operationalActionCount,
}) {
  final issues = <BillingExceptionReliefIssue>[];

  if (!policyPlan.isConfigured) {
    issues.add(
      BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.policyNotConfigured,
        message:
            'Configure a ${policyPlan.kind.label.toLowerCase()} policy before relief can be planned.',
      ),
    );
  }

  if (affectedInvoiceCount <= 0) {
    issues.add(
      const BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.invalidAffectedInvoiceCount,
        message: 'At least one affected invoice is required.',
      ),
    );
  }
  if (openAmount <= 0) {
    issues.add(
      const BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.invalidOpenAmount,
        message: 'The affected open amount must be greater than zero.',
      ),
    );
  }
  if (reliefDurationDays <= 0) {
    issues.add(
      const BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.invalidReliefDuration,
        message: 'Relief duration must be at least one day.',
      ),
    );
  }

  for (final capabilityId in policyPlan.missingCapabilityIds) {
    issues.add(
      BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.missingCapability,
        message: '${capabilityId.label} must be enabled for this relief plan.',
        capabilityId: capabilityId,
      ),
    );
  }

  if (policyPlan.isConfigured && operationalActionCount == 0) {
    issues.add(
      BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.noReliefEffects,
        message:
            'Add at least one operational relief effect for ${policyPlan.kind.label.toLowerCase()}.',
      ),
    );
  }

  if (evidenceDecision != null &&
      evidenceDecision.isAllowed &&
      !evidenceCaptured) {
    issues.add(
      const BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.evidenceRequired,
        message: 'Evidence must be captured before relief is applied.',
      ),
    );
  }
  if (approvalDecision != null &&
      approvalDecision.isAllowed &&
      !approvalGranted) {
    issues.add(
      const BillingExceptionReliefIssue(
        kind: BillingExceptionReliefIssueKind.approvalRequired,
        message: 'Approval must be granted before relief is applied.',
      ),
    );
  }

  return List.unmodifiable(issues);
}

BillingExceptionReliefAction _reliefActionForEffect({
  required BillingPolicyExceptionEffectDecision decision,
  required int affectedInvoiceCount,
  required int reliefDurationDays,
}) {
  final kind = _actionKindForEffect(decision.effect);

  return BillingExceptionReliefAction(
    kind: kind,
    label: kind.label,
    description: _descriptionForEffect(
      effect: decision.effect,
      affectedInvoiceCount: affectedInvoiceCount,
      reliefDurationDays: reliefDurationDays,
    ),
    effect: decision.effect,
    requiredCapabilityIds: decision.requiredCapabilityIds,
    missingCapabilityIds: decision.missingCapabilityIds,
  );
}

BillingExceptionReliefActionKind _actionKindForEffect(
  BillingExceptionPolicyEffect effect,
) {
  return switch (effect) {
    BillingExceptionPolicyEffect.pauseDueDates =>
      BillingExceptionReliefActionKind.pauseDueDates,
    BillingExceptionPolicyEffect.suspendDunning =>
      BillingExceptionReliefActionKind.suspendDunning,
    BillingExceptionPolicyEffect.waiveLateFees =>
      BillingExceptionReliefActionKind.waiveLateFees,
    BillingExceptionPolicyEffect.reschedulePayments =>
      BillingExceptionReliefActionKind.reschedulePayments,
    BillingExceptionPolicyEffect.freezeIssuance =>
      BillingExceptionReliefActionKind.freezeIssuance,
    BillingExceptionPolicyEffect.requireApproval =>
      BillingExceptionReliefActionKind.requestApproval,
    BillingExceptionPolicyEffect.requireEvidence =>
      BillingExceptionReliefActionKind.captureEvidence,
  };
}

String _descriptionForEffect({
  required BillingExceptionPolicyEffect effect,
  required int affectedInvoiceCount,
  required int reliefDurationDays,
}) {
  final invoiceLabel =
      affectedInvoiceCount == 1
          ? '1 invoice'
          : '$affectedInvoiceCount invoices';

  return switch (effect) {
    BillingExceptionPolicyEffect.pauseDueDates =>
      'Move due dates for $invoiceLabel by $reliefDurationDays days.',
    BillingExceptionPolicyEffect.suspendDunning =>
      'Hold reminders and collection escalation while relief is active.',
    BillingExceptionPolicyEffect.waiveLateFees =>
      'Suppress late fees on affected balances during the relief window.',
    BillingExceptionPolicyEffect.reschedulePayments =>
      'Move affected balances into a recovery schedule after relief ends.',
    BillingExceptionPolicyEffect.freezeIssuance =>
      'Stop new invoice issuance until the exception is resolved.',
    BillingExceptionPolicyEffect.requireApproval =>
      'Route the relief plan for approval before balances are changed.',
    BillingExceptionPolicyEffect.requireEvidence =>
      'Attach event evidence before sensitive billing relief is applied.',
  };
}

bool _isGovernanceEffect(BillingExceptionPolicyEffect effect) {
  return effect == BillingExceptionPolicyEffect.requireApproval ||
      effect == BillingExceptionPolicyEffect.requireEvidence;
}
