import 'incoming_talent_development_intervention.dart';
import 'incoming_talent_development_intervention_draft.dart';

extension IncomingTalentDevelopmentInterventionDraftSource
    on IncomingTalentDevelopmentInterventionDraft {
  bool get hasSource {
    return checkInId.trim().isNotEmpty ||
        activationFollowUpId.trim().isNotEmpty;
  }

  IncomingTalentDevelopmentInterventionSource? get source {
    if (activationFollowUpId.trim().isNotEmpty) {
      return IncomingTalentDevelopmentInterventionSource.activationFollowUp;
    }
    if (checkInId.trim().isNotEmpty) {
      return IncomingTalentDevelopmentInterventionSource.checkIn;
    }
    return null;
  }

  String get sourceKey {
    return switch (source) {
      IncomingTalentDevelopmentInterventionSource.checkIn =>
        '${IncomingTalentDevelopmentInterventionSource.checkIn.name}:$checkInId',
      IncomingTalentDevelopmentInterventionSource.activationFollowUp =>
        '${IncomingTalentDevelopmentInterventionSource.activationFollowUp.name}:$activationFollowUpId',
      null => '',
    };
  }

  int get releaseEvidenceCount {
    return acceptedProgramMilestoneCount + roleReadyProgramCompletionCount;
  }
}
