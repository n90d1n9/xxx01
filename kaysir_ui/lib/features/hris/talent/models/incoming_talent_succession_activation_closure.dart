import 'incoming_talent_succession_activation_resolution_review.dart';

enum IncomingTalentSuccessionActivationClosureType {
  promotion('Promotion'),
  interimAssignment('Interim assignment'),
  roleExpansion('Role expansion'),
  successionMove('Succession move');

  final String label;

  const IncomingTalentSuccessionActivationClosureType(this.label);
}

enum IncomingTalentSuccessionActivationClosureStatus {
  scheduled('Scheduled'),
  active('Active'),
  completed('Completed'),
  deferred('Deferred');

  final String label;

  const IncomingTalentSuccessionActivationClosureStatus(this.label);
}

class IncomingTalentSuccessionActivationClosure {
  final String id;
  final String resolutionReviewId;
  final String escalationId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionActivationResolutionOutcome resolutionOutcome;
  final IncomingTalentSuccessionActivationResidualRisk residualRisk;
  final IncomingTalentSuccessionActivationClosureType closureType;
  final IncomingTalentSuccessionActivationClosureStatus status;
  final DateTime effectiveDate;
  final String handoverOwner;
  final String hrPartnerName;
  final String communicationPlan;
  final String accessReadiness;
  final String compensationNote;
  final String governanceNote;
  final DateTime createdAt;

  const IncomingTalentSuccessionActivationClosure({
    required this.id,
    required this.resolutionReviewId,
    required this.escalationId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.resolutionOutcome,
    required this.residualRisk,
    required this.closureType,
    required this.status,
    required this.effectiveDate,
    required this.handoverOwner,
    required this.hrPartnerName,
    required this.communicationPlan,
    required this.accessReadiness,
    required this.compensationNote,
    required this.governanceNote,
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentSuccessionActivationClosureStatus.completed;
  }

  bool get needsAttention {
    return status == IncomingTalentSuccessionActivationClosureStatus.deferred;
  }

  int daysUntilEffective(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final effective = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
    );
    return effective.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilEffective(asOfDate);
    return !isClosed && days >= 0 && days <= 14;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isClosed && daysUntilEffective(asOfDate) < 0;
  }

  IncomingTalentSuccessionActivationClosure copyWith({
    IncomingTalentSuccessionActivationClosureStatus? status,
  }) {
    return IncomingTalentSuccessionActivationClosure(
      id: id,
      resolutionReviewId: resolutionReviewId,
      escalationId: escalationId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      targetRole: targetRole,
      ownerName: ownerName,
      resolutionOutcome: resolutionOutcome,
      residualRisk: residualRisk,
      closureType: closureType,
      status: status ?? this.status,
      effectiveDate: effectiveDate,
      handoverOwner: handoverOwner,
      hrPartnerName: hrPartnerName,
      communicationPlan: communicationPlan,
      accessReadiness: accessReadiness,
      compensationNote: compensationNote,
      governanceNote: governanceNote,
      createdAt: createdAt,
    );
  }
}
