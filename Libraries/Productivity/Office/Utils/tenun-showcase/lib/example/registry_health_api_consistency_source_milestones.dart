import 'registry_health_api_consistency_scorecard.dart';
import 'registry_health_api_consistency_source_checklist.dart';
import 'registry_health_api_consistency_source_plan.dart';

enum RegistryHealthApiConsistencySourceMilestoneKind {
  foundation,
  publicSurface,
  adoptionRouting,
  triage,
}

class RegistryHealthApiConsistencySourceMilestoneItem {
  final RegistryHealthApiConsistencySourceMilestoneKind kind;
  final List<RegistryHealthApiConsistencySourceChecklistItem> stages;

  const RegistryHealthApiConsistencySourceMilestoneItem({
    required this.kind,
    required this.stages,
  });

  String get milestoneKey => kind.name;

  String get milestoneLabel => _sourceMilestoneLabel(kind);

  String get implementationLabel => _sourceMilestoneImplementationLabel(kind);

  String get reviewGateLabel => _sourceMilestoneReviewGateLabel(kind);

  String get handoffLabel => _sourceMilestoneHandoffLabel(kind);

  int get stageCount => stages.length;

  int get taskCount =>
      stages.fold<int>(0, (total, stage) => total + stage.taskCount);

  int get sourceCount =>
      stages.fold<int>(0, (total, stage) => total + stage.sourceCount);

  int get traceTouchCount =>
      stages.fold<int>(0, (total, stage) => total + stage.traceTouchCount);

  int get actionTouchCount =>
      stages.fold<int>(0, (total, stage) => total + stage.actionTouchCount);

  RegistryHealthApiConsistencySourceChecklistRisk get risk {
    if (stages.any(
      (stage) =>
          stage.risk == RegistryHealthApiConsistencySourceChecklistRisk.high,
    )) {
      return RegistryHealthApiConsistencySourceChecklistRisk.high;
    }
    if (stages.any(
      (stage) =>
          stage.risk == RegistryHealthApiConsistencySourceChecklistRisk.medium,
    )) {
      return RegistryHealthApiConsistencySourceChecklistRisk.medium;
    }
    return RegistryHealthApiConsistencySourceChecklistRisk.low;
  }

  String get riskLabel =>
      registryHealthApiConsistencySourceChecklistRiskLabel(risk);

  String get stageNumbersLabel {
    if (stages.isEmpty) return 'Stages: none';
    final numbers = stages.map((stage) => stage.stageNumber).join(', ');
    return stageCount == 1 ? 'Stage $numbers' : 'Stages $numbers';
  }

  String get scopeLabel =>
      '${_sourceMilestoneCount(stageCount, 'stage', 'stages')}, '
      '${_sourceMilestoneCount(sourceCount, 'source', 'sources')}, '
      '${_sourceMilestoneCount(traceTouchCount, 'trace touch', 'trace touches')}';

  String get actionTouchLabel =>
      _sourceMilestoneCount(actionTouchCount, 'action touch', 'action touches');

  String get stageSummaryLabel {
    if (stages.isEmpty) return 'Stages: none';
    final visibleStages = stages
        .take(3)
        .map((stage) => stage.titleLabel)
        .join('; ');
    final hiddenCount = stages.length - 3;
    return hiddenCount > 0
        ? 'Stages: $visibleStages; +$hiddenCount more'
        : 'Stages: $visibleStages';
  }

  Map<String, dynamic> toJson() => {
    'milestone': milestoneKey,
    'milestoneLabel': milestoneLabel,
    'implementationLabel': implementationLabel,
    'reviewGateLabel': reviewGateLabel,
    'handoffLabel': handoffLabel,
    'stageCount': stageCount,
    'taskCount': taskCount,
    'sourceCount': sourceCount,
    'traceTouchCount': traceTouchCount,
    'actionTouchCount': actionTouchCount,
    'risk': risk.name,
    'riskLabel': riskLabel,
    'stageNumbersLabel': stageNumbersLabel,
    'scopeLabel': scopeLabel,
    'actionTouchLabel': actionTouchLabel,
    'stageSummaryLabel': stageSummaryLabel,
    'stages': [for (final stage in stages) stage.toJson()],
  };
}

class RegistryHealthApiConsistencySourceMilestonesReport {
  final List<RegistryHealthApiConsistencySourceMilestoneItem> items;
  final int stageCount;
  final int taskCount;
  final int sourceCount;
  final int traceTouchCount;
  final int actionCount;
  final int actionTouchCount;
  final double scoreImpactWeight;

  const RegistryHealthApiConsistencySourceMilestonesReport({
    required this.items,
    required this.stageCount,
    required this.taskCount,
    required this.sourceCount,
    required this.traceTouchCount,
    required this.actionCount,
    required this.actionTouchCount,
    required this.scoreImpactWeight,
  });

  bool get isClear => items.isEmpty;

  int get milestoneCount => items.length;

  int get highRiskCount =>
      _riskCount(RegistryHealthApiConsistencySourceChecklistRisk.high);

  int get mediumRiskCount =>
      _riskCount(RegistryHealthApiConsistencySourceChecklistRisk.medium);

  int get lowRiskCount =>
      _riskCount(RegistryHealthApiConsistencySourceChecklistRisk.low);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencySourceMilestoneItem? get topMilestone {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencySourceMilestoneItem> visibleItems({
    int limit = 4,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int milestoneLimit = 8}) {
    final safeLimit = milestoneLimit < 0 ? 0 : milestoneLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'milestoneCount': milestoneCount,
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
      'topMilestone': topMilestone?.milestoneKey,
      'topMilestoneLabel': topMilestone?.milestoneLabel,
      'topRisk': topMilestone?.risk.name,
      'topRiskLabel': topMilestone?.riskLabel,
      'exportedMilestoneCount': exportedItems.length,
      'hiddenMilestoneCount': items.length - exportedItems.length,
      'milestones': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _riskCount(RegistryHealthApiConsistencySourceChecklistRisk risk) =>
      items.where((item) => item.risk == risk).length;
}

RegistryHealthApiConsistencySourceMilestonesReport
registryHealthApiConsistencySourceMilestonesReport(
  RegistryHealthApiConsistencySourceChecklistReport checklistReport,
) {
  final buckets =
      <
        RegistryHealthApiConsistencySourceMilestoneKind,
        _SourceMilestoneBucket
      >{};
  for (final stage in checklistReport.items) {
    final kind = _sourceMilestoneKindFor(stage.batch.area);
    buckets.putIfAbsent(kind, () => _SourceMilestoneBucket(kind)).add(stage);
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_compareSourceMilestoneItems);

  return RegistryHealthApiConsistencySourceMilestonesReport(
    items: List<RegistryHealthApiConsistencySourceMilestoneItem>.unmodifiable(
      items,
    ),
    stageCount: checklistReport.stageCount,
    taskCount: checklistReport.taskCount,
    sourceCount: checklistReport.sourceCount,
    traceTouchCount: checklistReport.traceTouchCount,
    actionCount: checklistReport.actionCount,
    actionTouchCount: checklistReport.actionTouchCount,
    scoreImpactWeight: checklistReport.scoreImpactWeight,
  );
}

String registryHealthApiConsistencySourceMilestonesText(
  RegistryHealthApiConsistencySourceMilestonesReport report, {
  int milestoneLimit = 8,
}) {
  final lines = <String>[
    '# API Source Milestones',
    '',
    'Milestones: ${report.milestoneCount}',
    'Stages: ${report.stageCount}',
    'Tasks: ${report.taskCount}',
    'Sources: ${report.sourceCount}',
    'Trace touches: ${report.traceTouchCount}',
    'Action touches: ${report.actionTouchCount}',
    'High risk: ${report.highRiskCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: milestoneLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.milestoneLabel}')
      ..add('')
      ..add('- ${item.implementationLabel}')
      ..add('- Risk: ${item.riskLabel}')
      ..add('- Scope: ${item.scopeLabel}, ${item.actionTouchLabel}')
      ..add('- ${item.stageSummaryLabel}')
      ..add('- Review gate: ${item.reviewGateLabel}')
      ..add('- Handoff: ${item.handoffLabel}')
      ..add('');
  }

  final hiddenCount = report.milestoneCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more milestones hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

class _SourceMilestoneBucket {
  final RegistryHealthApiConsistencySourceMilestoneKind kind;
  final List<RegistryHealthApiConsistencySourceChecklistItem> stages = [];

  _SourceMilestoneBucket(this.kind);

  void add(RegistryHealthApiConsistencySourceChecklistItem stage) {
    stages.add(stage);
  }

  RegistryHealthApiConsistencySourceMilestoneItem toItem() {
    stages.sort((a, b) => a.stageNumber.compareTo(b.stageNumber));
    return RegistryHealthApiConsistencySourceMilestoneItem(
      kind: kind,
      stages:
          List<RegistryHealthApiConsistencySourceChecklistItem>.unmodifiable(
            stages,
          ),
    );
  }
}

RegistryHealthApiConsistencySourceMilestoneKind _sourceMilestoneKindFor(
  RegistryHealthApiConsistencySourcePlanArea area,
) {
  switch (area) {
    case RegistryHealthApiConsistencySourcePlanArea.coreContracts:
    case RegistryHealthApiConsistencySourcePlanArea.configAdapters:
      return RegistryHealthApiConsistencySourceMilestoneKind.foundation;
    case RegistryHealthApiConsistencySourcePlanArea.widgetApis:
    case RegistryHealthApiConsistencySourcePlanArea.sharedPrimitives:
      return RegistryHealthApiConsistencySourceMilestoneKind.publicSurface;
    case RegistryHealthApiConsistencySourcePlanArea.chartFamilies:
    case RegistryHealthApiConsistencySourcePlanArea.registryMapping:
      return RegistryHealthApiConsistencySourceMilestoneKind.adoptionRouting;
    case RegistryHealthApiConsistencySourcePlanArea.other:
      return RegistryHealthApiConsistencySourceMilestoneKind.triage;
  }
}

String _sourceMilestoneLabel(
  RegistryHealthApiConsistencySourceMilestoneKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConsistencySourceMilestoneKind.foundation:
      return 'Foundation';
    case RegistryHealthApiConsistencySourceMilestoneKind.publicSurface:
      return 'Public Surface';
    case RegistryHealthApiConsistencySourceMilestoneKind.adoptionRouting:
      return 'Adoption & Routing';
    case RegistryHealthApiConsistencySourceMilestoneKind.triage:
      return 'Triage';
  }
}

String _sourceMilestoneImplementationLabel(
  RegistryHealthApiConsistencySourceMilestoneKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConsistencySourceMilestoneKind.foundation:
      return 'Stabilize contract shape and config adapters before public API rollout.';
    case RegistryHealthApiConsistencySourceMilestoneKind.publicSurface:
      return 'Expose shared behavior through widgets and reusable primitives.';
    case RegistryHealthApiConsistencySourceMilestoneKind.adoptionRouting:
      return 'Adopt shared API behavior inside chart families and registry routing.';
    case RegistryHealthApiConsistencySourceMilestoneKind.triage:
      return 'Classify uncategorized source work before scheduling.';
  }
}

String _sourceMilestoneReviewGateLabel(
  RegistryHealthApiConsistencySourceMilestoneKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConsistencySourceMilestoneKind.foundation:
      return 'Contracts and adapters pass analyzer, JSON, and registry health checks.';
    case RegistryHealthApiConsistencySourceMilestoneKind.publicSurface:
      return 'Public widgets and primitives expose matching options without duplicated behavior.';
    case RegistryHealthApiConsistencySourceMilestoneKind.adoptionRouting:
      return 'Chart families and registry mapping resolve every adopted API capability.';
    case RegistryHealthApiConsistencySourceMilestoneKind.triage:
      return 'Every uncategorized source has a named owner and target milestone.';
  }
}

String _sourceMilestoneHandoffLabel(
  RegistryHealthApiConsistencySourceMilestoneKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConsistencySourceMilestoneKind.foundation:
      return 'Move next to public surface only after contract and config shape settle.';
    case RegistryHealthApiConsistencySourceMilestoneKind.publicSurface:
      return 'Move next to adoption once reusable surface APIs are coherent.';
    case RegistryHealthApiConsistencySourceMilestoneKind.adoptionRouting:
      return 'Move next to showcase validation after chart families consume the APIs.';
    case RegistryHealthApiConsistencySourceMilestoneKind.triage:
      return 'Move into the right milestone after source ownership is clear.';
  }
}

int _compareSourceMilestoneItems(
  RegistryHealthApiConsistencySourceMilestoneItem a,
  RegistryHealthApiConsistencySourceMilestoneItem b,
) {
  final rank = _sourceMilestoneRank(
    a.kind,
  ).compareTo(_sourceMilestoneRank(b.kind));
  if (rank != 0) return rank;
  return a.milestoneLabel.compareTo(b.milestoneLabel);
}

int _sourceMilestoneRank(RegistryHealthApiConsistencySourceMilestoneKind kind) {
  switch (kind) {
    case RegistryHealthApiConsistencySourceMilestoneKind.foundation:
      return 0;
    case RegistryHealthApiConsistencySourceMilestoneKind.publicSurface:
      return 1;
    case RegistryHealthApiConsistencySourceMilestoneKind.adoptionRouting:
      return 2;
    case RegistryHealthApiConsistencySourceMilestoneKind.triage:
      return 3;
  }
}

String _sourceMilestoneCount(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';
