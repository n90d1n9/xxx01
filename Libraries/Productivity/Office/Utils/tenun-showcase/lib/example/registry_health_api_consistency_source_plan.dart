import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_scorecard.dart';
import 'registry_health_api_consistency_source_queue.dart';

enum RegistryHealthApiConsistencySourcePlanArea {
  coreContracts,
  configAdapters,
  widgetApis,
  sharedPrimitives,
  chartFamilies,
  registryMapping,
  other,
}

class RegistryHealthApiConsistencySourcePlanItem {
  final RegistryHealthApiConsistencySourcePlanArea area;
  final List<String> sourceFiles;
  final List<String> traceTargets;
  final List<String> responsibilities;
  final int familyTraceCount;
  final int primitiveTraceCount;
  final int fieldTraceCount;
  final int traceTouchCount;
  final int actionTouchCount;
  final int blockedCount;
  final int warningCount;
  final int readyCount;
  final int nowCount;
  final int nextCount;
  final int laterCount;

  const RegistryHealthApiConsistencySourcePlanItem({
    required this.area,
    required this.sourceFiles,
    required this.traceTargets,
    required this.responsibilities,
    required this.familyTraceCount,
    required this.primitiveTraceCount,
    required this.fieldTraceCount,
    required this.traceTouchCount,
    required this.actionTouchCount,
    required this.blockedCount,
    required this.warningCount,
    required this.readyCount,
    required this.nowCount,
    required this.nextCount,
    required this.laterCount,
  });

  String get areaKey => area.name;

  String get areaLabel => _sourcePlanAreaLabel(area);

  String get implementationLabel => _sourcePlanImplementationLabel(area);

  int get sourceCount => sourceFiles.length;

  RegistryHealthApiConsistencyStatus get status {
    if (blockedCount > 0) return RegistryHealthApiConsistencyStatus.blocked;
    if (warningCount > 0) return RegistryHealthApiConsistencyStatus.warning;
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

  String get kindSummaryLabel {
    final parts = <String>[];
    if (familyTraceCount > 0) parts.add('Family $familyTraceCount');
    if (primitiveTraceCount > 0) parts.add('Primitive $primitiveTraceCount');
    if (fieldTraceCount > 0) parts.add('Field $fieldTraceCount');
    return parts.isEmpty ? 'No trace kinds' : parts.join(', ');
  }

  String get sourceSummaryLabel {
    if (sourceFiles.isEmpty) return 'Sources: none';
    final visibleSources = sourceFiles.take(3).join(', ');
    final hiddenCount = sourceFiles.length - 3;
    return hiddenCount > 0
        ? 'Sources: $visibleSources, +$hiddenCount more'
        : 'Sources: $visibleSources';
  }

  String get targetSummaryLabel {
    if (traceTargets.isEmpty) return 'Targets: none';
    final visibleTargets = traceTargets.take(4).join(', ');
    final hiddenCount = traceTargets.length - 4;
    return hiddenCount > 0
        ? 'Targets: $visibleTargets, +$hiddenCount more'
        : 'Targets: $visibleTargets';
  }

  String get responsibilityLabel {
    if (responsibilities.isEmpty) return implementationLabel;
    return responsibilities.first;
  }

  Map<String, dynamic> toJson() => {
    'area': areaKey,
    'areaLabel': areaLabel,
    'implementationLabel': implementationLabel,
    'sourceCount': sourceCount,
    'sourceFiles': List<String>.from(sourceFiles),
    'sourceSummaryLabel': sourceSummaryLabel,
    'traceTargets': List<String>.from(traceTargets),
    'targetSummaryLabel': targetSummaryLabel,
    'responsibilities': List<String>.from(responsibilities),
    'responsibilityLabel': responsibilityLabel,
    'familyTraceCount': familyTraceCount,
    'primitiveTraceCount': primitiveTraceCount,
    'fieldTraceCount': fieldTraceCount,
    'kindSummaryLabel': kindSummaryLabel,
    'traceTouchCount': traceTouchCount,
    'actionTouchCount': actionTouchCount,
    'status': status.name,
    'statusLabel': statusLabel,
    'phase': leadingPhase.name,
    'phaseLabel': leadingPhaseLabel,
    'phaseCounts': {'now': nowCount, 'next': nextCount, 'later': laterCount},
  };
}

class RegistryHealthApiConsistencySourcePlanReport {
  final List<RegistryHealthApiConsistencySourcePlanItem> items;
  final int sourceCount;
  final int traceCount;
  final int actionCount;
  final double scoreImpactWeight;

  const RegistryHealthApiConsistencySourcePlanReport({
    required this.items,
    required this.sourceCount,
    required this.traceCount,
    required this.actionCount,
    required this.scoreImpactWeight,
  });

  bool get isClear => items.isEmpty;

  int get batchCount => items.length;

  int get traceTouchCount =>
      items.fold<int>(0, (total, item) => total + item.traceTouchCount);

  int get actionTouchCount =>
      items.fold<int>(0, (total, item) => total + item.actionTouchCount);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencySourcePlanItem? get topBatch {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencySourcePlanItem> visibleItems({
    int limit = 6,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int batchLimit = 12}) {
    final safeLimit = batchLimit < 0 ? 0 : batchLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'batchCount': batchCount,
      'sourceCount': sourceCount,
      'traceCount': traceCount,
      'traceTouchCount': traceTouchCount,
      'actionCount': actionCount,
      'actionTouchCount': actionTouchCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topArea': topBatch?.areaKey,
      'topAreaLabel': topBatch?.areaLabel,
      'exportedBatchCount': exportedItems.length,
      'hiddenBatchCount': items.length - exportedItems.length,
      'batches': [for (final item in exportedItems) item.toJson()],
    };
  }
}

RegistryHealthApiConsistencySourcePlanReport
registryHealthApiConsistencySourcePlanReport(
  RegistryHealthApiConsistencySourceQueueReport queueReport,
) {
  final buckets =
      <RegistryHealthApiConsistencySourcePlanArea, _SourcePlanBucket>{};
  for (final item in queueReport.items) {
    final area = _sourcePlanAreaFor(item.sourceFile);
    buckets.putIfAbsent(area, () => _SourcePlanBucket(area)).add(item);
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_compareSourcePlanItems);

  return RegistryHealthApiConsistencySourcePlanReport(
    items: List<RegistryHealthApiConsistencySourcePlanItem>.unmodifiable(items),
    sourceCount: queueReport.sourceCount,
    traceCount: queueReport.traceCount,
    actionCount: queueReport.actionCount,
    scoreImpactWeight: queueReport.scoreImpactWeight,
  );
}

String registryHealthApiConsistencySourcePlanText(
  RegistryHealthApiConsistencySourcePlanReport report, {
  int batchLimit = 12,
}) {
  final lines = <String>[
    '# API Source Plan',
    '',
    'Batches: ${report.batchCount}',
    'Sources: ${report.sourceCount}',
    'Trace touches: ${report.traceTouchCount}',
    'Actions: ${report.actionCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: batchLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.areaLabel}')
      ..add('')
      ..add('- ${item.implementationLabel}')
      ..add('- ${item.kindSummaryLabel}')
      ..add('- ${item.sourceSummaryLabel}')
      ..add('- ${item.targetSummaryLabel}')
      ..add(
        '- Status: ${item.statusLabel}, ${item.leadingPhaseLabel}, '
        '${item.actionTouchCount} action touches',
      )
      ..add('');
  }

  final hiddenCount = report.batchCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more batches hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

class _SourcePlanBucket {
  final RegistryHealthApiConsistencySourcePlanArea area;
  final Set<String> sourceFiles = {};
  final Set<String> traceTargets = {};
  final Set<String> responsibilities = {};
  int familyTraceCount = 0;
  int primitiveTraceCount = 0;
  int fieldTraceCount = 0;
  int traceTouchCount = 0;
  int actionTouchCount = 0;
  int blockedCount = 0;
  int warningCount = 0;
  int readyCount = 0;
  int nowCount = 0;
  int nextCount = 0;
  int laterCount = 0;

  _SourcePlanBucket(this.area);

  void add(RegistryHealthApiConsistencySourceQueueItem item) {
    sourceFiles.add(item.sourceFile);
    traceTargets.addAll(item.traceTargets);
    responsibilities.addAll(item.responsibilities);
    familyTraceCount += item.familyTraceCount;
    primitiveTraceCount += item.primitiveTraceCount;
    fieldTraceCount += item.fieldTraceCount;
    traceTouchCount += item.traceCount;
    actionTouchCount += item.actionTouchCount;
    blockedCount += item.blockedCount;
    warningCount += item.warningCount;
    readyCount += item.readyCount;
    nowCount += item.nowCount;
    nextCount += item.nextCount;
    laterCount += item.laterCount;
  }

  RegistryHealthApiConsistencySourcePlanItem toItem() {
    final sortedSources = sourceFiles.toList()..sort();
    final sortedTargets = traceTargets.toList()..sort();
    final sortedResponsibilities = responsibilities.toList()..sort();
    return RegistryHealthApiConsistencySourcePlanItem(
      area: area,
      sourceFiles: List<String>.unmodifiable(sortedSources),
      traceTargets: List<String>.unmodifiable(sortedTargets),
      responsibilities: List<String>.unmodifiable(sortedResponsibilities),
      familyTraceCount: familyTraceCount,
      primitiveTraceCount: primitiveTraceCount,
      fieldTraceCount: fieldTraceCount,
      traceTouchCount: traceTouchCount,
      actionTouchCount: actionTouchCount,
      blockedCount: blockedCount,
      warningCount: warningCount,
      readyCount: readyCount,
      nowCount: nowCount,
      nextCount: nextCount,
      laterCount: laterCount,
    );
  }
}

RegistryHealthApiConsistencySourcePlanArea _sourcePlanAreaFor(
  String sourceFile,
) {
  if (sourceFile.contains('/core/chart_api_contract.dart') ||
      sourceFile.contains('/core/chart_api_fields.dart')) {
    return RegistryHealthApiConsistencySourcePlanArea.coreContracts;
  }
  if (sourceFile.contains('/core/base_config.dart') ||
      sourceFile.contains('/core/utils/helper.dart')) {
    return RegistryHealthApiConsistencySourcePlanArea.configAdapters;
  }
  if (sourceFile.contains('/widget/')) {
    return RegistryHealthApiConsistencySourcePlanArea.widgetApis;
  }
  if (sourceFile.contains('/charts/common/')) {
    return RegistryHealthApiConsistencySourcePlanArea.sharedPrimitives;
  }
  if (sourceFile.contains('/charts/')) {
    return RegistryHealthApiConsistencySourcePlanArea.chartFamilies;
  }
  if (sourceFile.contains('/registry/')) {
    return RegistryHealthApiConsistencySourcePlanArea.registryMapping;
  }
  return RegistryHealthApiConsistencySourcePlanArea.other;
}

String _sourcePlanAreaLabel(RegistryHealthApiConsistencySourcePlanArea area) {
  switch (area) {
    case RegistryHealthApiConsistencySourcePlanArea.coreContracts:
      return 'Core Contracts';
    case RegistryHealthApiConsistencySourcePlanArea.configAdapters:
      return 'Config Adapters';
    case RegistryHealthApiConsistencySourcePlanArea.widgetApis:
      return 'Widget APIs';
    case RegistryHealthApiConsistencySourcePlanArea.sharedPrimitives:
      return 'Shared Primitives';
    case RegistryHealthApiConsistencySourcePlanArea.chartFamilies:
      return 'Chart Families';
    case RegistryHealthApiConsistencySourcePlanArea.registryMapping:
      return 'Registry Mapping';
    case RegistryHealthApiConsistencySourcePlanArea.other:
      return 'Other Sources';
  }
}

String _sourcePlanImplementationLabel(
  RegistryHealthApiConsistencySourcePlanArea area,
) {
  switch (area) {
    case RegistryHealthApiConsistencySourcePlanArea.coreContracts:
      return 'Normalize field specs and API contract membership first.';
    case RegistryHealthApiConsistencySourcePlanArea.configAdapters:
      return 'Thread shared options through config parsing and JSON adapters.';
    case RegistryHealthApiConsistencySourcePlanArea.widgetApis:
      return 'Expose shared options and callbacks in widget APIs.';
    case RegistryHealthApiConsistencySourcePlanArea.sharedPrimitives:
      return 'Centralize reusable behavior in common chart helpers.';
    case RegistryHealthApiConsistencySourcePlanArea.chartFamilies:
      return 'Apply shared primitives inside chart family implementations.';
    case RegistryHealthApiConsistencySourcePlanArea.registryMapping:
      return 'Keep chart type routing aligned with family adoption.';
    case RegistryHealthApiConsistencySourcePlanArea.other:
      return 'Review uncategorized source targets before implementation.';
  }
}

int _compareSourcePlanItems(
  RegistryHealthApiConsistencySourcePlanItem a,
  RegistryHealthApiConsistencySourcePlanItem b,
) {
  final status = _statusRank(b.status).compareTo(_statusRank(a.status));
  if (status != 0) return status;
  final phase = _phaseRank(
    b.leadingPhase,
  ).compareTo(_phaseRank(a.leadingPhase));
  if (phase != 0) return phase;
  final traces = b.traceTouchCount.compareTo(a.traceTouchCount);
  if (traces != 0) return traces;
  final actions = b.actionTouchCount.compareTo(a.actionTouchCount);
  if (actions != 0) return actions;
  return a.areaLabel.compareTo(b.areaLabel);
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

int _phaseRank(RegistryHealthApiConsistencyActionPhase phase) {
  switch (phase) {
    case RegistryHealthApiConsistencyActionPhase.later:
      return 0;
    case RegistryHealthApiConsistencyActionPhase.next:
      return 1;
    case RegistryHealthApiConsistencyActionPhase.now:
      return 2;
  }
}
