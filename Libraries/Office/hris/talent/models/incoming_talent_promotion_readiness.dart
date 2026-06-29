import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_path.dart';

/// Readiness rating used by HR and calibration panels.
enum IncomingTalentPromotionReadinessRating {
  readyNow('Ready now'),
  readySoon('Ready soon'),
  developing('Developing'),
  blocked('Blocked');

  final String label;

  const IncomingTalentPromotionReadinessRating(this.label);
}

/// Lifecycle status for a promotion-readiness packet.
enum IncomingTalentPromotionReadinessStatus {
  draft('Draft'),
  calibration('Calibration'),
  endorsed('Endorsed'),
  hold('Hold'),
  closed('Closed');

  final String label;

  const IncomingTalentPromotionReadinessStatus(this.label);
}

/// Evidence packet that assesses a career path against a framework level.
class IncomingTalentPromotionReadiness {
  final String id;
  final String careerPathId;
  final String frameworkLevelId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String targetRole;
  final String frameworkFamilyName;
  final String frameworkLevelCode;
  final IncomingTalentCareerFrameworkLevelScope frameworkScope;
  final IncomingTalentCareerFrameworkReviewCadence frameworkReviewCadence;
  final String assessorName;
  final IncomingTalentPromotionReadinessRating rating;
  final IncomingTalentPromotionReadinessStatus status;
  final String competencyName;
  final String evidenceSummary;
  final String gapSummary;
  final String panelRecommendation;
  final DateTime reviewDate;
  final DateTime nextReviewDate;
  final IncomingTalentCareerPathStatus sourceCareerPathStatus;
  final IncomingTalentCareerPathPriority sourceCareerPathPriority;
  final DateTime createdAt;

  const IncomingTalentPromotionReadiness({
    required this.id,
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
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentPromotionReadinessStatus.closed ||
        status == IncomingTalentPromotionReadinessStatus.endorsed;
  }

  bool get needsAttention {
    return status == IncomingTalentPromotionReadinessStatus.hold ||
        status == IncomingTalentPromotionReadinessStatus.calibration ||
        rating == IncomingTalentPromotionReadinessRating.developing ||
        rating == IncomingTalentPromotionReadinessRating.blocked ||
        sourceCareerPathStatus == IncomingTalentCareerPathStatus.blocked ||
        sourceCareerPathPriority == IncomingTalentCareerPathPriority.critical;
  }

  double get readinessScore {
    return switch (rating) {
      IncomingTalentPromotionReadinessRating.readyNow => 1,
      IncomingTalentPromotionReadinessRating.readySoon => 0.75,
      IncomingTalentPromotionReadinessRating.developing => 0.45,
      IncomingTalentPromotionReadinessRating.blocked => 0.15,
    };
  }
}
