import 'employee_payroll_run_console_audit_decision_models.dart';
import 'employee_payroll_run_console_audit_handoff_models.dart';

/// Read model for the immutable receipt shown after a payroll audit decision.
class EmployeePayrollRunConsoleAuditDecisionReceipt {
  final EmployeePayrollRunConsoleAuditHandoffRecord record;

  const EmployeePayrollRunConsoleAuditDecisionReceipt({required this.record});

  bool get isVisible => record.isDecided;

  bool get isApproval {
    return record.status ==
        EmployeePayrollRunConsoleAuditHandoffStatus.approved;
  }

  String get title {
    return isApproval ? 'Close approval receipt' : 'Returned evidence receipt';
  }

  String get outcomeLabel => record.statusLabel;

  String get decisionNoteLabel {
    if (record.decisionNote.isEmpty) return 'No decision note recorded.';
    return record.decisionNote;
  }

  String get controlsLabel => record.decisionAttestationLabel;

  String get evidenceLabel {
    return '${record.readyItemCount}/${record.totalItemCount} package, '
        '${record.evidencedCommandCount}/${record.totalCommandCount} commands';
  }

  String get reviewerApproverLabel {
    return '${record.reviewer} to ${record.approver}';
  }

  List<EmployeePayrollRunConsoleAuditDecisionAttestation> get attestations {
    return EmployeePayrollRunConsoleAuditDecisionAttestation.values
        .where(record.decisionAttestations.contains)
        .toList(growable: false);
  }
}
