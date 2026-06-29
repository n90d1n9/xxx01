import 'employee_document_lifecycle_audit_filter_models.dart';
import 'employee_document_lifecycle_audit_models.dart';

/// Export readiness state for a document lifecycle audit package.
enum EmployeeDocumentLifecycleAuditExportStatus {
  empty('No rows'),
  scoped('Scoped'),
  ready('Ready');

  final String label;

  const EmployeeDocumentLifecycleAuditExportStatus(this.label);
}

/// Metadata row shown in the document lifecycle audit export manifest.
class EmployeeDocumentLifecycleAuditExportManifestItem {
  final String label;
  final String value;

  const EmployeeDocumentLifecycleAuditExportManifestItem({
    required this.label,
    required this.value,
  });
}

/// CSV-safe representation of one document lifecycle audit event.
class EmployeeDocumentLifecycleAuditExportEventRow {
  final EmployeeDocumentLifecycleAuditEntry entry;

  const EmployeeDocumentLifecycleAuditExportEventRow({required this.entry});

  List<String> get values {
    return [
      entry.id,
      entry.employeeId,
      entry.employeeName,
      entry.typeLabel,
      entry.groupLabel,
      entry.subjectId,
      entry.title,
      entry.actor,
      entry.owner,
      entry.detail,
      entry.correlationId,
      _formatTimestamp(entry.occurredAt),
    ];
  }
}

/// Reviewable export preview for filtered document lifecycle audit events.
class EmployeeDocumentLifecycleAuditExportPreview {
  final EmployeeDocumentLifecycleAuditProfile profile;
  final List<EmployeeDocumentLifecycleAuditEntry> entries;
  final EmployeeDocumentLifecycleAuditFilterQuery query;
  final DateTime generatedAt;

  const EmployeeDocumentLifecycleAuditExportPreview({
    required this.profile,
    required this.entries,
    required this.query,
    required this.generatedAt,
  });

  EmployeeDocumentLifecycleAuditExportStatus get status {
    if (entries.isEmpty) {
      return EmployeeDocumentLifecycleAuditExportStatus.empty;
    }
    if (!query.isDefault) {
      return EmployeeDocumentLifecycleAuditExportStatus.scoped;
    }
    return EmployeeDocumentLifecycleAuditExportStatus.ready;
  }

  bool get isReady => entries.isNotEmpty;

  String get statusLabel => status.label;

  String get fileName {
    final employeeSlug = _slug(profile.employeeName);
    final scopeSlug = _slug(query.group.label);
    final dateSlug = _formatDate(generatedAt).replaceAll('-', '');
    return '$employeeSlug-document-lifecycle-audit-$scopeSlug-$dateSlug.csv';
  }

  int get rowCount => eventRows.length;

  String get rowCountLabel {
    return '$rowCount audit event${rowCount == 1 ? '' : 's'}';
  }

  String get exportActionLabel {
    return switch (status) {
      EmployeeDocumentLifecycleAuditExportStatus.empty =>
        'No audit events available for export.',
      EmployeeDocumentLifecycleAuditExportStatus.scoped =>
        'Filtered lifecycle audit export ready.',
      EmployeeDocumentLifecycleAuditExportStatus.ready =>
        'Lifecycle audit export ready.',
    };
  }

  List<EmployeeDocumentLifecycleAuditExportManifestItem> get manifestItems {
    return [
      EmployeeDocumentLifecycleAuditExportManifestItem(
        label: 'Employee',
        value: profile.employeeName,
      ),
      EmployeeDocumentLifecycleAuditExportManifestItem(
        label: 'Scope',
        value: query.summaryLabel,
      ),
      EmployeeDocumentLifecycleAuditExportManifestItem(
        label: 'Rows',
        value: '$rowCount/${profile.totalCount}',
      ),
      EmployeeDocumentLifecycleAuditExportManifestItem(
        label: 'Requests',
        value: '${entries.where((entry) => entry.isRequest).length}',
      ),
      EmployeeDocumentLifecycleAuditExportManifestItem(
        label: 'Vault',
        value: '${entries.where((entry) => entry.isVault).length}',
      ),
      EmployeeDocumentLifecycleAuditExportManifestItem(
        label: 'Fulfilled',
        value: '${entries.where((entry) => entry.isFulfillment).length}',
      ),
      EmployeeDocumentLifecycleAuditExportManifestItem(
        label: 'Generated',
        value: _formatTimestamp(generatedAt),
      ),
    ];
  }

  List<EmployeeDocumentLifecycleAuditExportEventRow> get eventRows {
    final sorted = [...entries]..sort((a, b) {
      final dateComparison = a.occurredAt.compareTo(b.occurredAt);
      if (dateComparison != 0) return dateComparison;
      return a.id.compareTo(b.id);
    });
    return [
      for (final entry in sorted)
        EmployeeDocumentLifecycleAuditExportEventRow(entry: entry),
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
  'employee_id',
  'employee_name',
  'event_type',
  'event_group',
  'subject_id',
  'title',
  'actor',
  'owner',
  'detail',
  'correlation_id',
  'occurred_at',
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

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _slug(String value) {
  final lower = value.trim().toLowerCase();
  final collapsed = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return collapsed.replaceAll(RegExp(r'^-+|-+$'), '');
}
