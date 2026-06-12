import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_implementation.dart';
import 'incoming_talent_promotion_readiness.dart';
import 'incoming_talent_promotion_stabilization_review.dart';

/// Editable draft for a post-promotion stabilization review.
class IncomingTalentPromotionStabilizationReviewDraft {
  final String implementationId;
  final String decisionId;
  final String readinessId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String newRole;
  final String frameworkLevelCode;
  final String ownerName;
  final String reviewerName;
  final IncomingTalentPromotionStabilizationOutcome? outcome;
  final IncomingTalentPromotionStabilizationStatus? status;
  final DateTime? reviewDate;
  final DateTime? followUpDate;
  final int confidenceScore;
  final String managerFeedback;
  final String employeeFeedback;
  final String evidenceSummary;
  final String supportPlan;
  final IncomingTalentPromotionImplementationAction? sourceAction;
  final IncomingTalentPromotionImplementationStatus? sourceImplementationStatus;
  final IncomingTalentPromotionDecisionOutcome? sourceOutcome;
  final IncomingTalentPromotionReadinessRating? sourceReadinessRating;
  final DateTime asOfDate;

  const IncomingTalentPromotionStabilizationReviewDraft({
    required this.implementationId,
    required this.decisionId,
    required this.readinessId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.newRole,
    required this.frameworkLevelCode,
    required this.ownerName,
    required this.reviewerName,
    required this.outcome,
    required this.status,
    required this.reviewDate,
    required this.followUpDate,
    required this.confidenceScore,
    required this.managerFeedback,
    required this.employeeFeedback,
    required this.evidenceSummary,
    required this.supportPlan,
    required this.sourceAction,
    required this.sourceImplementationStatus,
    required this.sourceOutcome,
    required this.sourceReadinessRating,
    required this.asOfDate,
  });

  factory IncomingTalentPromotionStabilizationReviewDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentPromotionStabilizationReviewDraft(
      implementationId: '',
      decisionId: '',
      readinessId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      newRole: '',
      frameworkLevelCode: '',
      ownerName: '',
      reviewerName: '',
      outcome: null,
      status: IncomingTalentPromotionStabilizationStatus.scheduled,
      reviewDate: asOfDate,
      followUpDate: asOfDate.add(const Duration(days: 30)),
      confidenceScore: 3,
      managerFeedback: '',
      employeeFeedback: '',
      evidenceSummary: '',
      supportPlan: '',
      sourceAction: null,
      sourceImplementationStatus: null,
      sourceOutcome: null,
      sourceReadinessRating: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentPromotionStabilizationReviewDraft.fromImplementation({
    required IncomingTalentPromotionImplementation implementation,
    required DateTime asOfDate,
  }) {
    final outcome = _outcomeFor(implementation);
    final reviewDate = implementation.completedDate ?? asOfDate;

    return IncomingTalentPromotionStabilizationReviewDraft(
      implementationId: implementation.id,
      decisionId: implementation.decisionId,
      readinessId: implementation.readinessId,
      candidateId: implementation.candidateId,
      candidateName: implementation.candidateName,
      department: implementation.department,
      currentRole: implementation.currentRole,
      newRole: implementation.newRole,
      frameworkLevelCode: implementation.frameworkLevelCode,
      ownerName: implementation.ownerName,
      reviewerName: implementation.approverName,
      outcome: outcome,
      status: _statusFor(outcome),
      reviewDate: reviewDate,
      followUpDate: defaultIncomingTalentPromotionStabilizationFollowUpDate(
        outcome: outcome,
        reviewDate: reviewDate,
      ),
      confidenceScore: _confidenceFor(outcome),
      managerFeedback: _managerFeedbackFor(outcome, implementation),
      employeeFeedback: _employeeFeedbackFor(outcome, implementation),
      evidenceSummary: implementation.evidenceNote,
      supportPlan: _supportPlanFor(outcome, implementation),
      sourceAction: implementation.action,
      sourceImplementationStatus: implementation.status,
      sourceOutcome: implementation.sourceOutcome,
      sourceReadinessRating: implementation.sourceReadinessRating,
      asOfDate: asOfDate,
    );
  }
}

DateTime? defaultIncomingTalentPromotionStabilizationFollowUpDate({
  required IncomingTalentPromotionStabilizationOutcome outcome,
  required DateTime reviewDate,
}) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole => reviewDate.add(
      const Duration(days: 60),
    ),
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      reviewDate.add(const Duration(days: 14)),
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      reviewDate.add(const Duration(days: 21)),
    IncomingTalentPromotionStabilizationOutcome.trialExtended => reviewDate.add(
      const Duration(days: 30),
    ),
    IncomingTalentPromotionStabilizationOutcome.roleReset => reviewDate.add(
      const Duration(days: 7),
    ),
  };
}

IncomingTalentPromotionStabilizationOutcome _outcomeFor(
  IncomingTalentPromotionImplementation implementation,
) {
  if (implementation.status ==
      IncomingTalentPromotionImplementationStatus.cancelled) {
    return IncomingTalentPromotionStabilizationOutcome.roleReset;
  }

  return switch (implementation.action) {
    IncomingTalentPromotionImplementationAction.titleUpdate =>
      IncomingTalentPromotionStabilizationOutcome.stableInRole,
    IncomingTalentPromotionImplementationAction.managerCommunication =>
      IncomingTalentPromotionStabilizationOutcome.stableInRole,
    IncomingTalentPromotionImplementationAction.compensationRoute =>
      IncomingTalentPromotionStabilizationOutcome.compensationFollowUp,
    IncomingTalentPromotionImplementationAction.trialAssignment =>
      IncomingTalentPromotionStabilizationOutcome.trialExtended,
    IncomingTalentPromotionImplementationAction.followUpCheck =>
      IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
  };
}

IncomingTalentPromotionStabilizationStatus _statusFor(
  IncomingTalentPromotionStabilizationOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      IncomingTalentPromotionStabilizationStatus.reviewed,
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      IncomingTalentPromotionStabilizationStatus.escalated,
  };
}

int _confidenceFor(IncomingTalentPromotionStabilizationOutcome outcome) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole => 4,
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport => 3,
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp => 3,
    IncomingTalentPromotionStabilizationOutcome.trialExtended => 3,
    IncomingTalentPromotionStabilizationOutcome.roleReset => 1,
  };
}

String _managerFeedbackFor(
  IncomingTalentPromotionStabilizationOutcome outcome,
  IncomingTalentPromotionImplementation implementation,
) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      'Manager confirmed ${implementation.candidateName} is operating in the new role scope.',
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      'Manager requested additional support to stabilize expectations and ownership.',
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      'Manager needs confirmation that compensation routing is complete.',
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      'Manager wants another checkpoint before closing the trial assignment.',
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      'Manager flagged role-fit risk that requires people leadership review.',
  };
}

String _employeeFeedbackFor(
  IncomingTalentPromotionStabilizationOutcome outcome,
  IncomingTalentPromotionImplementation implementation,
) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      '${implementation.candidateName} understands the new expectations and support channels.',
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      'Employee needs clearer priorities, coaching rhythm, and success measures.',
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      'Employee expects compensation confirmation tied to the effective date.',
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      'Employee needs trial goals and decision criteria restated.',
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      'Employee experience requires careful reset communication and support.',
  };
}

String _supportPlanFor(
  IncomingTalentPromotionStabilizationOutcome outcome,
  IncomingTalentPromotionImplementation implementation,
) {
  return switch (outcome) {
    IncomingTalentPromotionStabilizationOutcome.stableInRole =>
      'Close review after confirming HRIS data, manager check-in, and next quarterly goal.',
    IncomingTalentPromotionStabilizationOutcome.needsManagerSupport =>
      'Schedule manager coaching and a two-week success-measure checkpoint.',
    IncomingTalentPromotionStabilizationOutcome.compensationFollowUp =>
      'Route compensation evidence and confirm payroll update with ${implementation.ownerName}.',
    IncomingTalentPromotionStabilizationOutcome.trialExtended =>
      'Extend trial with explicit outcomes, sponsor support, and review date.',
    IncomingTalentPromotionStabilizationOutcome.roleReset =>
      'Escalate to people panel for role reset, communication plan, and risk support.',
  };
}
