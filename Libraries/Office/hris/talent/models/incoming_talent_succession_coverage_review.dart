import 'incoming_talent_succession_coverage_dashboard.dart';

enum IncomingTalentSuccessionCoverageReviewDecision {
  endorsed('Endorsed'),
  watch('Watch'),
  rework('Rework'),
  executiveEscalation('Executive escalation');

  final String label;

  const IncomingTalentSuccessionCoverageReviewDecision(this.label);
}

class IncomingTalentSuccessionCoverageReview {
  final String id;
  final String scopeLabel;
  final String departmentScope;
  final bool attentionOnly;
  final String reviewerName;
  final DateTime reviewDate;
  final IncomingTalentSuccessionCoverageReviewDecision decision;
  final IncomingTalentSuccessionCoverageHealth coverageHealth;
  final int coverageScore;
  final int totalCandidates;
  final int readyCoverageCount;
  final int attentionSignalCount;
  final int openBenchActionCount;
  final String reviewSummary;
  final String executiveCommitment;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentSuccessionCoverageReview({
    required this.id,
    required this.scopeLabel,
    required this.departmentScope,
    required this.attentionOnly,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.coverageHealth,
    required this.coverageScore,
    required this.totalCandidates,
    required this.readyCoverageCount,
    required this.attentionSignalCount,
    required this.openBenchActionCount,
    required this.reviewSummary,
    required this.executiveCommitment,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision == IncomingTalentSuccessionCoverageReviewDecision.rework ||
        decision ==
            IncomingTalentSuccessionCoverageReviewDecision
                .executiveEscalation ||
        coverageHealth != IncomingTalentSuccessionCoverageHealth.strong ||
        attentionSignalCount > 0 ||
        openBenchActionCount > 0;
  }

  double get coverageRatio => coverageScore / 100;

  int daysUntilNextReview(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final next = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );
    return next.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilNextReview(asOfDate);
    return days >= 0 && days <= 14;
  }

  bool isOverdue(DateTime asOfDate) {
    return daysUntilNextReview(asOfDate) < 0;
  }
}
