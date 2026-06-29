import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_implementation.dart';
import 'incoming_talent_promotion_readiness.dart';

/// Editable draft for promotion implementation work.
class IncomingTalentPromotionImplementationDraft {
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
  final IncomingTalentPromotionImplementationAction? action;
  final IncomingTalentPromotionImplementationStatus? status;
  final String systemOfRecord;
  final String implementationStep;
  final String evidenceNote;
  final String blockerNote;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final IncomingTalentPromotionDecisionOutcome? sourceOutcome;
  final IncomingTalentPromotionDecisionStatus? sourceDecisionStatus;
  final IncomingTalentPromotionReadinessRating? sourceReadinessRating;
  final DateTime asOfDate;

  const IncomingTalentPromotionImplementationDraft({
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
    required this.asOfDate,
  });

  factory IncomingTalentPromotionImplementationDraft.empty(DateTime asOfDate) {
    return IncomingTalentPromotionImplementationDraft(
      decisionId: '',
      readinessId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      newRole: '',
      frameworkLevelCode: '',
      ownerName: '',
      approverName: '',
      action: null,
      status: IncomingTalentPromotionImplementationStatus.planned,
      systemOfRecord: '',
      implementationStep: '',
      evidenceNote: '',
      blockerNote: '',
      dueDate: asOfDate.add(const Duration(days: 14)),
      completedDate: null,
      sourceOutcome: null,
      sourceDecisionStatus: null,
      sourceReadinessRating: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentPromotionImplementationDraft.fromDecision({
    required IncomingTalentPromotionDecision decision,
    required DateTime asOfDate,
  }) {
    final action = _actionFor(decision.outcome);

    return IncomingTalentPromotionImplementationDraft(
      decisionId: decision.id,
      readinessId: decision.readinessId,
      candidateId: decision.candidateId,
      candidateName: decision.candidateName,
      department: decision.department,
      currentRole: decision.currentRole,
      newRole: decision.newRole,
      frameworkLevelCode: decision.frameworkLevelCode,
      ownerName: decision.ownerName,
      approverName: decision.approverName,
      action: action,
      status: _statusFor(decision.status),
      systemOfRecord: _systemFor(action),
      implementationStep: decision.implementationNote,
      evidenceNote: _evidenceNoteFor(action, decision),
      blockerNote: decision.riskControlNote,
      dueDate: decision.effectiveDate,
      completedDate: null,
      sourceOutcome: decision.outcome,
      sourceDecisionStatus: decision.status,
      sourceReadinessRating: decision.sourceRating,
      asOfDate: asOfDate,
    );
  }
}

IncomingTalentPromotionImplementationAction _actionFor(
  IncomingTalentPromotionDecisionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentPromotionDecisionOutcome.promoteNow =>
      IncomingTalentPromotionImplementationAction.titleUpdate,
    IncomingTalentPromotionDecisionOutcome.promoteWithTrial =>
      IncomingTalentPromotionImplementationAction.trialAssignment,
    IncomingTalentPromotionDecisionOutcome.compensationReview =>
      IncomingTalentPromotionImplementationAction.compensationRoute,
    IncomingTalentPromotionDecisionOutcome.deferPromotion ||
    IncomingTalentPromotionDecisionOutcome.retainInRole =>
      IncomingTalentPromotionImplementationAction.followUpCheck,
  };
}

IncomingTalentPromotionImplementationStatus _statusFor(
  IncomingTalentPromotionDecisionStatus status,
) {
  return switch (status) {
    IncomingTalentPromotionDecisionStatus.approved =>
      IncomingTalentPromotionImplementationStatus.planned,
    IncomingTalentPromotionDecisionStatus.routed =>
      IncomingTalentPromotionImplementationStatus.inProgress,
    IncomingTalentPromotionDecisionStatus.deferred =>
      IncomingTalentPromotionImplementationStatus.planned,
    IncomingTalentPromotionDecisionStatus.implemented ||
    IncomingTalentPromotionDecisionStatus
        .closed => IncomingTalentPromotionImplementationStatus.completed,
    IncomingTalentPromotionDecisionStatus.draft =>
      IncomingTalentPromotionImplementationStatus.planned,
  };
}

String _systemFor(IncomingTalentPromotionImplementationAction action) {
  return switch (action) {
    IncomingTalentPromotionImplementationAction.titleUpdate =>
      'HRIS employee profile',
    IncomingTalentPromotionImplementationAction.compensationRoute =>
      'Compensation review queue',
    IncomingTalentPromotionImplementationAction.trialAssignment =>
      'Talent trial assignment board',
    IncomingTalentPromotionImplementationAction.managerCommunication =>
      'Manager communication tracker',
    IncomingTalentPromotionImplementationAction.followUpCheck =>
      'Development follow-up tracker',
  };
}

String _evidenceNoteFor(
  IncomingTalentPromotionImplementationAction action,
  IncomingTalentPromotionDecision decision,
) {
  return switch (action) {
    IncomingTalentPromotionImplementationAction.titleUpdate =>
      'Capture signed promotion letter and HRIS title update confirmation.',
    IncomingTalentPromotionImplementationAction.compensationRoute =>
      'Attach compensation approval and payroll effective-date confirmation.',
    IncomingTalentPromotionImplementationAction.trialAssignment =>
      'Attach trial scope, success metrics, and manager checkpoint plan.',
    IncomingTalentPromotionImplementationAction.managerCommunication =>
      'Attach manager announcement and transition expectation notes.',
    IncomingTalentPromotionImplementationAction.followUpCheck =>
      'Attach follow-up plan linked to ${decision.riskControlNote}',
  };
}
