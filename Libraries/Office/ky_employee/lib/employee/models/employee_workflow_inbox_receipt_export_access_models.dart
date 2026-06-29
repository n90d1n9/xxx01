import 'employee_workflow_inbox_receipt_export_models.dart';

/// HR role used to gate employee workflow inbox receipt exports.
enum EmployeeWorkflowInboxReceiptExportRole {
  peopleOperations(
    label: 'People Operations',
    shortLabel: 'People Ops',
    description: 'Owns employee workflow receipt custody and export handling.',
  ),
  payrollOfficer(
    label: 'Payroll officer',
    shortLabel: 'Payroll',
    description: 'Copies payroll-scoped receipt exports for payroll evidence.',
  ),
  manager(
    label: 'Manager',
    shortLabel: 'Manager',
    description: 'Reviews non-payroll workflow receipts for direct reports.',
  ),
  hrAuditor(
    label: 'HR auditor',
    shortLabel: 'Auditor',
    description: 'Reviews receipt evidence without copying export files.',
  );

  final String label;
  final String shortLabel;
  final String description;

  const EmployeeWorkflowInboxReceiptExportRole({
    required this.label,
    required this.shortLabel,
    required this.description,
  });
}

/// Receipt export action that can be allowed or blocked by access policy.
enum EmployeeWorkflowInboxReceiptExportAction {
  copyCsv('Copy receipt CSV');

  final String label;

  const EmployeeWorkflowInboxReceiptExportAction(this.label);
}

/// Role and readiness decision for one receipt export action.
class EmployeeWorkflowInboxReceiptExportPermission {
  final EmployeeWorkflowInboxReceiptExportAction action;
  final bool allowed;
  final String reason;

  const EmployeeWorkflowInboxReceiptExportPermission({
    required this.action,
    required this.allowed,
    required this.reason,
  });

  String get statusLabel => allowed ? 'Allowed' : 'Blocked';
}

/// Evaluates scoped receipt export permissions for one HR role.
class EmployeeWorkflowInboxReceiptExportAccessReview {
  final EmployeeWorkflowInboxReceiptExportRole role;
  final EmployeeWorkflowInboxReceiptExportPreview preview;

  const EmployeeWorkflowInboxReceiptExportAccessReview({
    required this.role,
    required this.preview,
  });

  List<EmployeeWorkflowInboxReceiptExportPermission> get permissions {
    return [copyCsvPermission];
  }

  int get allowedCount {
    return permissions.where((permission) => permission.allowed).length;
  }

  int get totalCount => permissions.length;

  String get statusLabel {
    if (allowedCount == 0) return 'View only';
    if (allowedCount == totalCount) return 'Copy ready';
    return '$allowedCount of $totalCount open';
  }

  String get roleGuidance {
    return switch (role) {
      EmployeeWorkflowInboxReceiptExportRole.peopleOperations =>
        'People Operations can copy ready receipt exports for HR evidence.',
      EmployeeWorkflowInboxReceiptExportRole.payrollOfficer =>
        'Payroll officer can copy payroll-scoped receipt exports only.',
      EmployeeWorkflowInboxReceiptExportRole.manager =>
        'Manager can copy non-payroll workflow receipts for direct reports.',
      EmployeeWorkflowInboxReceiptExportRole.hrAuditor =>
        'HR auditor can inspect receipt evidence without copying CSV files.',
    };
  }

  EmployeeWorkflowInboxReceiptExportPermission get copyCsvPermission {
    if (!preview.isReady) {
      return _blocked(preview.exportActionLabel);
    }

    return switch (role) {
      EmployeeWorkflowInboxReceiptExportRole.peopleOperations => _allowed(
        'People Operations can copy this ready receipt export.',
      ),
      EmployeeWorkflowInboxReceiptExportRole.payrollOfficer =>
        _payrollOfficerPermission,
      EmployeeWorkflowInboxReceiptExportRole.manager => _managerPermission,
      EmployeeWorkflowInboxReceiptExportRole.hrAuditor => _blocked(
        'HR auditor can review receipt exports but cannot copy CSV files.',
      ),
    };
  }

  EmployeeWorkflowInboxReceiptExportPermission get _payrollOfficerPermission {
    if (preview.scope != EmployeeWorkflowInboxReceiptExportScope.payroll) {
      return _blocked('Switch to Payroll receipts to copy as payroll officer.');
    }
    return _allowed('Payroll officer can copy payroll-scoped receipt exports.');
  }

  EmployeeWorkflowInboxReceiptExportPermission get _managerPermission {
    if (preview.rows.any((row) => row.receipt.isPayroll)) {
      return _blocked('Manager cannot copy exports that include payroll data.');
    }
    if (preview.scope ==
        EmployeeWorkflowInboxReceiptExportScope.dataCorrection) {
      return _blocked('Manager cannot copy data correction receipt exports.');
    }
    return _allowed('Manager can copy this non-payroll receipt export.');
  }

  EmployeeWorkflowInboxReceiptExportPermission _allowed(String reason) {
    return EmployeeWorkflowInboxReceiptExportPermission(
      action: EmployeeWorkflowInboxReceiptExportAction.copyCsv,
      allowed: true,
      reason: reason,
    );
  }

  EmployeeWorkflowInboxReceiptExportPermission _blocked(String reason) {
    return EmployeeWorkflowInboxReceiptExportPermission(
      action: EmployeeWorkflowInboxReceiptExportAction.copyCsv,
      allowed: false,
      reason: reason,
    );
  }
}
