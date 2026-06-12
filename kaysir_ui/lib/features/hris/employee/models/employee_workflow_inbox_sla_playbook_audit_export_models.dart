import 'employee_workflow_inbox_sla_playbook_action_models.dart';

/// Saved export scope for employee workflow inbox SLA playbook audit receipts.
enum EmployeeWorkflowInboxSlaPlaybookAuditExportScope {
  all('Full audit', 'full'),
  actions('Original actions', 'actions'),
  corrections('Corrections', 'corrections'),
  reasoned('With reasons', 'reasoned');

  final String label;
  final String fileNameToken;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportScope(
    this.label,
    this.fileNameToken,
  );
}

/// Export readiness state for employee workflow inbox SLA playbook audit data.
enum EmployeeWorkflowInboxSlaPlaybookAuditExportStatus {
  empty('No audit events'),
  ready('Ready');

  final String label;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportStatus(this.label);
}

/// Redaction policy applied to a workflow inbox SLA playbook audit export.
enum EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction {
  none('Full evidence', 'full', ''),
  managerSafe('Manager redacted', 'redacted', 'manager-redacted');

  final String label;
  final String shortLabel;
  final String fileNameToken;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction(
    this.label,
    this.shortLabel,
    this.fileNameToken,
  );
}

/// Metadata value included in a workflow inbox SLA playbook audit package.
class EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem {
  final String label;
  final String value;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem({
    required this.label,
    required this.value,
  });
}

/// CSV-safe representation of one workflow inbox SLA playbook audit receipt.
class EmployeeWorkflowInboxSlaPlaybookAuditExportRow {
  final EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction redaction;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportRow({
    required this.receipt,
    this.redaction = EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none,
  });

  List<String> get values {
    return [
      receipt.id,
      receipt.employeeId,
      receipt.employeeName,
      receipt.receiptKind.label,
      receipt.actionType.label,
      _redactedValue(receipt.correctedReceiptId ?? ''),
      receipt.stepId,
      receipt.stepTitle,
      receipt.stepType.label,
      receipt.actor,
      receipt.owner,
      '${receipt.itemCount}',
      '${receipt.sources.length}',
      receipt.sourceLabel,
      receipt.reasonLabel,
      _redactedValue(
        receipt.hasPreviousReason ? receipt.previousReasonLabel : '',
      ),
      _formatTimestamp(receipt.decidedAt),
    ];
  }

  String _redactedValue(String value) {
    if (redaction !=
            EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none &&
        value.isNotEmpty) {
      return 'Redacted';
    }
    return value;
  }
}

/// Reviewable export package for workflow inbox SLA playbook audit receipts.
class EmployeeWorkflowInboxSlaPlaybookAuditExportPreview {
  final EmployeeWorkflowInboxSlaPlaybookActionProfile profile;
  final DateTime generatedAt;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportScope scope;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction redaction;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportPreview({
    required this.profile,
    required this.generatedAt,
    this.scope = EmployeeWorkflowInboxSlaPlaybookAuditExportScope.all,
    this.redaction = EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none,
  });

  EmployeeWorkflowInboxSlaPlaybookAuditExportPreview copyWith({
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope? scope,
    EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction? redaction,
  }) {
    return EmployeeWorkflowInboxSlaPlaybookAuditExportPreview(
      profile: profile,
      generatedAt: generatedAt,
      scope: scope ?? this.scope,
      redaction: redaction ?? this.redaction,
    );
  }

  EmployeeWorkflowInboxSlaPlaybookAuditExportStatus get status {
    if (rows.isEmpty) {
      return EmployeeWorkflowInboxSlaPlaybookAuditExportStatus.empty;
    }
    return EmployeeWorkflowInboxSlaPlaybookAuditExportStatus.ready;
  }

  bool get isReady =>
      status == EmployeeWorkflowInboxSlaPlaybookAuditExportStatus.ready;

  String get statusLabel => status.label;

  String get fileName {
    final suffix =
        redaction.fileNameToken.isEmpty ? '' : '-${redaction.fileNameToken}';
    return 'employee-${profile.employeeId}-workflow-inbox-playbook-audit-${scope.fileNameToken}$suffix.csv';
  }

  int get rowCount => rows.length;

  String get rowCountLabel {
    return '$rowCount event${rowCount == 1 ? '' : 's'}';
  }

  String get exportActionLabel {
    if (isReady) {
      if (redaction ==
          EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none) {
        return 'Playbook audit package ready';
      }
      return '${redaction.label} package ready';
    }
    if (profile.receipts.isEmpty) return 'Record a playbook action first';
    if (redaction !=
            EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none &&
        _unredactedCountFor(scope) > 0) {
      return 'No ${redaction.shortLabel.toLowerCase()} events match this audit scope';
    }
    return 'No ${scope.label.toLowerCase()} match this audit scope';
  }

  int countFor(EmployeeWorkflowInboxSlaPlaybookAuditExportScope scope) {
    return profile.receipts
        .where((receipt) => _matchesScope(receipt, scope))
        .where((receipt) => _matchesRedaction(receipt, redaction))
        .length;
  }

  List<EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem>
  get manifestItems {
    final scopedRows = rows;
    final scopedReceipts = scopedRows.map((row) => row.receipt).toList();
    final sourceCount = scopedReceipts.fold<int>(
      0,
      (total, receipt) => total + receipt.sources.length,
    );

    return [
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Employee',
        value: profile.employeeName,
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Employee ID',
        value: profile.employeeId,
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Scope',
        value: scope.label,
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Redaction',
        value: redaction.label,
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Rows',
        value: rowCountLabel,
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Corrections',
        value:
            '${scopedReceipts.where((receipt) => receipt.isCorrection).length}',
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Reasons',
        value: '${scopedReceipts.where((receipt) => receipt.hasReason).length}',
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Owners',
        value:
            '${scopedReceipts.map((receipt) => receipt.owner).toSet().length}',
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Sources',
        value: '$sourceCount',
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem(
        label: 'Generated',
        value: _formatTimestamp(generatedAt),
      ),
    ];
  }

  List<EmployeeWorkflowInboxSlaPlaybookAuditExportRow> get rows {
    final sorted =
        profile.receipts
            .where((receipt) => _matchesScope(receipt, scope))
            .where((receipt) => _matchesRedaction(receipt, redaction))
            .toList()
          ..sort((a, b) {
            final dateCompare = a.decidedAt.compareTo(b.decidedAt);
            if (dateCompare != 0) return dateCompare;
            return a.id.compareTo(b.id);
          });
    return [
      for (final receipt in sorted)
        EmployeeWorkflowInboxSlaPlaybookAuditExportRow(
          receipt: receipt,
          redaction: redaction,
        ),
    ];
  }

  String get csvContent {
    final lines = [
      _headers.map(_escapeCsv).join(','),
      ...rows.map((row) => row.values.map(_escapeCsv).join(',')),
    ];
    return lines.join('\n');
  }

  String get plainTextContent {
    final lines = [
      'Playbook audit package',
      'Employee: ${profile.employeeName} (${profile.employeeId})',
      'Scope: ${scope.label}',
      'Redaction: ${redaction.label}',
      'Rows: $rowCountLabel',
      'Generated: ${_formatTimestamp(generatedAt)}',
      'Events:',
      if (rows.isEmpty) 'No audit events match this scope.',
      for (final row in rows) _plainTextLine(row.receipt, redaction),
    ];
    return lines.join('\n');
  }

  int _unredactedCountFor(
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope scope,
  ) {
    return profile.receipts
        .where((receipt) => _matchesScope(receipt, scope))
        .length;
  }
}

bool _matchesScope(
  EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt,
  EmployeeWorkflowInboxSlaPlaybookAuditExportScope scope,
) {
  return switch (scope) {
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.all => true,
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.actions =>
      !receipt.isCorrection,
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.corrections =>
      receipt.isCorrection,
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.reasoned =>
      receipt.hasReason,
  };
}

bool _matchesRedaction(
  EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt,
  EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction redaction,
) {
  return switch (redaction) {
    EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none => true,
    EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.managerSafe =>
      !receipt.isCorrection,
  };
}

String _plainTextLine(
  EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt,
  EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction redaction,
) {
  final includeCorrectionContext =
      redaction == EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none;
  final correction =
      includeCorrectionContext && receipt.correctedReceiptId != null
          ? ' | Corrects: ${receipt.correctedReceiptId}'
          : '';
  final previous =
      includeCorrectionContext && receipt.hasPreviousReason
          ? ' | Previous: ${receipt.previousReasonLabel}'
          : '';
  return '- ${receipt.id} | ${receipt.receiptKind.label} | '
      '${receipt.actionType.label} | ${receipt.stepTitle} | '
      'Owner: ${receipt.owner} | Items: ${receipt.itemCountLabel} | '
      'Sources: ${receipt.sourceLabel} | Reason: ${receipt.reasonLabel}'
      '$correction$previous';
}

const _headers = [
  'receipt_id',
  'employee_id',
  'employee_name',
  'event_kind',
  'action',
  'corrected_receipt_id',
  'step_id',
  'step_title',
  'step_type',
  'actor',
  'owner',
  'item_count',
  'source_count',
  'sources',
  'reason',
  'previous_reason',
  'decided_at',
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
