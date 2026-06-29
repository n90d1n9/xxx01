import 'company_governance_follow_up_policy.dart';
import 'company_governance_follow_up_policy_impact.dart';

/// Audit payload for recording governance follow-up SLA policy changes.
class CompanyGovernanceFollowUpPolicyAuditPayload {
  final String documentId;
  final String documentTitle;
  final String entityName;
  final String actorName;
  final String note;
  final String correlationId;

  const CompanyGovernanceFollowUpPolicyAuditPayload({
    required this.documentId,
    required this.documentTitle,
    required this.entityName,
    required this.actorName,
    required this.note,
    required this.correlationId,
  });

  factory CompanyGovernanceFollowUpPolicyAuditPayload.fromChange({
    required CompanyGovernanceFollowUpPolicy previousPolicy,
    required CompanyGovernanceFollowUpPolicy nextPolicy,
    required CompanyGovernanceFollowUpPolicyImpact impact,
    required String entityName,
    String actorName = 'People Operations',
  }) {
    return CompanyGovernanceFollowUpPolicyAuditPayload(
      documentId: 'governance-follow-up-sla',
      documentTitle: 'Governance Follow-up SLA policy',
      entityName:
          entityName.trim().isEmpty ? 'Company Governance' : entityName.trim(),
      actorName: actorName.trim().isEmpty ? 'People Operations' : actorName,
      note: _auditNote(
        previousPolicy: previousPolicy,
        nextPolicy: nextPolicy,
        impact: impact,
      ),
      correlationId: 'governance-follow-up-sla',
    );
  }
}

String _auditNote({
  required CompanyGovernanceFollowUpPolicy previousPolicy,
  required CompanyGovernanceFollowUpPolicy nextPolicy,
  required CompanyGovernanceFollowUpPolicyImpact impact,
}) {
  final laneDetail =
      impact.changedLanes.isEmpty
          ? ''
          : ' Top change: ${impact.changedLanes.first.ownerName} moves from '
              '${impact.changedLanes.first.currentTouchLabel} to '
              '${impact.changedLanes.first.previewTouchLabel}.';

  return 'Updated governance follow-up SLA: '
      'critical ${previousPolicy.criticalCadenceDays}d -> '
      '${nextPolicy.criticalCadenceDays}d, '
      'high ${previousPolicy.highCadenceDays}d -> '
      '${nextPolicy.highCadenceDays}d, '
      'steady ${previousPolicy.steadyCadenceDays}d -> '
      '${nextPolicy.steadyCadenceDays}d. '
      'Preview before save: ${impact.headline.toLowerCase()}, '
      '${impact.dueNowCount} due now, '
      '${impact.needsHandoffCount} need handoff, '
      '${impact.scheduledCount} scheduled.'
      '$laneDetail';
}
