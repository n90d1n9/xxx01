import 'incoming_talent_development_program.dart';
import 'incoming_talent_training_session.dart';

/// Editable draft used by HR to schedule a training cohort.
class IncomingTalentTrainingSessionDraft {
  final String programId;
  final String programTitle;
  final String department;
  final String trainerName;
  final IncomingTalentTrainingSessionFormat? format;
  final IncomingTalentTrainingSessionStatus? status;
  final String location;
  final String prerequisite;
  final String outcomeCheckpoint;
  final int capacity;
  final int reservedSeats;
  final DateTime? sessionDate;
  final DateTime? followUpDate;
  final IncomingTalentDevelopmentProgramTrack? sourceProgramTrack;
  final IncomingTalentDevelopmentProgramIntensity? sourceProgramIntensity;
  final DateTime asOfDate;

  const IncomingTalentTrainingSessionDraft({
    required this.programId,
    required this.programTitle,
    required this.department,
    required this.trainerName,
    required this.format,
    required this.status,
    required this.location,
    required this.prerequisite,
    required this.outcomeCheckpoint,
    required this.capacity,
    required this.reservedSeats,
    required this.sessionDate,
    required this.followUpDate,
    required this.sourceProgramTrack,
    required this.sourceProgramIntensity,
    required this.asOfDate,
  });

  factory IncomingTalentTrainingSessionDraft.empty(DateTime asOfDate) {
    return IncomingTalentTrainingSessionDraft(
      programId: '',
      programTitle: '',
      department: '',
      trainerName: '',
      format: IncomingTalentTrainingSessionFormat.hybrid,
      status: IncomingTalentTrainingSessionStatus.scheduled,
      location: '',
      prerequisite: '',
      outcomeCheckpoint: '',
      capacity: 12,
      reservedSeats: 0,
      sessionDate: asOfDate.add(const Duration(days: 7)),
      followUpDate: asOfDate.add(const Duration(days: 21)),
      sourceProgramTrack: null,
      sourceProgramIntensity: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentTrainingSessionDraft.fromProgram({
    required IncomingTalentDevelopmentProgram program,
    required DateTime asOfDate,
  }) {
    final sessionDate =
        program.startDate.isBefore(asOfDate)
            ? asOfDate.add(const Duration(days: 7))
            : program.startDate;
    final capacity = program.capacity > 20 ? 20 : program.capacity;

    return IncomingTalentTrainingSessionDraft(
      programId: program.id,
      programTitle: program.title,
      department: program.department,
      trainerName: program.ownerName,
      format: _formatFor(program),
      status: IncomingTalentTrainingSessionStatus.scheduled,
      location: _locationFor(program),
      prerequisite: 'Complete manager briefing before ${program.title}.',
      outcomeCheckpoint:
          'Submit ${program.skillFocus} evidence after the session.',
      capacity: capacity,
      reservedSeats: 0,
      sessionDate: sessionDate,
      followUpDate: sessionDate.add(const Duration(days: 14)),
      sourceProgramTrack: program.track,
      sourceProgramIntensity: program.intensity,
      asOfDate: asOfDate,
    );
  }
}

IncomingTalentTrainingSessionFormat _formatFor(
  IncomingTalentDevelopmentProgram program,
) {
  return switch (program.intensity) {
    IncomingTalentDevelopmentProgramIntensity.light =>
      IncomingTalentTrainingSessionFormat.virtual,
    IncomingTalentDevelopmentProgramIntensity.standard =>
      IncomingTalentTrainingSessionFormat.hybrid,
    IncomingTalentDevelopmentProgramIntensity.accelerated =>
      IncomingTalentTrainingSessionFormat.onsite,
  };
}

String _locationFor(IncomingTalentDevelopmentProgram program) {
  return switch (program.intensity) {
    IncomingTalentDevelopmentProgramIntensity.light =>
      '${program.department} virtual room',
    IncomingTalentDevelopmentProgramIntensity.standard =>
      '${program.department} hybrid cohort room',
    IncomingTalentDevelopmentProgramIntensity.accelerated =>
      '${program.department} academy room',
  };
}
