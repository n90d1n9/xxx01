import 'incoming_talent_succession_coverage_action.dart';
import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';

enum IncomingTalentSuccessionCoverageActionOutcomeDecision {
  validated('Validated'),
  monitor('Monitor'),
  reworkCoverage('Rework coverage'),
  executiveReview('Executive review');

  final String label;

  const IncomingTalentSuccessionCoverageActionOutcomeDecision(this.label);
}

enum IncomingTalentSuccessionCoverageActionResidualRisk {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;

  const IncomingTalentSuccessionCoverageActionResidualRisk(this.label);
}

class IncomingTalentSuccessionCoverageActionOutcome {
  final String id;
  final String actionId;
  final String coverageReviewId;
  final String scopeLabel;
  final String departmentScope;
  final bool attentionOnly;
  final String reviewerName;
  final String actionOwnerName;
  final IncomingTalentSuccessionCoverageReviewDecision reviewDecision;
  final IncomingTalentSuccessionCoverageHealth coverageHealthBefore;
  final int coverageScoreBefore;
  final IncomingTalentSuccessionCoverageActionType actionType;
  final String resolutionEvidence;
  final DateTime reviewDate;
  final IncomingTalentSuccessionCoverageActionOutcomeDecision decision;
  final IncomingTalentSuccessionCoverageActionResidualRisk residualRisk;
  final int coverageScoreAfter;
  final String evidenceSummary;
  final String learningSummary;
  final String nextCoverageAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentSuccessionCoverageActionOutcome({
    required this.id,
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
    required this.resolutionEvidence,
    required this.reviewDate,
    required this.decision,
    required this.residualRisk,
    required this.coverageScoreAfter,
    required this.evidenceSummary,
    required this.learningSummary,
    required this.nextCoverageAction,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision !=
            IncomingTalentSuccessionCoverageActionOutcomeDecision.validated ||
        residualRisk ==
            IncomingTalentSuccessionCoverageActionResidualRisk.high ||
        coverageScoreAfter < 70;
  }

  int get coverageImprovement => coverageScoreAfter - coverageScoreBefore;

  double get coverageRatio => coverageScoreAfter / 100;
}
