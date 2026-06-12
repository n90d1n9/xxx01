import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_family_recipe.dart';
import 'registry_health_api_consistency_scorecard.dart';

class RegistryHealthApiConsistencyFamilyRemediationItem {
  final String familyName;
  final List<String> contractNames;
  final int chartCount;
  final List<String> chartExamples;
  final int actionCount;
  final int requiredGapCount;
  final int advisoryGapCount;
  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int nowCount;
  final int nextCount;
  final int laterCount;
  final double scoreImpactWeight;
  final List<String> topConcernLabels;
  final String topAction;

  const RegistryHealthApiConsistencyFamilyRemediationItem({
    required this.familyName,
    required this.contractNames,
    required this.chartCount,
    required this.chartExamples,
    required this.actionCount,
    required this.requiredGapCount,
    required this.advisoryGapCount,
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.nowCount,
    required this.nextCount,
    required this.laterCount,
    required this.scoreImpactWeight,
    required this.topConcernLabels,
    required this.topAction,
  });

  int get contractCount => contractNames.length;

  int get gapCount => requiredGapCount + advisoryGapCount;

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencyStatus get status {
    if (requiredGapCount > 0) return RegistryHealthApiConsistencyStatus.blocked;
    if (advisoryGapCount > 0) return RegistryHealthApiConsistencyStatus.warning;
    return RegistryHealthApiConsistencyStatus.ready;
  }

  String get statusLabel => registryHealthApiConsistencyStatusLabel(status);

  RegistryHealthApiConsistencyActionPhase get leadingPhase {
    if (nowCount > 0) return RegistryHealthApiConsistencyActionPhase.now;
    if (nextCount > 0) return RegistryHealthApiConsistencyActionPhase.next;
    return RegistryHealthApiConsistencyActionPhase.later;
  }

  String get leadingPhaseLabel =>
      registryHealthApiConsistencyActionPhaseLabel(leadingPhase);

  String get focusLabel {
    if (topConcernLabels.isEmpty) return 'No focused concerns';
    return 'Focus: ${topConcernLabels.join(', ')}';
  }

  RegistryHealthApiConsistencyFamilyRecipe get recipe =>
      registryHealthApiConsistencyFamilyRecipe(familyName);

  Map<String, dynamic> toJson() => {
    'familyName': familyName,
    'contractCount': contractCount,
    'contractNames': List<String>.from(contractNames),
    'chartCount': chartCount,
    'chartExamples': List<String>.from(chartExamples),
    'status': status.name,
    'statusLabel': statusLabel,
    'actionCount': actionCount,
    'gapCount': gapCount,
    'requiredGapCount': requiredGapCount,
    'advisoryGapCount': advisoryGapCount,
    'priorityCounts': {
      'critical': criticalCount,
      'high': highCount,
      'medium': mediumCount,
    },
    'phaseCounts': {'now': nowCount, 'next': nextCount, 'later': laterCount},
    'leadingPhase': leadingPhase.name,
    'leadingPhaseLabel': leadingPhaseLabel,
    'scoreImpactWeight': scoreImpactWeight,
    'scoreImpactLabel': scoreImpactLabel,
    'topConcernLabels': List<String>.from(topConcernLabels),
    'focusLabel': focusLabel,
    'topAction': topAction,
    'recipe': recipe.toJson(),
  };
}

class RegistryHealthApiConsistencyFamilyRemediationReport {
  final List<RegistryHealthApiConsistencyFamilyRemediationItem> items;

  const RegistryHealthApiConsistencyFamilyRemediationReport({
    required this.items,
  });

  bool get isClear => items.isEmpty;

  int get familyCount => items.length;

  int get actionCount =>
      items.fold<int>(0, (count, item) => count + item.actionCount);

  int get requiredGapCount =>
      items.fold<int>(0, (count, item) => count + item.requiredGapCount);

  int get advisoryGapCount =>
      items.fold<int>(0, (count, item) => count + item.advisoryGapCount);

  double get scoreImpactWeight =>
      items.fold<double>(0, (total, item) => total + item.scoreImpactWeight);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencyFamilyRemediationItem? get topFamily {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencyFamilyRemediationItem> visibleItems({
    int limit = 4,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int familyLimit = 12}) {
    final safeLimit = familyLimit < 0 ? 0 : familyLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'familyCount': familyCount,
      'actionCount': actionCount,
      'requiredGapCount': requiredGapCount,
      'advisoryGapCount': advisoryGapCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topFamilyName': topFamily?.familyName,
      'exportedFamilyCount': exportedItems.length,
      'hiddenFamilyCount': items.length - exportedItems.length,
      'families': [for (final item in exportedItems) item.toJson()],
    };
  }
}

RegistryHealthApiConsistencyFamilyRemediationReport
registryHealthApiConsistencyFamilyRemediationReport(
  RegistryHealthApiConsistencyActionPlan actionPlan,
) {
  final buckets = <String, _FamilyRemediationBucket>{};

  for (final item in actionPlan.items) {
    buckets
        .putIfAbsent(
          item.familyName,
          () => _FamilyRemediationBucket(item.familyName),
        )
        .add(item);
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_compareFamilyRemediationItems);

  return RegistryHealthApiConsistencyFamilyRemediationReport(
    items: List<RegistryHealthApiConsistencyFamilyRemediationItem>.unmodifiable(
      items,
    ),
  );
}

String registryHealthApiConsistencyFamilyChecklistText(
  RegistryHealthApiConsistencyFamilyRemediationReport report, {
  int familyLimit = 12,
}) {
  final lines = <String>[
    '# API Family Implementation Checklist',
    '',
    'Families: ${report.familyCount}',
    'Actions: ${report.actionCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final safeLimit = familyLimit < 0 ? 0 : familyLimit;
  final visibleItems = report.visibleItems(limit: safeLimit);

  for (final item in visibleItems) {
    lines
      ..add('## ${item.familyName}')
      ..add('')
      ..add(
        '- Status: ${item.statusLabel}, ${item.leadingPhaseLabel}, '
        'impact +${item.scoreImpactLabel}',
      )
      ..add('- ${item.focusLabel}')
      ..add('- Contracts: ${item.contractNames.join(', ')}')
      ..add('- Build: ${item.recipe.targetLabel}')
      ..add('- Foundation: ${item.recipe.foundationLabel}')
      ..add('- Implementation: ${item.recipe.implementationLabel}')
      ..add('- Test: ${item.recipe.testLabel}')
      ..add('- ${item.recipe.acceptanceLabel}');
    if (item.chartExamples.isNotEmpty) {
      lines.add('- Examples: ${item.chartExamples.join(', ')}');
    }
    lines.add('');
  }

  final hiddenCount = report.familyCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more families hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

class _FamilyRemediationBucket {
  final String familyName;
  final List<RegistryHealthApiConsistencyActionItem> items = [];
  final Set<String> contractNames = {};
  final Set<String> chartExamples = {};
  final Map<String, int> chartCountByContract = {};

  _FamilyRemediationBucket(this.familyName);

  void add(RegistryHealthApiConsistencyActionItem item) {
    items.add(item);
    contractNames.add(item.contractName);
    chartExamples.addAll(item.chartExamples);
    chartCountByContract.update(
      item.contractName,
      (existing) => existing > item.chartCount ? existing : item.chartCount,
      ifAbsent: () => item.chartCount,
    );
  }

  RegistryHealthApiConsistencyFamilyRemediationItem toItem() {
    final sortedContracts = contractNames.toList()..sort();
    final sortedExamples = chartExamples.toList()..sort();
    return RegistryHealthApiConsistencyFamilyRemediationItem(
      familyName: familyName,
      contractNames: List<String>.unmodifiable(sortedContracts),
      chartCount: chartCountByContract.values.fold<int>(
        0,
        (count, value) => count + value,
      ),
      chartExamples: List<String>.unmodifiable(sortedExamples),
      actionCount: items.length,
      requiredGapCount: _levelCount(
        RegistryHealthApiConsistencyConcernLevel.required,
      ),
      advisoryGapCount: _levelCount(
        RegistryHealthApiConsistencyConcernLevel.advisory,
      ),
      criticalCount: _priorityCount(
        RegistryHealthApiConsistencyActionPriority.critical,
      ),
      highCount: _priorityCount(
        RegistryHealthApiConsistencyActionPriority.high,
      ),
      mediumCount: _priorityCount(
        RegistryHealthApiConsistencyActionPriority.medium,
      ),
      nowCount: _phaseCount(RegistryHealthApiConsistencyActionPhase.now),
      nextCount: _phaseCount(RegistryHealthApiConsistencyActionPhase.next),
      laterCount: _phaseCount(RegistryHealthApiConsistencyActionPhase.later),
      scoreImpactWeight: items.fold<double>(
        0,
        (total, item) => total + item.scoreImpactWeight,
      ),
      topConcernLabels: List<String>.unmodifiable(_topConcernLabels(items)),
      topAction: items.isEmpty ? '' : items.first.action,
    );
  }

  int _levelCount(RegistryHealthApiConsistencyConcernLevel level) {
    return items.where((item) => item.level == level).length;
  }

  int _priorityCount(RegistryHealthApiConsistencyActionPriority priority) {
    return items.where((item) => item.priority == priority).length;
  }

  int _phaseCount(RegistryHealthApiConsistencyActionPhase phase) {
    return items.where((item) => item.phase == phase).length;
  }
}

List<String> _topConcernLabels(
  List<RegistryHealthApiConsistencyActionItem> items, {
  int limit = 3,
}) {
  final labels = <String>[];
  final seenKeys = <String>{};
  for (final item in items) {
    if (!seenKeys.add(item.concernKey)) continue;
    labels.add(item.concernLabel);
    if (labels.length >= limit) break;
  }
  return labels;
}

int _compareFamilyRemediationItems(
  RegistryHealthApiConsistencyFamilyRemediationItem a,
  RegistryHealthApiConsistencyFamilyRemediationItem b,
) {
  final status = _statusRank(b.status).compareTo(_statusRank(a.status));
  if (status != 0) return status;
  final required = b.requiredGapCount.compareTo(a.requiredGapCount);
  if (required != 0) return required;
  final critical = b.criticalCount.compareTo(a.criticalCount);
  if (critical != 0) return critical;
  final impact = b.scoreImpactWeight.compareTo(a.scoreImpactWeight);
  if (impact != 0) return impact;
  final actions = b.actionCount.compareTo(a.actionCount);
  if (actions != 0) return actions;
  final charts = b.chartCount.compareTo(a.chartCount);
  if (charts != 0) return charts;
  return a.familyName.compareTo(b.familyName);
}

int _statusRank(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return 0;
    case RegistryHealthApiConsistencyStatus.warning:
      return 1;
    case RegistryHealthApiConsistencyStatus.blocked:
      return 2;
  }
}
