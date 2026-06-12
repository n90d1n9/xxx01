import 'registry_health_api_consistency.dart';

enum RegistryHealthApiConsistencyScoreGrade { excellent, good, watch, blocked }

class RegistryHealthApiConsistencyScorecard {
  final int applicableConcernCount;
  final int supportedConcernCount;
  final int requiredGapCount;
  final int advisoryGapCount;
  final double totalWeight;
  final double requiredPenaltyWeight;
  final double advisoryPenaltyWeight;

  const RegistryHealthApiConsistencyScorecard({
    required this.applicableConcernCount,
    required this.supportedConcernCount,
    required this.requiredGapCount,
    required this.advisoryGapCount,
    required this.totalWeight,
    required this.requiredPenaltyWeight,
    required this.advisoryPenaltyWeight,
  });

  double get penaltyWeight => requiredPenaltyWeight + advisoryPenaltyWeight;

  double get earnedWeight {
    final earned = totalWeight - penaltyWeight;
    return earned < 0 ? 0 : earned;
  }

  double get scoreRatio {
    if (totalWeight <= 0) return 1;
    final ratio = earnedWeight / totalWeight;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  int get scorePercent {
    final value = (scoreRatio * 100).round();
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
  }

  RegistryHealthApiConsistencyScoreGrade get grade {
    if (requiredGapCount > 0) {
      return RegistryHealthApiConsistencyScoreGrade.blocked;
    }
    if (scorePercent >= 95) {
      return RegistryHealthApiConsistencyScoreGrade.excellent;
    }
    if (scorePercent >= 75) {
      return RegistryHealthApiConsistencyScoreGrade.good;
    }
    return RegistryHealthApiConsistencyScoreGrade.watch;
  }

  String get gradeLabel => registryHealthApiConsistencyScoreGradeLabel(grade);

  Map<String, dynamic> toJson() => {
    'scorePercent': scorePercent,
    'scoreRatio': scoreRatio,
    'grade': grade.name,
    'gradeLabel': gradeLabel,
    'applicableConcernCount': applicableConcernCount,
    'supportedConcernCount': supportedConcernCount,
    'requiredGapCount': requiredGapCount,
    'advisoryGapCount': advisoryGapCount,
    'totalWeight': totalWeight,
    'earnedWeight': earnedWeight,
    'penaltyWeight': penaltyWeight,
    'requiredPenaltyWeight': requiredPenaltyWeight,
    'advisoryPenaltyWeight': advisoryPenaltyWeight,
    'advisoryPenaltyMultiplier':
        registryHealthApiConsistencyAdvisoryPenaltyMultiplier,
  };
}

RegistryHealthApiConsistencyScorecard registryHealthApiConsistencyScorecard(
  RegistryHealthApiConsistencyReport report,
) {
  var applicableConcernCount = 0;
  var supportedConcernCount = 0;
  var requiredGapCount = 0;
  var advisoryGapCount = 0;
  var totalWeight = 0.0;
  var requiredPenaltyWeight = 0.0;
  var advisoryPenaltyWeight = 0.0;

  for (final row in report.rows) {
    for (final concern in row.supportedConcerns) {
      applicableConcernCount += 1;
      supportedConcernCount += 1;
      totalWeight += registryHealthApiConsistencyConcernScoreWeight(concern);
    }
    for (final concern in row.requiredMissingConcerns) {
      applicableConcernCount += 1;
      requiredGapCount += 1;
      final weight = registryHealthApiConsistencyConcernScoreWeight(concern);
      totalWeight += weight;
      requiredPenaltyWeight += weight;
    }
    for (final concern in row.advisoryMissingConcerns) {
      applicableConcernCount += 1;
      advisoryGapCount += 1;
      final weight = registryHealthApiConsistencyConcernScoreWeight(concern);
      totalWeight += weight;
      advisoryPenaltyWeight += registryHealthApiConsistencyConcernPenaltyWeight(
        concern,
        RegistryHealthApiConsistencyConcernLevel.advisory,
      );
    }
  }

  return RegistryHealthApiConsistencyScorecard(
    applicableConcernCount: applicableConcernCount,
    supportedConcernCount: supportedConcernCount,
    requiredGapCount: requiredGapCount,
    advisoryGapCount: advisoryGapCount,
    totalWeight: totalWeight,
    requiredPenaltyWeight: requiredPenaltyWeight,
    advisoryPenaltyWeight: advisoryPenaltyWeight,
  );
}

String registryHealthApiConsistencyScoreGradeLabel(
  RegistryHealthApiConsistencyScoreGrade grade,
) {
  switch (grade) {
    case RegistryHealthApiConsistencyScoreGrade.excellent:
      return 'Excellent';
    case RegistryHealthApiConsistencyScoreGrade.good:
      return 'Good';
    case RegistryHealthApiConsistencyScoreGrade.watch:
      return 'Watch';
    case RegistryHealthApiConsistencyScoreGrade.blocked:
      return 'Blocked';
  }
}

double registryHealthApiConsistencyConcernScoreWeight(
  RegistryHealthApiConsistencyConcern concern,
) {
  switch (concern.priority) {
    case RegistryHealthApiConsistencyConcernPriority.critical:
      return 5;
    case RegistryHealthApiConsistencyConcernPriority.high:
      return 3;
    case RegistryHealthApiConsistencyConcernPriority.medium:
      return 1;
  }
}

double registryHealthApiConsistencyConcernPenaltyWeight(
  RegistryHealthApiConsistencyConcern concern,
  RegistryHealthApiConsistencyConcernLevel level,
) {
  switch (level) {
    case RegistryHealthApiConsistencyConcernLevel.required:
      return registryHealthApiConsistencyConcernScoreWeight(concern);
    case RegistryHealthApiConsistencyConcernLevel.advisory:
      return registryHealthApiConsistencyConcernScoreWeight(concern) *
          registryHealthApiConsistencyAdvisoryPenaltyMultiplier;
    case RegistryHealthApiConsistencyConcernLevel.notApplicable:
      return 0;
  }
}

String registryHealthApiConsistencyScoreWeightLabel(double value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return rounded.toInt().toString();
  }
  return rounded.toStringAsFixed(1);
}

const registryHealthApiConsistencyAdvisoryPenaltyMultiplier = 0.35;
