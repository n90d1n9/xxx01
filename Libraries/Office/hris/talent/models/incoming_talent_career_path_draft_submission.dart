import 'incoming_talent_career_path.dart';
import 'incoming_talent_career_path_draft.dart';
import 'incoming_talent_career_path_policy.dart';

extension IncomingTalentCareerPathDraftSubmission
    on IncomingTalentCareerPathDraft {
  double get completionRatio {
    final completed =
        [
          portfolioId.trim().isNotEmpty,
          currentRole.trim().isNotEmpty,
          targetRole.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          competencyName.trim().length >= 3,
          developmentAction.trim().length >= 12,
          evidenceRequirement.trim().length >= 12,
          status != null,
          priority != null,
          currentLevel >= 1 && currentLevel <= 5,
          targetLevel >= currentLevel && targetLevel <= 5,
          reviewDate != null,
        ].where((item) => item).length;

    return completed / 13;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentCareerPathRequired(
            portfolioId,
            'an IDP portfolio',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathRequired(
            currentRole,
            'a current role',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathRequired(targetRole, 'a target role')
          case final error?)
        error,
      if (validateIncomingTalentCareerPathRequired(ownerName, 'an owner')
          case final error?)
        error,
      if (validateIncomingTalentCareerPathRequired(mentorName, 'a mentor')
          case final error?)
        error,
      if (validateIncomingTalentCareerPathFocus(competencyName)
          case final error?)
        error,
      if (validateIncomingTalentCareerPathLongText(
            developmentAction,
            'development action',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathLongText(
            evidenceRequirement,
            'evidence requirement',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathStatus(status) case final error?)
        error,
      if (validateIncomingTalentCareerPathPriority(priority) case final error?)
        error,
      if (validateIncomingTalentCareerPathLevel(currentLevel, 'Current level')
          case final error?)
        error,
      if (validateIncomingTalentCareerPathTargetLevel(
            currentLevel: currentLevel,
            targetLevel: targetLevel,
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewDate(reviewDate, asOfDate)
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentCareerPath toCareerPath({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentCareerPath(
      id: id,
      portfolioId: portfolioId,
      roadmapId: roadmapId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      department: department.trim(),
      currentRole: currentRole.trim(),
      targetRole: targetRole.trim(),
      ownerName: ownerName.trim(),
      mentorName: mentorName.trim(),
      competencyName: competencyName.trim(),
      currentLevel: currentLevel,
      targetLevel: targetLevel,
      status: status!,
      priority: priority!,
      developmentAction: developmentAction.trim(),
      evidenceRequirement: evidenceRequirement.trim(),
      reviewDate: reviewDate!,
      sourcePortfolioPriority: sourcePortfolioPriority!,
      sourcePortfolioStage: sourcePortfolioStage!,
      createdAt: createdAt,
    );
  }
}

String? validateIncomingTalentCareerPathFocus(String? value) {
  final requiredError = validateIncomingTalentCareerPathRequired(
    value,
    'a competency',
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 3) return 'Competency is too short';
  return null;
}
