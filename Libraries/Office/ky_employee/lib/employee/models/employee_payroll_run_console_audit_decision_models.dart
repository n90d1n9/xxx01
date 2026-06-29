/// Control acknowledgement required before approving a payroll audit handoff.
enum EmployeePayrollRunConsoleAuditDecisionAttestation {
  evidenceReviewed(
    label: 'Evidence reviewed',
    detail: 'Audit events, package checks, and exceptions were reviewed.',
  ),
  commandCoverageConfirmed(
    label: 'Command coverage confirmed',
    detail: 'Prepare, settle, publish, and close stages are evidenced.',
  ),
  archiveRiskAccepted(
    label: 'Archive risk accepted',
    detail: 'The approver accepts the package for payroll close archive.',
  );

  final String label;
  final String detail;

  const EmployeePayrollRunConsoleAuditDecisionAttestation({
    required this.label,
    required this.detail,
  });
}

/// Draft state for approver notes and close-control attestations.
class EmployeePayrollRunConsoleAuditDecisionDraft {
  final String note;
  final Set<EmployeePayrollRunConsoleAuditDecisionAttestation> attestations;

  const EmployeePayrollRunConsoleAuditDecisionDraft({
    this.note = '',
    this.attestations = const {},
  });

  int get completedAttestationCount => attestations.length;

  int get totalAttestationCount {
    return EmployeePayrollRunConsoleAuditDecisionAttestation.values.length;
  }

  String get attestationLabel {
    return '$completedAttestationCount/$totalAttestationCount';
  }

  bool get canApprove => completedAttestationCount == totalAttestationCount;

  bool get canReturn => note.trim().length >= 8;

  String get approvalHint {
    if (canApprove) return 'Approval controls acknowledged.';
    return 'Acknowledge all close controls before approval.';
  }

  String get decisionNote => note.trim();

  bool isAttested(
    EmployeePayrollRunConsoleAuditDecisionAttestation attestation,
  ) {
    return attestations.contains(attestation);
  }

  EmployeePayrollRunConsoleAuditDecisionDraft copyWith({
    String? note,
    Set<EmployeePayrollRunConsoleAuditDecisionAttestation>? attestations,
  }) {
    return EmployeePayrollRunConsoleAuditDecisionDraft(
      note: note ?? this.note,
      attestations: attestations ?? this.attestations,
    );
  }

  EmployeePayrollRunConsoleAuditDecisionDraft toggleAttestation(
    EmployeePayrollRunConsoleAuditDecisionAttestation attestation,
    bool selected,
  ) {
    final next = {...attestations};
    if (selected) {
      next.add(attestation);
    } else {
      next.remove(attestation);
    }
    return copyWith(attestations: next);
  }
}
