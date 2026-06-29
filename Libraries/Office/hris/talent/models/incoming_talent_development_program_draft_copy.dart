import 'incoming_talent_development_program.dart';
import 'incoming_talent_development_program_draft.dart';

extension IncomingTalentDevelopmentProgramDraftCopy
    on IncomingTalentDevelopmentProgramDraft {
  IncomingTalentDevelopmentProgramDraft copyWith({
    String? title,
    String? department,
    String? ownerName,
    IncomingTalentDevelopmentProgramTrack? track,
    IncomingTalentDevelopmentProgramStatus? status,
    IncomingTalentDevelopmentProgramIntensity? intensity,
    String? skillFocus,
    String? expectedOutcome,
    int? capacity,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentProgramDraft(
      title: title ?? this.title,
      department: department ?? this.department,
      ownerName: ownerName ?? this.ownerName,
      track: track ?? this.track,
      status: status ?? this.status,
      intensity: intensity ?? this.intensity,
      skillFocus: skillFocus ?? this.skillFocus,
      expectedOutcome: expectedOutcome ?? this.expectedOutcome,
      capacity: capacity ?? this.capacity,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
