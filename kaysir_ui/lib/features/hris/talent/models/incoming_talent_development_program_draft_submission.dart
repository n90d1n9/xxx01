import 'incoming_talent_development_program.dart';
import 'incoming_talent_development_program_draft.dart';
import 'incoming_talent_development_program_policy.dart';

extension IncomingTalentDevelopmentProgramDraftSubmission
    on IncomingTalentDevelopmentProgramDraft {
  double get completionRatio {
    final completed =
        [
          title.trim().isNotEmpty,
          department.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          track != null,
          status != null,
          intensity != null,
          skillFocus.trim().length >= 12,
          expectedOutcome.trim().length >= 12,
          capacity >= 1,
          durationDays >= 14,
          startDate != null,
          endDate != null,
        ].where((item) => item).length;

    return completed / 12;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentDevelopmentProgramRequired(title, 'a title')
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramRequired(
            department,
            'a department',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramRequired(
            ownerName,
            'a program owner',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramTrack(track)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramIntensity(intensity)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramLongText(
            skillFocus,
            'skill focus',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramLongText(
            expectedOutcome,
            'expected outcome',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramCapacity(capacity)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramDuration(durationDays)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramStartDate(startDate, asOfDate)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentProgramEndDate(startDate, endDate)
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentProgram toProgram({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentProgram(
      id: id,
      title: title.trim(),
      department: department.trim(),
      ownerName: ownerName.trim(),
      track: track!,
      status: status!,
      intensity: intensity!,
      skillFocus: skillFocus.trim(),
      expectedOutcome: expectedOutcome.trim(),
      capacity: capacity,
      durationDays: durationDays,
      startDate: startDate!,
      endDate: endDate!,
      createdAt: createdAt,
    );
  }
}
