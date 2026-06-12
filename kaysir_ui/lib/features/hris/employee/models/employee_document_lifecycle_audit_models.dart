/// Type of document lifecycle event recorded for an employee.
enum EmployeeDocumentLifecycleAuditEventType {
  requestCreated('Request created', 'Request'),
  requestReviewing('Request reviewing', 'Request'),
  requestIssued('Request issued', 'Request'),
  requestAcknowledged('Request acknowledged', 'Request'),
  requestRejected('Request rejected', 'Request'),
  vaultUploaded('Vault upload', 'Vault'),
  vaultUploadRequested('Upload requested', 'Vault'),
  vaultVerified('Vault verified', 'Vault'),
  vaultRejected('Vault rejected', 'Vault'),
  vaultArchived('Vault archived', 'Vault'),
  vaultFulfilled('Vault fulfilled', 'Fulfillment');

  final String label;
  final String groupLabel;

  const EmployeeDocumentLifecycleAuditEventType(this.label, this.groupLabel);
}

/// Immutable audit event for one employee document lifecycle action.
class EmployeeDocumentLifecycleAuditEntry {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeDocumentLifecycleAuditEventType type;
  final String subjectId;
  final String title;
  final String actor;
  final String owner;
  final String detail;
  final String correlationId;
  final DateTime occurredAt;

  const EmployeeDocumentLifecycleAuditEntry({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.subjectId,
    required this.title,
    required this.actor,
    required this.owner,
    required this.detail,
    required this.correlationId,
    required this.occurredAt,
  });

  String get typeLabel => type.label;

  String get groupLabel => type.groupLabel;

  String get ownershipLabel {
    if (actor == owner) return actor;
    return '$actor for $owner';
  }

  bool get isRequest => type.groupLabel == 'Request';

  bool get isVault => type.groupLabel == 'Vault';

  bool get isFulfillment => type.groupLabel == 'Fulfillment';
}

/// Per-employee document lifecycle audit stream.
class EmployeeDocumentLifecycleAuditProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDocumentLifecycleAuditEntry> entries;

  const EmployeeDocumentLifecycleAuditProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.entries,
  });

  EmployeeDocumentLifecycleAuditProfile copyWith({
    List<EmployeeDocumentLifecycleAuditEntry>? entries,
  }) {
    return EmployeeDocumentLifecycleAuditProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      entries: entries ?? this.entries,
    );
  }

  List<EmployeeDocumentLifecycleAuditEntry> get sortedEntries {
    final sorted = [...entries]..sort((a, b) {
      final dateCompare = b.occurredAt.compareTo(a.occurredAt);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  List<EmployeeDocumentLifecycleAuditEntry> get latestEntries {
    return sortedEntries.take(5).toList();
  }

  int get totalCount => entries.length;

  int get requestCount => entries.where((entry) => entry.isRequest).length;

  int get vaultCount => entries.where((entry) => entry.isVault).length;

  int get fulfillmentCount {
    return entries.where((entry) => entry.isFulfillment).length;
  }

  String get nextAction {
    if (entries.isEmpty) {
      return 'Document lifecycle actions will appear after request or vault work is completed.';
    }
    final latest = sortedEntries.first;
    return 'Latest document event: ${latest.typeLabel} for ${latest.title}.';
  }
}
