import 'company_governance_follow_up_policy.dart';
import 'company_governance_follow_up_policy_impact.dart';

/// Structured record of one saved governance follow-up SLA policy change.
class CompanyGovernanceFollowUpPolicyChangeRecord {
  final String id;
  final CompanyGovernanceFollowUpPolicy previousPolicy;
  final CompanyGovernanceFollowUpPolicy nextPolicy;
  final String entityName;
  final String actorName;
  final DateTime recordedAt;
  final String impactHeadline;
  final int dueNowCount;
  final int changedLaneCount;
  final int needsHandoffCount;
  final int scheduledCount;
  final String topOwnerName;
  final String topOwnerBeforeLabel;
  final String topOwnerAfterLabel;
  final String auditEventId;

  const CompanyGovernanceFollowUpPolicyChangeRecord({
    required this.id,
    required this.previousPolicy,
    required this.nextPolicy,
    required this.entityName,
    required this.actorName,
    required this.recordedAt,
    required this.impactHeadline,
    required this.dueNowCount,
    required this.changedLaneCount,
    required this.needsHandoffCount,
    required this.scheduledCount,
    this.topOwnerName = '',
    this.topOwnerBeforeLabel = '',
    this.topOwnerAfterLabel = '',
    this.auditEventId = '',
  });

  factory CompanyGovernanceFollowUpPolicyChangeRecord.fromChange({
    required String id,
    required CompanyGovernanceFollowUpPolicy previousPolicy,
    required CompanyGovernanceFollowUpPolicy nextPolicy,
    required CompanyGovernanceFollowUpPolicyImpact impact,
    required String entityName,
    required String actorName,
    required DateTime recordedAt,
  }) {
    final topChange = impact.changedLanes.firstOrNull;
    return CompanyGovernanceFollowUpPolicyChangeRecord(
      id: id,
      previousPolicy: previousPolicy,
      nextPolicy: nextPolicy,
      entityName:
          entityName.trim().isEmpty ? 'Company Governance' : entityName.trim(),
      actorName: actorName.trim().isEmpty ? 'People Operations' : actorName,
      recordedAt: recordedAt,
      impactHeadline: impact.headline,
      dueNowCount: impact.dueNowCount,
      changedLaneCount: impact.changedLaneCount,
      needsHandoffCount: impact.needsHandoffCount,
      scheduledCount: impact.scheduledCount,
      topOwnerName: topChange?.ownerName ?? '',
      topOwnerBeforeLabel: topChange?.currentTouchLabel ?? '',
      topOwnerAfterLabel: topChange?.previewTouchLabel ?? '',
    );
  }

  bool get hasAuditEvent => auditEventId.trim().isNotEmpty;

  bool get hasTopChange => topOwnerName.trim().isNotEmpty;

  String get recordedDateLabel => _dateLabel(recordedAt);

  String get policyChangeLabel {
    return '${previousPolicy.compactLabel} -> ${nextPolicy.compactLabel}';
  }

  String get topChangeLabel {
    if (!hasTopChange) return 'No owner lane changed';
    return '$topOwnerName: $topOwnerBeforeLabel -> $topOwnerAfterLabel';
  }

  CompanyGovernanceFollowUpPolicyChangeRecord copyWith({String? auditEventId}) {
    return CompanyGovernanceFollowUpPolicyChangeRecord(
      id: id,
      previousPolicy: previousPolicy,
      nextPolicy: nextPolicy,
      entityName: entityName,
      actorName: actorName,
      recordedAt: recordedAt,
      impactHeadline: impactHeadline,
      dueNowCount: dueNowCount,
      changedLaneCount: changedLaneCount,
      needsHandoffCount: needsHandoffCount,
      scheduledCount: scheduledCount,
      topOwnerName: topOwnerName,
      topOwnerBeforeLabel: topOwnerBeforeLabel,
      topOwnerAfterLabel: topOwnerAfterLabel,
      auditEventId: auditEventId ?? this.auditEventId,
    );
  }
}

/// Read model for rendering governance follow-up SLA policy history.
class CompanyGovernanceFollowUpPolicyHistory {
  final List<CompanyGovernanceFollowUpPolicyChangeRecord> records;

  const CompanyGovernanceFollowUpPolicyHistory({required this.records});

  int get recordCount => records.length;

  bool get isEmpty => records.isEmpty;

  CompanyGovernanceFollowUpPolicyChangeRecord? get latest {
    return records.firstOrNull;
  }

  String get latestLabel {
    final latestRecord = latest;
    return latestRecord == null
        ? 'No changes yet'
        : latestRecord.recordedDateLabel;
  }

  int get auditedCount {
    return records.where((record) => record.hasAuditEvent).length;
  }
}

String _dateLabel(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
