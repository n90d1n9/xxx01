import 'package:tenun/tenun_core.dart';

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_primitive_recipe.dart';
import 'registry_health_api_consistency_scorecard.dart';

class RegistryHealthApiConsistencyPrimitiveRemediationItem {
  final String primitiveKey;
  final String primitiveLabel;
  final List<String> fieldNames;
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

  const RegistryHealthApiConsistencyPrimitiveRemediationItem({
    required this.primitiveKey,
    required this.primitiveLabel,
    required this.fieldNames,
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

  int get fieldCount => fieldNames.length;

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

  String get fieldLabel {
    if (fieldNames.isEmpty) return 'No fields';
    return 'Fields: ${fieldNames.join(', ')}';
  }

  String get coverageLabel {
    if (concernLabels.isEmpty) return 'No concern coverage';
    return 'Covers: ${concernLabels.join(', ')}';
  }

  RegistryHealthApiConsistencyPrimitiveRecipe get recipe =>
      registryHealthApiConsistencyPrimitiveRecipe(primitiveKey);

  Map<String, dynamic> toJson() => {
    'primitiveKey': primitiveKey,
    'primitiveLabel': primitiveLabel,
    'fieldCount': fieldCount,
    'fieldNames': List<String>.from(fieldNames),
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
    'fieldLabel': fieldLabel,
    'coverageLabel': coverageLabel,
    'topAction': topAction,
    'recipe': recipe.toJson(),
  };
}

class RegistryHealthApiConsistencyPrimitiveRemediationReport {
  final List<RegistryHealthApiConsistencyPrimitiveRemediationItem> items;
  final int actionCount;
  final int requiredGapCount;
  final int advisoryGapCount;
  final double scoreImpactWeight;

  const RegistryHealthApiConsistencyPrimitiveRemediationReport({
    required this.items,
    required this.actionCount,
    required this.requiredGapCount,
    required this.advisoryGapCount,
    required this.scoreImpactWeight,
  });

  bool get isClear => items.isEmpty;

  int get primitiveCount => items.length;

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencyPrimitiveRemediationItem? get topPrimitive {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencyPrimitiveRemediationItem> visibleItems({
    int limit = 5,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int primitiveLimit = 12}) {
    final safeLimit = primitiveLimit < 0 ? 0 : primitiveLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'primitiveCount': primitiveCount,
      'actionCount': actionCount,
      'requiredGapCount': requiredGapCount,
      'advisoryGapCount': advisoryGapCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topPrimitiveKey': topPrimitive?.primitiveKey,
      'topPrimitiveLabel': topPrimitive?.primitiveLabel,
      'exportedPrimitiveCount': exportedItems.length,
      'hiddenPrimitiveCount': items.length - exportedItems.length,
      'primitives': [for (final item in exportedItems) item.toJson()],
    };
  }
}

RegistryHealthApiConsistencyPrimitiveRemediationReport
registryHealthApiConsistencyPrimitiveRemediationReport(
  RegistryHealthApiConsistencyActionPlan actionPlan,
) {
  final buckets = <String, _PrimitiveRemediationBucket>{};

  for (final item in actionPlan.items) {
    for (final fieldName in item.fieldOptions) {
      final primitiveKey =
          ChartApiFields.specFor(fieldName)?.category.name ?? 'unknown';
      buckets
          .putIfAbsent(
            primitiveKey,
            () => _PrimitiveRemediationBucket(
              primitiveKey: primitiveKey,
              primitiveLabel: _primitiveLabel(primitiveKey),
            ),
          )
          .add(fieldName: fieldName, item: item);
    }
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_comparePrimitiveRemediationItems);

  return RegistryHealthApiConsistencyPrimitiveRemediationReport(
    items:
        List<RegistryHealthApiConsistencyPrimitiveRemediationItem>.unmodifiable(
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

String registryHealthApiConsistencyPrimitiveChecklistText(
  RegistryHealthApiConsistencyPrimitiveRemediationReport report, {
  int primitiveLimit = 12,
}) {
  final lines = <String>[
    '# API Primitive Implementation Checklist',
    '',
    'Primitives: ${report.primitiveCount}',
    'Actions: ${report.actionCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];

  if (report.isClear) {
    lines.add('No primitive remediation targets.');
    return lines.join('\n').trimRight();
  }

  final safeLimit = primitiveLimit < 0 ? 0 : primitiveLimit;
  final exportedItems = report.visibleItems(limit: safeLimit);
  for (final item in exportedItems) {
    lines
      ..add('## ${item.primitiveLabel}')
      ..add('')
      ..add(
        '- [ ] ${item.fieldLabel} '
        '(${item.leadingPhaseLabel}, impact +${item.scoreImpactLabel})',
      )
      ..add('- Status: ${item.statusLabel}')
      ..add('- ${item.coverageLabel}')
      ..add('- Build: ${item.recipe.targetLabel}')
      ..add('- Implementation: ${item.recipe.implementationLabel}')
      ..add('- Test: ${item.recipe.testLabel}')
      ..add('- ${item.recipe.acceptanceLabel}')
      ..add('- Families: ${item.familyNames.join(', ')}')
      ..add('- Contracts: ${item.contractNames.join(', ')}')
      ..add('- Action: ${item.topAction}')
      ..add('');
  }

  if (report.primitiveCount > exportedItems.length) {
    lines.add(
      '+${report.primitiveCount - exportedItems.length} more primitives hidden.',
    );
  }

  return lines.join('\n').trimRight();
}

class _PrimitiveRemediationBucket {
  final String primitiveKey;
  final String primitiveLabel;
  final Map<String, RegistryHealthApiConsistencyActionItem> itemsById = {};
  final Set<String> fieldNames = {};
  final Set<String> concernLabels = {};
  final Set<String> familyNames = {};
  final Set<String> contractNames = {};
  final Set<String> chartExamples = {};
  final Map<String, int> chartCountByContract = {};

  _PrimitiveRemediationBucket({
    required this.primitiveKey,
    required this.primitiveLabel,
  });

  Iterable<RegistryHealthApiConsistencyActionItem> get items =>
      itemsById.values;

  void add({
    required String fieldName,
    required RegistryHealthApiConsistencyActionItem item,
  }) {
    itemsById.putIfAbsent(item.id, () => item);
    fieldNames.add(fieldName);
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

  RegistryHealthApiConsistencyPrimitiveRemediationItem toItem() {
    final sortedFields = fieldNames.toList()..sort();
    final sortedConcerns = concernLabels.toList()..sort();
    final sortedFamilies = familyNames.toList()..sort();
    final sortedContracts = contractNames.toList()..sort();
    final sortedExamples = chartExamples.toList()..sort();
    return RegistryHealthApiConsistencyPrimitiveRemediationItem(
      primitiveKey: primitiveKey,
      primitiveLabel: primitiveLabel,
      fieldNames: List<String>.unmodifiable(sortedFields),
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

int _comparePrimitiveRemediationItems(
  RegistryHealthApiConsistencyPrimitiveRemediationItem a,
  RegistryHealthApiConsistencyPrimitiveRemediationItem b,
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
  final fields = b.fieldCount.compareTo(a.fieldCount);
  if (fields != 0) return fields;
  return a.primitiveLabel.compareTo(b.primitiveLabel);
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

String _primitiveLabel(String key) {
  switch (key) {
    case 'accessibility':
      return 'Accessibility';
    case 'animation':
      return 'Animation';
    case 'display':
      return 'Display';
    case 'formatting':
      return 'Formatting';
    case 'interaction':
      return 'Interaction';
    case 'layout':
      return 'Layout';
    case 'runtime':
      return 'Runtime';
    case 'structure':
      return 'Structure';
    default:
      return 'Unknown';
  }
}
