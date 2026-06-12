import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_scorecard.dart';
import 'registry_health_api_consistency_traceability.dart';

class RegistryHealthApiConsistencySourceQueueItem {
  final String sourceFile;
  final List<String> labels;
  final List<String> responsibilities;
  final List<String> traceTargets;
  final List<String> chartExamples;
  final int familyTraceCount;
  final int primitiveTraceCount;
  final int fieldTraceCount;
  final int actionTouchCount;
  final int blockedCount;
  final int warningCount;
  final int readyCount;
  final int nowCount;
  final int nextCount;
  final int laterCount;

  const RegistryHealthApiConsistencySourceQueueItem({
    required this.sourceFile,
    required this.labels,
    required this.responsibilities,
    required this.traceTargets,
    required this.chartExamples,
    required this.familyTraceCount,
    required this.primitiveTraceCount,
    required this.fieldTraceCount,
    required this.actionTouchCount,
    required this.blockedCount,
    required this.warningCount,
    required this.readyCount,
    required this.nowCount,
    required this.nextCount,
    required this.laterCount,
  });

  int get traceCount =>
      familyTraceCount + primitiveTraceCount + fieldTraceCount;

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

  String get targetSummaryLabel {
    if (traceTargets.isEmpty) return 'Targets: none';
    final visibleTargets = traceTargets.take(4).join(', ');
    final hiddenCount = traceTargets.length - 4;
    return hiddenCount > 0
        ? 'Targets: $visibleTargets, +$hiddenCount more'
        : 'Targets: $visibleTargets';
  }

  String get responsibilityLabel {
    if (responsibilities.isEmpty) return 'No responsibility mapped';
    return responsibilities.first;
  }

  String get sourceLabel => 'Source: $sourceFile';

  Map<String, dynamic> toJson() => {
    'sourceFile': sourceFile,
    'sourceLabel': sourceLabel,
    'labels': List<String>.from(labels),
    'responsibilities': List<String>.from(responsibilities),
    'responsibilityLabel': responsibilityLabel,
    'traceTargets': List<String>.from(traceTargets),
    'chartExamples': List<String>.from(chartExamples),
    'traceCount': traceCount,
    'familyTraceCount': familyTraceCount,
    'primitiveTraceCount': primitiveTraceCount,
    'fieldTraceCount': fieldTraceCount,
    'kindSummaryLabel': kindSummaryLabel,
    'targetSummaryLabel': targetSummaryLabel,
    'actionTouchCount': actionTouchCount,
    'status': status.name,
    'statusLabel': statusLabel,
    'phase': leadingPhase.name,
    'phaseLabel': leadingPhaseLabel,
    'phaseCounts': {'now': nowCount, 'next': nextCount, 'later': laterCount},
  };
}

class RegistryHealthApiConsistencySourceQueueReport {
  final List<RegistryHealthApiConsistencySourceQueueItem> items;
  final int traceCount;
  final int actionCount;
  final double scoreImpactWeight;

  const RegistryHealthApiConsistencySourceQueueReport({
    required this.items,
    required this.traceCount,
    required this.actionCount,
    required this.scoreImpactWeight,
  });

  bool get isClear => items.isEmpty;

  int get sourceCount => items.length;

  int get traceTouchCount =>
      items.fold<int>(0, (total, item) => total + item.traceCount);

  int get actionTouchCount =>
      items.fold<int>(0, (total, item) => total + item.actionTouchCount);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencySourceQueueItem? get topSource {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencySourceQueueItem> visibleItems({
    int limit = 8,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int sourceLimit = 24}) {
    final safeLimit = sourceLimit < 0 ? 0 : sourceLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'sourceCount': sourceCount,
      'traceCount': traceCount,
      'traceTouchCount': traceTouchCount,
      'actionCount': actionCount,
      'actionTouchCount': actionTouchCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topSourceFile': topSource?.sourceFile,
      'topSourceTraceCount': topSource?.traceCount,
      'exportedSourceCount': exportedItems.length,
      'hiddenSourceCount': items.length - exportedItems.length,
      'sources': [for (final item in exportedItems) item.toJson()],
    };
  }
}

RegistryHealthApiConsistencySourceQueueReport
registryHealthApiConsistencySourceQueueReport(
  RegistryHealthApiConsistencyTraceabilityReport traceabilityReport,
) {
  final buckets = <String, _SourceQueueBucket>{};
  for (final trace in traceabilityReport.items) {
    for (final target in trace.sourceTargets) {
      buckets
          .putIfAbsent(
            target.sourceFile,
            () => _SourceQueueBucket(target.sourceFile),
          )
          .add(trace, target);
    }
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_compareSourceQueueItems);

  return RegistryHealthApiConsistencySourceQueueReport(
    items: List<RegistryHealthApiConsistencySourceQueueItem>.unmodifiable(
      items,
    ),
    traceCount: traceabilityReport.traceCount,
    actionCount: traceabilityReport.actionCount,
    scoreImpactWeight: traceabilityReport.scoreImpactWeight,
  );
}

String registryHealthApiConsistencySourceQueueText(
  RegistryHealthApiConsistencySourceQueueReport report, {
  int sourceLimit = 24,
}) {
  final lines = <String>[
    '# API Source Queue',
    '',
    'Sources: ${report.sourceCount}',
    'Traces: ${report.traceCount}',
    'Trace touches: ${report.traceTouchCount}',
    'Actions: ${report.actionCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: sourceLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.sourceFile}')
      ..add('')
      ..add('- ${item.kindSummaryLabel}')
      ..add('- ${item.targetSummaryLabel}')
      ..add('- ${item.responsibilityLabel}')
      ..add(
        '- Status: ${item.statusLabel}, ${item.leadingPhaseLabel}, '
        '${item.actionTouchCount} action touches',
      )
      ..add('');
  }

  final hiddenCount = report.sourceCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more sources hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

class _SourceQueueBucket {
  final String sourceFile;
  final Set<String> labels = {};
  final Set<String> responsibilities = {};
  final Set<String> traceTargets = {};
  final Set<String> chartExamples = {};
  final Set<String> traceKeys = {};
  int familyTraceCount = 0;
  int primitiveTraceCount = 0;
  int fieldTraceCount = 0;
  int actionTouchCount = 0;
  int blockedCount = 0;
  int warningCount = 0;
  int readyCount = 0;
  int nowCount = 0;
  int nextCount = 0;
  int laterCount = 0;

  _SourceQueueBucket(this.sourceFile);

  void add(
    RegistryHealthApiConsistencyTraceItem trace,
    RegistryHealthApiConsistencySourceTarget target,
  ) {
    labels.add(target.label);
    responsibilities.add(target.responsibility);
    final traceKey = '${trace.kind.name}:${trace.targetId}';
    if (!traceKeys.add(traceKey)) return;

    traceTargets.add(trace.targetId);
    chartExamples.addAll(trace.chartExamples);
    actionTouchCount += trace.actionCount;
    switch (trace.kind) {
      case RegistryHealthApiConsistencyTraceKind.family:
        familyTraceCount += 1;
      case RegistryHealthApiConsistencyTraceKind.primitive:
        primitiveTraceCount += 1;
      case RegistryHealthApiConsistencyTraceKind.field:
        fieldTraceCount += 1;
    }
    switch (trace.status) {
      case RegistryHealthApiConsistencyStatus.blocked:
        blockedCount += 1;
      case RegistryHealthApiConsistencyStatus.warning:
        warningCount += 1;
      case RegistryHealthApiConsistencyStatus.ready:
        readyCount += 1;
    }
    switch (trace.phase) {
      case RegistryHealthApiConsistencyActionPhase.now:
        nowCount += 1;
      case RegistryHealthApiConsistencyActionPhase.next:
        nextCount += 1;
      case RegistryHealthApiConsistencyActionPhase.later:
        laterCount += 1;
    }
  }

  RegistryHealthApiConsistencySourceQueueItem toItem() {
    final sortedLabels = labels.toList()..sort();
    final sortedResponsibilities = responsibilities.toList()..sort();
    final sortedTargets = traceTargets.toList()..sort();
    final sortedExamples = chartExamples.toList()..sort();
    return RegistryHealthApiConsistencySourceQueueItem(
      sourceFile: sourceFile,
      labels: List<String>.unmodifiable(sortedLabels),
      responsibilities: List<String>.unmodifiable(sortedResponsibilities),
      traceTargets: List<String>.unmodifiable(sortedTargets),
      chartExamples: List<String>.unmodifiable(sortedExamples),
      familyTraceCount: familyTraceCount,
      primitiveTraceCount: primitiveTraceCount,
      fieldTraceCount: fieldTraceCount,
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

int _compareSourceQueueItems(
  RegistryHealthApiConsistencySourceQueueItem a,
  RegistryHealthApiConsistencySourceQueueItem b,
) {
  final status = _statusRank(b.status).compareTo(_statusRank(a.status));
  if (status != 0) return status;
  final phase = _phaseRank(
    b.leadingPhase,
  ).compareTo(_phaseRank(a.leadingPhase));
  if (phase != 0) return phase;
  final traces = b.traceCount.compareTo(a.traceCount);
  if (traces != 0) return traces;
  final actions = b.actionTouchCount.compareTo(a.actionTouchCount);
  if (actions != 0) return actions;
  return a.sourceFile.compareTo(b.sourceFile);
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
