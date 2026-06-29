import 'incoming_talent_development_intervention.dart';

extension IncomingTalentDevelopmentInterventionActionCopy
    on IncomingTalentDevelopmentInterventionAction {
  IncomingTalentDevelopmentInterventionAction copyWith({
    IncomingTalentDevelopmentInterventionStatus? status,
    String? resolutionNote,
  }) {
    return IncomingTalentDevelopmentInterventionAction(
      id: id,
      checkInId: checkInId,
      activationFollowUpId: activationFollowUpId,
      roadmapId: roadmapId,
      outcomeReviewId: outcomeReviewId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      ownerName: ownerName,
      acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      actionType: actionType,
      priority: priority,
      status: status ?? this.status,
      dueDate: dueDate,
      action: action,
      successCriteria: successCriteria,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      sourceTrend: sourceTrend,
      confidenceScore: confidenceScore,
      retentionRisk: retentionRisk,
      createdAt: createdAt,
    );
  }
}
