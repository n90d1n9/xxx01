import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_check_in_models.dart';
import 'incoming_talent_development_intervention.dart';
import 'incoming_talent_development_intervention_draft.dart';

extension IncomingTalentDevelopmentInterventionDraftCopy
    on IncomingTalentDevelopmentInterventionDraft {
  IncomingTalentDevelopmentInterventionDraft copyWith({
    String? checkInId,
    String? activationFollowUpId,
    String? roadmapId,
    String? outcomeReviewId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? ownerName,
    int? acceptedProgramMilestoneCount,
    int? roleReadyProgramCompletionCount,
    int? programCompletionExtensionCount,
    IncomingTalentDevelopmentInterventionType? actionType,
    IncomingTalentDevelopmentInterventionPriority? priority,
    IncomingTalentDevelopmentInterventionStatus? status,
    DateTime? dueDate,
    String? action,
    String? successCriteria,
    String? resolutionNote,
    IncomingTalentDevelopmentCheckInTrend? sourceTrend,
    int? confidenceScore,
    IncomingTalentActivationRetentionRisk? retentionRisk,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentInterventionDraft(
      checkInId: checkInId ?? this.checkInId,
      activationFollowUpId: activationFollowUpId ?? this.activationFollowUpId,
      roadmapId: roadmapId ?? this.roadmapId,
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      ownerName: ownerName ?? this.ownerName,
      acceptedProgramMilestoneCount:
          acceptedProgramMilestoneCount ?? this.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          roleReadyProgramCompletionCount ??
          this.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          programCompletionExtensionCount ??
          this.programCompletionExtensionCount,
      actionType: actionType ?? this.actionType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      action: action ?? this.action,
      successCriteria: successCriteria ?? this.successCriteria,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      sourceTrend: sourceTrend ?? this.sourceTrend,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
