enum CompanyDocumentAuditEventType {
  created,
  reviewed,
  reminderSent,
  renewalStarted,
  renewed,
  verified,
  escalated,
  employeeRequestGenerated,
  employeeEvidenceVerified,
  employeeRequestClosed,
  employeeGapWaived,
  employeeOwnerDigestSent,
  employeeOwnerEscalated,
  employeeOwnerFollowedUp,
  governanceOwnerHandoffRecorded,
  governanceOwnerFollowedUp,
  governanceFollowUpPolicyChanged,
}

extension CompanyDocumentAuditEventTypeLabels on CompanyDocumentAuditEventType {
  String get label {
    switch (this) {
      case CompanyDocumentAuditEventType.created:
        return 'Created';
      case CompanyDocumentAuditEventType.reviewed:
        return 'Reviewed';
      case CompanyDocumentAuditEventType.reminderSent:
        return 'Reminder sent';
      case CompanyDocumentAuditEventType.renewalStarted:
        return 'Renewal started';
      case CompanyDocumentAuditEventType.renewed:
        return 'Renewed';
      case CompanyDocumentAuditEventType.verified:
        return 'Verified';
      case CompanyDocumentAuditEventType.escalated:
        return 'Escalated';
      case CompanyDocumentAuditEventType.employeeRequestGenerated:
        return 'Request generated';
      case CompanyDocumentAuditEventType.employeeEvidenceVerified:
        return 'Evidence verified';
      case CompanyDocumentAuditEventType.employeeRequestClosed:
        return 'Request closed';
      case CompanyDocumentAuditEventType.employeeGapWaived:
        return 'Gap waived';
      case CompanyDocumentAuditEventType.employeeOwnerDigestSent:
        return 'Owner digest sent';
      case CompanyDocumentAuditEventType.employeeOwnerEscalated:
        return 'Owner escalated';
      case CompanyDocumentAuditEventType.employeeOwnerFollowedUp:
        return 'Owner followed up';
      case CompanyDocumentAuditEventType.governanceOwnerHandoffRecorded:
        return 'Governance handoff';
      case CompanyDocumentAuditEventType.governanceOwnerFollowedUp:
        return 'Governance follow-up';
      case CompanyDocumentAuditEventType.governanceFollowUpPolicyChanged:
        return 'Governance SLA changed';
    }
  }
}

/// Immutable record of one company or employee document audit activity.
class CompanyDocumentAuditEvent {
  final String id;
  final String documentId;
  final String documentTitle;
  final String entityName;
  final String actorName;
  final CompanyDocumentAuditEventType type;
  final DateTime happenedAt;
  final String note;
  final String correlationId;

  const CompanyDocumentAuditEvent({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.entityName,
    required this.actorName,
    required this.type,
    required this.happenedAt,
    required this.note,
    this.correlationId = '',
  });

  String get title => '${type.label}: $documentTitle';
}
