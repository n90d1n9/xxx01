import 'incoming_talent_succession_coverage_action.dart';
import 'incoming_talent_succession_coverage_action_outcome.dart';
import 'incoming_talent_succession_coverage_action_outcome_policy.dart';
import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';

class IncomingTalentSuccessionCoverageActionOutcomeDraft {
  final String actionId;
  final String coverageReviewId;
  final String scopeLabel;
  final String departmentScope;
  final bool attentionOnly;
  final String reviewerName;
  final String actionOwnerName;
  final IncomingTalentSuccessionCoverageReviewDecision? reviewDecision;
  final IncomingTalentSuccessionCoverageHealth? coverageHealthBefore;
  final int coverageScoreBefore;
  final IncomingTalentSuccessionCoverageActionType? actionType;
  final IncomingTalentSuccessionCoverageActionStatus? actionStatus;
  final String resolutionEvidence;
  final DateTime? reviewDate;
  final IncomingTalentSuccessionCoverageActionOutcomeDecision? decision;
  final IncomingTalentSuccessionCoverageActionResidualRisk? residualRisk;
  final int coverageScoreAfter;
  final String evidenceSummary;
  final String learningSummary;
  final String nextCoverageAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentSuccessionCoverageActionOutcomeDraft({
    required this.actionId,
    required this.coverageReviewId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.attentionOnly,
    required this.reviewerName,
    required this.actionOwnerName,
    required this.reviewDecision,
    required this.coverageHealthBefore,
    required this.coverageScoreBefore,
    required this.actionType,
    required this.actionStatus,
    required this.resolutionEvidence,
    required this.reviewDate,
    required this.decision,
    required this.residualRisk,
    required this.coverageScoreAfter,
    required this.evidenceSummary,
    required this.learningSummary,
    required this.nextCoverageAction,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionCoverageActionOutcomeDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionCoverageActionOutcomeDraft(
      actionId: '',
      coverageReviewId: '',
      scopeLabel: '',
      departmentScope: '',
      attentionOnly: false,
      reviewerName: '',
      actionOwnerName: '',
      reviewDecision: null,
      coverageHealthBefore: null,
      coverageScoreBefore: 0,
      actionType: null,
      actionStatus: null,
      resolutionEvidence: '',
      reviewDate: null,
      decision: null,
      residualRisk: null,
      coverageScoreAfter: 0,
      evidenceSummary: '',
      learningSummary: '',
      nextCoverageAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionCoverageActionOutcomeDraft.fromAction({
    required IncomingTalentSuccessionCoverageAction action,
    required DateTime asOfDate,
  }) {
    final decision = defaultCoverageActionOutcomeDecision(action);
    final scoreAfter = defaultCoverageActionOutcomeScoreAfter(action);

    return IncomingTalentSuccessionCoverageActionOutcomeDraft(
      actionId: action.id,
      coverageReviewId: action.coverageReviewId,
      scopeLabel: action.scopeLabel,
      departmentScope: action.departmentScope,
      attentionOnly: action.attentionOnly,
      reviewerName: action.ownerName,
      actionOwnerName: action.ownerName,
      reviewDecision: action.reviewDecision,
      coverageHealthBefore: action.coverageHealth,
      coverageScoreBefore: action.coverageScore,
      actionType: action.actionType,
      actionStatus: action.status,
      resolutionEvidence: action.resolutionEvidence,
      reviewDate: asOfDate,
      decision: decision,
      residualRisk: defaultCoverageActionOutcomeResidualRisk(action),
      coverageScoreAfter: scoreAfter,
      evidenceSummary:
          '${action.actionType.label} closed with evidence: ${action.resolutionEvidence}',
      learningSummary:
          'Capture what changed coverage health from ${action.coverageScore}% to $scoreAfter%.',
      nextCoverageAction: defaultCoverageActionOutcomeNextAction(decision),
      nextReviewDate: defaultCoverageActionOutcomeNextReviewDate(
        decision: decision,
        asOfDate: asOfDate,
      ),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionCoverageActionOutcomeDraft copyWith({
    String? actionId,
    String? coverageReviewId,
    String? scopeLabel,
    String? departmentScope,
    bool? attentionOnly,
    String? reviewerName,
    String? actionOwnerName,
    IncomingTalentSuccessionCoverageReviewDecision? reviewDecision,
    IncomingTalentSuccessionCoverageHealth? coverageHealthBefore,
    int? coverageScoreBefore,
    IncomingTalentSuccessionCoverageActionType? actionType,
    IncomingTalentSuccessionCoverageActionStatus? actionStatus,
    String? resolutionEvidence,
    DateTime? reviewDate,
    IncomingTalentSuccessionCoverageActionOutcomeDecision? decision,
    IncomingTalentSuccessionCoverageActionResidualRisk? residualRisk,
    int? coverageScoreAfter,
    String? evidenceSummary,
    String? learningSummary,
    String? nextCoverageAction,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageActionOutcomeDraft(
      actionId: actionId ?? this.actionId,
      coverageReviewId: coverageReviewId ?? this.coverageReviewId,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      departmentScope: departmentScope ?? this.departmentScope,
      attentionOnly: attentionOnly ?? this.attentionOnly,
      reviewerName: reviewerName ?? this.reviewerName,
      actionOwnerName: actionOwnerName ?? this.actionOwnerName,
      reviewDecision: reviewDecision ?? this.reviewDecision,
      coverageHealthBefore: coverageHealthBefore ?? this.coverageHealthBefore,
      coverageScoreBefore: coverageScoreBefore ?? this.coverageScoreBefore,
      actionType: actionType ?? this.actionType,
      actionStatus: actionStatus ?? this.actionStatus,
      resolutionEvidence: resolutionEvidence ?? this.resolutionEvidence,
      reviewDate: reviewDate ?? this.reviewDate,
      decision: decision ?? this.decision,
      residualRisk: residualRisk ?? this.residualRisk,
      coverageScoreAfter: coverageScoreAfter ?? this.coverageScoreAfter,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      learningSummary: learningSummary ?? this.learningSummary,
      nextCoverageAction: nextCoverageAction ?? this.nextCoverageAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          actionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          actionStatus == IncomingTalentSuccessionCoverageActionStatus.resolved,
          reviewDate != null,
          decision != null,
          residualRisk != null,
          validateCoverageActionOutcomeScoreAfter(coverageScoreAfter) == null,
          evidenceSummary.trim().length >= 12,
          learningSummary.trim().length >= 12,
          nextCoverageAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateCoverageActionOutcomeActionId(actionId) case final error?)
        error,
      if (validateCoverageActionOutcomeRequired(
            reviewerName,
            'an outcome reviewer',
          )
          case final error?)
        error,
      if (validateCoverageActionOutcomeActionStatus(actionStatus)
          case final error?)
        error,
      if (validateCoverageActionOutcomeReviewDate(reviewDate, asOfDate)
          case final error?)
        error,
      if (validateCoverageActionOutcomeDecision(decision) case final error?)
        error,
      if (validateCoverageActionOutcomeResidualRisk(residualRisk)
          case final error?)
        error,
      if (validateCoverageActionOutcomeScoreAfter(coverageScoreAfter)
          case final error?)
        error,
      if (coverageActionOutcomeLongTextError(
            evidenceSummary,
            'evidence summary',
          )
          case final error?)
        error,
      if (coverageActionOutcomeLongTextError(
            learningSummary,
            'learning summary',
          )
          case final error?)
        error,
      if (coverageActionOutcomeLongTextError(
            nextCoverageAction,
            'next coverage action',
          )
          case final error?)
        error,
      if (validateCoverageActionOutcomeNextReviewDate(
            reviewDate,
            nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionCoverageActionOutcome toOutcome({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionCoverageActionOutcome(
      id: id,
      actionId: actionId,
      coverageReviewId: coverageReviewId,
      scopeLabel: scopeLabel.trim(),
      departmentScope: departmentScope.trim(),
      attentionOnly: attentionOnly,
      reviewerName: reviewerName.trim(),
      actionOwnerName: actionOwnerName.trim(),
      reviewDecision: reviewDecision!,
      coverageHealthBefore: coverageHealthBefore!,
      coverageScoreBefore: coverageScoreBefore,
      actionType: actionType!,
      resolutionEvidence: resolutionEvidence.trim(),
      reviewDate: reviewDate!,
      decision: decision!,
      residualRisk: residualRisk!,
      coverageScoreAfter: coverageScoreAfter,
      evidenceSummary: evidenceSummary.trim(),
      learningSummary: learningSummary.trim(),
      nextCoverageAction: nextCoverageAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }
}
