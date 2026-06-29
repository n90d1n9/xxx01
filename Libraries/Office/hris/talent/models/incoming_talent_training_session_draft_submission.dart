import 'incoming_talent_training_session.dart';
import 'incoming_talent_training_session_draft.dart';
import 'incoming_talent_training_session_policy.dart';

extension IncomingTalentTrainingSessionDraftSubmission
    on IncomingTalentTrainingSessionDraft {
  double get completionRatio {
    final completed =
        [
          programId.trim().isNotEmpty,
          trainerName.trim().isNotEmpty,
          format != null,
          status != null,
          location.trim().isNotEmpty,
          prerequisite.trim().length >= 12,
          outcomeCheckpoint.trim().length >= 12,
          capacity >= 1,
          reservedSeats >= 0 && reservedSeats <= capacity,
          sessionDate != null,
          followUpDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentTrainingSessionRequired(
            programId,
            'a development program',
          )
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionRequired(
            trainerName,
            'a trainer',
          )
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionFormat(format) case final error?)
        error,
      if (validateIncomingTalentTrainingSessionStatus(status) case final error?)
        error,
      if (validateIncomingTalentTrainingSessionRequired(location, 'a location')
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionLongText(
            prerequisite,
            'prerequisite',
          )
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionLongText(
            outcomeCheckpoint,
            'outcome checkpoint',
          )
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionCapacity(capacity)
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionReservedSeats(
            reservedSeats: reservedSeats,
            capacity: capacity,
          )
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionDate(sessionDate, asOfDate)
          case final error?)
        error,
      if (validateIncomingTalentTrainingSessionFollowUpDate(
            sessionDate: sessionDate,
            followUpDate: followUpDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentTrainingSession toSession({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentTrainingSession(
      id: id,
      programId: programId.trim(),
      programTitle: programTitle.trim(),
      department: department.trim(),
      trainerName: trainerName.trim(),
      format: format!,
      status: status!,
      location: location.trim(),
      prerequisite: prerequisite.trim(),
      outcomeCheckpoint: outcomeCheckpoint.trim(),
      capacity: capacity,
      reservedSeats: reservedSeats,
      sessionDate: sessionDate!,
      followUpDate: followUpDate!,
      sourceProgramTrack: sourceProgramTrack!,
      sourceProgramIntensity: sourceProgramIntensity!,
      createdAt: createdAt,
    );
  }
}
