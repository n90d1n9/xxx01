import 'company_governance_follow_up_cadence.dart';

/// Audit payload for recording governance owner follow-up touches.
class CompanyGovernanceFollowUpAuditPayload {
  final String documentId;
  final String documentTitle;
  final String entityName;
  final String actorName;
  final String note;
  final String correlationId;

  const CompanyGovernanceFollowUpAuditPayload({
    required this.documentId,
    required this.documentTitle,
    required this.entityName,
    required this.actorName,
    required this.note,
    required this.correlationId,
  });

  factory CompanyGovernanceFollowUpAuditPayload.fromLane({
    required CompanyGovernanceFollowUpLane lane,
    required String entityName,
    String actorName = 'People Operations',
  }) {
    return CompanyGovernanceFollowUpAuditPayload(
      documentId: lane.handoffRecordId,
      documentTitle: '${lane.ownerLabel} - Governance follow-up',
      entityName:
          entityName.trim().isEmpty ? 'Company Governance' : entityName.trim(),
      actorName: actorName.trim().isEmpty ? 'People Operations' : actorName,
      note: _auditNote(lane),
      correlationId: lane.handoffRecordId,
    );
  }
}

String _auditNote(CompanyGovernanceFollowUpLane lane) {
  final criticalLabel =
      lane.criticalCount == 1
          ? '1 critical action'
          : '${lane.criticalCount} critical actions';
  final highLabel =
      lane.highCount == 1 ? '1 high action' : '${lane.highCount} high actions';

  return 'Recorded governance follow-up for ${lane.ownerLabel}: '
      '${lane.actionCount} active actions across ${lane.sourceSummary}. '
      'Priority includes $criticalLabel and $highLabel. '
      'Next queue item: ${lane.primaryActionLabel}.';
}
