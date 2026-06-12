import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_framework_level_draft.dart';

extension IncomingTalentCareerFrameworkLevelDraftCopy
    on IncomingTalentCareerFrameworkLevelDraft {
  IncomingTalentCareerFrameworkLevelDraft copyWith({
    String? sourceCareerPathId,
    String? department,
    String? familyName,
    String? levelCode,
    String? roleTitle,
    IncomingTalentCareerFrameworkLevelScope? scope,
    IncomingTalentCareerFrameworkLevelStatus? status,
    String? ownerName,
    String? competencyName,
    String? successCriteria,
    String? evidenceRequirement,
    IncomingTalentCareerFrameworkReviewCadence? reviewCadence,
    DateTime? asOfDate,
  }) {
    return IncomingTalentCareerFrameworkLevelDraft(
      sourceCareerPathId: sourceCareerPathId ?? this.sourceCareerPathId,
      department: department ?? this.department,
      familyName: familyName ?? this.familyName,
      levelCode: levelCode ?? this.levelCode,
      roleTitle: roleTitle ?? this.roleTitle,
      scope: scope ?? this.scope,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      competencyName: competencyName ?? this.competencyName,
      successCriteria: successCriteria ?? this.successCriteria,
      evidenceRequirement: evidenceRequirement ?? this.evidenceRequirement,
      reviewCadence: reviewCadence ?? this.reviewCadence,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
