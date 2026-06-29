import 'employee_document_lifecycle_audit_models.dart';

/// Filter group used to narrow employee document lifecycle audit events.
enum EmployeeDocumentLifecycleAuditFilterGroup {
  all('All'),
  request('Requests'),
  vault('Vault'),
  fulfillment('Fulfilled'),
  linked('Linked');

  final String label;

  const EmployeeDocumentLifecycleAuditFilterGroup(this.label);

  bool matches(EmployeeDocumentLifecycleAuditEntry entry) {
    return switch (this) {
      EmployeeDocumentLifecycleAuditFilterGroup.all => true,
      EmployeeDocumentLifecycleAuditFilterGroup.request => entry.isRequest,
      EmployeeDocumentLifecycleAuditFilterGroup.vault => entry.isVault,
      EmployeeDocumentLifecycleAuditFilterGroup.fulfillment =>
        entry.isFulfillment,
      EmployeeDocumentLifecycleAuditFilterGroup.linked =>
        entry.correlationId.trim().isNotEmpty,
    };
  }
}

/// Search and grouping query for employee document lifecycle audit events.
class EmployeeDocumentLifecycleAuditFilterQuery {
  final EmployeeDocumentLifecycleAuditFilterGroup group;
  final String searchText;

  const EmployeeDocumentLifecycleAuditFilterQuery({
    this.group = EmployeeDocumentLifecycleAuditFilterGroup.all,
    this.searchText = '',
  });

  bool get hasSearch => _normalizedSearch.isNotEmpty;

  bool get isDefault {
    return group == EmployeeDocumentLifecycleAuditFilterGroup.all && !hasSearch;
  }

  int get activeFilterCount {
    return (group == EmployeeDocumentLifecycleAuditFilterGroup.all ? 0 : 1) +
        (hasSearch ? 1 : 0);
  }

  String get summaryLabel {
    if (isDefault) return 'All document lifecycle events';
    if (hasSearch) return '${group.label} matching "$searchText"';
    return group.label;
  }

  EmployeeDocumentLifecycleAuditFilterQuery copyWith({
    EmployeeDocumentLifecycleAuditFilterGroup? group,
    String? searchText,
  }) {
    return EmployeeDocumentLifecycleAuditFilterQuery(
      group: group ?? this.group,
      searchText: searchText ?? this.searchText,
    );
  }

  List<EmployeeDocumentLifecycleAuditEntry> applyTo(
    Iterable<EmployeeDocumentLifecycleAuditEntry> entries,
  ) {
    return entries.where(matches).toList();
  }

  bool matches(EmployeeDocumentLifecycleAuditEntry entry) {
    if (!group.matches(entry)) return false;

    final search = _normalizedSearch;
    if (search.isEmpty) return true;

    return _searchCorpus(entry).contains(search);
  }

  String get _normalizedSearch => _normalize(searchText);
}

String _searchCorpus(EmployeeDocumentLifecycleAuditEntry entry) {
  return _normalize(
    [
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
    ].join(' '),
  );
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}
