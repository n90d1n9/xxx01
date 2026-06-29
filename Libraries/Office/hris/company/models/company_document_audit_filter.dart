import 'company_document_audit_event.dart';

enum CompanyDocumentAuditTimelineScope {
  all('All'),
  companyDocuments('Company docs'),
  employeeDocuments('Employee docs');

  final String label;

  const CompanyDocumentAuditTimelineScope(this.label);

  bool matches(CompanyDocumentAuditEvent event) {
    switch (this) {
      case CompanyDocumentAuditTimelineScope.all:
        return true;
      case CompanyDocumentAuditTimelineScope.companyDocuments:
        return !event.type.isEmployeeDocumentEvent;
      case CompanyDocumentAuditTimelineScope.employeeDocuments:
        return event.type.isEmployeeDocumentEvent;
    }
  }
}

enum CompanyDocumentAuditFilterPreset {
  allActivity('All activity'),
  employeeEvidence('Employee evidence'),
  requestLifecycle('Request lifecycle'),
  companyDocuments('Company documents');

  final String label;

  const CompanyDocumentAuditFilterPreset(this.label);

  CompanyDocumentAuditTimelineFilter get filter {
    switch (this) {
      case CompanyDocumentAuditFilterPreset.allActivity:
        return const CompanyDocumentAuditTimelineFilter();
      case CompanyDocumentAuditFilterPreset.employeeEvidence:
        return const CompanyDocumentAuditTimelineFilter(
          scope: CompanyDocumentAuditTimelineScope.employeeDocuments,
          searchText: 'evidence verified',
        );
      case CompanyDocumentAuditFilterPreset.requestLifecycle:
        return const CompanyDocumentAuditTimelineFilter(
          scope: CompanyDocumentAuditTimelineScope.employeeDocuments,
          searchText: 'request',
        );
      case CompanyDocumentAuditFilterPreset.companyDocuments:
        return const CompanyDocumentAuditTimelineFilter(
          scope: CompanyDocumentAuditTimelineScope.companyDocuments,
        );
    }
  }

  bool isActiveFor(CompanyDocumentAuditTimelineFilter value) {
    return filter == value;
  }
}

class CompanyDocumentAuditTimelineFilter {
  final CompanyDocumentAuditTimelineScope scope;
  final String searchText;

  const CompanyDocumentAuditTimelineFilter({
    this.scope = CompanyDocumentAuditTimelineScope.all,
    this.searchText = '',
  });

  bool get hasSearch => searchText.trim().isNotEmpty;

  CompanyDocumentAuditTimelineFilter copyWith({
    CompanyDocumentAuditTimelineScope? scope,
    String? searchText,
  }) {
    return CompanyDocumentAuditTimelineFilter(
      scope: scope ?? this.scope,
      searchText: searchText ?? this.searchText,
    );
  }

  bool matches(CompanyDocumentAuditEvent event) {
    return scope.matches(event) && _matchesSearch(event);
  }

  bool _matchesSearch(CompanyDocumentAuditEvent event) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) return true;

    return event.documentTitle.toLowerCase().contains(query) ||
        event.entityName.toLowerCase().contains(query) ||
        event.actorName.toLowerCase().contains(query) ||
        event.note.toLowerCase().contains(query) ||
        event.type.label.toLowerCase().contains(query);
  }

  @override
  bool operator ==(Object other) {
    return other is CompanyDocumentAuditTimelineFilter &&
        other.scope == scope &&
        other.searchText.trim().toLowerCase() ==
            searchText.trim().toLowerCase();
  }

  @override
  int get hashCode {
    return Object.hash(scope, searchText.trim().toLowerCase());
  }
}

extension CompanyDocumentAuditEventTypeScope on CompanyDocumentAuditEventType {
  bool get isEmployeeDocumentEvent {
    switch (this) {
      case CompanyDocumentAuditEventType.employeeRequestGenerated:
      case CompanyDocumentAuditEventType.employeeEvidenceVerified:
      case CompanyDocumentAuditEventType.employeeRequestClosed:
      case CompanyDocumentAuditEventType.employeeGapWaived:
      case CompanyDocumentAuditEventType.employeeOwnerDigestSent:
      case CompanyDocumentAuditEventType.employeeOwnerEscalated:
      case CompanyDocumentAuditEventType.employeeOwnerFollowedUp:
        return true;
      case CompanyDocumentAuditEventType.created:
      case CompanyDocumentAuditEventType.reviewed:
      case CompanyDocumentAuditEventType.reminderSent:
      case CompanyDocumentAuditEventType.renewalStarted:
      case CompanyDocumentAuditEventType.renewed:
      case CompanyDocumentAuditEventType.verified:
      case CompanyDocumentAuditEventType.escalated:
      case CompanyDocumentAuditEventType.governanceOwnerHandoffRecorded:
      case CompanyDocumentAuditEventType.governanceOwnerFollowedUp:
      case CompanyDocumentAuditEventType.governanceFollowUpPolicyChanged:
        return false;
    }
  }
}
