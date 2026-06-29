import 'incoming_talent_development_program.dart';

class IncomingTalentDevelopmentProgramDraft {
  final String title;
  final String department;
  final String ownerName;
  final IncomingTalentDevelopmentProgramTrack? track;
  final IncomingTalentDevelopmentProgramStatus? status;
  final IncomingTalentDevelopmentProgramIntensity? intensity;
  final String skillFocus;
  final String expectedOutcome;
  final int capacity;
  final int durationDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentProgramDraft({
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
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentProgramDraft.empty(DateTime asOfDate) {
    return IncomingTalentDevelopmentProgramDraft(
      title: '',
      department: '',
      ownerName: '',
      track: null,
      status: IncomingTalentDevelopmentProgramStatus.active,
      intensity: IncomingTalentDevelopmentProgramIntensity.standard,
      skillFocus: '',
      expectedOutcome: '',
      capacity: 12,
      durationDays: 60,
      startDate: asOfDate,
      endDate: asOfDate.add(const Duration(days: 60)),
      asOfDate: asOfDate,
    );
  }
}
