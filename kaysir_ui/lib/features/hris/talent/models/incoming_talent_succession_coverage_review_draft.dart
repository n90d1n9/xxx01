import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';
import 'incoming_talent_succession_coverage_review_policy.dart';

class IncomingTalentSuccessionCoverageReviewDraft {
  final String scopeLabel;
  final String departmentScope;
  final bool attentionOnly;
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentSuccessionCoverageReviewDecision? decision;
  final IncomingTalentSuccessionCoverageHealth? coverageHealth;
  final int coverageScore;
  final int totalCandidates;
  final int readyCoverageCount;
  final int attentionSignalCount;
  final int openBenchActionCount;
  final String reviewSummary;
  final String executiveCommitment;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentSuccessionCoverageReviewDraft({
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
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionCoverageReviewDraft.empty(DateTime asOfDate) {
    return IncomingTalentSuccessionCoverageReviewDraft(
      scopeLabel: '',
      departmentScope: '',
      attentionOnly: false,
      reviewerName: '',
      reviewDate: null,
      decision: null,
      coverageHealth: null,
      coverageScore: 0,
      totalCandidates: 0,
      readyCoverageCount: 0,
      attentionSignalCount: 0,
      openBenchActionCount: 0,
      reviewSummary: '',
      executiveCommitment: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionCoverageReviewDraft.fromDashboard({
    required IncomingTalentSuccessionCoverageDashboard dashboard,
    required DateTime asOfDate,
    required String scopeLabel,
    required String departmentScope,
    required bool attentionOnly,
  }) {
    final decision = defaultCoverageReviewDecision(dashboard);

    return IncomingTalentSuccessionCoverageReviewDraft(
      scopeLabel: scopeLabel,
      departmentScope: departmentScope,
      attentionOnly: attentionOnly,
      reviewerName: 'Talent Council',
      reviewDate: asOfDate,
      decision: decision,
      coverageHealth: dashboard.health,
      coverageScore: dashboard.coverageScore,
      totalCandidates: dashboard.totalCandidates,
      readyCoverageCount: dashboard.readyCoverageCount,
      attentionSignalCount: dashboard.attentionSignalCount,
      openBenchActionCount: dashboard.openBenchActionCount,
      reviewSummary:
          'Coverage score ${dashboard.coverageScore}% with ${dashboard.readyCoverageCount}/${dashboard.totalCandidates} ready successors and ${dashboard.attentionSignalCount} attention signals.',
      executiveCommitment: defaultCoverageReviewCommitment(decision),
      nextReviewDate: nextCoverageReviewDateForDecision(decision, asOfDate),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionCoverageReviewDraft copyWith({
    String? scopeLabel,
    String? departmentScope,
    bool? attentionOnly,
    String? reviewerName,
    DateTime? reviewDate,
    IncomingTalentSuccessionCoverageReviewDecision? decision,
    IncomingTalentSuccessionCoverageHealth? coverageHealth,
    int? coverageScore,
    int? totalCandidates,
    int? readyCoverageCount,
    int? attentionSignalCount,
    int? openBenchActionCount,
    String? reviewSummary,
    String? executiveCommitment,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageReviewDraft(
      scopeLabel: scopeLabel ?? this.scopeLabel,
      departmentScope: departmentScope ?? this.departmentScope,
      attentionOnly: attentionOnly ?? this.attentionOnly,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDate: reviewDate ?? this.reviewDate,
      decision: decision ?? this.decision,
      coverageHealth: coverageHealth ?? this.coverageHealth,
      coverageScore: coverageScore ?? this.coverageScore,
      totalCandidates: totalCandidates ?? this.totalCandidates,
      readyCoverageCount: readyCoverageCount ?? this.readyCoverageCount,
      attentionSignalCount: attentionSignalCount ?? this.attentionSignalCount,
      openBenchActionCount: openBenchActionCount ?? this.openBenchActionCount,
      reviewSummary: reviewSummary ?? this.reviewSummary,
      executiveCommitment: executiveCommitment ?? this.executiveCommitment,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          scopeLabel.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          reviewDate != null,
          decision != null,
          coverageHealth != null,
          coverageScore >= 0 && coverageScore <= 100,
          reviewSummary.trim().length >= 12,
          executiveCommitment.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(scopeLabel, 'a review scope') case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateDecision(decision) case final error?) error,
      if (validateCoverageHealth(coverageHealth) case final error?) error,
      if (validateCoverageScore(coverageScore) case final error?) error,
      if (validateReviewSummary(reviewSummary) case final error?) error,
      if (validateExecutiveCommitment(executiveCommitment) case final error?)
        error,
      if (validateNextReviewDate(reviewDate, nextReviewDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionCoverageReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionCoverageReview(
      id: id,
      scopeLabel: scopeLabel.trim(),
      departmentScope: departmentScope.trim(),
      attentionOnly: attentionOnly,
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      decision: decision!,
      coverageHealth: coverageHealth!,
      coverageScore: coverageScore,
      totalCandidates: totalCandidates,
      readyCoverageCount: readyCoverageCount,
      attentionSignalCount: attentionSignalCount,
      openBenchActionCount: openBenchActionCount,
      reviewSummary: reviewSummary.trim(),
      executiveCommitment: executiveCommitment.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }

  static String? validateDecision(
    IncomingTalentSuccessionCoverageReviewDecision? value,
  ) {
    if (value == null) return 'Select coverage decision';
    return null;
  }

  static String? validateCoverageHealth(
    IncomingTalentSuccessionCoverageHealth? value,
  ) {
    if (value == null) return 'Refresh coverage snapshot';
    return null;
  }

  static String? validateCoverageScore(int value) {
    if (value < 0 || value > 100) {
      return 'Coverage score must be between 0 and 100';
    }
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select review date';
    if (coverageReviewDateOnly(
      value,
    ).isBefore(coverageReviewDateOnly(asOfDate))) {
      return 'Review date cannot be in the past';
    }
    return null;
  }

  static String? validateNextReviewDate(
    DateTime? reviewDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select next review date';
    if (reviewDate == null) return null;
    if (!coverageReviewDateOnly(
      nextReviewDate,
    ).isAfter(coverageReviewDateOnly(reviewDate))) {
      return 'Next review must be after review date';
    }
    return null;
  }

  static String? validateReviewSummary(String? value) {
    return coverageReviewLongTextError(value, 'review summary');
  }

  static String? validateExecutiveCommitment(String? value) {
    return coverageReviewLongTextError(value, 'executive commitment');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}
