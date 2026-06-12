import '../models/billing_exception_event.dart';
import '../models/exception_relief_plan.dart';
import '../models/relief_application_packet.dart';
import 'billing_formatters.dart';

/// Builds an auditable handoff packet for applying relief commands.
BillingExceptionReliefApplicationPacket
buildBillingExceptionReliefApplicationPacket({
  required BillingExceptionReliefPlan plan,
  String requestedBy = 'System',
  DateTime? requestedAt,
}) {
  final commands =
      plan.isActionable
          ? [
            for (final action in plan.actions)
              if (!action.isGovernance && !action.isBlocked)
                _commandForAction(action: action, plan: plan),
          ]
          : const <BillingExceptionReliefApplicationCommand>[];

  return BillingExceptionReliefApplicationPacket(
    plan: plan,
    requestedBy: requestedBy.trim().isEmpty ? 'System' : requestedBy.trim(),
    requestedAt: requestedAt ?? DateTime.now().toUtc(),
    commands: commands,
    auditFacts: _auditFacts(plan: plan),
    issues: _issues(plan: plan, commandCount: commands.length),
  );
}

BillingExceptionReliefApplicationCommand _commandForAction({
  required BillingExceptionReliefAction action,
  required BillingExceptionReliefPlan plan,
}) {
  return BillingExceptionReliefApplicationCommand(
    id: '${plan.kind.name}-${action.kind.name}',
    actionKind: action.kind,
    label: action.label,
    description: action.description,
    payload: {
      'exceptionKind': plan.kind.name,
      'actionKind': action.kind.name,
      'affectedInvoiceCount': plan.affectedInvoiceCount,
      'openAmount': plan.openAmount,
      'reliefDurationDays': plan.reliefDurationDays,
      'approvalGranted': plan.approvalGranted,
      'evidenceCaptured': plan.evidenceCaptured,
    },
  );
}

List<BillingExceptionReliefAuditFact> _auditFacts({
  required BillingExceptionReliefPlan plan,
}) {
  return [
    BillingExceptionReliefAuditFact(label: 'Exception', value: plan.kind.label),
    BillingExceptionReliefAuditFact(
      label: 'Affected invoices',
      value: '${plan.affectedInvoiceCount}',
    ),
    BillingExceptionReliefAuditFact(
      label: 'Exposure',
      value: formatBillingCurrency(plan.openAmount),
    ),
    BillingExceptionReliefAuditFact(
      label: 'Relief window',
      value: '${plan.reliefDurationDays}d',
    ),
    BillingExceptionReliefAuditFact(
      label: 'Approval',
      value: plan.approvalGranted ? 'Granted' : 'Pending',
    ),
    BillingExceptionReliefAuditFact(
      label: 'Evidence',
      value: plan.evidenceCaptured ? 'Captured' : 'Pending',
    ),
  ];
}

List<BillingExceptionReliefApplicationIssue> _issues({
  required BillingExceptionReliefPlan plan,
  required int commandCount,
}) {
  if (!plan.isActionable) {
    return [
      const BillingExceptionReliefApplicationIssue(
        kind: BillingExceptionReliefApplicationIssueKind.planNotActionable,
        message: 'Resolve relief plan blockers before applying changes.',
      ),
      for (final issue in plan.blockerIssues)
        BillingExceptionReliefApplicationIssue(
          kind: BillingExceptionReliefApplicationIssueKind.planNotActionable,
          message: issue.message,
          details: issue.details,
        ),
    ];
  }

  if (commandCount == 0) {
    return const [
      BillingExceptionReliefApplicationIssue(
        kind: BillingExceptionReliefApplicationIssueKind.noCommands,
        message: 'No operational relief commands were produced.',
      ),
    ];
  }

  return const [];
}
