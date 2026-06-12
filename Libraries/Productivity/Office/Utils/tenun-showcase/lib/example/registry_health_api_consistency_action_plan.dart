import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_scorecard.dart';

enum RegistryHealthApiConsistencyActionPriority { critical, high, medium }

enum RegistryHealthApiConsistencyActionPhase { now, next, later }

class RegistryHealthApiConsistencyActionItem {
  final String id;
  final String contractName;
  final String familyName;
  final String concernKey;
  final String concernLabel;
  final List<String> fieldOptions;
  final int chartCount;
  final List<String> chartExamples;
  final RegistryHealthApiConsistencyConcernLevel level;
  final RegistryHealthApiConsistencyConcernPriority concernPriority;
  final RegistryHealthApiConsistencyActionPriority priority;
  final RegistryHealthApiConsistencyActionPhase phase;
  final double scoreImpactWeight;
  final String action;

  const RegistryHealthApiConsistencyActionItem({
    required this.id,
    required this.contractName,
    required this.familyName,
    required this.concernKey,
    required this.concernLabel,
    required this.fieldOptions,
    required this.chartCount,
    required this.chartExamples,
    this.level = RegistryHealthApiConsistencyConcernLevel.required,
    this.concernPriority = RegistryHealthApiConsistencyConcernPriority.medium,
    required this.priority,
    required this.phase,
    this.scoreImpactWeight = 0,
    required this.action,
  });

  String get priorityLabel =>
      registryHealthApiConsistencyActionPriorityLabel(priority);

  String get phaseLabel => registryHealthApiConsistencyActionPhaseLabel(phase);

  String get levelLabel => registryHealthApiConsistencyConcernLevelLabel(level);

  String get concernPriorityLabel =>
      registryHealthApiConsistencyConcernPriorityLabel(concernPriority);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  Map<String, dynamic> toJson() => {
    'id': id,
    'contractName': contractName,
    'familyName': familyName,
    'concernKey': concernKey,
    'concernLabel': concernLabel,
    'fieldOptions': List<String>.from(fieldOptions),
    'chartCount': chartCount,
    'chartExamples': List<String>.from(chartExamples),
    'level': level.name,
    'levelLabel': levelLabel,
    'concernPriority': concernPriority.name,
    'concernPriorityLabel': concernPriorityLabel,
    'priority': priority.name,
    'priorityLabel': priorityLabel,
    'phase': phase.name,
    'phaseLabel': phaseLabel,
    'scoreImpactWeight': scoreImpactWeight,
    'scoreImpactLabel': scoreImpactLabel,
    'action': action,
  };
}

class RegistryHealthApiConsistencyActionPlan {
  final List<RegistryHealthApiConsistencyActionItem> items;

  const RegistryHealthApiConsistencyActionPlan({required this.items});

  int get actionCount => items.length;
  int get criticalCount =>
      _countPriority(RegistryHealthApiConsistencyActionPriority.critical);
  int get highCount =>
      _countPriority(RegistryHealthApiConsistencyActionPriority.high);
  int get mediumCount =>
      _countPriority(RegistryHealthApiConsistencyActionPriority.medium);
  double get scoreImpactWeight =>
      items.fold<double>(0, (sum, item) => sum + item.scoreImpactWeight);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  bool get isClear => items.isEmpty;

  int phaseCount(RegistryHealthApiConsistencyActionPhase phase) {
    return items.where((item) => item.phase == phase).length;
  }

  List<RegistryHealthApiConsistencyActionItem> visibleItems({int limit = 8}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  List<RegistryHealthApiConsistencyActionItem> phaseItems(
    RegistryHealthApiConsistencyActionPhase phase, {
    int limit = 8,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items
        .where((item) => item.phase == phase)
        .take(safeLimit)
        .toList(growable: false);
  }

  Map<String, dynamic> toJson({int itemLimit = 16}) {
    final safeLimit = itemLimit < 0 ? 0 : itemLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'actionCount': actionCount,
      'criticalCount': criticalCount,
      'highCount': highCount,
      'mediumCount': mediumCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'phaseCounts': {
        for (final phase in RegistryHealthApiConsistencyActionPhase.values)
          phase.name: phaseCount(phase),
      },
      'exportedActionCount': exportedItems.length,
      'hiddenActionCount': items.length - exportedItems.length,
      'items': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _countPriority(RegistryHealthApiConsistencyActionPriority priority) {
    return items.where((item) => item.priority == priority).length;
  }
}

RegistryHealthApiConsistencyActionPlan registryHealthApiConsistencyActionPlan(
  RegistryHealthApiConsistencyReport report,
) {
  final items = <RegistryHealthApiConsistencyActionItem>[];
  for (final row in report.attentionRows) {
    for (final concern in row.missingConcerns) {
      final level = row.requiredMissingConcerns.contains(concern)
          ? RegistryHealthApiConsistencyConcernLevel.required
          : RegistryHealthApiConsistencyConcernLevel.advisory;
      final priority = _apiConsistencyActionPriority(row, concern, level);
      final scoreImpactWeight =
          registryHealthApiConsistencyConcernPenaltyWeight(concern, level);
      items.add(
        RegistryHealthApiConsistencyActionItem(
          id: '${row.contractName}.${concern.key}',
          contractName: row.contractName,
          familyName: row.familyName,
          concernKey: concern.key,
          concernLabel: concern.label,
          fieldOptions: concern.fields,
          chartCount: row.chartCount,
          chartExamples: row.chartExamples,
          level: level,
          concernPriority: concern.priority,
          priority: priority,
          phase: registryHealthApiConsistencyActionPhaseForPriority(priority),
          scoreImpactWeight: scoreImpactWeight,
          action: concern.action,
        ),
      );
    }
  }

  items.sort(_compareApiConsistencyActionItems);
  return RegistryHealthApiConsistencyActionPlan(
    items: List<RegistryHealthApiConsistencyActionItem>.unmodifiable(items),
  );
}

String registryHealthApiConsistencyActionPriorityLabel(
  RegistryHealthApiConsistencyActionPriority priority,
) {
  switch (priority) {
    case RegistryHealthApiConsistencyActionPriority.critical:
      return 'Critical';
    case RegistryHealthApiConsistencyActionPriority.high:
      return 'High';
    case RegistryHealthApiConsistencyActionPriority.medium:
      return 'Medium';
  }
}

String registryHealthApiConsistencyActionPhaseLabel(
  RegistryHealthApiConsistencyActionPhase phase,
) {
  switch (phase) {
    case RegistryHealthApiConsistencyActionPhase.now:
      return 'Now';
    case RegistryHealthApiConsistencyActionPhase.next:
      return 'Next';
    case RegistryHealthApiConsistencyActionPhase.later:
      return 'Later';
  }
}

String registryHealthApiConsistencyConcernLevelLabel(
  RegistryHealthApiConsistencyConcernLevel level,
) {
  switch (level) {
    case RegistryHealthApiConsistencyConcernLevel.required:
      return 'Required';
    case RegistryHealthApiConsistencyConcernLevel.advisory:
      return 'Advisory';
    case RegistryHealthApiConsistencyConcernLevel.notApplicable:
      return 'Not Applicable';
  }
}

RegistryHealthApiConsistencyActionPhase
registryHealthApiConsistencyActionPhaseForPriority(
  RegistryHealthApiConsistencyActionPriority priority,
) {
  switch (priority) {
    case RegistryHealthApiConsistencyActionPriority.critical:
      return RegistryHealthApiConsistencyActionPhase.now;
    case RegistryHealthApiConsistencyActionPriority.high:
      return RegistryHealthApiConsistencyActionPhase.next;
    case RegistryHealthApiConsistencyActionPriority.medium:
      return RegistryHealthApiConsistencyActionPhase.later;
  }
}

String registryHealthApiConsistencyActionChecklistText(
  RegistryHealthApiConsistencyActionPlan plan, {
  int itemLimit = 16,
}) {
  final lines = <String>[
    '# API Consistency Action Checklist',
    '',
    'Actions: ${plan.actionCount}',
    '',
  ];
  var exportedCount = 0;
  final safeLimit = itemLimit < 0 ? 0 : itemLimit;

  for (final phase in RegistryHealthApiConsistencyActionPhase.values) {
    final items = plan.phaseItems(phase, limit: safeLimit);
    if (items.isEmpty) continue;
    lines
      ..add('## ${registryHealthApiConsistencyActionPhaseLabel(phase)}')
      ..add('');
    for (final item in items) {
      exportedCount += 1;
      lines.add(
        '- [ ] ${item.contractName}: ${item.concernLabel} '
        '(impact +${item.scoreImpactLabel}) - ${item.action}',
      );
    }
    lines.add('');
  }

  if (plan.actionCount > exportedCount) {
    lines.add('+${plan.actionCount - exportedCount} more actions hidden.');
  }

  return lines.join('\n').trimRight();
}

RegistryHealthApiConsistencyActionPriority _apiConsistencyActionPriority(
  RegistryHealthApiConsistencyRow row,
  RegistryHealthApiConsistencyConcern concern,
  RegistryHealthApiConsistencyConcernLevel level,
) {
  if (level == RegistryHealthApiConsistencyConcernLevel.advisory) {
    return RegistryHealthApiConsistencyActionPriority.medium;
  }
  if (row.status == RegistryHealthApiConsistencyStatus.blocked &&
      concern.priority ==
          RegistryHealthApiConsistencyConcernPriority.critical) {
    return RegistryHealthApiConsistencyActionPriority.critical;
  }
  if (row.status == RegistryHealthApiConsistencyStatus.blocked ||
      concern.priority == RegistryHealthApiConsistencyConcernPriority.high) {
    return RegistryHealthApiConsistencyActionPriority.high;
  }
  return RegistryHealthApiConsistencyActionPriority.medium;
}

int _compareApiConsistencyActionItems(
  RegistryHealthApiConsistencyActionItem a,
  RegistryHealthApiConsistencyActionItem b,
) {
  final priority = _apiConsistencyPriorityRank(
    b.priority,
  ).compareTo(_apiConsistencyPriorityRank(a.priority));
  if (priority != 0) return priority;
  final impact = b.scoreImpactWeight.compareTo(a.scoreImpactWeight);
  if (impact != 0) return impact;
  final charts = b.chartCount.compareTo(a.chartCount);
  if (charts != 0) return charts;
  final concern =
      registryHealthApiConsistencyConcernPriorityRank(
        b.concernPriority,
      ).compareTo(
        registryHealthApiConsistencyConcernPriorityRank(a.concernPriority),
      );
  if (concern != 0) return concern;
  final contract = a.contractName.compareTo(b.contractName);
  if (contract != 0) return contract;
  return a.concernLabel.compareTo(b.concernLabel);
}

int _apiConsistencyPriorityRank(
  RegistryHealthApiConsistencyActionPriority priority,
) {
  switch (priority) {
    case RegistryHealthApiConsistencyActionPriority.critical:
      return 2;
    case RegistryHealthApiConsistencyActionPriority.high:
      return 1;
    case RegistryHealthApiConsistencyActionPriority.medium:
      return 0;
  }
}
