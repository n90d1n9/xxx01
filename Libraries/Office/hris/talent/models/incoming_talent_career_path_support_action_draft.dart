import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_support_action.dart';
import 'incoming_talent_career_path_support_action_policy.dart';

class IncomingTalentCareerPathSupportActionDraft {
  final String reviewId;
  final String careerPathId;
  final String portfolioId;
  final String roadmapId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String targetRole;
  final String competencyName;
  final String ownerName;
  final IncomingTalentCareerPathSupportActionType? actionType;
  final IncomingTalentCareerPathSupportActionPriority? priority;
  final IncomingTalentCareerPathSupportActionStatus? status;
  final DateTime? dueDate;
  final String actionPlan;
  final String successCriteria;
  final String escalationNote;
  final IncomingTalentCareerPathReviewDecision? sourceDecision;
  final int reviewedLevel;
  final int targetLevel;
  final int sourceLevelGap;
  final DateTime asOfDate;

  const IncomingTalentCareerPathSupportActionDraft({
    required this.reviewId,
    required this.careerPathId,
    required this.portfolioId,
    required this.roadmapId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.targetRole,
    required this.competencyName,
    required this.ownerName,
    required this.actionType,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.successCriteria,
    required this.escalationNote,
    required this.sourceDecision,
    required this.reviewedLevel,
    required this.targetLevel,
    required this.sourceLevelGap,
    required this.asOfDate,
  });

  factory IncomingTalentCareerPathSupportActionDraft.empty(DateTime asOfDate) {
    return IncomingTalentCareerPathSupportActionDraft(
      reviewId: '',
      careerPathId: '',
      portfolioId: '',
      roadmapId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      targetRole: '',
      competencyName: '',
      ownerName: '',
      actionType: null,
      priority: null,
      status: null,
      dueDate: null,
      actionPlan: '',
      successCriteria: '',
      escalationNote: '',
      sourceDecision: null,
      reviewedLevel: 0,
      targetLevel: 0,
      sourceLevelGap: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentCareerPathSupportActionDraft.fromReview({
    required IncomingTalentCareerPathReview review,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentCareerPathSupportActionDefaults.fromReview(
      review,
    );

    return IncomingTalentCareerPathSupportActionDraft(
      reviewId: review.id,
      careerPathId: review.careerPathId,
      portfolioId: review.portfolioId,
      roadmapId: review.roadmapId,
      candidateId: review.candidateId,
      candidateName: review.candidateName,
      department: review.department,
      targetRole: review.targetRole,
      competencyName: review.competencyName,
      ownerName: review.reviewerName,
      actionType: defaults.actionType,
      priority: defaults.priority,
      status: defaults.status,
      dueDate: asOfDate.add(defaults.dueOffset),
      actionPlan: defaults.actionPlan,
      successCriteria: defaults.successCriteria,
      escalationNote: defaults.escalationNote,
      sourceDecision: review.decision,
      reviewedLevel: review.reviewedLevel,
      targetLevel: review.targetLevel,
      sourceLevelGap: review.levelGap,
      asOfDate: asOfDate,
    );
  }
}
