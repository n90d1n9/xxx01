import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_scorecard.dart';

class RegistryHealthApiConsistencyScoreProjectionStep {
  final RegistryHealthApiConsistencyActionPhase phase;
  final int actionCount;
  final int phaseRequiredGapCount;
  final int phaseAdvisoryGapCount;
  final int resolvedRequiredGapCount;
  final int resolvedAdvisoryGapCount;
  final double impactWeight;
  final int projectedRequiredGapCount;
  final int projectedAdvisoryGapCount;
  final double projectedScoreRatio;
  final int projectedScorePercent;
  final RegistryHealthApiConsistencyScoreGrade projectedGrade;

  const RegistryHealthApiConsistencyScoreProjectionStep({
    required this.phase,
    required this.actionCount,
    required this.phaseRequiredGapCount,
    required this.phaseAdvisoryGapCount,
    required this.resolvedRequiredGapCount,
    required this.resolvedAdvisoryGapCount,
    required this.impactWeight,
    required this.projectedRequiredGapCount,
    required this.projectedAdvisoryGapCount,
    required this.projectedScoreRatio,
    required this.projectedScorePercent,
    required this.projectedGrade,
  });

  String get phaseLabel => registryHealthApiConsistencyActionPhaseLabel(phase);

  String get impactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(impactWeight);

  String get projectedGradeLabel =>
      registryHealthApiConsistencyScoreGradeLabel(projectedGrade);

  int get phaseGapCount => phaseRequiredGapCount + phaseAdvisoryGapCount;

  int get resolvedGapCount =>
      resolvedRequiredGapCount + resolvedAdvisoryGapCount;

  int get projectedGapCount =>
      projectedRequiredGapCount + projectedAdvisoryGapCount;

  bool get isProjectedBlocked => projectedRequiredGapCount > 0;

  String get resolutionLabel {
    final parts = <String>[
      if (phaseRequiredGapCount > 0)
        _gapCountLabel(phaseRequiredGapCount, 'required'),
      if (phaseAdvisoryGapCount > 0)
        _gapCountLabel(phaseAdvisoryGapCount, 'advisory'),
    ];
    if (parts.isEmpty) return 'No gaps resolved';
    return 'Resolves ${_joinLabels(parts)}';
  }

  String get statusLabel => _projectedGapStatusLabel(
    projectedRequiredGapCount: projectedRequiredGapCount,
    projectedAdvisoryGapCount: projectedAdvisoryGapCount,
  );

  Map<String, dynamic> toJson() => {
    'phase': phase.name,
    'phaseLabel': phaseLabel,
    'actionCount': actionCount,
    'phaseGapCount': phaseGapCount,
    'phaseRequiredGapCount': phaseRequiredGapCount,
    'phaseAdvisoryGapCount': phaseAdvisoryGapCount,
    'resolutionLabel': resolutionLabel,
    'resolvedGapCount': resolvedGapCount,
    'resolvedRequiredGapCount': resolvedRequiredGapCount,
    'resolvedAdvisoryGapCount': resolvedAdvisoryGapCount,
    'impactWeight': impactWeight,
    'impactLabel': impactLabel,
    'projectedGapCount': projectedGapCount,
    'projectedRequiredGapCount': projectedRequiredGapCount,
    'projectedAdvisoryGapCount': projectedAdvisoryGapCount,
    'isProjectedBlocked': isProjectedBlocked,
    'statusLabel': statusLabel,
    'projectedScoreRatio': projectedScoreRatio,
    'projectedScorePercent': projectedScorePercent,
    'projectedGrade': projectedGrade.name,
    'projectedGradeLabel': projectedGradeLabel,
  };
}

class RegistryHealthApiConsistencyScoreProjection {
  final RegistryHealthApiConsistencyScorecard scorecard;
  final List<RegistryHealthApiConsistencyScoreProjectionStep> steps;

  const RegistryHealthApiConsistencyScoreProjection({
    required this.scorecard,
    required this.steps,
  });

  bool get isClear => steps.isEmpty;

  double get totalImpactWeight =>
      steps.fold<double>(0, (sum, step) => sum + step.impactWeight);

  String get totalImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(totalImpactWeight);

  RegistryHealthApiConsistencyScoreProjectionStep? get finalStep {
    if (steps.isEmpty) return null;
    return steps.last;
  }

  int get projectedScorePercent =>
      finalStep?.projectedScorePercent ?? scorecard.scorePercent;

  int get projectedRequiredGapCount =>
      finalStep?.projectedRequiredGapCount ?? scorecard.requiredGapCount;

  int get projectedAdvisoryGapCount =>
      finalStep?.projectedAdvisoryGapCount ?? scorecard.advisoryGapCount;

  int get projectedGapCount =>
      projectedRequiredGapCount + projectedAdvisoryGapCount;

  bool get isProjectedBlocked => projectedRequiredGapCount > 0;

  RegistryHealthApiConsistencyScoreGrade get projectedGrade =>
      finalStep?.projectedGrade ?? scorecard.grade;

  String get projectedGradeLabel =>
      registryHealthApiConsistencyScoreGradeLabel(projectedGrade);

  String get statusLabel => _projectedGapStatusLabel(
    projectedRequiredGapCount: projectedRequiredGapCount,
    projectedAdvisoryGapCount: projectedAdvisoryGapCount,
  );

  Map<String, dynamic> toJson() => {
    'currentScorePercent': scorecard.scorePercent,
    'currentGrade': scorecard.grade.name,
    'currentGradeLabel': scorecard.gradeLabel,
    'currentGapCount': scorecard.requiredGapCount + scorecard.advisoryGapCount,
    'currentRequiredGapCount': scorecard.requiredGapCount,
    'currentAdvisoryGapCount': scorecard.advisoryGapCount,
    'projectedScorePercent': projectedScorePercent,
    'projectedGrade': projectedGrade.name,
    'projectedGradeLabel': projectedGradeLabel,
    'projectedGapCount': projectedGapCount,
    'projectedRequiredGapCount': projectedRequiredGapCount,
    'projectedAdvisoryGapCount': projectedAdvisoryGapCount,
    'isProjectedBlocked': isProjectedBlocked,
    'statusLabel': statusLabel,
    'totalImpactWeight': totalImpactWeight,
    'totalImpactLabel': totalImpactLabel,
    'stepCount': steps.length,
    'steps': [for (final step in steps) step.toJson()],
  };
}

RegistryHealthApiConsistencyScoreProjection
registryHealthApiConsistencyScoreProjection({
  required RegistryHealthApiConsistencyScorecard scorecard,
  required RegistryHealthApiConsistencyActionPlan actionPlan,
}) {
  final steps = <RegistryHealthApiConsistencyScoreProjectionStep>[];
  var cumulativeImpact = 0.0;
  var resolvedRequiredGapCount = 0;
  var resolvedAdvisoryGapCount = 0;

  for (final phase in RegistryHealthApiConsistencyActionPhase.values) {
    final items = actionPlan.items
        .where((item) => item.phase == phase)
        .toList(growable: false);
    if (items.isEmpty) continue;

    final phaseImpact = items.fold<double>(
      0,
      (sum, item) => sum + item.scoreImpactWeight,
    );
    final phaseRequiredGapCount = items
        .where(
          (item) =>
              item.level == RegistryHealthApiConsistencyConcernLevel.required,
        )
        .length;
    final phaseAdvisoryGapCount = items
        .where(
          (item) =>
              item.level == RegistryHealthApiConsistencyConcernLevel.advisory,
        )
        .length;

    cumulativeImpact += phaseImpact;
    resolvedRequiredGapCount += phaseRequiredGapCount;
    resolvedAdvisoryGapCount += phaseAdvisoryGapCount;
    final rawProjectedRequiredGapCount =
        scorecard.requiredGapCount - resolvedRequiredGapCount;
    final projectedRequiredGapCount = rawProjectedRequiredGapCount < 0
        ? 0
        : rawProjectedRequiredGapCount;
    final rawProjectedAdvisoryGapCount =
        scorecard.advisoryGapCount - resolvedAdvisoryGapCount;
    final projectedAdvisoryGapCount = rawProjectedAdvisoryGapCount < 0
        ? 0
        : rawProjectedAdvisoryGapCount;
    final projectedScoreRatio = _projectedScoreRatio(
      scorecard,
      cumulativeImpact,
    );
    final projectedScorePercent = _scorePercent(projectedScoreRatio);

    steps.add(
      RegistryHealthApiConsistencyScoreProjectionStep(
        phase: phase,
        actionCount: items.length,
        phaseRequiredGapCount: phaseRequiredGapCount,
        phaseAdvisoryGapCount: phaseAdvisoryGapCount,
        resolvedRequiredGapCount: resolvedRequiredGapCount,
        resolvedAdvisoryGapCount: resolvedAdvisoryGapCount,
        impactWeight: phaseImpact,
        projectedRequiredGapCount: projectedRequiredGapCount,
        projectedAdvisoryGapCount: projectedAdvisoryGapCount,
        projectedScoreRatio: projectedScoreRatio,
        projectedScorePercent: projectedScorePercent,
        projectedGrade: _projectedGrade(
          projectedScorePercent,
          projectedRequiredGapCount,
        ),
      ),
    );
  }

  return RegistryHealthApiConsistencyScoreProjection(
    scorecard: scorecard,
    steps: List<RegistryHealthApiConsistencyScoreProjectionStep>.unmodifiable(
      steps,
    ),
  );
}

double _projectedScoreRatio(
  RegistryHealthApiConsistencyScorecard scorecard,
  double cumulativeImpact,
) {
  if (scorecard.totalWeight <= 0) return 1;
  final ratio =
      (scorecard.earnedWeight + cumulativeImpact) / scorecard.totalWeight;
  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}

int _scorePercent(double ratio) {
  final value = (ratio * 100).round();
  if (value < 0) return 0;
  if (value > 100) return 100;
  return value;
}

RegistryHealthApiConsistencyScoreGrade _projectedGrade(
  int scorePercent,
  int projectedRequiredGapCount,
) {
  if (projectedRequiredGapCount > 0) {
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

String _projectedGapStatusLabel({
  required int projectedRequiredGapCount,
  required int projectedAdvisoryGapCount,
}) {
  if (projectedRequiredGapCount > 0) {
    return _remainingGapLabel(projectedRequiredGapCount, 'required');
  }
  if (projectedAdvisoryGapCount > 0) {
    return _remainingGapLabel(projectedAdvisoryGapCount, 'advisory');
  }
  return 'All gaps resolved';
}

String _gapCountLabel(int count, String level) {
  final suffix = count == 1 ? 'gap' : 'gaps';
  return '$count $level $suffix';
}

String _remainingGapLabel(int count, String level) {
  final verb = count == 1 ? 'remains' : 'remain';
  return '${_gapCountLabel(count, level)} $verb';
}

String _joinLabels(List<String> labels) {
  if (labels.length <= 1) return labels.join();
  if (labels.length == 2) return '${labels.first} and ${labels.last}';
  return '${labels.take(labels.length - 1).join(', ')}, and ${labels.last}';
}
