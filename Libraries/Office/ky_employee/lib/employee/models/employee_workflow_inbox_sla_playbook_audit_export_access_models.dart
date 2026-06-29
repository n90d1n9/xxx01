import 'employee_workflow_inbox_sla_playbook_audit_export_models.dart';

/// HR role used to gate workflow inbox SLA playbook audit exports.
enum EmployeeWorkflowInboxSlaPlaybookAuditExportRole {
  peopleOperations(
    label: 'People Operations',
    shortLabel: 'People Ops',
    description: 'Owns playbook recovery evidence and export handling.',
  ),
  manager(
    label: 'Manager',
    shortLabel: 'Manager',
    description: 'Reviews direct-report recovery actions with scoped access.',
  ),
  hrAuditor(
    label: 'HR auditor',
    shortLabel: 'Auditor',
    description: 'Reviews playbook evidence without copying export files.',
  );

  final String label;
  final String shortLabel;
  final String description;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportRole({
    required this.label,
    required this.shortLabel,
    required this.description,
  });
}

/// Playbook audit export action that can be allowed or blocked by policy.
enum EmployeeWorkflowInboxSlaPlaybookAuditExportAction {
  copyCsv('Copy CSV'),
  copyText('Copy text');

  final String label;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportAction(this.label);
}

/// Role and readiness decision for one playbook audit export action.
class EmployeeWorkflowInboxSlaPlaybookAuditExportPermission {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportAction action;
  final bool allowed;
  final String reason;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportPermission({
    required this.action,
    required this.allowed,
    required this.reason,
  });

  String get statusLabel => allowed ? 'Allowed' : 'Blocked';
}

/// Evaluates scoped playbook audit package permissions for one HR role.
class EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportRole role;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview({
    required this.role,
    required this.preview,
  });

  EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction get redaction {
    return switch (role) {
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations =>
        EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none,
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager =>
        EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.managerSafe,
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.hrAuditor =>
        EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none,
    };
  }

  EmployeeWorkflowInboxSlaPlaybookAuditExportPreview get exportPreview {
    return preview.copyWith(redaction: redaction);
  }

  bool get isRedacted {
    return redaction !=
        EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none;
  }

  List<EmployeeWorkflowInboxSlaPlaybookAuditExportPermission> get permissions {
    return [copyCsvPermission, copyTextPermission];
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
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations =>
        'People Operations can copy ready playbook audit packages.',
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager =>
        'Manager receives redacted packages that hide correction history and previous reasons.',
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.hrAuditor =>
        'HR auditor can inspect playbook evidence without copying files.',
    };
  }

  EmployeeWorkflowInboxSlaPlaybookAuditExportPermission get copyCsvPermission {
    return _permissionFor(
      action: EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyCsv,
      allowedReason:
          role == EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager
              ? 'Manager can copy this redacted playbook audit CSV.'
              : 'People Operations can copy this playbook audit CSV.',
      auditorReason:
          'HR auditor can review playbook audit packages but cannot copy CSV files.',
    );
  }

  EmployeeWorkflowInboxSlaPlaybookAuditExportPermission get copyTextPermission {
    return _permissionFor(
      action: EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyText,
      allowedReason:
          role == EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager
              ? 'Manager can copy this redacted playbook audit text.'
              : 'People Operations can copy this playbook audit text.',
      auditorReason:
          'HR auditor can review playbook audit packages but cannot copy text files.',
    );
  }

  EmployeeWorkflowInboxSlaPlaybookAuditExportPermission _permissionFor({
    required EmployeeWorkflowInboxSlaPlaybookAuditExportAction action,
    required String allowedReason,
    required String auditorReason,
  }) {
    final safePreview = exportPreview;
    if (!safePreview.isReady) {
      return _blocked(action, safePreview.exportActionLabel);
    }

    return switch (role) {
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations =>
        _allowed(action, allowedReason),
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager => _allowed(
        action,
        allowedReason,
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.hrAuditor => _blocked(
        action,
        auditorReason,
      ),
    };
  }

  EmployeeWorkflowInboxSlaPlaybookAuditExportPermission _allowed(
    EmployeeWorkflowInboxSlaPlaybookAuditExportAction action,
    String reason,
  ) {
    return EmployeeWorkflowInboxSlaPlaybookAuditExportPermission(
      action: action,
      allowed: true,
      reason: reason,
    );
  }

  EmployeeWorkflowInboxSlaPlaybookAuditExportPermission _blocked(
    EmployeeWorkflowInboxSlaPlaybookAuditExportAction action,
    String reason,
  ) {
    return EmployeeWorkflowInboxSlaPlaybookAuditExportPermission(
      action: action,
      allowed: false,
      reason: reason,
    );
  }
}
