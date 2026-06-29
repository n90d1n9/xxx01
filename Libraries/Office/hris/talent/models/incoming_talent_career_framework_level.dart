import 'incoming_talent_career_path.dart';

/// Type of career ladder used to classify progression expectations.
enum IncomingTalentCareerFrameworkLevelScope {
  individualContributor('Individual contributor'),
  peopleLeadership('People leadership'),
  specialist('Specialist');

  final String label;

  const IncomingTalentCareerFrameworkLevelScope(this.label);
}

/// Lifecycle status for a career framework level.
enum IncomingTalentCareerFrameworkLevelStatus {
  draft('Draft'),
  active('Active'),
  review('Review'),
  archived('Archived');

  final String label;

  const IncomingTalentCareerFrameworkLevelStatus(this.label);
}

/// Review rhythm for keeping a role ladder current.
enum IncomingTalentCareerFrameworkReviewCadence {
  quarterly('Quarterly'),
  semiannual('Semiannual'),
  annual('Annual');

  final String label;

  const IncomingTalentCareerFrameworkReviewCadence(this.label);
}

/// Career ladder level with competency, success, and evidence expectations.
class IncomingTalentCareerFrameworkLevel {
  final String id;
  final String sourceCareerPathId;
  final String department;
  final String familyName;
  final String levelCode;
  final String roleTitle;
  final IncomingTalentCareerFrameworkLevelScope scope;
  final IncomingTalentCareerFrameworkLevelStatus status;
  final String ownerName;
  final String competencyName;
  final String successCriteria;
  final String evidenceRequirement;
  final IncomingTalentCareerFrameworkReviewCadence reviewCadence;
  final DateTime createdAt;

  const IncomingTalentCareerFrameworkLevel({
    required this.id,
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
    required this.createdAt,
  });

  bool get isArchived {
    return status == IncomingTalentCareerFrameworkLevelStatus.archived;
  }

  bool get isActive {
    return status == IncomingTalentCareerFrameworkLevelStatus.active;
  }

  bool get needsAttention {
    return status == IncomingTalentCareerFrameworkLevelStatus.draft ||
        status == IncomingTalentCareerFrameworkLevelStatus.review;
  }

  bool matchesCareerPath(IncomingTalentCareerPath careerPath) {
    if (isArchived || department != careerPath.department) return false;
    if (sourceCareerPathId.isNotEmpty && sourceCareerPathId == careerPath.id) {
      return true;
    }

    final roleMatches =
        _normalize(roleTitle) == _normalize(careerPath.targetRole);
    final competencyMatches =
        _normalize(competencyName) == _normalize(careerPath.competencyName);
    final levelMatches = _normalize(
      levelCode,
    ).contains('${careerPath.targetLevel}');

    return roleMatches || competencyMatches && levelMatches;
  }

  String get duplicateKey {
    return [
      department,
      familyName,
      levelCode,
      roleTitle,
    ].map(_normalize).join('|');
  }
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
