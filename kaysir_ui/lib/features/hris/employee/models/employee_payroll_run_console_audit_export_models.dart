import 'employee_payroll_run_console_audit_models.dart';
import 'employee_payroll_run_console_audit_package_models.dart';

/// Export readiness state for a payroll console audit evidence package.
enum EmployeePayrollRunConsoleAuditExportStatus {
  empty('No evidence'),
  needsReview('Needs review'),
  incomplete('Incomplete'),
  ready('Ready');

  final String label;

  const EmployeePayrollRunConsoleAuditExportStatus(this.label);
}

/// Metadata row included in the payroll audit export preview manifest.
class EmployeePayrollRunConsoleAuditExportManifestItem {
  final String label;
  final String value;

  const EmployeePayrollRunConsoleAuditExportManifestItem({
    required this.label,
    required this.value,
  });
}

/// CSV-safe representation of one payroll console audit event.
class EmployeePayrollRunConsoleAuditExportEventRow {
  final EmployeePayrollRunConsoleAuditEvent event;

  const EmployeePayrollRunConsoleAuditExportEventRow({required this.event});

  List<String> get values {
    return [
      event.id,
      event.runReference,
      event.commandType.label,
      event.status.label,
      event.operatorName,
      _formatTimestamp(event.occurredAt),
      event.scopeLabel,
      event.targetEmployeeCount.toString(),
      event.completedCount.toString(),
      event.skippedCount.toString(),
      event.errors.join(' | '),
      event.message,
    ];
  }
}

/// Reviewable export preview for a payroll console audit evidence package.
class EmployeePayrollRunConsoleAuditExportPreview {
  final EmployeePayrollRunConsoleAuditEvidencePackage package;
  final DateTime generatedAt;

  const EmployeePayrollRunConsoleAuditExportPreview({
    required this.package,
    required this.generatedAt,
  });

  EmployeePayrollRunConsoleAuditSummary get summary => package.summary;

  EmployeePayrollRunConsoleAuditExportStatus get status {
    if (summary.eventCount == 0) {
      return EmployeePayrollRunConsoleAuditExportStatus.empty;
    }
    if (summary.attentionCount > 0) {
      return EmployeePayrollRunConsoleAuditExportStatus.needsReview;
    }
    if (!package.hasCompleteCommandCoverage ||
        package.readyItemCount != package.totalItemCount ||
        package.report.status !=
            EmployeePayrollRunConsoleAuditEvidenceStatus.ready) {
      return EmployeePayrollRunConsoleAuditExportStatus.incomplete;
    }
    return EmployeePayrollRunConsoleAuditExportStatus.ready;
  }

  bool get isReady =>
      status == EmployeePayrollRunConsoleAuditExportStatus.ready;

  String get statusLabel => status.label;

  String get fileName {
    return '${package.packageReference.toLowerCase()}-audit-events.csv';
  }

  int get rowCount => eventRows.length;

  String get rowCountLabel {
    return '$rowCount audit event${rowCount == 1 ? '' : 's'}';
  }

  String get exportActionLabel {
    return isReady ? 'Export preview ready' : 'Resolve package checks first';
  }

  List<EmployeePayrollRunConsoleAuditExportManifestItem> get manifestItems {
    return [
      EmployeePayrollRunConsoleAuditExportManifestItem(
        label: 'Package',
        value: package.packageReference,
      ),
      EmployeePayrollRunConsoleAuditExportManifestItem(
        label: 'Run',
        value: summary.runReferenceLabel,
      ),
      EmployeePayrollRunConsoleAuditExportManifestItem(
        label: 'Window',
        value: _formatWindow(package.openedAt, package.closedAt),
      ),
      EmployeePayrollRunConsoleAuditExportManifestItem(
        label: 'Readiness',
        value: package.readinessLabel,
      ),
      EmployeePayrollRunConsoleAuditExportManifestItem(
        label: 'Commands',
        value:
            '${package.evidencedCommandCount}/'
            '${package.totalCommandCount} evidenced',
      ),
      EmployeePayrollRunConsoleAuditExportManifestItem(
        label: 'Review',
        value:
            '${summary.attentionCount} item${summary.attentionCount == 1 ? '' : 's'}',
      ),
      EmployeePayrollRunConsoleAuditExportManifestItem(
        label: 'Generated',
        value: _formatTimestamp(generatedAt),
      ),
    ];
  }

  List<EmployeePayrollRunConsoleAuditExportEventRow> get eventRows {
    final sorted = [...summary.events]..sort((a, b) {
      final dateComparison = a.occurredAt.compareTo(b.occurredAt);
      if (dateComparison != 0) return dateComparison;
      return a.id.compareTo(b.id);
    });
    return [
      for (final event in sorted)
        EmployeePayrollRunConsoleAuditExportEventRow(event: event),
    ];
  }

  String get csvContent {
    final lines = [
      _headers.map(_escapeCsv).join(','),
      ...eventRows.map((row) => row.values.map(_escapeCsv).join(',')),
    ];
    return lines.join('\n');
  }
}

const _headers = [
  'event_id',
  'run_reference',
  'command',
  'status',
  'operator',
  'occurred_at',
  'scope',
  'target_count',
  'completed_count',
  'skipped_count',
  'errors',
  'message',
];

String _escapeCsv(String value) {
  final needsEscaping =
      value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsEscaping) return value;
  return '"${value.replaceAll('"', '""')}"';
}

String _formatTimestamp(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}

String _formatWindow(DateTime? openedAt, DateTime? closedAt) {
  if (openedAt == null || closedAt == null) return 'No evidence window';
  if (openedAt == closedAt) return _formatTimestamp(openedAt);
  return '${_formatTimestamp(openedAt)} - ${_formatTimestamp(closedAt)}';
}
