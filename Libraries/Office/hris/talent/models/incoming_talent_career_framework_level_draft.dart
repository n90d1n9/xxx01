import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_path.dart';

/// Editable draft for defining a career framework level.
class IncomingTalentCareerFrameworkLevelDraft {
  final String sourceCareerPathId;
  final String department;
  final String familyName;
  final String levelCode;
  final String roleTitle;
  final IncomingTalentCareerFrameworkLevelScope? scope;
  final IncomingTalentCareerFrameworkLevelStatus? status;
  final String ownerName;
  final String competencyName;
  final String successCriteria;
  final String evidenceRequirement;
  final IncomingTalentCareerFrameworkReviewCadence? reviewCadence;
  final DateTime asOfDate;

  const IncomingTalentCareerFrameworkLevelDraft({
    required this.sourceCareerPathId,
    required this.department,
    required this.familyName,
    required this.levelCode,
    required this.roleTitle,
    required this.scope,
    required this.status,
    required this.ownerName,
    required this.competencyName,
    required this.successCriteria,
    required this.evidenceRequirement,
    required this.reviewCadence,
    required this.asOfDate,
  });

  factory IncomingTalentCareerFrameworkLevelDraft.empty(DateTime asOfDate) {
    return IncomingTalentCareerFrameworkLevelDraft(
      sourceCareerPathId: '',
      department: '',
      familyName: '',
      levelCode: '',
      roleTitle: '',
      scope: IncomingTalentCareerFrameworkLevelScope.individualContributor,
      status: IncomingTalentCareerFrameworkLevelStatus.active,
      ownerName: '',
      competencyName: '',
      successCriteria: '',
      evidenceRequirement: '',
      reviewCadence: IncomingTalentCareerFrameworkReviewCadence.semiannual,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentCareerFrameworkLevelDraft.fromCareerPath({
    required IncomingTalentCareerPath careerPath,
    required DateTime asOfDate,
  }) {
    return IncomingTalentCareerFrameworkLevelDraft(
      sourceCareerPathId: careerPath.id,
      department: careerPath.department,
      familyName: _familyNameFor(careerPath),
      levelCode: 'L${careerPath.targetLevel}',
      roleTitle: careerPath.targetRole,
      scope: _scopeFor(careerPath.targetRole),
      status: _statusFor(careerPath.status),
      ownerName: careerPath.ownerName,
      competencyName: careerPath.competencyName,
      successCriteria: careerPath.developmentAction,
      evidenceRequirement: careerPath.evidenceRequirement,
      reviewCadence: _reviewCadenceFor(careerPath.priority),
      asOfDate: asOfDate,
    );
  }
}

IncomingTalentCareerFrameworkLevelScope _scopeFor(String roleTitle) {
  final normalizedRole = roleTitle.toLowerCase();
  if (normalizedRole.contains('lead') ||
      normalizedRole.contains('manager') ||
      normalizedRole.contains('head') ||
      normalizedRole.contains('director')) {
    return IncomingTalentCareerFrameworkLevelScope.peopleLeadership;
  }
  if (normalizedRole.contains('specialist') ||
      normalizedRole.contains('principal') ||
      normalizedRole.contains('staff') ||
      normalizedRole.contains('architect')) {
    return IncomingTalentCareerFrameworkLevelScope.specialist;
  }
  return IncomingTalentCareerFrameworkLevelScope.individualContributor;
}

IncomingTalentCareerFrameworkLevelStatus _statusFor(
  IncomingTalentCareerPathStatus status,
) {
  return switch (status) {
    IncomingTalentCareerPathStatus.draft =>
      IncomingTalentCareerFrameworkLevelStatus.draft,
    IncomingTalentCareerPathStatus.blocked =>
      IncomingTalentCareerFrameworkLevelStatus.review,
    IncomingTalentCareerPathStatus.active ||
    IncomingTalentCareerPathStatus
        .achieved => IncomingTalentCareerFrameworkLevelStatus.active,
  };
}

IncomingTalentCareerFrameworkReviewCadence _reviewCadenceFor(
  IncomingTalentCareerPathPriority priority,
) {
  return switch (priority) {
    IncomingTalentCareerPathPriority.standard =>
      IncomingTalentCareerFrameworkReviewCadence.semiannual,
    IncomingTalentCareerPathPriority.accelerated ||
    IncomingTalentCareerPathPriority
        .critical => IncomingTalentCareerFrameworkReviewCadence.quarterly,
  };
}

String _familyNameFor(IncomingTalentCareerPath careerPath) {
  final cleanedRole =
      careerPath.targetRole
          .replaceFirst(
            RegExp(
              r'^(lead|senior|principal|staff|head of)\s+',
              caseSensitive: false,
            ),
            '',
          )
          .replaceFirst(RegExp(r'\s+-\s+.*$'), '')
          .trim();

  if (cleanedRole.isEmpty) return '${careerPath.department} career family';
  return '$cleanedRole family';
}
