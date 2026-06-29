import 'incoming_talent_mobility_launch_checklist.dart';
import 'incoming_talent_mobility_launch_checklist_draft.dart';
import 'incoming_talent_mobility_launch_checklist_policy.dart';

extension IncomingTalentMobilityLaunchChecklistDraftSubmission
    on IncomingTalentMobilityLaunchChecklistDraft {
  int get totalGateCount => 6;

  int get completedGateCount {
    return [
      sponsorSignedOff,
      hostManagerReady,
      accessReady,
      communicationReady,
      backfillReady,
      firstReviewScheduled,
    ].where((gate) => gate).length;
  }

  bool get allGatesReady => completedGateCount == totalGateCount;

  double get completionRatio {
    final checks = [
      matchId.trim().isNotEmpty,
      ownerName.trim().isNotEmpty,
      moveType != null,
      matchStatus != null,
      status != null,
      launchDate != null,
      firstReviewDate != null,
      launchNotes.trim().length >= 12,
      sponsorSignedOff,
      hostManagerReady,
      accessReady,
      communicationReady,
      backfillReady,
      firstReviewScheduled,
      if (status == IncomingTalentMobilityLaunchStatus.blocked)
        riskNote.trim().length >= 12,
    ];

    return checks.where((item) => item).length / checks.length;
  }

  List<String> get validationErrors {
    return [
      if (IncomingTalentMobilityLaunchChecklistDraft.validateRequired(
            matchId,
            'a mobility match',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityLaunchChecklistDraft.validateRequired(
            ownerName,
            'a launch owner',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityLaunchChecklistDraft.validateMoveType(moveType)
          case final error?)
        error,
      if (IncomingTalentMobilityLaunchChecklistDraft.validateMatchStatus(
            matchStatus,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityLaunchChecklistDraft.validateStatus(status)
          case final error?)
        error,
      if (IncomingTalentMobilityLaunchChecklistDraft.validateLaunchDate(
            launchDate,
            asOfDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityLaunchChecklistDraft.validateFirstReviewDate(
            launchDate,
            firstReviewDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityLaunchChecklistDraft.validateLaunchNotes(
            launchNotes,
          )
          case final error?)
        error,
      if (status == IncomingTalentMobilityLaunchStatus.blocked)
        if (IncomingTalentMobilityLaunchChecklistDraft.validateRiskNote(
              riskNote,
            )
            case final error?)
          error,
      if (incomingTalentMobilityLaunchRequiresReadyGates(status) &&
          !allGatesReady)
        'Complete every launch gate before marking ready',
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityLaunchChecklist toChecklist({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityLaunchChecklist(
      id: id,
      matchId: matchId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      currentRole: currentRole.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      opportunityTitle: opportunityTitle.trim(),
      hostDepartment: hostDepartment.trim(),
      sponsorName: sponsorName.trim(),
      mobilityOwnerName: mobilityOwnerName.trim(),
      moveType: moveType!,
      matchStatus: matchStatus!,
      status: status!,
      fitScore: fitScore,
      ownerName: ownerName.trim(),
      launchDate: launchDate!,
      firstReviewDate: firstReviewDate!,
      sponsorSignedOff: sponsorSignedOff,
      hostManagerReady: hostManagerReady,
      accessReady: accessReady,
      communicationReady: communicationReady,
      backfillReady: backfillReady,
      firstReviewScheduled: firstReviewScheduled,
      riskNote: riskNote.trim(),
      launchNotes: launchNotes.trim(),
      createdAt: createdAt,
    );
  }
}
