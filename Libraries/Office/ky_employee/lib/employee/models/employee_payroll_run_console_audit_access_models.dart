import 'employee_payroll_run_console_audit_export_models.dart';
import 'employee_payroll_run_console_audit_handoff_models.dart';

/// Payroll audit console role used to scope sensitive close actions.
enum EmployeePayrollRunConsoleAuditRole {
  payrollOfficer(
    label: 'Payroll officer',
    shortLabel: 'Officer',
    description: 'Owns export custody and payroll audit file preparation.',
  ),
  payrollReviewer(
    label: 'Payroll reviewer',
    shortLabel: 'Reviewer',
    description: 'Validates evidence and submits the close handoff.',
  ),
  payrollApprover(
    label: 'Payroll approver',
    shortLabel: 'Approver',
    description: 'Approves or returns submitted close handoffs.',
  ),
  auditor(
    label: 'Auditor',
    shortLabel: 'Auditor',
    description: 'Reviews audit evidence without changing close state.',
  );

  final String label;
  final String shortLabel;
  final String description;

  const EmployeePayrollRunConsoleAuditRole({
    required this.label,
    required this.shortLabel,
    required this.description,
  });
}

/// Payroll audit action that can be allowed or blocked by role and readiness.
enum EmployeePayrollRunConsoleAuditAction {
  copyExport('Copy CSV export'),
  submitHandoff('Submit handoff'),
  approveHandoff('Approve handoff'),
  returnHandoff('Return handoff');

  final String label;

  const EmployeePayrollRunConsoleAuditAction(this.label);
}

/// Role and readiness decision for one payroll audit console action.
class EmployeePayrollRunConsoleAuditPermission {
  final EmployeePayrollRunConsoleAuditAction action;
  final bool allowed;
  final String reason;

  const EmployeePayrollRunConsoleAuditPermission({
    required this.action,
    required this.allowed,
    required this.reason,
  });

  String get statusLabel => allowed ? 'Allowed' : 'Blocked';
}

/// Next-step guidance derived from payroll audit role and readiness.
class EmployeePayrollRunConsoleAuditGuidance {
  final String title;
  final String detail;
  final EmployeePayrollRunConsoleAuditAction? action;
  final bool isReady;

  const EmployeePayrollRunConsoleAuditGuidance({
    required this.title,
    required this.detail,
    this.action,
    required this.isReady,
  });

  String get statusLabel => isReady ? 'Ready' : 'Guidance';
}

/// Evaluates payroll audit export and handoff permissions for one role.
class EmployeePayrollRunConsoleAuditAccessReview {
  final EmployeePayrollRunConsoleAuditRole role;
  final EmployeePayrollRunConsoleAuditExportPreview? exportPreview;
  final EmployeePayrollRunConsoleAuditHandoffReview? handoffReview;

  const EmployeePayrollRunConsoleAuditAccessReview({
    required this.role,
    this.exportPreview,
    this.handoffReview,
  });

  List<EmployeePayrollRunConsoleAuditPermission> get permissions {
    return [
      copyExportPermission,
      submitHandoffPermission,
      approveHandoffPermission,
      returnHandoffPermission,
    ];
  }

  int get allowedCount {
    return permissions.where((permission) => permission.allowed).length;
  }

  int get totalCount => permissions.length;

  String get allowedLabel => '$allowedCount/$totalCount';

  String get statusLabel {
    if (allowedCount == 0) return 'View only';
    if (allowedCount == totalCount) return 'All open';
    return '$allowedCount of $totalCount open';
  }

  EmployeePayrollRunConsoleAuditGuidance get guidance {
    return switch (role) {
      EmployeePayrollRunConsoleAuditRole.payrollOfficer => _officerGuidance,
      EmployeePayrollRunConsoleAuditRole.payrollReviewer => _reviewerGuidance,
      EmployeePayrollRunConsoleAuditRole.payrollApprover => _approverGuidance,
      EmployeePayrollRunConsoleAuditRole.auditor =>
        const EmployeePayrollRunConsoleAuditGuidance(
          title: 'Review evidence only',
          detail:
              'Auditor can inspect package evidence without changing close state.',
          isReady: false,
        ),
    };
  }

  EmployeePayrollRunConsoleAuditPermission get copyExportPermission {
    final preview = exportPreview;
    if (preview == null) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.copyExport,
        'Export preview is not attached to this role review.',
      );
    }
    if (!preview.isReady) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.copyExport,
        preview.exportActionLabel,
      );
    }
    if (role != EmployeePayrollRunConsoleAuditRole.payrollOfficer) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.copyExport,
        _roleBlockReason(
          role,
          'copy audit exports',
          EmployeePayrollRunConsoleAuditRole.payrollOfficer,
        ),
      );
    }
    return _allowed(
      EmployeePayrollRunConsoleAuditAction.copyExport,
      'Payroll officer can copy a ready audit export.',
    );
  }

  EmployeePayrollRunConsoleAuditPermission get submitHandoffPermission {
    final review = handoffReview;
    if (review == null) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.submitHandoff,
        'Handoff review is not attached to this role review.',
      );
    }
    if (role != EmployeePayrollRunConsoleAuditRole.payrollReviewer) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.submitHandoff,
        _roleBlockReason(
          role,
          'submit payroll close handoffs',
          EmployeePayrollRunConsoleAuditRole.payrollReviewer,
        ),
      );
    }
    if (!review.canSubmit) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.submitHandoff,
        review.errors.isEmpty
            ? 'Complete handoff details.'
            : review.errors.first,
      );
    }
    return _allowed(
      EmployeePayrollRunConsoleAuditAction.submitHandoff,
      'Payroll reviewer can submit the complete close handoff.',
    );
  }

  EmployeePayrollRunConsoleAuditPermission get approveHandoffPermission {
    final review = handoffReview;
    if (review == null) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.approveHandoff,
        'Handoff review is not attached to this role review.',
      );
    }
    if (role != EmployeePayrollRunConsoleAuditRole.payrollApprover) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.approveHandoff,
        _roleBlockReason(
          role,
          'approve payroll close handoffs',
          EmployeePayrollRunConsoleAuditRole.payrollApprover,
        ),
      );
    }
    final latest = review.latestHandoff;
    if (latest == null) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.approveHandoff,
        'Submit a handoff before approval.',
      );
    }
    if (!latest.canApprove) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.approveHandoff,
        'Latest handoff is ${latest.statusLabel.toLowerCase()}.',
      );
    }
    return _allowed(
      EmployeePayrollRunConsoleAuditAction.approveHandoff,
      'Payroll approver can approve the submitted handoff.',
    );
  }

  EmployeePayrollRunConsoleAuditPermission get returnHandoffPermission {
    final review = handoffReview;
    if (review == null) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.returnHandoff,
        'Handoff review is not attached to this role review.',
      );
    }
    if (role != EmployeePayrollRunConsoleAuditRole.payrollApprover) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.returnHandoff,
        _roleBlockReason(
          role,
          'return payroll close handoffs',
          EmployeePayrollRunConsoleAuditRole.payrollApprover,
        ),
      );
    }
    final latest = review.latestHandoff;
    if (latest == null) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.returnHandoff,
        'Submit a handoff before return.',
      );
    }
    if (!latest.canReturn) {
      return _blocked(
        EmployeePayrollRunConsoleAuditAction.returnHandoff,
        'Latest handoff is ${latest.statusLabel.toLowerCase()}.',
      );
    }
    return _allowed(
      EmployeePayrollRunConsoleAuditAction.returnHandoff,
      'Payroll approver can return the submitted handoff.',
    );
  }

  EmployeePayrollRunConsoleAuditGuidance get _officerGuidance {
    final copy = copyExportPermission;
    if (copy.allowed) {
      return const EmployeePayrollRunConsoleAuditGuidance(
        title: 'Copy audit export',
        detail: 'The CSV package is ready for controlled payroll custody.',
        action: EmployeePayrollRunConsoleAuditAction.copyExport,
        isReady: true,
      );
    }
    return EmployeePayrollRunConsoleAuditGuidance(
      title: 'Prepare export readiness',
      detail: copy.reason,
      action: EmployeePayrollRunConsoleAuditAction.copyExport,
      isReady: false,
    );
  }

  EmployeePayrollRunConsoleAuditGuidance get _reviewerGuidance {
    final submit = submitHandoffPermission;
    if (submit.allowed) {
      return const EmployeePayrollRunConsoleAuditGuidance(
        title: 'Submit close handoff',
        detail: 'The handoff is complete and ready for approver review.',
        action: EmployeePayrollRunConsoleAuditAction.submitHandoff,
        isReady: true,
      );
    }
    return EmployeePayrollRunConsoleAuditGuidance(
      title: 'Complete handoff inputs',
      detail: submit.reason,
      action: EmployeePayrollRunConsoleAuditAction.submitHandoff,
      isReady: false,
    );
  }

  EmployeePayrollRunConsoleAuditGuidance get _approverGuidance {
    final approve = approveHandoffPermission;
    final returnForRevision = returnHandoffPermission;
    if (approve.allowed || returnForRevision.allowed) {
      return const EmployeePayrollRunConsoleAuditGuidance(
        title: 'Decide submitted handoff',
        detail: 'Approve the payroll close evidence or return it for revision.',
        action: EmployeePayrollRunConsoleAuditAction.approveHandoff,
        isReady: true,
      );
    }
    return EmployeePayrollRunConsoleAuditGuidance(
      title: 'Wait for handoff submission',
      detail: approve.reason,
      action: EmployeePayrollRunConsoleAuditAction.approveHandoff,
      isReady: false,
    );
  }
}

EmployeePayrollRunConsoleAuditPermission _allowed(
  EmployeePayrollRunConsoleAuditAction action,
  String reason,
) {
  return EmployeePayrollRunConsoleAuditPermission(
    action: action,
    allowed: true,
    reason: reason,
  );
}

EmployeePayrollRunConsoleAuditPermission _blocked(
  EmployeePayrollRunConsoleAuditAction action,
  String reason,
) {
  return EmployeePayrollRunConsoleAuditPermission(
    action: action,
    allowed: false,
    reason: reason,
  );
}

String _roleBlockReason(
  EmployeePayrollRunConsoleAuditRole role,
  String action,
  EmployeePayrollRunConsoleAuditRole requiredRole,
) {
  if (role == EmployeePayrollRunConsoleAuditRole.auditor) {
    return 'Auditor can review evidence but cannot $action.';
  }
  return 'Switch to ${requiredRole.label.toLowerCase()} to $action.';
}
