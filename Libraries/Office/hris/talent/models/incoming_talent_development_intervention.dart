import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_check_in_models.dart';

enum IncomingTalentDevelopmentInterventionType {
  coaching('Coaching'),
  unblocker('Unblocker'),
  escalation('Escalation'),
  learningAdjustment('Learning adjustment'),
  roleShadowing('Role shadowing');

  final String label;

  const IncomingTalentDevelopmentInterventionType(this.label);
}

enum IncomingTalentDevelopmentInterventionPriority {
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;

  const IncomingTalentDevelopmentInterventionPriority(this.label);
}

enum IncomingTalentDevelopmentInterventionStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved'),
  cancelled('Cancelled');

  final String label;

  const IncomingTalentDevelopmentInterventionStatus(this.label);
}

enum IncomingTalentDevelopmentInterventionSource {
  checkIn('Development check-in'),
  activationFollowUp('Activation follow-up');

  final String label;

  const IncomingTalentDevelopmentInterventionSource(this.label);
}

class IncomingTalentDevelopmentInterventionAction {
  final String id;
  final String checkInId;
  final String activationFollowUpId;
  final String roadmapId;
  final String outcomeReviewId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final IncomingTalentDevelopmentInterventionType actionType;
  final IncomingTalentDevelopmentInterventionPriority priority;
  final IncomingTalentDevelopmentInterventionStatus status;
  final DateTime dueDate;
  final String action;
  final String successCriteria;
  final String resolutionNote;
  final IncomingTalentDevelopmentCheckInTrend sourceTrend;
  final int confidenceScore;
  final IncomingTalentActivationRetentionRisk retentionRisk;
  final DateTime createdAt;

  const IncomingTalentDevelopmentInterventionAction({
    required this.id,
    required this.checkInId,
    this.activationFollowUpId = '',
    required this.roadmapId,
    required this.outcomeReviewId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    this.acceptedProgramMilestoneCount = 0,
    this.roleReadyProgramCompletionCount = 0,
    this.programCompletionExtensionCount = 0,
    required this.actionType,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.action,
    required this.successCriteria,
    required this.resolutionNote,
    required this.sourceTrend,
    required this.confidenceScore,
    required this.retentionRisk,
    required this.createdAt,
  });

  bool get needsAttention {
    return status != IncomingTalentDevelopmentInterventionStatus.resolved &&
        status != IncomingTalentDevelopmentInterventionStatus.cancelled &&
        (priority == IncomingTalentDevelopmentInterventionPriority.high ||
            priority ==
                IncomingTalentDevelopmentInterventionPriority.critical ||
            hasReleaseEvidenceRisk ||
            sourceTrend == IncomingTalentDevelopmentCheckInTrend.watch ||
            sourceTrend == IncomingTalentDevelopmentCheckInTrend.blocked ||
            confidenceScore <= 3 ||
            retentionRisk == IncomingTalentActivationRetentionRisk.high);
  }

  IncomingTalentDevelopmentInterventionSource get source {
    if (activationFollowUpId.isNotEmpty) {
      return IncomingTalentDevelopmentInterventionSource.activationFollowUp;
    }
    return IncomingTalentDevelopmentInterventionSource.checkIn;
  }

  String get sourceId {
    return activationFollowUpId.isNotEmpty ? activationFollowUpId : checkInId;
  }

  int get releaseEvidenceCount {
    return acceptedProgramMilestoneCount + roleReadyProgramCompletionCount;
  }

  bool get hasReleaseEvidenceRisk {
    return programCompletionExtensionCount > 0;
  }
}
