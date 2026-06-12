import 'registry_health_api_consistency_scorecard.dart';
import 'registry_health_api_consistency_source_plan.dart';

enum RegistryHealthApiConsistencySourceChecklistRisk { low, medium, high }

class RegistryHealthApiConsistencySourceChecklistItem {
  final int stageNumber;
  final RegistryHealthApiConsistencySourcePlanItem batch;
  final RegistryHealthApiConsistencySourceChecklistRisk risk;
  final List<String> checklistItems;
  final String reviewGateLabel;
  final String handoffLabel;

  const RegistryHealthApiConsistencySourceChecklistItem({
    required this.stageNumber,
    required this.batch,
    required this.risk,
    required this.checklistItems,
    required this.reviewGateLabel,
    required this.handoffLabel,
  });

  String get stageLabel => 'Stage $stageNumber';

  String get titleLabel => '$stageLabel: ${batch.areaLabel}';

  String get areaKey => batch.areaKey;

  String get areaLabel => batch.areaLabel;

  String get riskLabel =>
      registryHealthApiConsistencySourceChecklistRiskLabel(risk);

  String get phaseLabel => batch.leadingPhaseLabel;

  int get taskCount => checklistItems.length;

  int get sourceCount => batch.sourceCount;

  int get traceTouchCount => batch.traceTouchCount;

  int get actionTouchCount => batch.actionTouchCount;

  String get sourceTouchLabel =>
      '${_sourceChecklistCount(sourceCount, 'source', 'sources')}, '
      '${_sourceChecklistCount(traceTouchCount, 'trace touch', 'trace touches')}';

  String get actionTouchLabel =>
      _sourceChecklistCount(actionTouchCount, 'action touch', 'action touches');

  String get taskSummaryLabel {
    if (checklistItems.isEmpty) return 'No checklist tasks';
    final visibleTasks = checklistItems.take(2).join(' ');
    final hiddenCount = checklistItems.length - 2;
    return hiddenCount > 0
        ? '$visibleTasks +$hiddenCount more tasks'
        : visibleTasks;
  }

  Map<String, dynamic> toJson() => {
    'stageNumber': stageNumber,
    'stageLabel': stageLabel,
    'titleLabel': titleLabel,
    'area': areaKey,
    'areaLabel': areaLabel,
    'risk': risk.name,
    'riskLabel': riskLabel,
    'phase': batch.leadingPhase.name,
    'phaseLabel': phaseLabel,
    'sourceCount': sourceCount,
    'traceTouchCount': traceTouchCount,
    'actionTouchCount': actionTouchCount,
    'sourceTouchLabel': sourceTouchLabel,
    'actionTouchLabel': actionTouchLabel,
    'taskCount': taskCount,
    'taskSummaryLabel': taskSummaryLabel,
    'checklistItems': List<String>.from(checklistItems),
    'reviewGateLabel': reviewGateLabel,
    'handoffLabel': handoffLabel,
  };
}

class RegistryHealthApiConsistencySourceChecklistReport {
  final List<RegistryHealthApiConsistencySourceChecklistItem> items;
  final int sourceCount;
  final int traceTouchCount;
  final int actionCount;
  final int actionTouchCount;
  final double scoreImpactWeight;

  const RegistryHealthApiConsistencySourceChecklistReport({
    required this.items,
    required this.sourceCount,
    required this.traceTouchCount,
    required this.actionCount,
    required this.actionTouchCount,
    required this.scoreImpactWeight,
  });

  bool get isClear => items.isEmpty;

  int get stageCount => items.length;

  int get taskCount =>
      items.fold<int>(0, (total, item) => total + item.taskCount);

  int get highRiskCount =>
      _riskCount(RegistryHealthApiConsistencySourceChecklistRisk.high);

  int get mediumRiskCount =>
      _riskCount(RegistryHealthApiConsistencySourceChecklistRisk.medium);

  int get lowRiskCount =>
      _riskCount(RegistryHealthApiConsistencySourceChecklistRisk.low);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencySourceChecklistItem? get topStage {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencySourceChecklistItem> visibleItems({
    int limit = 6,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int stageLimit = 12}) {
    final safeLimit = stageLimit < 0 ? 0 : stageLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'stageCount': stageCount,
      'taskCount': taskCount,
      'sourceCount': sourceCount,
      'traceTouchCount': traceTouchCount,
      'actionCount': actionCount,
      'actionTouchCount': actionTouchCount,
      'highRiskCount': highRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'lowRiskCount': lowRiskCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topStageNumber': topStage?.stageNumber,
      'topArea': topStage?.areaKey,
      'topAreaLabel': topStage?.areaLabel,
      'topRisk': topStage?.risk.name,
      'topRiskLabel': topStage?.riskLabel,
      'exportedStageCount': exportedItems.length,
      'hiddenStageCount': items.length - exportedItems.length,
      'stages': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _riskCount(RegistryHealthApiConsistencySourceChecklistRisk risk) =>
      items.where((item) => item.risk == risk).length;
}

RegistryHealthApiConsistencySourceChecklistReport
registryHealthApiConsistencySourceChecklistReport(
  RegistryHealthApiConsistencySourcePlanReport sourcePlanReport,
) {
  final items = <RegistryHealthApiConsistencySourceChecklistItem>[];
  for (final entry in sourcePlanReport.items.asMap().entries) {
    final batch = entry.value;
    items.add(
      RegistryHealthApiConsistencySourceChecklistItem(
        stageNumber: entry.key + 1,
        batch: batch,
        risk: _sourceChecklistRisk(batch),
        checklistItems: _sourceChecklistTasks(batch),
        reviewGateLabel: _sourceChecklistReviewGate(batch.area),
        handoffLabel: _sourceChecklistHandoff(batch.area),
      ),
    );
  }

  return RegistryHealthApiConsistencySourceChecklistReport(
    items: List<RegistryHealthApiConsistencySourceChecklistItem>.unmodifiable(
      items,
    ),
    sourceCount: sourcePlanReport.sourceCount,
    traceTouchCount: sourcePlanReport.traceTouchCount,
    actionCount: sourcePlanReport.actionCount,
    actionTouchCount: sourcePlanReport.actionTouchCount,
    scoreImpactWeight: sourcePlanReport.scoreImpactWeight,
  );
}

String registryHealthApiConsistencySourceChecklistText(
  RegistryHealthApiConsistencySourceChecklistReport report, {
  int stageLimit = 12,
}) {
  final lines = <String>[
    '# API Source Checklist',
    '',
    'Stages: ${report.stageCount}',
    'Tasks: ${report.taskCount}',
    'Sources: ${report.sourceCount}',
    'Trace touches: ${report.traceTouchCount}',
    'Action touches: ${report.actionTouchCount}',
    'High risk: ${report.highRiskCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: stageLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.titleLabel}')
      ..add('')
      ..add('- Risk: ${item.riskLabel}, ${item.phaseLabel}')
      ..add('- Scope: ${item.sourceTouchLabel}, ${item.actionTouchLabel}')
      ..add('- Review gate: ${item.reviewGateLabel}')
      ..add('- Handoff: ${item.handoffLabel}');
    for (final task in item.checklistItems) {
      lines.add('- [ ] $task');
    }
    lines.add('');
  }

  final hiddenCount = report.stageCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more stages hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

String registryHealthApiConsistencySourceChecklistRiskLabel(
  RegistryHealthApiConsistencySourceChecklistRisk risk,
) {
  switch (risk) {
    case RegistryHealthApiConsistencySourceChecklistRisk.high:
      return 'High Risk';
    case RegistryHealthApiConsistencySourceChecklistRisk.medium:
      return 'Medium Risk';
    case RegistryHealthApiConsistencySourceChecklistRisk.low:
      return 'Low Risk';
  }
}

RegistryHealthApiConsistencySourceChecklistRisk _sourceChecklistRisk(
  RegistryHealthApiConsistencySourcePlanItem batch,
) {
  if (batch.blockedCount > 0 ||
      batch.traceTouchCount >= 24 ||
      batch.actionTouchCount >= 24) {
    return RegistryHealthApiConsistencySourceChecklistRisk.high;
  }
  if (batch.warningCount > 0 ||
      batch.traceTouchCount >= 10 ||
      batch.actionTouchCount >= 10 ||
      batch.sourceCount > 1) {
    return RegistryHealthApiConsistencySourceChecklistRisk.medium;
  }
  return RegistryHealthApiConsistencySourceChecklistRisk.low;
}

List<String> _sourceChecklistTasks(
  RegistryHealthApiConsistencySourcePlanItem batch,
) => List<String>.unmodifiable([
  batch.implementationLabel,
  'Update ${_sourceChecklistCount(batch.sourceCount, 'source', 'sources')} '
      'in ${batch.areaLabel}.',
  'Verify ${batch.kindSummaryLabel.toLowerCase()} across '
      '${_sourceChecklistCount(batch.traceTouchCount, 'trace touch', 'trace touches')}.',
  'Confirm ${_sourceChecklistCount(batch.actionTouchCount, 'action touch', 'action touches')} '
      'from the API action plan.',
  'Run analyzer, registry health widget tests, and JSON export checks.',
]);

String _sourceChecklistReviewGate(
  RegistryHealthApiConsistencySourcePlanArea area,
) {
  switch (area) {
    case RegistryHealthApiConsistencySourcePlanArea.coreContracts:
      return 'Contract fields compile and chart API coverage remains stable.';
    case RegistryHealthApiConsistencySourcePlanArea.configAdapters:
      return 'JSON and config parsing accept the normalized options.';
    case RegistryHealthApiConsistencySourcePlanArea.widgetApis:
      return 'Public widget constructors expose the same shared options.';
    case RegistryHealthApiConsistencySourcePlanArea.sharedPrimitives:
      return 'Common helpers cover empty, semantic, animation, formatting, and interaction hooks.';
    case RegistryHealthApiConsistencySourcePlanArea.chartFamilies:
      return 'Family renderers consume shared primitive behavior.';
    case RegistryHealthApiConsistencySourcePlanArea.registryMapping:
      return 'Registry routing still resolves every adopted chart type.';
    case RegistryHealthApiConsistencySourcePlanArea.other:
      return 'Uncategorized targets are mapped or explicitly deferred.';
  }
}

String _sourceChecklistHandoff(
  RegistryHealthApiConsistencySourcePlanArea area,
) {
  switch (area) {
    case RegistryHealthApiConsistencySourcePlanArea.coreContracts:
      return 'Handoff to config adapters after contract shape is stable.';
    case RegistryHealthApiConsistencySourcePlanArea.configAdapters:
      return 'Handoff to widgets after JSON adapters preserve the options.';
    case RegistryHealthApiConsistencySourcePlanArea.widgetApis:
      return 'Handoff to primitives after public APIs are aligned.';
    case RegistryHealthApiConsistencySourcePlanArea.sharedPrimitives:
      return 'Handoff to chart families after shared behavior is reusable.';
    case RegistryHealthApiConsistencySourcePlanArea.chartFamilies:
      return 'Handoff to registry mapping after families adopt the behavior.';
    case RegistryHealthApiConsistencySourcePlanArea.registryMapping:
      return 'Handoff to showcase validation after routing is aligned.';
    case RegistryHealthApiConsistencySourcePlanArea.other:
      return 'Handoff after ownership is clarified.';
  }
}

String _sourceChecklistCount(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';
