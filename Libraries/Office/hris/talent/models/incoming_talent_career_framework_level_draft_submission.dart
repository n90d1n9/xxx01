import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_framework_level_draft.dart';
import 'incoming_talent_career_framework_level_policy.dart';

extension IncomingTalentCareerFrameworkLevelDraftSubmission
    on IncomingTalentCareerFrameworkLevelDraft {
  double get completionRatio {
    final completed =
        [
          department.trim().isNotEmpty,
          familyName.trim().isNotEmpty,
          levelCode.trim().length >= 2,
          roleTitle.trim().isNotEmpty,
          scope != null,
          status != null,
          ownerName.trim().isNotEmpty,
          competencyName.trim().length >= 3,
          successCriteria.trim().length >= 12,
          evidenceRequirement.trim().length >= 12,
          reviewCadence != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentCareerFrameworkRequired(
            department,
            'a department',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkRequired(
            familyName,
            'a role family',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkLevelCode(levelCode)
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkRequired(
            roleTitle,
            'a role title',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkScope(scope) case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkStatus(status) case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkRequired(ownerName, 'an owner')
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkFocus(competencyName)
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkLongText(
            successCriteria,
            'success criteria',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkLongText(
            evidenceRequirement,
            'evidence requirement',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerFrameworkReviewCadence(reviewCadence)
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentCareerFrameworkLevel toLevel({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentCareerFrameworkLevel(
      id: id,
      sourceCareerPathId: sourceCareerPathId.trim(),
      department: department.trim(),
      familyName: familyName.trim(),
      levelCode: levelCode.trim(),
      roleTitle: roleTitle.trim(),
      scope: scope!,
      status: status!,
      ownerName: ownerName.trim(),
      competencyName: competencyName.trim(),
      successCriteria: successCriteria.trim(),
      evidenceRequirement: evidenceRequirement.trim(),
      reviewCadence: reviewCadence!,
      createdAt: createdAt,
    );
  }
}
