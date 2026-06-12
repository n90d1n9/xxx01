import 'company_governance_owner_handoff_record.dart';

/// Audit payload for recording governance owner handoffs in the timeline.
class CompanyGovernanceOwnerHandoffAuditPayload {
  final String documentId;
  final String documentTitle;
  final String entityName;
  final String actorName;
  final String note;
  final String correlationId;

  const CompanyGovernanceOwnerHandoffAuditPayload({
    required this.documentId,
    required this.documentTitle,
    required this.entityName,
    required this.actorName,
    required this.note,
    required this.correlationId,
  });

  factory CompanyGovernanceOwnerHandoffAuditPayload.fromRecord({
    required CompanyGovernanceOwnerHandoffRecord record,
    required String entityName,
  }) {
    return CompanyGovernanceOwnerHandoffAuditPayload(
      documentId: record.id,
      documentTitle: '${record.ownerLabel} - Governance handoff',
      entityName:
          entityName.trim().isEmpty ? 'Company Governance' : entityName.trim(),
      actorName: record.actorName,
      note: _auditNote(record),
      correlationId: record.id,
    );
  }
}

String _auditNote(CompanyGovernanceOwnerHandoffRecord record) {
  final criticalLabel =
      record.criticalCount == 1
          ? '1 critical action'
          : '${record.criticalCount} critical actions';
  final highLabel =
      record.highCount == 1
          ? '1 high action'
          : '${record.highCount} high actions';

  return 'Recorded governance handoff for ${record.ownerLabel}: '
      '${record.actionCount} actions across ${record.sourceSummary}. '
      'Priority includes $criticalLabel and $highLabel. '
      'Next touch: ${record.nextDueLabel}.';
}
