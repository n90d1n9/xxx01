import 'employee_workflow_inbox_models.dart';
import 'employee_workflow_inbox_receipt_models.dart';

/// Saved export scope for employee workflow inbox action receipts.
enum EmployeeWorkflowInboxReceiptExportScope {
  all('All receipts', 'all'),
  governed('Governed actions', 'governed'),
  payroll('Payroll receipts', 'payroll'),
  actionWorkflow('Workflow tasks', 'workflow-tasks'),
  profileChange('Profile changes', 'profile-changes'),
  dataCorrection('Data corrections', 'data-corrections'),
  jobAssignment('Job assignments', 'job-assignments');

  final String label;
  final String fileNameToken;

  const EmployeeWorkflowInboxReceiptExportScope(this.label, this.fileNameToken);
}

/// Export readiness state for employee workflow inbox action receipts.
enum EmployeeWorkflowInboxReceiptExportStatus {
  empty('No receipts'),
  ready('Ready');

  final String label;

  const EmployeeWorkflowInboxReceiptExportStatus(this.label);
}

/// Metadata value included in the workflow inbox receipt export manifest.
class EmployeeWorkflowInboxReceiptExportManifestItem {
  final String label;
  final String value;

  const EmployeeWorkflowInboxReceiptExportManifestItem({
    required this.label,
    required this.value,
  });
}

/// CSV-safe representation of one employee workflow inbox action receipt.
class EmployeeWorkflowInboxReceiptExportRow {
  final EmployeeWorkflowInboxActionReceipt receipt;

  const EmployeeWorkflowInboxReceiptExportRow({required this.receipt});

  List<String> get values {
    return [
      receipt.id,
      receipt.employeeId,
      receipt.employeeName,
      receipt.workflowItemId,
      receipt.sourceRecordId,
      receipt.sourceLabel,
      receipt.actionLabel,
      receipt.area.label,
      receipt.actor,
      receipt.owner,
      receipt.previousStatus,
      _formatTimestamp(receipt.decidedAt),
      receipt.title,
    ];
  }
}

/// Reviewable CSV export preview for employee workflow inbox action receipts.
class EmployeeWorkflowInboxReceiptExportPreview {
  final EmployeeWorkflowInboxReceiptProfile profile;
  final DateTime generatedAt;
  final EmployeeWorkflowInboxReceiptExportScope scope;

  const EmployeeWorkflowInboxReceiptExportPreview({
    required this.profile,
    required this.generatedAt,
    this.scope = EmployeeWorkflowInboxReceiptExportScope.all,
  });

  EmployeeWorkflowInboxReceiptExportPreview copyWith({
    EmployeeWorkflowInboxReceiptExportScope? scope,
  }) {
    return EmployeeWorkflowInboxReceiptExportPreview(
      profile: profile,
      generatedAt: generatedAt,
      scope: scope ?? this.scope,
    );
  }

  EmployeeWorkflowInboxReceiptExportStatus get status {
    if (rows.isEmpty) {
      return EmployeeWorkflowInboxReceiptExportStatus.empty;
    }
    return EmployeeWorkflowInboxReceiptExportStatus.ready;
  }

  bool get isReady => status == EmployeeWorkflowInboxReceiptExportStatus.ready;

  String get statusLabel => status.label;

  String get fileName {
    return 'employee-${profile.employeeId}-workflow-inbox-receipts-${scope.fileNameToken}.csv';
  }

  int get rowCount => rows.length;

  String get rowCountLabel {
    return '$rowCount receipt${rowCount == 1 ? '' : 's'}';
  }

  String get exportActionLabel {
    if (isReady) return 'Receipt export preview ready';
    if (profile.receipts.isEmpty) return 'Complete an inbox action first';
    return 'No ${scope.label.toLowerCase()} match this export scope';
  }

  int countFor(EmployeeWorkflowInboxReceiptExportScope scope) {
    return profile.receipts
        .where((receipt) => _matchesScope(receipt, scope))
        .length;
  }

  List<EmployeeWorkflowInboxReceiptExportManifestItem> get manifestItems {
    return [
      EmployeeWorkflowInboxReceiptExportManifestItem(
        label: 'Employee',
        value: profile.employeeName,
      ),
      EmployeeWorkflowInboxReceiptExportManifestItem(
        label: 'Employee ID',
        value: profile.employeeId,
      ),
      EmployeeWorkflowInboxReceiptExportManifestItem(
        label: 'Scope',
        value: scope.label,
      ),
      EmployeeWorkflowInboxReceiptExportManifestItem(
        label: 'Rows',
        value: rowCountLabel,
      ),
      EmployeeWorkflowInboxReceiptExportManifestItem(
        label: 'Governed',
        value: '${rows.where((row) => row.receipt.isGovernedAction).length}',
      ),
      EmployeeWorkflowInboxReceiptExportManifestItem(
        label: 'Payroll',
        value: '${rows.where((row) => row.receipt.isPayroll).length}',
      ),
      EmployeeWorkflowInboxReceiptExportManifestItem(
        label: 'Generated',
        value: _formatTimestamp(generatedAt),
      ),
    ];
  }

  List<EmployeeWorkflowInboxReceiptExportRow> get rows {
    final sorted =
        profile.receipts
            .where((receipt) => _matchesScope(receipt, scope))
            .toList()
          ..sort((a, b) {
            final dateCompare = a.decidedAt.compareTo(b.decidedAt);
            if (dateCompare != 0) return dateCompare;
            return a.id.compareTo(b.id);
          });
    return [
      for (final receipt in sorted)
        EmployeeWorkflowInboxReceiptExportRow(receipt: receipt),
    ];
  }

  String get csvContent {
    final lines = [
      _headers.map(_escapeCsv).join(','),
      ...rows.map((row) => row.values.map(_escapeCsv).join(',')),
    ];
    return lines.join('\n');
  }
}

bool _matchesScope(
  EmployeeWorkflowInboxActionReceipt receipt,
  EmployeeWorkflowInboxReceiptExportScope scope,
) {
  return switch (scope) {
    EmployeeWorkflowInboxReceiptExportScope.all => true,
    EmployeeWorkflowInboxReceiptExportScope.governed =>
      receipt.isGovernedAction,
    EmployeeWorkflowInboxReceiptExportScope.payroll => receipt.isPayroll,
    EmployeeWorkflowInboxReceiptExportScope.actionWorkflow =>
      receipt.source == EmployeeWorkflowInboxSource.actionWorkflow,
    EmployeeWorkflowInboxReceiptExportScope.profileChange =>
      receipt.source == EmployeeWorkflowInboxSource.profileChange,
    EmployeeWorkflowInboxReceiptExportScope.dataCorrection =>
      receipt.source == EmployeeWorkflowInboxSource.dataCorrection,
    EmployeeWorkflowInboxReceiptExportScope.jobAssignment =>
      receipt.source == EmployeeWorkflowInboxSource.jobAssignment,
  };
}

const _headers = [
  'receipt_id',
  'employee_id',
  'employee_name',
  'workflow_item_id',
  'source_record_id',
  'source',
  'action',
  'area',
  'actor',
  'owner',
  'previous_status',
  'decided_at',
  'title',
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
