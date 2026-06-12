import 'package:tenun/tenun_core.dart';

enum RegistryHealthApiConsistencyStatus { ready, warning, blocked }

enum RegistryHealthApiConsistencyConcernLevel {
  required,
  advisory,
  notApplicable,
}

enum RegistryHealthApiConsistencyConcernPriority { critical, high, medium }

class RegistryHealthApiConsistencyConcern {
  final String key;
  final String label;
  final List<String> fields;
  final String action;
  final RegistryHealthApiConsistencyConcernPriority priority;
  final List<ChartApiFamily> requiredFamilies;
  final List<ChartApiFamily> advisoryFamilies;

  const RegistryHealthApiConsistencyConcern({
    required this.key,
    required this.label,
    required this.fields,
    required this.action,
    this.priority = RegistryHealthApiConsistencyConcernPriority.medium,
    this.requiredFamilies = const [],
    this.advisoryFamilies = const [],
  });

  String get priorityLabel =>
      registryHealthApiConsistencyConcernPriorityLabel(priority);

  RegistryHealthApiConsistencyConcernLevel levelFor(ChartApiContract contract) {
    if (requiredFamilies.isEmpty && advisoryFamilies.isEmpty) {
      return RegistryHealthApiConsistencyConcernLevel.required;
    }
    if (requiredFamilies.contains(contract.family)) {
      return RegistryHealthApiConsistencyConcernLevel.required;
    }
    if (advisoryFamilies.contains(contract.family)) {
      return RegistryHealthApiConsistencyConcernLevel.advisory;
    }
    return RegistryHealthApiConsistencyConcernLevel.notApplicable;
  }

  bool isSupportedBy(ChartApiContract contract) {
    return fields.any(contract.supports);
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'fields': List<String>.from(fields),
    'action': action,
    'priority': priority.name,
    'priorityLabel': priorityLabel,
    if (requiredFamilies.isNotEmpty)
      'requiredFamilies': [for (final family in requiredFamilies) family.name],
    if (advisoryFamilies.isNotEmpty)
      'advisoryFamilies': [for (final family in advisoryFamilies) family.name],
  };
}

String registryHealthApiConsistencyConcernPriorityLabel(
  RegistryHealthApiConsistencyConcernPriority priority,
) {
  switch (priority) {
    case RegistryHealthApiConsistencyConcernPriority.critical:
      return 'Critical';
    case RegistryHealthApiConsistencyConcernPriority.high:
      return 'High';
    case RegistryHealthApiConsistencyConcernPriority.medium:
      return 'Medium';
  }
}

int registryHealthApiConsistencyConcernPriorityRank(
  RegistryHealthApiConsistencyConcernPriority priority,
) {
  switch (priority) {
    case RegistryHealthApiConsistencyConcernPriority.critical:
      return 2;
    case RegistryHealthApiConsistencyConcernPriority.high:
      return 1;
    case RegistryHealthApiConsistencyConcernPriority.medium:
      return 0;
  }
}

class RegistryHealthApiConsistencyRow {
  final String contractName;
  final String familyName;
  final int familyIndex;
  final int chartCount;
  final List<String> chartExamples;
  final List<RegistryHealthApiConsistencyConcern> supportedConcerns;
  final List<RegistryHealthApiConsistencyConcern> requiredMissingConcerns;
  final List<RegistryHealthApiConsistencyConcern> advisoryMissingConcerns;
  final List<RegistryHealthApiConsistencyConcern> notApplicableConcerns;

  const RegistryHealthApiConsistencyRow({
    required this.contractName,
    required this.familyName,
    required this.familyIndex,
    required this.chartCount,
    required this.chartExamples,
    required this.supportedConcerns,
    required this.requiredMissingConcerns,
    required this.advisoryMissingConcerns,
    required this.notApplicableConcerns,
  });

  int get supportedCount => supportedConcerns.length;
  int get requiredMissingCount => requiredMissingConcerns.length;
  int get advisoryMissingCount => advisoryMissingConcerns.length;
  List<RegistryHealthApiConsistencyConcern> get missingConcerns => [
    ...requiredMissingConcerns,
    ...advisoryMissingConcerns,
  ];
  int get missingCount => missingConcerns.length;

  RegistryHealthApiConsistencyStatus get status {
    if (requiredMissingCount > 0) {
      return RegistryHealthApiConsistencyStatus.blocked;
    }
    if (advisoryMissingCount > 0) {
      return RegistryHealthApiConsistencyStatus.warning;
    }
    return RegistryHealthApiConsistencyStatus.ready;
  }

  String get statusLabel => registryHealthApiConsistencyStatusLabel(status);

  bool get isReady => status == RegistryHealthApiConsistencyStatus.ready;

  Map<String, dynamic> toJson() => {
    'contractName': contractName,
    'familyName': familyName,
    'chartCount': chartCount,
    'chartExamples': List<String>.from(chartExamples),
    'status': status.name,
    'statusLabel': statusLabel,
    'supportedCount': supportedCount,
    'missingCount': missingCount,
    'requiredMissingCount': requiredMissingCount,
    'advisoryMissingCount': advisoryMissingCount,
    'notApplicableCount': notApplicableConcerns.length,
    'supportedConcerns': [
      for (final concern in supportedConcerns) concern.toJson(),
    ],
    'requiredMissingConcerns': [
      for (final concern in requiredMissingConcerns) concern.toJson(),
    ],
    'advisoryMissingConcerns': [
      for (final concern in advisoryMissingConcerns) concern.toJson(),
    ],
    'notApplicableConcerns': [
      for (final concern in notApplicableConcerns) concern.toJson(),
    ],
    'missingConcerns': [
      for (final concern in missingConcerns) concern.toJson(),
    ],
  };
}

class RegistryHealthApiConsistencyReport {
  final List<RegistryHealthApiConsistencyConcern> concerns;
  final List<RegistryHealthApiConsistencyRow> rows;

  const RegistryHealthApiConsistencyReport({
    required this.concerns,
    required this.rows,
  });

  int get concernCount => concerns.length;
  int get contractCount => rows.length;
  int get chartCount =>
      rows.fold<int>(0, (count, row) => count + row.chartCount);
  int get readyCount => rows.where((row) => row.isReady).length;
  int get warningCount => rows
      .where((row) => row.status == RegistryHealthApiConsistencyStatus.warning)
      .length;
  int get blockedCount => rows
      .where((row) => row.status == RegistryHealthApiConsistencyStatus.blocked)
      .length;
  int get requiredIssueCount =>
      rows.fold<int>(0, (count, row) => count + row.requiredMissingCount);
  int get advisoryIssueCount =>
      rows.fold<int>(0, (count, row) => count + row.advisoryMissingCount);
  int get issueCount =>
      rows.fold<int>(0, (count, row) => count + row.missingCount);

  RegistryHealthApiConsistencyStatus get status {
    if (blockedCount > 0) return RegistryHealthApiConsistencyStatus.blocked;
    if (warningCount > 0) return RegistryHealthApiConsistencyStatus.warning;
    return RegistryHealthApiConsistencyStatus.ready;
  }

  String get statusLabel => registryHealthApiConsistencyStatusLabel(status);

  bool get isReady => status == RegistryHealthApiConsistencyStatus.ready;

  List<RegistryHealthApiConsistencyRow> get attentionRows {
    final out = rows.where((row) => !row.isReady).toList();
    out.sort(_compareApiConsistencyRows);
    return out;
  }

  Map<String, dynamic> toJson({int rowLimit = 16}) {
    final safeLimit = rowLimit < 0 ? 0 : rowLimit;
    final exportedRows = attentionRows.take(safeLimit).toList(growable: false);
    return {
      'status': status.name,
      'statusLabel': statusLabel,
      'isReady': isReady,
      'concernCount': concernCount,
      'contractCount': contractCount,
      'chartCount': chartCount,
      'readyCount': readyCount,
      'warningCount': warningCount,
      'blockedCount': blockedCount,
      'issueCount': issueCount,
      'requiredIssueCount': requiredIssueCount,
      'advisoryIssueCount': advisoryIssueCount,
      'exportedRowCount': exportedRows.length,
      'hiddenRowCount': attentionRows.length - exportedRows.length,
      'concerns': [for (final concern in concerns) concern.toJson()],
      'rows': [for (final row in exportedRows) row.toJson()],
    };
  }
}

RegistryHealthApiConsistencyReport registryHealthApiConsistencyReport(
  Iterable<ChartCapabilities> capabilities, {
  int exampleLimit = 5,
}) {
  final grouped = <String, List<ChartCapabilities>>{};
  for (final capability in capabilities) {
    grouped
        .putIfAbsent(capability.apiContract.name, () => <ChartCapabilities>[])
        .add(capability);
  }

  final rows = <RegistryHealthApiConsistencyRow>[];
  for (final entry in grouped.entries) {
    final items = entry.value.toList()
      ..sort((a, b) => a.typeString.compareTo(b.typeString));
    final contract = items.first.apiContract;
    final supported = <RegistryHealthApiConsistencyConcern>[];
    final requiredMissing = <RegistryHealthApiConsistencyConcern>[];
    final advisoryMissing = <RegistryHealthApiConsistencyConcern>[];
    final notApplicable = <RegistryHealthApiConsistencyConcern>[];
    for (final concern in registryHealthApiConsistencyConcerns) {
      final level = concern.levelFor(contract);
      if (level == RegistryHealthApiConsistencyConcernLevel.notApplicable) {
        notApplicable.add(concern);
      } else if (concern.isSupportedBy(contract)) {
        supported.add(concern);
      } else if (level == RegistryHealthApiConsistencyConcernLevel.required) {
        requiredMissing.add(concern);
      } else {
        advisoryMissing.add(concern);
      }
    }

    rows.add(
      RegistryHealthApiConsistencyRow(
        contractName: contract.name,
        familyName: contract.family.name,
        familyIndex: contract.family.index,
        chartCount: items.length,
        chartExamples: _apiConsistencyExamples(items, exampleLimit),
        supportedConcerns:
            List<RegistryHealthApiConsistencyConcern>.unmodifiable(supported),
        requiredMissingConcerns:
            List<RegistryHealthApiConsistencyConcern>.unmodifiable(
              requiredMissing,
            ),
        advisoryMissingConcerns:
            List<RegistryHealthApiConsistencyConcern>.unmodifiable(
              advisoryMissing,
            ),
        notApplicableConcerns:
            List<RegistryHealthApiConsistencyConcern>.unmodifiable(
              notApplicable,
            ),
      ),
    );
  }

  rows.sort(_compareApiConsistencyRows);
  return RegistryHealthApiConsistencyReport(
    concerns: registryHealthApiConsistencyConcerns,
    rows: List<RegistryHealthApiConsistencyRow>.unmodifiable(rows),
  );
}

String registryHealthApiConsistencyStatusLabel(
  RegistryHealthApiConsistencyStatus status,
) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return 'Ready';
    case RegistryHealthApiConsistencyStatus.warning:
      return 'Warnings';
    case RegistryHealthApiConsistencyStatus.blocked:
      return 'Blocked';
  }
}

const registryHealthApiConsistencyConcerns = [
  RegistryHealthApiConsistencyConcern(
    key: 'tooltip',
    label: 'Tooltip',
    fields: [
      ChartApiFields.tooltip,
      ChartApiFields.showTooltip,
      ChartApiFields.tooltipBuilder,
    ],
    action: 'Expose a tooltip toggle or tooltip builder.',
    priority: RegistryHealthApiConsistencyConcernPriority.high,
  ),
  RegistryHealthApiConsistencyConcern(
    key: 'legend',
    label: 'Legend',
    fields: [ChartApiFields.legend, ChartApiFields.showLegend],
    action: 'Expose legend configuration or a legend visibility toggle.',
    priority: RegistryHealthApiConsistencyConcernPriority.high,
  ),
  RegistryHealthApiConsistencyConcern(
    key: 'theming',
    label: 'Theming',
    fields: [ChartApiFields.theme, ChartApiFields.palette],
    action: 'Expose theme or palette controls.',
    priority: RegistryHealthApiConsistencyConcernPriority.high,
  ),
  RegistryHealthApiConsistencyConcern(
    key: 'emptyState',
    label: 'Empty State',
    fields: [ChartApiFields.emptyBuilder],
    action: 'Expose an empty-state builder for no-data cases.',
    priority: RegistryHealthApiConsistencyConcernPriority.critical,
    requiredFamilies: _widgetApiFamilies,
    advisoryFamilies: [ChartApiFamily.optionConfig],
  ),
  RegistryHealthApiConsistencyConcern(
    key: 'semantics',
    label: 'Semantics',
    fields: [ChartApiFields.semanticLabel, ChartApiFields.excludeFromSemantics],
    action: 'Expose semantic label and semantics opt-out controls.',
    priority: RegistryHealthApiConsistencyConcernPriority.critical,
    requiredFamilies: _widgetApiFamilies,
    advisoryFamilies: [ChartApiFamily.optionConfig],
  ),
  RegistryHealthApiConsistencyConcern(
    key: 'animation',
    label: 'Animation',
    fields: [ChartApiFields.animationDuration, ChartApiFields.animationCurve],
    action: 'Expose animation duration and curve controls.',
    requiredFamilies: _widgetApiFamilies,
    advisoryFamilies: [ChartApiFamily.optionConfig],
  ),
  RegistryHealthApiConsistencyConcern(
    key: 'formatting',
    label: 'Formatting',
    fields: [
      ChartApiFields.valueFormatter,
      ChartApiFields.labelFormatter,
      ChartApiFields.axisLabelFormatter,
    ],
    action: 'Expose value, label, or axis label formatting hooks.',
    priority: RegistryHealthApiConsistencyConcernPriority.high,
    requiredFamilies: _widgetApiFamilies,
    advisoryFamilies: [ChartApiFamily.optionConfig],
  ),
  RegistryHealthApiConsistencyConcern(
    key: 'interaction',
    label: 'Interaction',
    fields: [
      ChartApiFields.onElementTap,
      ChartApiFields.onSelectionChanged,
      ChartApiFields.showActiveElement,
    ],
    action: 'Expose tap, selection, or active element controls.',
    priority: RegistryHealthApiConsistencyConcernPriority.critical,
    requiredFamilies: _widgetApiFamilies,
    advisoryFamilies: [ChartApiFamily.optionConfig],
  ),
];

const _widgetApiFamilies = [
  ChartApiFamily.simpleWidget,
  ChartApiFamily.cartesian,
  ChartApiFamily.polar,
  ChartApiFamily.statistical,
  ChartApiFamily.hierarchyFlow,
  ChartApiFamily.temporal,
  ChartApiFamily.financial,
  ChartApiFamily.densitySpatial,
];

List<String> _apiConsistencyExamples(
  List<ChartCapabilities> capabilities,
  int exampleLimit,
) {
  final safeLimit = exampleLimit < 0 ? 0 : exampleLimit;
  final labels = capabilities.map((item) => item.typeString).toList()..sort();
  if (labels.length <= safeLimit) return labels;
  return [...labels.take(safeLimit), '+${labels.length - safeLimit}'];
}

int _compareApiConsistencyRows(
  RegistryHealthApiConsistencyRow a,
  RegistryHealthApiConsistencyRow b,
) {
  final status = _apiConsistencyStatusRank(
    b.status,
  ).compareTo(_apiConsistencyStatusRank(a.status));
  if (status != 0) return status;
  final required = b.requiredMissingCount.compareTo(a.requiredMissingCount);
  if (required != 0) return required;
  final advisory = b.advisoryMissingCount.compareTo(a.advisoryMissingCount);
  if (advisory != 0) return advisory;
  final family = a.familyIndex.compareTo(b.familyIndex);
  if (family != 0) return family;
  return a.contractName.compareTo(b.contractName);
}

int _apiConsistencyStatusRank(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return 0;
    case RegistryHealthApiConsistencyStatus.warning:
      return 1;
    case RegistryHealthApiConsistencyStatus.blocked:
      return 2;
  }
}
