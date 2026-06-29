enum IncomingTalentDevelopmentProgramTrack {
  onboarding('Onboarding academy'),
  leadership('Leadership'),
  technical('Technical mastery'),
  succession('Succession bench'),
  recovery('Performance recovery');

  final String label;

  const IncomingTalentDevelopmentProgramTrack(this.label);
}

enum IncomingTalentDevelopmentProgramStatus {
  draft('Draft'),
  active('Active'),
  paused('Paused'),
  archived('Archived');

  final String label;

  const IncomingTalentDevelopmentProgramStatus(this.label);
}

enum IncomingTalentDevelopmentProgramIntensity {
  light('Light'),
  standard('Standard'),
  accelerated('Accelerated');

  final String label;

  const IncomingTalentDevelopmentProgramIntensity(this.label);
}

class IncomingTalentDevelopmentProgram {
  final String id;
  final String title;
  final String department;
  final String ownerName;
  final IncomingTalentDevelopmentProgramTrack track;
  final IncomingTalentDevelopmentProgramStatus status;
  final IncomingTalentDevelopmentProgramIntensity intensity;
  final String skillFocus;
  final String expectedOutcome;
  final int capacity;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const IncomingTalentDevelopmentProgram({
    required this.id,
    required this.title,
    required this.department,
    required this.ownerName,
    required this.track,
    required this.status,
    required this.intensity,
    required this.skillFocus,
    required this.expectedOutcome,
    required this.capacity,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  bool get acceptsEnrollment {
    return status == IncomingTalentDevelopmentProgramStatus.active;
  }

  bool get needsAttention {
    return status == IncomingTalentDevelopmentProgramStatus.draft ||
        status == IncomingTalentDevelopmentProgramStatus.paused ||
        capacity <= 0;
  }

  double fillRatio(int enrolledCount) {
    if (capacity <= 0) return 1;
    final ratio = enrolledCount / capacity;
    return ratio > 1 ? 1 : ratio;
  }

  int availableSeats(int enrolledCount) {
    final seats = capacity - enrolledCount;
    return seats < 0 ? 0 : seats;
  }
}
