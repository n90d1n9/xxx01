import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_family_remediation.dart';
import 'registry_health_api_consistency_field_remediation.dart';
import 'registry_health_api_consistency_implementation_plan.dart';
import 'registry_health_api_consistency_primitive_remediation.dart';
import 'registry_health_api_consistency_scorecard.dart';

enum RegistryHealthApiConsistencyTraceKind { family, primitive, field }

class RegistryHealthApiConsistencySourceTarget {
  final String label;
  final String sourceFile;
  final String responsibility;

  const RegistryHealthApiConsistencySourceTarget({
    required this.label,
    required this.sourceFile,
    required this.responsibility,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'sourceFile': sourceFile,
    'responsibility': responsibility,
  };
}

class RegistryHealthApiConsistencyTraceItem {
  final RegistryHealthApiConsistencyTraceKind kind;
  final String targetId;
  final String title;
  final String recipeTargetLabel;
  final String acceptanceLabel;
  final List<RegistryHealthApiConsistencySourceTarget> sourceTargets;
  final List<String> chartExamples;
  final int actionCount;
  final double scoreImpactWeight;
  final RegistryHealthApiConsistencyStatus status;
  final RegistryHealthApiConsistencyActionPhase phase;

  const RegistryHealthApiConsistencyTraceItem({
    required this.kind,
    required this.targetId,
    required this.title,
    required this.recipeTargetLabel,
    required this.acceptanceLabel,
    required this.sourceTargets,
    required this.chartExamples,
    required this.actionCount,
    required this.scoreImpactWeight,
    required this.status,
    required this.phase,
  });

  String get kindLabel => _traceKindLabel(kind);

  String get statusLabel => registryHealthApiConsistencyStatusLabel(status);

  String get phaseLabel => registryHealthApiConsistencyActionPhaseLabel(phase);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencySourceTarget? get primarySourceTarget {
    if (sourceTargets.isEmpty) return null;
    return sourceTargets.first;
  }

  String get primarySourceFile =>
      primarySourceTarget?.sourceFile ?? 'Packages/tenun/lib';

  String get primarySourceLabel => 'Primary: $primarySourceFile';

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'kindLabel': kindLabel,
    'targetId': targetId,
    'title': title,
    'recipeTargetLabel': recipeTargetLabel,
    'acceptanceLabel': acceptanceLabel,
    'primarySourceFile': primarySourceFile,
    'primarySourceLabel': primarySourceLabel,
    'sourceTargets': [for (final target in sourceTargets) target.toJson()],
    'chartExamples': List<String>.from(chartExamples),
    'actionCount': actionCount,
    'scoreImpactWeight': scoreImpactWeight,
    'scoreImpactLabel': scoreImpactLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'phase': phase.name,
    'phaseLabel': phaseLabel,
  };
}

class RegistryHealthApiConsistencyTraceabilityReport {
  final List<RegistryHealthApiConsistencyTraceItem> items;
  final int actionCount;
  final double scoreImpactWeight;

  const RegistryHealthApiConsistencyTraceabilityReport({
    required this.items,
    required this.actionCount,
    required this.scoreImpactWeight,
  });

  bool get isClear => items.isEmpty;

  int get traceCount => items.length;

  int get familyTraceCount =>
      _kindCount(RegistryHealthApiConsistencyTraceKind.family);

  int get primitiveTraceCount =>
      _kindCount(RegistryHealthApiConsistencyTraceKind.primitive);

  int get fieldTraceCount =>
      _kindCount(RegistryHealthApiConsistencyTraceKind.field);

  String get scoreImpactLabel =>
      registryHealthApiConsistencyScoreWeightLabel(scoreImpactWeight);

  RegistryHealthApiConsistencyTraceItem? get topTrace {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencyTraceItem> visibleItems({int limit = 8}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int traceLimit = 24}) {
    final safeLimit = traceLimit < 0 ? 0 : traceLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'traceCount': traceCount,
      'familyTraceCount': familyTraceCount,
      'primitiveTraceCount': primitiveTraceCount,
      'fieldTraceCount': fieldTraceCount,
      'actionCount': actionCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topTargetId': topTrace?.targetId,
      'topPrimarySourceFile': topTrace?.primarySourceFile,
      'exportedTraceCount': exportedItems.length,
      'hiddenTraceCount': items.length - exportedItems.length,
      'traces': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _kindCount(RegistryHealthApiConsistencyTraceKind kind) {
    return items.where((item) => item.kind == kind).length;
  }
}

RegistryHealthApiConsistencyTraceabilityReport
registryHealthApiConsistencyTraceabilityReport(
  RegistryHealthApiConsistencyImplementationPlan plan,
) {
  final items = <RegistryHealthApiConsistencyTraceItem>[
    for (final item in plan.familyRemediation.items) _familyTraceItem(item),
    for (final item in plan.primitiveRemediation.items)
      _primitiveTraceItem(item),
    for (final item in plan.fieldRemediation.items) _fieldTraceItem(item),
  ];

  return RegistryHealthApiConsistencyTraceabilityReport(
    items: List<RegistryHealthApiConsistencyTraceItem>.unmodifiable(items),
    actionCount: plan.actionCount,
    scoreImpactWeight: plan.scoreImpactWeight,
  );
}

String registryHealthApiConsistencyTraceabilityText(
  RegistryHealthApiConsistencyTraceabilityReport report, {
  int traceLimit = 24,
}) {
  final lines = <String>[
    '# API Implementation Traceability',
    '',
    'Traces: ${report.traceCount}',
    'Actions: ${report.actionCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: traceLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.kindLabel} ${item.targetId}')
      ..add('')
      ..add('- Build: ${item.recipeTargetLabel}')
      ..add('- ${item.primarySourceLabel}')
      ..add(
        '- Status: ${item.statusLabel}, ${item.phaseLabel}, '
        'impact +${item.scoreImpactLabel}',
      )
      ..add('- ${item.acceptanceLabel}');
    for (final target in item.sourceTargets.skip(1)) {
      lines.add('- ${target.label}: ${target.sourceFile}');
    }
    lines.add('');
  }

  final hiddenCount = report.traceCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more traces hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

RegistryHealthApiConsistencyTraceItem _familyTraceItem(
  RegistryHealthApiConsistencyFamilyRemediationItem item,
) {
  return RegistryHealthApiConsistencyTraceItem(
    kind: RegistryHealthApiConsistencyTraceKind.family,
    targetId: item.familyName,
    title: item.familyName,
    recipeTargetLabel: item.recipe.targetLabel,
    acceptanceLabel: item.recipe.acceptanceLabel,
    sourceTargets: _familySourceTargets(item.familyName),
    chartExamples: item.chartExamples,
    actionCount: item.actionCount,
    scoreImpactWeight: item.scoreImpactWeight,
    status: item.status,
    phase: item.leadingPhase,
  );
}

RegistryHealthApiConsistencyTraceItem _primitiveTraceItem(
  RegistryHealthApiConsistencyPrimitiveRemediationItem item,
) {
  return RegistryHealthApiConsistencyTraceItem(
    kind: RegistryHealthApiConsistencyTraceKind.primitive,
    targetId: item.primitiveKey,
    title: item.primitiveLabel,
    recipeTargetLabel: item.recipe.targetLabel,
    acceptanceLabel: item.recipe.acceptanceLabel,
    sourceTargets: _primitiveSourceTargets(item.primitiveKey),
    chartExamples: item.chartExamples,
    actionCount: item.actionCount,
    scoreImpactWeight: item.scoreImpactWeight,
    status: item.status,
    phase: item.leadingPhase,
  );
}

RegistryHealthApiConsistencyTraceItem _fieldTraceItem(
  RegistryHealthApiConsistencyFieldRemediationItem item,
) {
  return RegistryHealthApiConsistencyTraceItem(
    kind: RegistryHealthApiConsistencyTraceKind.field,
    targetId: item.fieldName,
    title: item.fieldName,
    recipeTargetLabel: item.recipe.targetLabel,
    acceptanceLabel: item.recipe.acceptanceLabel,
    sourceTargets: _fieldSourceTargets(item),
    chartExamples: item.chartExamples,
    actionCount: item.actionCount,
    scoreImpactWeight: item.scoreImpactWeight,
    status: item.status,
    phase: item.leadingPhase,
  );
}

List<RegistryHealthApiConsistencySourceTarget> _familySourceTargets(
  String familyName,
) {
  return [
    ..._familySpecificTargets(familyName),
    const RegistryHealthApiConsistencySourceTarget(
      label: 'Contract catalog',
      sourceFile: 'Packages/tenun/lib/core/chart_api_contract.dart',
      responsibility: 'Shared API family field definitions.',
    ),
    const RegistryHealthApiConsistencySourceTarget(
      label: 'Family mapping',
      sourceFile: 'Packages/tenun/lib/registry/chart_api_contract_mapping.dart',
      responsibility: 'Chart type to API family routing.',
    ),
  ];
}

List<RegistryHealthApiConsistencySourceTarget> _familySpecificTargets(
  String familyName,
) {
  switch (familyName) {
    case 'optionConfig':
      return const [
        RegistryHealthApiConsistencySourceTarget(
          label: 'Config foundation',
          sourceFile: 'Packages/tenun/lib/core/base_config.dart',
          responsibility: 'Config and JSON-driven chart option plumbing.',
        ),
        RegistryHealthApiConsistencySourceTarget(
          label: 'Config helper',
          sourceFile: 'Packages/tenun/lib/core/utils/helper.dart',
          responsibility: 'JSON config to chart config routing.',
        ),
      ];
    case 'simpleWidget':
      return const [
        RegistryHealthApiConsistencySourceTarget(
          label: 'Widget APIs',
          sourceFile: 'Packages/tenun/lib/widget/',
          responsibility: 'Direct Flutter widget chart API surfaces.',
        ),
      ];
    case 'cartesian':
      return _chartDirectoryTargets('Cartesian charts', const [
        'bar',
        'line',
        'area',
        'scatter',
        'range',
        'combo',
        'sparkline',
      ]);
    case 'polar':
      return _chartDirectoryTargets('Polar charts', const [
        'pie',
        'radar',
        'radial',
        'gauge',
        'polar_bar',
        'polar_line',
      ]);
    case 'statistical':
      return _chartDirectoryTargets('Statistical charts', const [
        'box_plot',
        'histogram',
        'error_bar',
        'violin',
        'strip',
        'rigeline',
        'ai_ml',
        'parallel',
      ]);
    case 'hierarchyFlow':
      return _chartDirectoryTargets('Hierarchy and flow charts', const [
        'tree',
        'treemap',
        'sunburst',
        'sankey',
        'chord',
        'network',
        'alluvial',
      ]);
    case 'temporal':
      return _chartDirectoryTargets('Temporal charts', const [
        'timeline',
        'gantt',
        'event_strip',
        'milestone',
        's_curve',
      ]);
    case 'financial':
      return _chartDirectoryTargets('Financial charts', const [
        'trading',
        'candle',
      ]);
    case 'densitySpatial':
      return _chartDirectoryTargets('Density and spatial charts', const [
        'heatmap',
        'calendar',
        'matrix',
        'wordcloud',
        'choroplet',
        'tile_map',
        'contour',
        'density',
      ]);
    default:
      return const [
        RegistryHealthApiConsistencySourceTarget(
          label: 'Chart implementations',
          sourceFile: 'Packages/tenun/lib/charts/',
          responsibility: 'Family-specific chart implementation surfaces.',
        ),
      ];
  }
}

List<RegistryHealthApiConsistencySourceTarget> _chartDirectoryTargets(
  String label,
  List<String> directories,
) {
  return [
    for (final directory in directories)
      RegistryHealthApiConsistencySourceTarget(
        label: label,
        sourceFile: 'Packages/tenun/lib/charts/$directory/',
        responsibility: 'Family-specific chart implementation surface.',
      ),
  ];
}

List<RegistryHealthApiConsistencySourceTarget> _primitiveSourceTargets(
  String primitiveKey,
) {
  final label = _primitiveSourceLabel(primitiveKey);
  return [
    RegistryHealthApiConsistencySourceTarget(
      label: label,
      sourceFile: 'Packages/tenun/lib/charts/common/',
      responsibility: 'Shared chart primitive rendering and behavior helpers.',
    ),
    const RegistryHealthApiConsistencySourceTarget(
      label: 'Widget APIs',
      sourceFile: 'Packages/tenun/lib/widget/',
      responsibility: 'Direct widget constructor and callback surfaces.',
    ),
    const RegistryHealthApiConsistencySourceTarget(
      label: 'Contract catalog',
      sourceFile: 'Packages/tenun/lib/core/chart_api_contract.dart',
      responsibility: 'Shared API field membership and recommendations.',
    ),
  ];
}

String _primitiveSourceLabel(String primitiveKey) {
  switch (primitiveKey) {
    case 'accessibility':
      return 'Semantics primitive';
    case 'animation':
      return 'Animation primitive';
    case 'display':
      return 'Display primitive';
    case 'formatting':
      return 'Formatter primitive';
    case 'interaction':
      return 'Interaction primitive';
    default:
      return 'Shared primitive';
  }
}

List<RegistryHealthApiConsistencySourceTarget> _fieldSourceTargets(
  RegistryHealthApiConsistencyFieldRemediationItem item,
) {
  final adapterLabel = item.recipe.adapterLabel;
  final targets = <RegistryHealthApiConsistencySourceTarget>[
    const RegistryHealthApiConsistencySourceTarget(
      label: 'Field catalog',
      sourceFile: 'Packages/tenun/lib/core/chart_api_fields.dart',
      responsibility: 'Canonical field name, aliases, and field metadata.',
    ),
    const RegistryHealthApiConsistencySourceTarget(
      label: 'Contract catalog',
      sourceFile: 'Packages/tenun/lib/core/chart_api_contract.dart',
      responsibility: 'Supported and recommended API field membership.',
    ),
  ];

  if (adapterLabel.contains('widget')) {
    targets.add(
      const RegistryHealthApiConsistencySourceTarget(
        label: 'Widget adapter',
        sourceFile: 'Packages/tenun/lib/widget/',
        responsibility: 'Widget constructor and callback forwarding.',
      ),
    );
  }
  if (adapterLabel.contains('config')) {
    targets.addAll(const [
      RegistryHealthApiConsistencySourceTarget(
        label: 'Config adapter',
        sourceFile: 'Packages/tenun/lib/core/base_config.dart',
        responsibility: 'Config option defaults and parsing.',
      ),
      RegistryHealthApiConsistencySourceTarget(
        label: 'Config helper',
        sourceFile: 'Packages/tenun/lib/core/utils/helper.dart',
        responsibility: 'JSON config to typed config routing.',
      ),
    ]);
  }
  return List<RegistryHealthApiConsistencySourceTarget>.unmodifiable(targets);
}

String _traceKindLabel(RegistryHealthApiConsistencyTraceKind kind) {
  switch (kind) {
    case RegistryHealthApiConsistencyTraceKind.family:
      return 'Family';
    case RegistryHealthApiConsistencyTraceKind.primitive:
      return 'Primitive';
    case RegistryHealthApiConsistencyTraceKind.field:
      return 'Field';
  }
}
