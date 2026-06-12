import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_readiness.dart';

/// Workstream used to implement a promotion decision.
enum IncomingTalentPromotionImplementationAction {
  titleUpdate('Title update'),
  compensationRoute('Compensation route'),
  trialAssignment('Trial assignment'),
  managerCommunication('Manager communication'),
  followUpCheck('Follow-up check');

  final String label;

  const IncomingTalentPromotionImplementationAction(this.label);
}

/// Operational state for a promotion implementation workstream.
enum IncomingTalentPromotionImplementationStatus {
  planned('Planned'),
  inProgress('In progress'),
  blocked('Blocked'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;

  const IncomingTalentPromotionImplementationStatus(this.label);
}

/// HRIS implementation packet for executing a promotion decision.
class IncomingTalentPromotionImplementation {
  final String id;
  final String decisionId;
  final String readinessId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String newRole;
  final String frameworkLevelCode;
  final String ownerName;
  final String approverName;
  final IncomingTalentPromotionImplementationAction action;
  final IncomingTalentPromotionImplementationStatus status;
  final String systemOfRecord;
  final String implementationStep;
  final String evidenceNote;
  final String blockerNote;
  final DateTime dueDate;
  final DateTime? completedDate;
  final IncomingTalentPromotionDecisionOutcome sourceOutcome;
  final IncomingTalentPromotionDecisionStatus sourceDecisionStatus;
  final IncomingTalentPromotionReadinessRating sourceReadinessRating;
  final DateTime createdAt;

  const IncomingTalentPromotionImplementation({
    required this.id,
    required this.decisionId,
    required this.readinessId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.newRole,
    required this.frameworkLevelCode,
    required this.ownerName,
    required this.approverName,
    required this.action,
    required this.status,
    required this.systemOfRecord,
    required this.implementationStep,
    required this.evidenceNote,
    required this.blockerNote,
    required this.dueDate,
    required this.completedDate,
    required this.sourceOutcome,
    required this.sourceDecisionStatus,
    required this.sourceReadinessRating,
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentPromotionImplementationStatus.completed ||
        status == IncomingTalentPromotionImplementationStatus.cancelled;
  }

  bool get needsAttention {
    return status == IncomingTalentPromotionImplementationStatus.blocked ||
        status == IncomingTalentPromotionImplementationStatus.cancelled ||
        sourceDecisionStatus ==
            IncomingTalentPromotionDecisionStatus.deferred ||
        action == IncomingTalentPromotionImplementationAction.followUpCheck;
  }

  double get progressRatio {
    return switch (status) {
      IncomingTalentPromotionImplementationStatus.planned => 0.2,
      IncomingTalentPromotionImplementationStatus.inProgress => 0.55,
      IncomingTalentPromotionImplementationStatus.blocked => 0.25,
      IncomingTalentPromotionImplementationStatus.completed => 1,
      IncomingTalentPromotionImplementationStatus.cancelled => 0,
    };
  }
}
