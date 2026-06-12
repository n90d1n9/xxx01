import 'payroll_approval_workflow_models.dart';

enum PayrollApprovalDelegationStatus {
  blocked('Blocked'),
  ready('Ready'),
  delegated('Delegated'),
  approved('Approved');

  final String label;

  const PayrollApprovalDelegationStatus(this.label);
}

class PayrollApprovalDelegationPolicy {
  final String stageId;
  final String primaryOwner;
  final String delegateOwner;
  final String backupOwner;
  final String escalationOwner;
  final bool delegateEnabled;
  final bool backupEnabled;

  const PayrollApprovalDelegationPolicy({
    required this.stageId,
    required this.primaryOwner,
    required this.delegateOwner,
    required this.backupOwner,
    required this.escalationOwner,
    required this.delegateEnabled,
    required this.backupEnabled,
  });

  bool get hasCoverage => delegateEnabled && backupEnabled;
}

class PayrollApprovalDelegationLine {
  final PayrollApprovalStage stage;
  final PayrollApprovalDelegationPolicy policy;

  const PayrollApprovalDelegationLine({
    required this.stage,
    required this.policy,
  });

  PayrollApprovalDelegationStatus get status {
    if (stage.status == PayrollApprovalStageStatus.approved) {
      return PayrollApprovalDelegationStatus.approved;
    }
    if (!policy.hasCoverage ||
        stage.status == PayrollApprovalStageStatus.blocked) {
      return PayrollApprovalDelegationStatus.blocked;
    }
    if (policy.delegateEnabled &&
        stage.status == PayrollApprovalStageStatus.ready) {
      return PayrollApprovalDelegationStatus.delegated;
    }
    return PayrollApprovalDelegationStatus.ready;
  }

  bool get hasCoverage => policy.hasCoverage;

  String get activeOwner {
    if (stage.status == PayrollApprovalStageStatus.approved) {
      return stage.approval?.approvedBy ?? policy.primaryOwner;
    }
    if (policy.delegateEnabled) return policy.delegateOwner;
    return policy.primaryOwner;
  }

  String get nextAction {
    if (!policy.delegateEnabled) {
      return '${stage.title} needs a named delegate before payroll close.';
    }
    if (!policy.backupEnabled) {
      return '${stage.title} needs backup approver coverage.';
    }
    if (stage.status == PayrollApprovalStageStatus.blocked) {
      return stage.nextAction;
    }
    if (stage.status == PayrollApprovalStageStatus.approved) {
      return '${stage.title} is approved with delegation coverage retained.';
    }
    return '${policy.delegateOwner} can approve ${stage.title.toLowerCase()} if primary is unavailable.';
  }
}

class PayrollApprovalDelegationSummary {
  final String periodLabel;
  final List<PayrollApprovalDelegationLine> lines;

  const PayrollApprovalDelegationSummary({
    required this.periodLabel,
    required this.lines,
  });

  factory PayrollApprovalDelegationSummary.fromWorkflow({
    required PayrollApprovalWorkflowSummary workflow,
    required List<PayrollApprovalDelegationPolicy> policies,
  }) {
    final policyByStageId = {
      for (final policy in policies) policy.stageId: policy,
    };
    final lines =
        workflow.stages.map((stage) {
          final policy = policyByStageId[stage.id] ?? _fallbackPolicy(stage);
          return PayrollApprovalDelegationLine(stage: stage, policy: policy);
        }).toList();

    return PayrollApprovalDelegationSummary(
      periodLabel: workflow.periodLabel,
      lines: lines,
    );
  }

  int get coveredCount => lines.where((line) => line.hasCoverage).length;

  int get blockedCount =>
      lines
          .where(
            (line) => line.status == PayrollApprovalDelegationStatus.blocked,
          )
          .length;

  int get delegatedCount =>
      lines
          .where(
            (line) => line.status == PayrollApprovalDelegationStatus.delegated,
          )
          .length;

  int get approvedCount =>
      lines
          .where(
            (line) => line.status == PayrollApprovalDelegationStatus.approved,
          )
          .length;

  bool get hasFullCoverage => coveredCount == lines.length;

  String get nextAction {
    if (!hasFullCoverage) {
      return 'Complete delegation coverage for ${lines.length - coveredCount} approval stages.';
    }
    if (blockedCount > 0) {
      return 'Resolve $blockedCount delegated approval blockers.';
    }
    if (delegatedCount > 0) {
      return '$delegatedCount approval stages can use delegated approvers.';
    }
    return 'Approval delegation coverage is complete.';
  }
}

PayrollApprovalDelegationPolicy _fallbackPolicy(PayrollApprovalStage stage) {
  return PayrollApprovalDelegationPolicy(
    stageId: stage.id,
    primaryOwner: stage.owner,
    delegateOwner: 'Unassigned delegate',
    backupOwner: 'Unassigned backup',
    escalationOwner: 'Payroll Controller',
    delegateEnabled: false,
    backupEnabled: false,
  );
}
