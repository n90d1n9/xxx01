import 'incoming_talent_development_program.dart';
import 'incoming_talent_training_session.dart';
import 'incoming_talent_training_session_draft.dart';

extension IncomingTalentTrainingSessionDraftCopy
    on IncomingTalentTrainingSessionDraft {
  IncomingTalentTrainingSessionDraft copyWith({
    String? programId,
    String? programTitle,
    String? department,
    String? trainerName,
    IncomingTalentTrainingSessionFormat? format,
    IncomingTalentTrainingSessionStatus? status,
    String? location,
    String? prerequisite,
    String? outcomeCheckpoint,
    int? capacity,
    int? reservedSeats,
    DateTime? sessionDate,
    DateTime? followUpDate,
    IncomingTalentDevelopmentProgramTrack? sourceProgramTrack,
    IncomingTalentDevelopmentProgramIntensity? sourceProgramIntensity,
    DateTime? asOfDate,
  }) {
    return IncomingTalentTrainingSessionDraft(
      programId: programId ?? this.programId,
      programTitle: programTitle ?? this.programTitle,
      department: department ?? this.department,
      trainerName: trainerName ?? this.trainerName,
      format: format ?? this.format,
      status: status ?? this.status,
      location: location ?? this.location,
      prerequisite: prerequisite ?? this.prerequisite,
      outcomeCheckpoint: outcomeCheckpoint ?? this.outcomeCheckpoint,
      capacity: capacity ?? this.capacity,
      reservedSeats: reservedSeats ?? this.reservedSeats,
      sessionDate: sessionDate ?? this.sessionDate,
      followUpDate: followUpDate ?? this.followUpDate,
      sourceProgramTrack: sourceProgramTrack ?? this.sourceProgramTrack,
      sourceProgramIntensity:
          sourceProgramIntensity ?? this.sourceProgramIntensity,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
