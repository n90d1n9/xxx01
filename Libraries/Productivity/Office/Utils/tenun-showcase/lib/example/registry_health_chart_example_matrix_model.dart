import 'package:tenun/tenun_core.dart';

import 'chart_sample_registry_audit.dart';
import 'chart_sample_source_audit.dart';
import 'chart_samples_registry.dart';

enum RegistryHealthChartExampleMatrixStatus {
  ready,
  missingSample,
  issue,
  unknown,
}

class RegistryHealthChartExampleMatrixRow {
  const RegistryHealthChartExampleMatrixRow({
    required this.typeString,
    required this.displayName,
    required this.dataShape,
    required this.bundleName,
    required this.bundleNames,
    required this.hasRegistryEntry,
    required this.sampleCount,
    required this.customCodeCount,
    required this.sourceCheckCount,
    required this.sampleIssueCount,
    required this.sourceIssueCount,
  });

  final String typeString;
  final String displayName;
  final String dataShape;
  final String bundleName;
  final List<String> bundleNames;
  final bool hasRegistryEntry;
  final int sampleCount;
  final int customCodeCount;
  final int sourceCheckCount;
  final int sampleIssueCount;
  final int sourceIssueCount;

  bool get hasFocusedSample => sampleCount > 0;

  int get issueCount => sampleIssueCount + sourceIssueCount;

  String get statusLabel =>
      registryHealthChartExampleMatrixRowStatusLabel(status);

  String get nextAction => registryHealthChartExampleMatrixRowActionLabel(this);

  int get priorityRank => registryHealthChartExampleMatrixRowPriorityRank(this);

  String get priorityLabel =>
      registryHealthChartExampleMatrixRowPriorityLabel(this);

  RegistryHealthChartExampleMatrixStatus get status {
    if (!hasRegistryEntry) {
      return RegistryHealthChartExampleMatrixStatus.unknown;
    }
    if (!hasFocusedSample) {
      return RegistryHealthChartExampleMatrixStatus.missingSample;
    }
    if (issueCount > 0) {
      return RegistryHealthChartExampleMatrixStatus.issue;
    }
    return RegistryHealthChartExampleMatrixStatus.ready;
  }

  Map<String, dynamic> toJson() => {
    'type': typeString,
    'displayName': displayName,
    'dataShape': dataShape,
    'bundleName': bundleName,
    'bundleNames': List<String>.from(bundleNames),
    'hasRegistryEntry': hasRegistryEntry,
    'sampleCount': sampleCount,
    'customCodeCount': customCodeCount,
    'sourceCheckCount': sourceCheckCount,
    'sampleIssueCount': sampleIssueCount,
    'sourceIssueCount': sourceIssueCount,
    'issueCount': issueCount,
    'status': status.name,
    'statusLabel': statusLabel,
    'nextAction': nextAction,
    'priorityRank': priorityRank,
    'priorityLabel': priorityLabel,
  };
}

class RegistryHealthChartExampleMatrixStatusSummary {
  const RegistryHealthChartExampleMatrixStatusSummary({
    required this.status,
    required this.count,
    required this.ratio,
  });

  final RegistryHealthChartExampleMatrixStatus status;
  final int count;
  final double ratio;

  String get statusLabel =>
      registryHealthChartExampleMatrixRowStatusLabel(status);

  String get bucketLabel =>
      registryHealthChartExampleMatrixStatusBucketLabel(status);

  String get ratioLabel => registryHealthChartExampleMatrixRatioLabel(ratio);

  bool get needsAttention =>
      count > 0 && status != RegistryHealthChartExampleMatrixStatus.ready;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'statusLabel': statusLabel,
    'bucketLabel': bucketLabel,
    'count': count,
    'ratio': ratio,
    'ratioLabel': ratioLabel,
    'needsAttention': needsAttention,
  };
}

class RegistryHealthChartExampleMatrixActionSummary {
  const RegistryHealthChartExampleMatrixActionSummary({
    required this.action,
    required this.status,
    required this.rowCount,
    required this.issueCount,
  });

  final String action;
  final RegistryHealthChartExampleMatrixStatus status;
  final int rowCount;
  final int issueCount;

  String get statusLabel =>
      registryHealthChartExampleMatrixRowStatusLabel(status);

  Map<String, dynamic> toJson() => {
    'action': action,
    'status': status.name,
    'statusLabel': statusLabel,
    'rowCount': rowCount,
    'issueCount': issueCount,
  };
}

class RegistryHealthChartExampleMatrixPrioritySummary {
  const RegistryHealthChartExampleMatrixPrioritySummary({
    required this.priorityRank,
    required this.priorityLabel,
    required this.rowCount,
    required this.readyCount,
    required this.attentionCount,
    required this.issueRowCount,
    required this.missingSampleCount,
    required this.unknownRowCount,
    required this.issueCount,
  });

  final int priorityRank;
  final String priorityLabel;
  final int rowCount;
  final int readyCount;
  final int attentionCount;
  final int issueRowCount;
  final int missingSampleCount;
  final int unknownRowCount;
  final int issueCount;

  bool get hasAttention => attentionCount > 0;

  Map<String, dynamic> toJson() => {
    'priorityRank': priorityRank,
    'priorityLabel': priorityLabel,
    'rowCount': rowCount,
    'readyCount': readyCount,
    'attentionCount': attentionCount,
    'issueRowCount': issueRowCount,
    'missingSampleCount': missingSampleCount,
    'unknownRowCount': unknownRowCount,
    'issueCount': issueCount,
  };
}

class RegistryHealthChartExampleMatrixWorkItem {
  const RegistryHealthChartExampleMatrixWorkItem({
    required this.rank,
    required this.typeString,
    required this.displayName,
    required this.dataShape,
    required this.bundleName,
    required this.status,
    required this.statusLabel,
    required this.priorityRank,
    required this.priorityLabel,
    required this.action,
    required this.sampleCount,
    required this.sourceCheckCount,
    required this.sampleIssueCount,
    required this.sourceIssueCount,
    required this.issueCount,
  });

  final int rank;
  final String typeString;
  final String displayName;
  final String dataShape;
  final String bundleName;
  final RegistryHealthChartExampleMatrixStatus status;
  final String statusLabel;
  final int priorityRank;
  final String priorityLabel;
  final String action;
  final int sampleCount;
  final int sourceCheckCount;
  final int sampleIssueCount;
  final int sourceIssueCount;
  final int issueCount;

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'type': typeString,
    'displayName': displayName,
    'dataShape': dataShape,
    'bundleName': bundleName,
    'status': status.name,
    'statusLabel': statusLabel,
    'priorityRank': priorityRank,
    'priorityLabel': priorityLabel,
    'action': action,
    'sampleCount': sampleCount,
    'sourceCheckCount': sourceCheckCount,
    'sampleIssueCount': sampleIssueCount,
    'sourceIssueCount': sourceIssueCount,
    'issueCount': issueCount,
  };
}

class RegistryHealthChartExampleMatrixReport {
  const RegistryHealthChartExampleMatrixReport({required this.rows});

  final List<RegistryHealthChartExampleMatrixRow> rows;

  int get rowCount => rows.length;

  int get readyCount =>
      _countStatus(RegistryHealthChartExampleMatrixStatus.ready);

  int get missingSampleCount =>
      _countStatus(RegistryHealthChartExampleMatrixStatus.missingSample);

  int get issueRowCount =>
      _countStatus(RegistryHealthChartExampleMatrixStatus.issue);

  int get unknownRowCount =>
      _countStatus(RegistryHealthChartExampleMatrixStatus.unknown);

  int get attentionCount => attentionRows.length;

  int get statusSummaryCount => statusSummaries.length;

  int get actionSummaryCount => actionSummaries.length;

  int get prioritySummaryCount => prioritySummaries.length;

  int get attentionPrioritySummaryCount => attentionPrioritySummaries.length;

  int get nextWorkItemCount => attentionRows.length;

  List<RegistryHealthChartExampleMatrixRow> get attentionRows {
    final out = rows
        .where(
          (row) => row.status != RegistryHealthChartExampleMatrixStatus.ready,
        )
        .toList(growable: false);
    return out..sort(_compareChartExampleMatrixAttentionRows);
  }

  List<RegistryHealthChartExampleMatrixActionSummary> get actionSummaries {
    final grouped = <String, _ActionSummaryAccumulator>{};
    for (final row in attentionRows) {
      final key = '${row.status.name}:${row.nextAction}';
      final accumulator = grouped.putIfAbsent(
        key,
        () => _ActionSummaryAccumulator(
          action: row.nextAction,
          status: row.status,
        ),
      );
      accumulator.add(row);
    }
    final summaries = grouped.values
        .map((accumulator) => accumulator.toSummary())
        .toList(growable: false);
    return summaries..sort(_compareActionSummaries);
  }

  List<RegistryHealthChartExampleMatrixPrioritySummary> get prioritySummaries {
    final grouped = <String, _PrioritySummaryAccumulator>{};
    for (final row in rows) {
      final key = '${row.priorityRank}:${row.priorityLabel}';
      final accumulator = grouped.putIfAbsent(
        key,
        () => _PrioritySummaryAccumulator(
          priorityRank: row.priorityRank,
          priorityLabel: row.priorityLabel,
        ),
      );
      accumulator.add(row);
    }
    final summaries = grouped.values
        .map((accumulator) => accumulator.toSummary())
        .toList(growable: false);
    return summaries..sort(_comparePrioritySummaries);
  }

  List<RegistryHealthChartExampleMatrixPrioritySummary>
  get attentionPrioritySummaries {
    return prioritySummaries
        .where((summary) => summary.hasAttention)
        .toList(growable: false);
  }

  List<RegistryHealthChartExampleMatrixWorkItem> get nextWorkItems {
    final out = <RegistryHealthChartExampleMatrixWorkItem>[];
    var rank = 1;
    for (final row in attentionRows) {
      out.add(_workItemForRow(rank, row));
      rank += 1;
    }
    return List<RegistryHealthChartExampleMatrixWorkItem>.unmodifiable(out);
  }

  Map<String, int> get statusCounts => {
    for (final status in RegistryHealthChartExampleMatrixStatus.values)
      status.name: _countStatus(status),
  };

  List<RegistryHealthChartExampleMatrixStatusSummary> get statusSummaries {
    return [
      for (final status in RegistryHealthChartExampleMatrixStatus.values)
        _statusSummary(status),
    ];
  }

  int get sampleCount =>
      rows.fold<int>(0, (count, row) => count + row.sampleCount);

  int get sourceCheckCount =>
      rows.fold<int>(0, (count, row) => count + row.sourceCheckCount);

  int get issueCount =>
      rows.fold<int>(0, (count, row) => count + row.issueCount);

  double get readinessRatio => _safeRatio(readyCount, rowCount);

  double get attentionRatio => _safeRatio(attentionCount, rowCount);

  String get readinessLabel =>
      registryHealthChartExampleMatrixRatioLabel(readinessRatio);

  String get attentionRatioLabel =>
      registryHealthChartExampleMatrixRatioLabel(attentionRatio);

  bool get isReady =>
      missingSampleCount == 0 && issueRowCount == 0 && unknownRowCount == 0;

  Map<String, dynamic> toJson({int nextWorkItemLimit = 12}) {
    final exportedNextWorkItems = registryHealthChartExampleMatrixNextWorkItems(
      this,
      limit: nextWorkItemLimit,
    );
    return {
      'rowCount': rowCount,
      'readyCount': readyCount,
      'missingSampleCount': missingSampleCount,
      'issueRowCount': issueRowCount,
      'unknownRowCount': unknownRowCount,
      'attentionCount': attentionCount,
      'statusSummaryCount': statusSummaryCount,
      'actionSummaryCount': actionSummaryCount,
      'prioritySummaryCount': prioritySummaryCount,
      'attentionPrioritySummaryCount': attentionPrioritySummaryCount,
      'nextWorkItemCount': nextWorkItemCount,
      'nextWorkItemsExportedCount': exportedNextWorkItems.length,
      'nextWorkItemsHiddenCount':
          nextWorkItemCount - exportedNextWorkItems.length,
      'statusCounts': statusCounts,
      'statusSummaries': statusSummaries
          .map((summary) => summary.toJson())
          .toList(growable: false),
      'sampleCount': sampleCount,
      'sourceCheckCount': sourceCheckCount,
      'issueCount': issueCount,
      'readinessRatio': readinessRatio,
      'readinessLabel': readinessLabel,
      'attentionRatio': attentionRatio,
      'attentionRatioLabel': attentionRatioLabel,
      'isReady': isReady,
      'actionSummaries': actionSummaries
          .map((summary) => summary.toJson())
          .toList(growable: false),
      'prioritySummaries': prioritySummaries
          .map((summary) => summary.toJson())
          .toList(growable: false),
      'attentionPrioritySummaries': attentionPrioritySummaries
          .map((summary) => summary.toJson())
          .toList(growable: false),
      'nextWorkItems': exportedNextWorkItems
          .map((item) => item.toJson())
          .toList(growable: false),
      'attentionRows': attentionRows
          .map((row) => row.toJson())
          .toList(growable: false),
      'rows': rows.map((row) => row.toJson()).toList(growable: false),
    };
  }

  int _countStatus(RegistryHealthChartExampleMatrixStatus status) {
    return rows.where((row) => row.status == status).length;
  }

  RegistryHealthChartExampleMatrixStatusSummary _statusSummary(
    RegistryHealthChartExampleMatrixStatus status,
  ) {
    final count = _countStatus(status);
    return RegistryHealthChartExampleMatrixStatusSummary(
      status: status,
      count: count,
      ratio: _safeRatio(count, rowCount),
    );
  }
}

RegistryHealthChartExampleMatrixReport registryHealthChartExampleMatrixReport({
  required ChartFamilyManifest manifest,
  required Iterable<ChartShowcaseFamily> families,
  required ChartSampleRegistryAuditReport sampleAudit,
  required ChartSampleSourceAuditReport sourceAudit,
}) {
  final sampleCounts = <String, int>{};
  final customCodeCounts = <String, int>{};
  final displayNames = <String, String>{};

  for (final family in families) {
    for (final sample in family.samples) {
      final type = sample.json['type'];
      if (type is! String || type.trim().isEmpty) continue;
      final key = normalizeChartTypeKey(type);
      sampleCounts[key] = (sampleCounts[key] ?? 0) + 1;
      displayNames.putIfAbsent(key, () => type.trim());
      final customCode = sample.code;
      if (customCode != null && customCode.trim().isNotEmpty) {
        customCodeCounts[key] = (customCodeCounts[key] ?? 0) + 1;
      }
    }
  }

  final sampleIssueCounts = _issueCountsByChartType(sampleAudit.issues);
  final sourceIssueCounts = _sourceIssueCountsByChartType(sourceAudit.issues);
  final keys = <String>{
    for (final entry in manifest.entries) entry.normalizedTypeKey,
    ...sampleCounts.keys,
    ...sampleIssueCounts.keys,
    ...sourceIssueCounts.keys,
  };

  final rows = <RegistryHealthChartExampleMatrixRow>[
    for (final key in keys)
      _chartExampleMatrixRow(
        key,
        manifest,
        displayNames,
        sampleCounts,
        customCodeCounts,
        sampleIssueCounts,
        sourceIssueCounts,
        sourceAudit.caseCount,
      ),
  ]..sort(_compareChartExampleMatrixRows);

  return RegistryHealthChartExampleMatrixReport(
    rows: List<RegistryHealthChartExampleMatrixRow>.unmodifiable(rows),
  );
}

RegistryHealthChartExampleMatrixReport
focusedRegistryHealthChartExampleMatrixReport({
  ChartFamilyManifest? manifest,
  ChartSampleRegistryAuditReport? sampleAudit,
  ChartSampleSourceAuditReport? sourceAudit,
}) {
  return registryHealthChartExampleMatrixReport(
    manifest: manifest ?? ChartFamilyManifests.available(),
    families: ChartSamplesRegistry.focusedFamilies,
    sampleAudit:
        sampleAudit ??
        auditFocusedChartSamples(
          requireRegisteredTypes: true,
          includeValidationWarnings: false,
        ),
    sourceAudit: sourceAudit ?? auditFocusedChartSampleSources(),
  );
}

String registryHealthChartExampleMatrixStatusLabel(
  RegistryHealthChartExampleMatrixReport report,
) {
  if (report.unknownRowCount > 0) return 'Unknown';
  if (report.issueRowCount > 0) return 'Issues';
  if (report.missingSampleCount > 0) return 'Gaps';
  return 'Ready';
}

String registryHealthChartExampleMatrixRatioLabel(double ratio) {
  if (!ratio.isFinite || ratio <= 0) return '0%';
  final percent = (ratio * 100).round().clamp(0, 100).toInt();
  return '$percent%';
}

String registryHealthChartExampleMatrixRowStatusLabel(
  RegistryHealthChartExampleMatrixStatus status,
) {
  return switch (status) {
    RegistryHealthChartExampleMatrixStatus.ready => 'Ready',
    RegistryHealthChartExampleMatrixStatus.missingSample => 'Gap',
    RegistryHealthChartExampleMatrixStatus.issue => 'Issue',
    RegistryHealthChartExampleMatrixStatus.unknown => 'Unknown',
  };
}

String registryHealthChartExampleMatrixStatusBucketLabel(
  RegistryHealthChartExampleMatrixStatus status,
) {
  return switch (status) {
    RegistryHealthChartExampleMatrixStatus.ready => 'Ready',
    RegistryHealthChartExampleMatrixStatus.missingSample => 'Gaps',
    RegistryHealthChartExampleMatrixStatus.issue => 'Issues',
    RegistryHealthChartExampleMatrixStatus.unknown => 'Unknown',
  };
}

String registryHealthChartExampleMatrixRowActionLabel(
  RegistryHealthChartExampleMatrixRow row,
) {
  return switch (row.status) {
    RegistryHealthChartExampleMatrixStatus.ready => 'Maintain focused sample',
    RegistryHealthChartExampleMatrixStatus.missingSample =>
      'Add focused showcase sample',
    RegistryHealthChartExampleMatrixStatus.unknown =>
      'Map chart type or rename sample',
    RegistryHealthChartExampleMatrixStatus.issue => _issueActionLabel(
      row.sampleIssueCount,
      row.sourceIssueCount,
    ),
  };
}

int registryHealthChartExampleMatrixRowPriorityRank(
  RegistryHealthChartExampleMatrixRow row,
) {
  if (!row.hasRegistryEntry) return 0;
  if (row.bundleNames.contains('core')) return 0;
  if (row.bundleNames.contains('business') ||
      row.bundleNames.contains('ai_ml')) {
    return 1;
  }
  if (row.bundleNames.contains('common')) return 2;
  return 3;
}

String registryHealthChartExampleMatrixRowPriorityLabel(
  RegistryHealthChartExampleMatrixRow row,
) {
  if (!row.hasRegistryEntry) return 'Unmapped';
  return switch (registryHealthChartExampleMatrixRowPriorityRank(row)) {
    0 => 'Core',
    1 => 'Domain',
    2 => 'Common',
    _ => 'Specialized',
  };
}

List<RegistryHealthChartExampleMatrixRow>
registryHealthChartExampleMatrixVisibleAttentionRows(
  RegistryHealthChartExampleMatrixReport report, {
  int limit = 8,
}) {
  return report.attentionRows.take(limit).toList(growable: false);
}

List<RegistryHealthChartExampleMatrixActionSummary>
registryHealthChartExampleMatrixVisibleActionSummaries(
  RegistryHealthChartExampleMatrixReport report, {
  int limit = 6,
}) {
  return report.actionSummaries.take(limit).toList(growable: false);
}

List<RegistryHealthChartExampleMatrixPrioritySummary>
registryHealthChartExampleMatrixVisiblePrioritySummaries(
  RegistryHealthChartExampleMatrixReport report, {
  int limit = 6,
}) {
  return report.attentionPrioritySummaries.take(limit).toList(growable: false);
}

List<RegistryHealthChartExampleMatrixWorkItem>
registryHealthChartExampleMatrixNextWorkItems(
  RegistryHealthChartExampleMatrixReport report, {
  int limit = 12,
}) {
  if (limit <= 0) {
    return const <RegistryHealthChartExampleMatrixWorkItem>[];
  }
  return report.nextWorkItems.take(limit).toList(growable: false);
}

double _safeRatio(int numerator, int denominator) {
  if (denominator <= 0) return 0;
  return numerator / denominator;
}

RegistryHealthChartExampleMatrixRow _chartExampleMatrixRow(
  String key,
  ChartFamilyManifest manifest,
  Map<String, String> displayNames,
  Map<String, int> sampleCounts,
  Map<String, int> customCodeCounts,
  Map<String, int> sampleIssueCounts,
  Map<String, int> sourceIssueCounts,
  int sourceCaseCount,
) {
  final entry = manifest.entries
      .where((entry) => entry.normalizedTypeKey == key)
      .firstOrNull;
  final sampleCount = sampleCounts[key] ?? 0;
  final typeString = entry?.typeString ?? displayNames[key] ?? key;
  return RegistryHealthChartExampleMatrixRow(
    typeString: typeString,
    displayName: entry?.displayName ?? displayNames[key] ?? typeString,
    dataShape: entry?.dataShape.name ?? 'unknown',
    bundleName: entry?.primaryBundleName ?? 'unknown',
    bundleNames: entry == null
        ? const <String>[]
        : List<String>.unmodifiable(entry.bundleNames),
    hasRegistryEntry: entry != null,
    sampleCount: sampleCount,
    customCodeCount: customCodeCounts[key] ?? 0,
    sourceCheckCount: sampleCount * sourceCaseCount,
    sampleIssueCount: sampleIssueCounts[key] ?? 0,
    sourceIssueCount: sourceIssueCounts[key] ?? 0,
  );
}

RegistryHealthChartExampleMatrixWorkItem _workItemForRow(
  int rank,
  RegistryHealthChartExampleMatrixRow row,
) {
  return RegistryHealthChartExampleMatrixWorkItem(
    rank: rank,
    typeString: row.typeString,
    displayName: row.displayName,
    dataShape: row.dataShape,
    bundleName: row.bundleName,
    status: row.status,
    statusLabel: row.statusLabel,
    priorityRank: row.priorityRank,
    priorityLabel: row.priorityLabel,
    action: row.nextAction,
    sampleCount: row.sampleCount,
    sourceCheckCount: row.sourceCheckCount,
    sampleIssueCount: row.sampleIssueCount,
    sourceIssueCount: row.sourceIssueCount,
    issueCount: row.issueCount,
  );
}

Map<String, int> _issueCountsByChartType(
  Iterable<ChartSampleRegistryAuditIssue> issues,
) {
  final out = <String, int>{};
  for (final issue in issues) {
    final chartType = issue.chartType;
    if (chartType == null || chartType.trim().isEmpty) continue;
    final key = normalizeChartTypeKey(chartType);
    out[key] = (out[key] ?? 0) + 1;
  }
  return out;
}

Map<String, int> _sourceIssueCountsByChartType(
  Iterable<ChartSampleSourceAuditIssue> issues,
) {
  final out = <String, int>{};
  for (final issue in issues) {
    final chartType = issue.chartType;
    if (chartType == null || chartType.trim().isEmpty) continue;
    final key = normalizeChartTypeKey(chartType);
    out[key] = (out[key] ?? 0) + 1;
  }
  return out;
}

int _compareChartExampleMatrixRows(
  RegistryHealthChartExampleMatrixRow a,
  RegistryHealthChartExampleMatrixRow b,
) {
  final status = _statusRank(a.status).compareTo(_statusRank(b.status));
  if (status != 0) return status;
  final priority = a.priorityRank.compareTo(b.priorityRank);
  if (priority != 0) return priority;
  return a.typeString.compareTo(b.typeString);
}

int _compareChartExampleMatrixAttentionRows(
  RegistryHealthChartExampleMatrixRow a,
  RegistryHealthChartExampleMatrixRow b,
) {
  final status = _statusRank(a.status).compareTo(_statusRank(b.status));
  if (status != 0) return status;
  final priority = a.priorityRank.compareTo(b.priorityRank);
  if (priority != 0) return priority;
  final issues = b.issueCount.compareTo(a.issueCount);
  if (issues != 0) return issues;
  final samples = b.sampleCount.compareTo(a.sampleCount);
  if (samples != 0) return samples;
  return a.typeString.compareTo(b.typeString);
}

int _statusRank(RegistryHealthChartExampleMatrixStatus status) {
  return switch (status) {
    RegistryHealthChartExampleMatrixStatus.issue => 0,
    RegistryHealthChartExampleMatrixStatus.unknown => 1,
    RegistryHealthChartExampleMatrixStatus.missingSample => 2,
    RegistryHealthChartExampleMatrixStatus.ready => 3,
  };
}

int _compareActionSummaries(
  RegistryHealthChartExampleMatrixActionSummary a,
  RegistryHealthChartExampleMatrixActionSummary b,
) {
  final status = _statusRank(a.status).compareTo(_statusRank(b.status));
  if (status != 0) return status;
  final rows = b.rowCount.compareTo(a.rowCount);
  if (rows != 0) return rows;
  final issues = b.issueCount.compareTo(a.issueCount);
  if (issues != 0) return issues;
  return a.action.compareTo(b.action);
}

int _comparePrioritySummaries(
  RegistryHealthChartExampleMatrixPrioritySummary a,
  RegistryHealthChartExampleMatrixPrioritySummary b,
) {
  final unknown = b.unknownRowCount.compareTo(a.unknownRowCount);
  if (unknown != 0) return unknown;
  final priority = a.priorityRank.compareTo(b.priorityRank);
  if (priority != 0) return priority;
  final issues = b.issueRowCount.compareTo(a.issueRowCount);
  if (issues != 0) return issues;
  final attention = b.attentionCount.compareTo(a.attentionCount);
  if (attention != 0) return attention;
  return a.priorityLabel.compareTo(b.priorityLabel);
}

String _issueActionLabel(int sampleIssueCount, int sourceIssueCount) {
  if (sampleIssueCount > 0 && sourceIssueCount > 0) {
    return 'Fix sample and source audit issues';
  }
  if (sampleIssueCount > 0) {
    return 'Fix sample audit issues';
  }
  return 'Fix source audit issues';
}

class _ActionSummaryAccumulator {
  _ActionSummaryAccumulator({required this.action, required this.status});

  final String action;
  final RegistryHealthChartExampleMatrixStatus status;
  var rowCount = 0;
  var issueCount = 0;

  void add(RegistryHealthChartExampleMatrixRow row) {
    rowCount += 1;
    issueCount += row.issueCount;
  }

  RegistryHealthChartExampleMatrixActionSummary toSummary() {
    return RegistryHealthChartExampleMatrixActionSummary(
      action: action,
      status: status,
      rowCount: rowCount,
      issueCount: issueCount,
    );
  }
}

class _PrioritySummaryAccumulator {
  _PrioritySummaryAccumulator({
    required this.priorityRank,
    required this.priorityLabel,
  });

  final int priorityRank;
  final String priorityLabel;
  var rowCount = 0;
  var readyCount = 0;
  var issueRowCount = 0;
  var missingSampleCount = 0;
  var unknownRowCount = 0;
  var issueCount = 0;

  int get attentionCount =>
      issueRowCount + missingSampleCount + unknownRowCount;

  void add(RegistryHealthChartExampleMatrixRow row) {
    rowCount += 1;
    issueCount += row.issueCount;
    switch (row.status) {
      case RegistryHealthChartExampleMatrixStatus.ready:
        readyCount += 1;
      case RegistryHealthChartExampleMatrixStatus.issue:
        issueRowCount += 1;
      case RegistryHealthChartExampleMatrixStatus.missingSample:
        missingSampleCount += 1;
      case RegistryHealthChartExampleMatrixStatus.unknown:
        unknownRowCount += 1;
    }
  }

  RegistryHealthChartExampleMatrixPrioritySummary toSummary() {
    return RegistryHealthChartExampleMatrixPrioritySummary(
      priorityRank: priorityRank,
      priorityLabel: priorityLabel,
      rowCount: rowCount,
      readyCount: readyCount,
      attentionCount: attentionCount,
      issueRowCount: issueRowCount,
      missingSampleCount: missingSampleCount,
      unknownRowCount: unknownRowCount,
      issueCount: issueCount,
    );
  }
}
