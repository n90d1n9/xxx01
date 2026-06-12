import 'employee_payroll_run_console_audit_export_models.dart';
import 'employee_payroll_run_console_audit_handoff_models.dart';
import 'employee_payroll_run_console_audit_package_models.dart';

/// Archive readiness state for a payroll close evidence package.
enum EmployeePayrollRunConsoleAuditArchiveStatus {
  noEvidence('No evidence'),
  packageBlocked('Package blocked'),
  handoffRequired('Handoff required'),
  decisionRequired('Decision required'),
  returned('Returned'),
  receiptIncomplete('Receipt incomplete'),
  ready('Archive ready');

  final String label;

  const EmployeePayrollRunConsoleAuditArchiveStatus(this.label);
}

/// Metadata row included in the payroll close archive pack preview.
class EmployeePayrollRunConsoleAuditArchiveManifestItem {
  final String label;
  final String value;

  const EmployeePayrollRunConsoleAuditArchiveManifestItem({
    required this.label,
    required this.value,
  });
}

/// Read model that combines package, export, handoff, and receipt readiness.
class EmployeePayrollRunConsoleAuditArchivePack {
  final EmployeePayrollRunConsoleAuditEvidencePackage package;
  final EmployeePayrollRunConsoleAuditExportPreview exportPreview;
  final EmployeePayrollRunConsoleAuditHandoffReview handoffReview;

  const EmployeePayrollRunConsoleAuditArchivePack({
    required this.package,
    required this.exportPreview,
    required this.handoffReview,
  });

  EmployeePayrollRunConsoleAuditHandoffRecord? get latestHandoff {
    return handoffReview.latestHandoff;
  }

  EmployeePayrollRunConsoleAuditArchiveStatus get status {
    final latest = latestHandoff;
    if (exportPreview.status ==
        EmployeePayrollRunConsoleAuditExportStatus.empty) {
      return EmployeePayrollRunConsoleAuditArchiveStatus.noEvidence;
    }
    if (!exportPreview.isReady || !handoffReview.errorsReadyForArchive) {
      return EmployeePayrollRunConsoleAuditArchiveStatus.packageBlocked;
    }
    if (latest == null) {
      return EmployeePayrollRunConsoleAuditArchiveStatus.handoffRequired;
    }
    if (latest.status ==
        EmployeePayrollRunConsoleAuditHandoffStatus.submitted) {
      return EmployeePayrollRunConsoleAuditArchiveStatus.decisionRequired;
    }
    if (latest.status == EmployeePayrollRunConsoleAuditHandoffStatus.returned) {
      return EmployeePayrollRunConsoleAuditArchiveStatus.returned;
    }
    if (latest.status == EmployeePayrollRunConsoleAuditHandoffStatus.approved &&
        (!latest.isDecided || !latest.hasCompleteDecisionAttestation)) {
      return EmployeePayrollRunConsoleAuditArchiveStatus.receiptIncomplete;
    }
    if (latest.status == EmployeePayrollRunConsoleAuditHandoffStatus.approved) {
      return EmployeePayrollRunConsoleAuditArchiveStatus.ready;
    }
    return EmployeePayrollRunConsoleAuditArchiveStatus.handoffRequired;
  }

  bool get isReady =>
      status == EmployeePayrollRunConsoleAuditArchiveStatus.ready;

  String get statusLabel => status.label;

  String get archiveReference {
    return 'ARC-${package.packageReference.replaceFirst('PKG-', '')}';
  }

  String get fileName {
    return '${archiveReference.toLowerCase()}-close-archive.zip';
  }

  String get actionLabel {
    return switch (status) {
      EmployeePayrollRunConsoleAuditArchiveStatus.ready =>
        'Archive pack ready for retention.',
      EmployeePayrollRunConsoleAuditArchiveStatus.noEvidence =>
        'Capture payroll command evidence first.',
      EmployeePayrollRunConsoleAuditArchiveStatus.packageBlocked =>
        'Resolve package and export blockers first.',
      EmployeePayrollRunConsoleAuditArchiveStatus.handoffRequired =>
        'Submit and approve handoff before archive.',
      EmployeePayrollRunConsoleAuditArchiveStatus.decisionRequired =>
        'Approver decision is required before archive.',
      EmployeePayrollRunConsoleAuditArchiveStatus.returned =>
        'Returned package must be refreshed before archive.',
      EmployeePayrollRunConsoleAuditArchiveStatus.receiptIncomplete =>
        'Approval receipt is missing required controls.',
    };
  }

  String get packageLabel => package.readinessLabel;

  String get exportLabel => exportPreview.statusLabel;

  String get handoffLabel {
    final latest = latestHandoff;
    if (latest == null) return 'Not submitted';
    return latest.statusLabel;
  }

  String get receiptLabel {
    final latest = latestHandoff;
    if (latest == null || !latest.isDecided) return 'Missing';
    return latest.decisionAttestationLabel;
  }

  List<String> get blockers {
    return switch (status) {
      EmployeePayrollRunConsoleAuditArchiveStatus.ready => const [],
      EmployeePayrollRunConsoleAuditArchiveStatus.noEvidence => const [
        'No payroll audit events are available.',
      ],
      EmployeePayrollRunConsoleAuditArchiveStatus.packageBlocked => [
        if (!exportPreview.isReady) exportPreview.exportActionLabel,
        ...handoffReview.archiveBlockingErrors,
      ],
      EmployeePayrollRunConsoleAuditArchiveStatus.handoffRequired => const [
        'Payroll close handoff has not been submitted.',
      ],
      EmployeePayrollRunConsoleAuditArchiveStatus.decisionRequired => const [
        'Submitted handoff is waiting for approver decision.',
      ],
      EmployeePayrollRunConsoleAuditArchiveStatus.returned => [
        latestHandoff?.returnedReason ?? 'Evidence package was returned.',
      ],
      EmployeePayrollRunConsoleAuditArchiveStatus.receiptIncomplete => const [
        'Approval receipt does not include every required attestation.',
      ],
    };
  }

  List<EmployeePayrollRunConsoleAuditArchiveManifestItem> get manifestItems {
    return [
      EmployeePayrollRunConsoleAuditArchiveManifestItem(
        label: 'Archive',
        value: archiveReference,
      ),
      EmployeePayrollRunConsoleAuditArchiveManifestItem(
        label: 'Package',
        value: package.packageReference,
      ),
      EmployeePayrollRunConsoleAuditArchiveManifestItem(
        label: 'Export',
        value: exportPreview.fileName,
      ),
      EmployeePayrollRunConsoleAuditArchiveManifestItem(
        label: 'Handoff',
        value: handoffLabel,
      ),
      EmployeePayrollRunConsoleAuditArchiveManifestItem(
        label: 'Receipt',
        value: receiptLabel,
      ),
    ];
  }
}

extension on EmployeePayrollRunConsoleAuditHandoffReview {
  bool get errorsReadyForArchive {
    return archiveBlockingErrors.isEmpty;
  }

  List<String> get archiveBlockingErrors {
    return errors
        .where(
          (error) =>
              error.startsWith('Capture') ||
              error.startsWith('Resolve') ||
              error.startsWith('Complete'),
        )
        .toList(growable: false);
  }
}
