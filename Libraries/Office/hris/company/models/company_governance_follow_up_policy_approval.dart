import 'company_governance_follow_up_policy.dart';
import 'company_governance_follow_up_policy_impact.dart';

/// Review status for a proposed governance follow-up SLA change.
enum CompanyGovernanceFollowUpPolicyApprovalStatus {
  pending('Pending approval'),
  approved('Approved'),
  rejected('Rejected');

  final String label;

  const CompanyGovernanceFollowUpPolicyApprovalStatus(this.label);
}

/// Structured approval request for changing governance follow-up SLA policy.
class CompanyGovernanceFollowUpPolicyApprovalRequest {
  final String id;
  final CompanyGovernanceFollowUpPolicy previousPolicy;
  final CompanyGovernanceFollowUpPolicy requestedPolicy;
  final CompanyGovernanceFollowUpPolicyImpact impact;
  final String entityName;
  final String requestedBy;
  final DateTime requestedAt;
  final CompanyGovernanceFollowUpPolicyApprovalStatus status;
  final String decidedBy;
  final DateTime? decidedAt;
  final String decisionNote;
  final String auditEventId;

  const CompanyGovernanceFollowUpPolicyApprovalRequest({
    required this.id,
    required this.previousPolicy,
    required this.requestedPolicy,
    required this.impact,
    required this.entityName,
    required this.requestedBy,
    required this.requestedAt,
    this.status = CompanyGovernanceFollowUpPolicyApprovalStatus.pending,
    this.decidedBy = '',
    this.decidedAt,
    this.decisionNote = '',
    this.auditEventId = '',
  });

  factory CompanyGovernanceFollowUpPolicyApprovalRequest.create({
    required String id,
    required CompanyGovernanceFollowUpPolicy previousPolicy,
    required CompanyGovernanceFollowUpPolicy requestedPolicy,
    required CompanyGovernanceFollowUpPolicyImpact impact,
    required String entityName,
    required String requestedBy,
    required DateTime requestedAt,
  }) {
    return CompanyGovernanceFollowUpPolicyApprovalRequest(
      id: id,
      previousPolicy: previousPolicy,
      requestedPolicy: requestedPolicy,
      impact: impact,
      entityName:
          entityName.trim().isEmpty ? 'Company Governance' : entityName.trim(),
      requestedBy:
          requestedBy.trim().isEmpty ? 'People Operations' : requestedBy.trim(),
      requestedAt: requestedAt,
    );
  }

  bool get isPending {
    return status == CompanyGovernanceFollowUpPolicyApprovalStatus.pending;
  }

  bool get hasDecision {
    return status != CompanyGovernanceFollowUpPolicyApprovalStatus.pending;
  }

  bool get hasAuditEvent => auditEventId.trim().isNotEmpty;

  bool get hasTopChange => impact.changedLanes.isNotEmpty;

  String get requestedDateLabel => _dateLabel(requestedAt);

  String get decisionDateLabel {
    final decisionDate = decidedAt;
    return decisionDate == null ? 'Not decided' : _dateLabel(decisionDate);
  }

  String get policyChangeLabel {
    return '${previousPolicy.compactLabel} -> ${requestedPolicy.compactLabel}';
  }

  String get topChangeLabel {
    if (!hasTopChange) return 'No owner lane changed';
    final topChange = impact.changedLanes.first;
    return '${topChange.ownerName}: ${topChange.currentTouchLabel} -> '
        '${topChange.previewTouchLabel}';
  }

  bool isStaleAgainst(CompanyGovernanceFollowUpPolicy currentPolicy) {
    return previousPolicy != currentPolicy;
  }

  CompanyGovernanceFollowUpPolicyApprovalRequest approve({
    required String decidedBy,
    required DateTime decidedAt,
    String auditEventId = '',
  }) {
    return copyWith(
      status: CompanyGovernanceFollowUpPolicyApprovalStatus.approved,
      decidedBy: decidedBy.trim().isEmpty ? 'People Operations' : decidedBy,
      decidedAt: decidedAt,
      decisionNote: 'Approved governance follow-up SLA change.',
      auditEventId: auditEventId,
    );
  }

  CompanyGovernanceFollowUpPolicyApprovalRequest reject({
    required String decidedBy,
    required DateTime decidedAt,
    String decisionNote = 'Rejected governance follow-up SLA change.',
  }) {
    return copyWith(
      status: CompanyGovernanceFollowUpPolicyApprovalStatus.rejected,
      decidedBy: decidedBy.trim().isEmpty ? 'People Operations' : decidedBy,
      decidedAt: decidedAt,
      decisionNote: decisionNote,
    );
  }

  CompanyGovernanceFollowUpPolicyApprovalRequest copyWith({
    CompanyGovernanceFollowUpPolicyApprovalStatus? status,
    String? decidedBy,
    DateTime? decidedAt,
    String? decisionNote,
    String? auditEventId,
  }) {
    return CompanyGovernanceFollowUpPolicyApprovalRequest(
      id: id,
      previousPolicy: previousPolicy,
      requestedPolicy: requestedPolicy,
      impact: impact,
      entityName: entityName,
      requestedBy: requestedBy,
      requestedAt: requestedAt,
      status: status ?? this.status,
      decidedBy: decidedBy ?? this.decidedBy,
      decidedAt: decidedAt ?? this.decidedAt,
      decisionNote: decisionNote ?? this.decisionNote,
      auditEventId: auditEventId ?? this.auditEventId,
    );
  }
}

/// Read model for governance follow-up SLA approval requests.
class CompanyGovernanceFollowUpPolicyApprovalQueue {
  final List<CompanyGovernanceFollowUpPolicyApprovalRequest> records;

  const CompanyGovernanceFollowUpPolicyApprovalQueue({required this.records});

  List<CompanyGovernanceFollowUpPolicyApprovalRequest> get pendingRecords {
    return records.where((record) => record.isPending).toList(growable: false);
  }

  int get pendingCount => pendingRecords.length;

  int get approvedCount {
    return records
        .where(
          (record) =>
              record.status ==
              CompanyGovernanceFollowUpPolicyApprovalStatus.approved,
        )
        .length;
  }

  int get rejectedCount {
    return records
        .where(
          (record) =>
              record.status ==
              CompanyGovernanceFollowUpPolicyApprovalStatus.rejected,
        )
        .length;
  }

  bool get isEmpty => records.isEmpty;

  CompanyGovernanceFollowUpPolicyApprovalRequest? get latestPending {
    return pendingRecords.firstOrNull;
  }
}

String _dateLabel(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
