import 'payroll_control_review_models.dart';
import 'payroll_evidence_center_models.dart';

/// Defines the audit readiness state for a payroll control evidence link.
enum PayrollControlsEvidenceMatrixStatus {
  missing('Missing'),
  blocked('Blocked'),
  ready('Ready'),
  complete('Complete');

  final String label;

  const PayrollControlsEvidenceMatrixStatus(this.label);
}

/// Maps one payroll close control to the evidence item that proves it.
class PayrollControlsEvidenceMatrixRule {
  final String controlId;
  final String evidenceId;
  final bool required;

  const PayrollControlsEvidenceMatrixRule({
    required this.controlId,
    required this.evidenceId,
    this.required = true,
  });
}

/// Represents one auditable control and the evidence currently linked to it.
class PayrollControlsEvidenceMatrixLine {
  final PayrollControlReviewItem control;
  final PayrollEvidenceItem? evidence;
  final PayrollControlsEvidenceMatrixRule? rule;

  const PayrollControlsEvidenceMatrixLine({
    required this.control,
    required this.evidence,
    required this.rule,
  });

  bool get hasRequiredEvidence => rule != null && evidence != null;

  bool get isRequired => rule?.required ?? true;

  PayrollControlsEvidenceMatrixStatus get status {
    if (evidence == null) return PayrollControlsEvidenceMatrixStatus.missing;
    if (control.hasBlockers ||
        evidence!.status == PayrollEvidenceStatus.blocked) {
      return PayrollControlsEvidenceMatrixStatus.blocked;
    }
    if (control.isReviewed && evidence!.isCaptured) {
      return PayrollControlsEvidenceMatrixStatus.complete;
    }
    return PayrollControlsEvidenceMatrixStatus.ready;
  }

  List<String> get blockers {
    if (evidence == null) {
      return ['Attach evidence for ${control.title.toLowerCase()}.'];
    }
    return [
      ...control.blockers,
      ...evidence!.blockers,
      if (!control.isReviewed && control.blockers.isEmpty)
        'Control sign-off is pending',
      if (!evidence!.isCaptured && evidence!.blockers.isEmpty)
        'Evidence capture is pending',
    ];
  }

  String get evidenceLabel => evidence?.title ?? 'Evidence not mapped';

  String get ownerLabel {
    final evidenceOwner = evidence?.owner;
    if (evidenceOwner == null || evidenceOwner == control.owner) {
      return control.owner;
    }
    return '${control.owner} / $evidenceOwner';
  }
}

/// Summarizes evidence coverage across every payroll control review item.
class PayrollControlsEvidenceMatrixSummary {
  final String periodLabel;
  final List<PayrollControlsEvidenceMatrixLine> lines;

  const PayrollControlsEvidenceMatrixSummary({
    required this.periodLabel,
    required this.lines,
  });

  factory PayrollControlsEvidenceMatrixSummary.fromRun({
    required PayrollControlReviewSummary controlReview,
    required PayrollEvidenceCenterSummary evidenceCenter,
    List<PayrollControlsEvidenceMatrixRule> rules =
        defaultPayrollControlsEvidenceMatrixRules,
  }) {
    final evidenceById = {
      for (final evidence in evidenceCenter.items) evidence.id: evidence,
    };
    final ruleByControlId = {for (final rule in rules) rule.controlId: rule};

    return PayrollControlsEvidenceMatrixSummary(
      periodLabel: controlReview.periodLabel,
      lines: [
        for (final control in controlReview.items)
          PayrollControlsEvidenceMatrixLine(
            control: control,
            rule: ruleByControlId[control.id],
            evidence:
                ruleByControlId[control.id] == null
                    ? null
                    : evidenceById[ruleByControlId[control.id]!.evidenceId],
          ),
      ],
    );
  }

  int get completeCount {
    return lines
        .where(
          (line) => line.status == PayrollControlsEvidenceMatrixStatus.complete,
        )
        .length;
  }

  int get readyCount {
    return lines
        .where(
          (line) => line.status == PayrollControlsEvidenceMatrixStatus.ready,
        )
        .length;
  }

  int get blockedCount {
    return lines
        .where(
          (line) => line.status == PayrollControlsEvidenceMatrixStatus.blocked,
        )
        .length;
  }

  int get missingCount {
    return lines
        .where(
          (line) => line.status == PayrollControlsEvidenceMatrixStatus.missing,
        )
        .length;
  }

  double get coverageRate {
    if (lines.isEmpty) return 0;
    return lines.where((line) => line.hasRequiredEvidence).length /
        lines.length;
  }

  PayrollControlsEvidenceMatrixStatus get status {
    if (missingCount > 0) return PayrollControlsEvidenceMatrixStatus.missing;
    if (blockedCount > 0) return PayrollControlsEvidenceMatrixStatus.blocked;
    if (completeCount == lines.length) {
      return PayrollControlsEvidenceMatrixStatus.complete;
    }
    return PayrollControlsEvidenceMatrixStatus.ready;
  }

  String get nextAction {
    if (missingCount > 0) {
      return 'Map evidence for $missingCount payroll controls.';
    }
    if (blockedCount > 0) {
      return 'Resolve $blockedCount control evidence blockers.';
    }
    if (readyCount > 0) {
      return 'Capture and sign off $readyCount control evidence items.';
    }
    return 'Payroll controls evidence matrix is complete.';
  }
}

/// Default control-to-evidence mapping for the payroll close audit packet.
const defaultPayrollControlsEvidenceMatrixRules =
    <PayrollControlsEvidenceMatrixRule>[
      PayrollControlsEvidenceMatrixRule(
        controlId: 'exception-clearance',
        evidenceId: 'exception-clearance',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'adjustment-approval',
        evidenceId: 'approvals',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'cost-center-budget-approval',
        evidenceId: 'cost-center-report',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'reconciliation-review',
        evidenceId: 'reconciliation',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'payment-disbursement',
        evidenceId: 'payment-release',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'payslip-publication',
        evidenceId: 'register-report',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'liability-remittance',
        evidenceId: 'register-report',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'journal-posting',
        evidenceId: 'register-report',
      ),
      PayrollControlsEvidenceMatrixRule(
        controlId: 'archive-retention',
        evidenceId: 'archive-package',
      ),
    ];
