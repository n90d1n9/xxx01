import 'incoming_talent_development_program.dart';

enum IncomingTalentTrainingSessionFormat {
  onsite('Onsite'),
  virtual('Virtual'),
  hybrid('Hybrid'),
  selfPaced('Self-paced');

  final String label;

  const IncomingTalentTrainingSessionFormat(this.label);
}

enum IncomingTalentTrainingSessionStatus {
  draft('Draft'),
  scheduled('Scheduled'),
  live('Live'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;

  const IncomingTalentTrainingSessionStatus(this.label);
}

/// Scheduled training cohort for an active talent-development program.
class IncomingTalentTrainingSession {
  final String id;
  final String programId;
  final String programTitle;
  final String department;
  final String trainerName;
  final IncomingTalentTrainingSessionFormat format;
  final IncomingTalentTrainingSessionStatus status;
  final String location;
  final String prerequisite;
  final String outcomeCheckpoint;
  final int capacity;
  final int reservedSeats;
  final DateTime sessionDate;
  final DateTime followUpDate;
  final IncomingTalentDevelopmentProgramTrack sourceProgramTrack;
  final IncomingTalentDevelopmentProgramIntensity sourceProgramIntensity;
  final DateTime createdAt;

  const IncomingTalentTrainingSession({
    required this.id,
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
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentTrainingSessionStatus.completed ||
        status == IncomingTalentTrainingSessionStatus.cancelled;
  }

  bool get needsAttention {
    return status == IncomingTalentTrainingSessionStatus.draft ||
        status == IncomingTalentTrainingSessionStatus.cancelled ||
        reservedSeats > capacity ||
        reservedSeats == 0;
  }

  int get openSeats {
    final seats = capacity - reservedSeats;
    return seats < 0 ? 0 : seats;
  }

  double get fillRatio {
    if (capacity <= 0) return 1;
    final ratio = reservedSeats / capacity;
    return ratio > 1 ? 1 : ratio;
  }
}
