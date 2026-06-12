import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_field_recipe.dart';
import 'registry_health_api_consistency_scorecard.dart';

class RegistryHealthApiConsistencyFieldRemediationItem {
  final String fieldName;
  final List<String> concernLabels;
  final List<String> familyNames;
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
  final String topAction;

  const RegistryHealthApiConsistencyFieldRemediationItem({
    required this.fieldName,
    required this.concernLabels,
    required this.familyNames,
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
    required this.topAction,
  });

  int get familyCount => familyNames.length;

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

  String get coverageLabel {
    if (concernLabels.isEmpty) return 'No concern coverage';
    return 'Covers: ${concernLabels.join(', ')}';
  }

  RegistryHealthApiConsistencyFieldRecipe get recipe =>
      registryHealthApiConsistencyFieldRecipe(fieldName);

  Map<String, dynamic> toJson() => {
    'fieldName': fieldName,
    'concernLabels': List<String>.from(concernLabels),
    'familyCount': familyCount,
    'familyNames': List<String>.from(familyNames),
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
    'coverageLabel': coverageLabel,
    'topAction': topAction,
    'recipe': recipe.toJson(),
  };
}

class RegistryHealthApiConsistencyFieldRemediationReport {
  final List<RegistryHealthApiConsistencyFieldRemediationItem> items;
  final int actionCount;
  final int requiredGapCount;
  final int advisoryGapCount;
  final double scoreImpactWeight;

  const RegistryHealthApiConsistencyFieldRemediationReport({
    required this.items,
    required this.actionCount,
    required this.requiredGapCount,
    required this.advisoryGapCount,
    required this.scoreImpactWeight,
  });

  bool get isClear => items.isEmpty;

  int get fieldOptionCount => items.length;

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencyFieldRemediationItem? get topField {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencyFieldRemediationItem> visibleItems({
    int limit = 6,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int fieldLimit = 16}) {
    final safeLimit = fieldLimit < 0 ? 0 : fieldLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'fieldOptionCount': fieldOptionCount,
      'actionCount': actionCount,
      'requiredGapCount': requiredGapCount,
      'advisoryGapCount': advisoryGapCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topFieldName': topField?.fieldName,
      'exportedFieldCount': exportedItems.length,
      'hiddenFieldCount': items.length - exportedItems.length,
      'fields': [for (final item in exportedItems) item.toJson()],
    };
  }
}

RegistryHealthApiConsistencyFieldRemediationReport
registryHealthApiConsistencyFieldRemediationReport(
  RegistryHealthApiConsistencyActionPlan actionPlan,
) {
  final buckets = <String, _FieldRemediationBucket>{};

  for (final item in actionPlan.items) {
    for (final fieldName in item.fieldOptions) {
      buckets
          .putIfAbsent(fieldName, () => _FieldRemediationBucket(fieldName))
          .add(item);
    }
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_compareFieldRemediationItems);

  return RegistryHealthApiConsistencyFieldRemediationReport(
    items: List<RegistryHealthApiConsistencyFieldRemediationItem>.unmodifiable(
      items,
    ),
    actionCount: actionPlan.actionCount,
    requiredGapCount: actionPlan.items
        .where(
          (item) =>
              item.level == RegistryHealthApiConsistencyConcernLevel.required,
        )
        .length,
    advisoryGapCount: actionPlan.items
        .where(
          (item) =>
              item.level == RegistryHealthApiConsistencyConcernLevel.advisory,
        )
        .length,
    scoreImpactWeight: actionPlan.scoreImpactWeight,
  );
}

String registryHealthApiConsistencyFieldChecklistText(
  RegistryHealthApiConsistencyFieldRemediationReport report, {
  int fieldLimit = 16,
}) {
  final lines = <String>[
    '# API Field Implementation Checklist',
    '',
    'Fields: ${report.fieldOptionCount}',
    'Actions: ${report.actionCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final safeLimit = fieldLimit < 0 ? 0 : fieldLimit;
  final visibleItems = report.visibleItems(limit: safeLimit);

  for (final item in visibleItems) {
    lines
      ..add('## ${item.fieldName}')
      ..add('')
      ..add(
        '- Status: ${item.statusLabel}, ${item.leadingPhaseLabel}, '
        'impact +${item.scoreImpactLabel}',
      )
      ..add('- ${item.coverageLabel}')
      ..add('- Families: ${item.familyNames.join(', ')}')
      ..add('- Contracts: ${item.contractNames.join(', ')}')
      ..add('- Build: ${item.recipe.targetLabel}')
      ..add('- Adapter: ${item.recipe.adapterLabel}')
      ..add('- Value: ${item.recipe.valueKindLabel}')
      ..add('- Implementation: ${item.recipe.implementationLabel}')
      ..add('- Test: ${item.recipe.testLabel}')
      ..add('- ${item.recipe.acceptanceLabel}');
    if (item.chartExamples.isNotEmpty) {
      lines.add('- Examples: ${item.chartExamples.join(', ')}');
    }
    lines.add('');
  }

  final hiddenCount = report.fieldOptionCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more fields hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

class _FieldRemediationBucket {
  final String fieldName;
  final List<RegistryHealthApiConsistencyActionItem> items = [];
  final Set<String> concernLabels = {};
  final Set<String> familyNames = {};
  final Set<String> contractNames = {};
  final Set<String> chartExamples = {};
  final Map<String, int> chartCountByContract = {};

  _FieldRemediationBucket(this.fieldName);

  void add(RegistryHealthApiConsistencyActionItem item) {
    items.add(item);
    concernLabels.add(item.concernLabel);
    familyNames.add(item.familyName);
    contractNames.add(item.contractName);
    chartExamples.addAll(item.chartExamples);
    chartCountByContract.update(
      item.contractName,
      (existing) => existing > item.chartCount ? existing : item.chartCount,
      ifAbsent: () => item.chartCount,
    );
  }

  RegistryHealthApiConsistencyFieldRemediationItem toItem() {
    final sortedConcerns = concernLabels.toList()..sort();
    final sortedFamilies = familyNames.toList()..sort();
    final sortedContracts = contractNames.toList()..sort();
    final sortedExamples = chartExamples.toList()..sort();
    return RegistryHealthApiConsistencyFieldRemediationItem(
      fieldName: fieldName,
      concernLabels: List<String>.unmodifiable(sortedConcerns),
      familyNames: List<String>.unmodifiable(sortedFamilies),
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

int _compareFieldRemediationItems(
  RegistryHealthApiConsistencyFieldRemediationItem a,
  RegistryHealthApiConsistencyFieldRemediationItem b,
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
  final families = b.familyCount.compareTo(a.familyCount);
  if (families != 0) return families;
  return a.fieldName.compareTo(b.fieldName);
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
