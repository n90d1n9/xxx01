import 'incoming_talent_career_path.dart';
import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_review_policy.dart';

class IncomingTalentCareerPathReviewDraft {
  final String careerPathId;
  final String portfolioId;
  final String roadmapId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String targetRole;
  final String competencyName;
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentCareerPathReviewDecision? decision;
  final int previousLevel;
  final int reviewedLevel;
  final int targetLevel;
  final String evidenceNote;
  final String blockerNote;
  final String nextAction;
  final DateTime? nextReviewDate;
  final IncomingTalentCareerPathStatus? sourceStatus;
  final IncomingTalentCareerPathPriority? sourcePriority;
  final DateTime asOfDate;

  const IncomingTalentCareerPathReviewDraft({
    required this.careerPathId,
    required this.portfolioId,
    required this.roadmapId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.targetRole,
    required this.competencyName,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.previousLevel,
    required this.reviewedLevel,
    required this.targetLevel,
    required this.evidenceNote,
    required this.blockerNote,
    required this.nextAction,
    required this.nextReviewDate,
    required this.sourceStatus,
    required this.sourcePriority,
    required this.asOfDate,
  });

  factory IncomingTalentCareerPathReviewDraft.empty(DateTime asOfDate) {
    return IncomingTalentCareerPathReviewDraft(
      careerPathId: '',
      portfolioId: '',
      roadmapId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      targetRole: '',
      competencyName: '',
      reviewerName: '',
      reviewDate: null,
      decision: null,
      previousLevel: 1,
      reviewedLevel: 1,
      targetLevel: 1,
      evidenceNote: '',
      blockerNote: '',
      nextAction: '',
      nextReviewDate: null,
      sourceStatus: null,
      sourcePriority: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentCareerPathReviewDraft.fromCareerPath({
    required IncomingTalentCareerPath careerPath,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentCareerPathReviewDefaults.fromCareerPath(
      careerPath,
    );

    return IncomingTalentCareerPathReviewDraft(
      careerPathId: careerPath.id,
      portfolioId: careerPath.portfolioId,
      roadmapId: careerPath.roadmapId,
      candidateId: careerPath.candidateId,
      candidateName: careerPath.candidateName,
      department: careerPath.department,
      currentRole: careerPath.currentRole,
      targetRole: careerPath.targetRole,
      competencyName: careerPath.competencyName,
      reviewerName: careerPath.ownerName,
      reviewDate: asOfDate,
      decision: defaults.decision,
      previousLevel: careerPath.currentLevel,
      reviewedLevel: defaults.reviewedLevel,
      targetLevel: careerPath.targetLevel,
      evidenceNote: defaults.evidenceNote,
      blockerNote: defaults.blockerNote,
      nextAction: defaults.nextAction,
      nextReviewDate: asOfDate.add(defaults.nextReviewOffset),
      sourceStatus: careerPath.status,
      sourcePriority: careerPath.priority,
      asOfDate: asOfDate,
    );
  }
}
