import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_path.dart';
import 'incoming_talent_promotion_readiness.dart';
import 'incoming_talent_promotion_readiness_source.dart';

/// Editable draft for a promotion-readiness assessment packet.
class IncomingTalentPromotionReadinessDraft {
  final String careerPathId;
  final String frameworkLevelId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String targetRole;
  final String frameworkFamilyName;
  final String frameworkLevelCode;
  final IncomingTalentCareerFrameworkLevelScope? frameworkScope;
  final IncomingTalentCareerFrameworkReviewCadence? frameworkReviewCadence;
  final String assessorName;
  final IncomingTalentPromotionReadinessRating? rating;
  final IncomingTalentPromotionReadinessStatus? status;
  final String competencyName;
  final String evidenceSummary;
  final String gapSummary;
  final String panelRecommendation;
  final DateTime? reviewDate;
  final DateTime? nextReviewDate;
  final IncomingTalentCareerPathStatus? sourceCareerPathStatus;
  final IncomingTalentCareerPathPriority? sourceCareerPathPriority;
  final DateTime asOfDate;

  const IncomingTalentPromotionReadinessDraft({
    required this.careerPathId,
    required this.frameworkLevelId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.targetRole,
    required this.frameworkFamilyName,
    required this.frameworkLevelCode,
    required this.frameworkScope,
    required this.frameworkReviewCadence,
    required this.assessorName,
    required this.rating,
    required this.status,
    required this.competencyName,
    required this.evidenceSummary,
    required this.gapSummary,
    required this.panelRecommendation,
    required this.reviewDate,
    required this.nextReviewDate,
    required this.sourceCareerPathStatus,
    required this.sourceCareerPathPriority,
    required this.asOfDate,
  });

  factory IncomingTalentPromotionReadinessDraft.empty(DateTime asOfDate) {
    return IncomingTalentPromotionReadinessDraft(
      careerPathId: '',
      frameworkLevelId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      targetRole: '',
      frameworkFamilyName: '',
      frameworkLevelCode: '',
      frameworkScope: null,
      frameworkReviewCadence: null,
      assessorName: '',
      rating: null,
      status: IncomingTalentPromotionReadinessStatus.draft,
      competencyName: '',
      evidenceSummary: '',
      gapSummary: '',
      panelRecommendation: '',
      reviewDate: asOfDate,
      nextReviewDate: asOfDate.add(const Duration(days: 45)),
      sourceCareerPathStatus: null,
      sourceCareerPathPriority: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentPromotionReadinessDraft.fromSource({
    required IncomingTalentPromotionReadinessSource source,
    required DateTime asOfDate,
  }) {
    final rating = _ratingFor(source.careerPath);
    final nextReviewDate = asOfDate.add(
      _nextReviewOffset(
        rating: rating,
        cadence: source.frameworkLevel.reviewCadence,
      ),
    );

    return IncomingTalentPromotionReadinessDraft(
      careerPathId: source.careerPath.id,
      frameworkLevelId: source.frameworkLevel.id,
      candidateId: source.careerPath.candidateId,
      candidateName: source.careerPath.candidateName,
      department: source.careerPath.department,
      currentRole: source.careerPath.currentRole,
      targetRole: source.careerPath.targetRole,
      frameworkFamilyName: source.frameworkLevel.familyName,
      frameworkLevelCode: source.frameworkLevel.levelCode,
      frameworkScope: source.frameworkLevel.scope,
      frameworkReviewCadence: source.frameworkLevel.reviewCadence,
      assessorName: source.careerPath.ownerName,
      rating: rating,
      status: _statusFor(rating),
      competencyName: source.careerPath.competencyName,
      evidenceSummary:
          '${source.careerPath.evidenceRequirement} Framework proof: ${source.frameworkLevel.evidenceRequirement}',
      gapSummary:
          'Validate ${source.frameworkLevel.successCriteria} against current role evidence.',
      panelRecommendation: _recommendationFor(rating),
      reviewDate: asOfDate,
      nextReviewDate: nextReviewDate,
      sourceCareerPathStatus: source.careerPath.status,
      sourceCareerPathPriority: source.careerPath.priority,
      asOfDate: asOfDate,
    );
  }
}

IncomingTalentPromotionReadinessRating _ratingFor(
  IncomingTalentCareerPath careerPath,
) {
  if (careerPath.status == IncomingTalentCareerPathStatus.blocked) {
    return IncomingTalentPromotionReadinessRating.blocked;
  }
  if (careerPath.status == IncomingTalentCareerPathStatus.achieved ||
      careerPath.levelGap == 0) {
    return IncomingTalentPromotionReadinessRating.readyNow;
  }
  if (careerPath.levelGap == 1 &&
      careerPath.priority != IncomingTalentCareerPathPriority.critical) {
    return IncomingTalentPromotionReadinessRating.readySoon;
  }
  return IncomingTalentPromotionReadinessRating.developing;
}

IncomingTalentPromotionReadinessStatus _statusFor(
  IncomingTalentPromotionReadinessRating rating,
) {
  return switch (rating) {
    IncomingTalentPromotionReadinessRating.readyNow =>
      IncomingTalentPromotionReadinessStatus.endorsed,
    IncomingTalentPromotionReadinessRating.readySoon ||
    IncomingTalentPromotionReadinessRating
        .developing => IncomingTalentPromotionReadinessStatus.calibration,
    IncomingTalentPromotionReadinessRating.blocked =>
      IncomingTalentPromotionReadinessStatus.hold,
  };
}

Duration _nextReviewOffset({
  required IncomingTalentPromotionReadinessRating rating,
  required IncomingTalentCareerFrameworkReviewCadence cadence,
}) {
  return switch (rating) {
    IncomingTalentPromotionReadinessRating.blocked => const Duration(days: 30),
    IncomingTalentPromotionReadinessRating.developing => const Duration(
      days: 60,
    ),
    IncomingTalentPromotionReadinessRating.readySoon => const Duration(
      days: 45,
    ),
    IncomingTalentPromotionReadinessRating.readyNow => switch (cadence) {
      IncomingTalentCareerFrameworkReviewCadence.quarterly => const Duration(
        days: 90,
      ),
      IncomingTalentCareerFrameworkReviewCadence.semiannual => const Duration(
        days: 180,
      ),
      IncomingTalentCareerFrameworkReviewCadence.annual => const Duration(
        days: 365,
      ),
    },
  };
}

String _recommendationFor(IncomingTalentPromotionReadinessRating rating) {
  return switch (rating) {
    IncomingTalentPromotionReadinessRating.readyNow =>
      'Endorse for promotion calibration with validated framework evidence.',
    IncomingTalentPromotionReadinessRating.readySoon =>
      'Schedule calibration after one more evidence checkpoint.',
    IncomingTalentPromotionReadinessRating.developing =>
      'Continue development plan and reassess framework gaps.',
    IncomingTalentPromotionReadinessRating.blocked =>
      'Hold progression until blockers are resolved and evidence improves.',
  };
}
