import 'package:tenun/tenun_core.dart';

import 'registry_health_api_consistency.dart';

enum RegistryHealthApiConformanceCaseStatus { pass, warning, fail, skipped }

class RegistryHealthApiConformanceCase {
  final String contractName;
  final String familyName;
  final int chartCount;
  final List<String> chartExamples;
  final RegistryHealthApiConsistencyConcern concern;
  final RegistryHealthApiConsistencyConcernLevel level;
  final RegistryHealthApiConformanceCaseStatus status;

  const RegistryHealthApiConformanceCase({
    required this.contractName,
    required this.familyName,
    required this.chartCount,
    required this.chartExamples,
    required this.concern,
    required this.level,
    required this.status,
  });

  String get id => '$contractName.${concern.key}';

  String get concernKey => concern.key;

  String get concernLabel => concern.label;

  String get statusLabel => registryHealthApiConformanceCaseStatusLabel(status);

  String get levelLabel => registryHealthApiConformanceLevelLabel(level);

  String get priorityLabel => concern.priorityLabel;

  String get titleLabel => '$contractName: $concernLabel';

  String get fieldSummaryLabel {
    final fields = concern.fields;
    if (fields.isEmpty) return 'Fields: none';
    final visibleFields = fields.take(3).join(', ');
    final hiddenCount = fields.length - 3;
    return hiddenCount > 0
        ? 'Fields: $visibleFields, +$hiddenCount more'
        : 'Fields: $visibleFields';
  }

  String get chartSummaryLabel {
    if (chartExamples.isEmpty) return 'Charts: none';
    final examples = chartExamples.take(3).join(', ');
    final hiddenCount = chartExamples.length - 3;
    return hiddenCount > 0
        ? 'Charts: $examples, +$hiddenCount more'
        : 'Charts: $examples';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'contractName': contractName,
    'familyName': familyName,
    'chartCount': chartCount,
    'chartExamples': List<String>.from(chartExamples),
    'chartSummaryLabel': chartSummaryLabel,
    'concernKey': concernKey,
    'concernLabel': concernLabel,
    'priority': concern.priority.name,
    'priorityLabel': priorityLabel,
    'level': level.name,
    'levelLabel': levelLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'fields': List<String>.from(concern.fields),
    'fieldSummaryLabel': fieldSummaryLabel,
    'action': concern.action,
  };
}

class RegistryHealthApiConformanceReport {
  final List<RegistryHealthApiConformanceCase> cases;
  final int contractCount;
  final int concernCount;
  final int chartCount;

  const RegistryHealthApiConformanceReport({
    required this.cases,
    required this.contractCount,
    required this.concernCount,
    required this.chartCount,
  });

  bool get isClear => cases.isEmpty;

  int get caseCount => cases.length;

  int get passCount =>
      _statusCount(RegistryHealthApiConformanceCaseStatus.pass);

  int get warningCount =>
      _statusCount(RegistryHealthApiConformanceCaseStatus.warning);

  int get failCount =>
      _statusCount(RegistryHealthApiConformanceCaseStatus.fail);

  int get skippedCount =>
      _statusCount(RegistryHealthApiConformanceCaseStatus.skipped);

  RegistryHealthApiConsistencyStatus get status {
    if (failCount > 0) return RegistryHealthApiConsistencyStatus.blocked;
    if (warningCount > 0) return RegistryHealthApiConsistencyStatus.warning;
    return RegistryHealthApiConsistencyStatus.ready;
  }

  String get statusLabel => registryHealthApiConsistencyStatusLabel(status);

  bool get isPassing => failCount == 0;

  bool get isReady => status == RegistryHealthApiConsistencyStatus.ready;

  RegistryHealthApiConformanceCase? get topCase {
    final cases = attentionCases;
    if (cases.isEmpty) return null;
    return cases.first;
  }

  List<RegistryHealthApiConformanceCase> get attentionCases {
    final out = cases
        .where(
          (item) =>
              item.status != RegistryHealthApiConformanceCaseStatus.pass &&
              item.status != RegistryHealthApiConformanceCaseStatus.skipped,
        )
        .toList();
    out.sort(_compareApiConformanceCases);
    return out;
  }

  List<RegistryHealthApiConformanceCase> visibleCases({int limit = 8}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return attentionCases.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int caseLimit = 16}) {
    final safeLimit = caseLimit < 0 ? 0 : caseLimit;
    final exportedCases = attentionCases
        .take(safeLimit)
        .toList(growable: false);
    return {
      'status': status.name,
      'statusLabel': statusLabel,
      'isPassing': isPassing,
      'isReady': isReady,
      'caseCount': caseCount,
      'contractCount': contractCount,
      'concernCount': concernCount,
      'chartCount': chartCount,
      'passCount': passCount,
      'warningCount': warningCount,
      'failCount': failCount,
      'skippedCount': skippedCount,
      'topCaseId': topCase?.id,
      'topCaseLabel': topCase?.titleLabel,
      'exportedCaseCount': exportedCases.length,
      'hiddenCaseCount': attentionCases.length - exportedCases.length,
      'cases': [for (final item in exportedCases) item.toJson()],
    };
  }

  int _statusCount(RegistryHealthApiConformanceCaseStatus status) =>
      cases.where((item) => item.status == status).length;
}

RegistryHealthApiConformanceReport registryHealthApiConformanceReport(
  RegistryHealthApiConsistencyReport consistencyReport,
) {
  final cases = <RegistryHealthApiConformanceCase>[];
  for (final row in consistencyReport.rows) {
    for (final concern in consistencyReport.concerns) {
      final level = _apiConformanceLevel(row, concern);
      cases.add(
        RegistryHealthApiConformanceCase(
          contractName: row.contractName,
          familyName: row.familyName,
          chartCount: row.chartCount,
          chartExamples: row.chartExamples,
          concern: concern,
          level: level,
          status: _apiConformanceStatus(row, concern, level),
        ),
      );
    }
  }

  return RegistryHealthApiConformanceReport(
    cases: List<RegistryHealthApiConformanceCase>.unmodifiable(cases),
    contractCount: consistencyReport.contractCount,
    concernCount: consistencyReport.concernCount,
    chartCount: consistencyReport.chartCount,
  );
}

String registryHealthApiConformanceText(
  RegistryHealthApiConformanceReport report, {
  int caseLimit = 16,
}) {
  final lines = <String>[
    '# API Conformance Harness',
    '',
    'Status: ${report.statusLabel}',
    'Cases: ${report.caseCount}',
    'Pass: ${report.passCount}',
    'Warnings: ${report.warningCount}',
    'Failures: ${report.failCount}',
    'Skipped: ${report.skippedCount}',
    '',
  ];
  final visibleCases = report.visibleCases(limit: caseLimit);
  for (final item in visibleCases) {
    lines
      ..add('## ${item.titleLabel}')
      ..add('')
      ..add('- Status: ${item.statusLabel}, ${item.levelLabel}')
      ..add('- ${item.fieldSummaryLabel}')
      ..add('- ${item.chartSummaryLabel}')
      ..add('- ${item.concern.action}')
      ..add('');
  }

  final hiddenCount = report.attentionCases.length - visibleCases.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more conformance cases hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

String registryHealthApiConformanceCaseStatusLabel(
  RegistryHealthApiConformanceCaseStatus status,
) {
  switch (status) {
    case RegistryHealthApiConformanceCaseStatus.pass:
      return 'Pass';
    case RegistryHealthApiConformanceCaseStatus.warning:
      return 'Warning';
    case RegistryHealthApiConformanceCaseStatus.fail:
      return 'Fail';
    case RegistryHealthApiConformanceCaseStatus.skipped:
      return 'Skipped';
  }
}

String registryHealthApiConformanceLevelLabel(
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

RegistryHealthApiConsistencyConcernLevel _apiConformanceLevel(
  RegistryHealthApiConsistencyRow row,
  RegistryHealthApiConsistencyConcern concern,
) {
  final contract = ChartApiContracts.byName(row.contractName);
  if (contract != null) {
    return concern.levelFor(contract);
  }
  if (row.advisoryMissingConcerns.contains(concern)) {
    return RegistryHealthApiConsistencyConcernLevel.advisory;
  }
  if (row.supportedConcerns.contains(concern) ||
      row.requiredMissingConcerns.contains(concern)) {
    return RegistryHealthApiConsistencyConcernLevel.required;
  }
  return RegistryHealthApiConsistencyConcernLevel.notApplicable;
}

RegistryHealthApiConformanceCaseStatus _apiConformanceStatus(
  RegistryHealthApiConsistencyRow row,
  RegistryHealthApiConsistencyConcern concern,
  RegistryHealthApiConsistencyConcernLevel level,
) {
  if (row.supportedConcerns.contains(concern)) {
    return RegistryHealthApiConformanceCaseStatus.pass;
  }
  switch (level) {
    case RegistryHealthApiConsistencyConcernLevel.required:
      return RegistryHealthApiConformanceCaseStatus.fail;
    case RegistryHealthApiConsistencyConcernLevel.advisory:
      return RegistryHealthApiConformanceCaseStatus.warning;
    case RegistryHealthApiConsistencyConcernLevel.notApplicable:
      return RegistryHealthApiConformanceCaseStatus.skipped;
  }
}

int _compareApiConformanceCases(
  RegistryHealthApiConformanceCase a,
  RegistryHealthApiConformanceCase b,
) {
  final status = _apiConformanceStatusRank(
    b.status,
  ).compareTo(_apiConformanceStatusRank(a.status));
  if (status != 0) return status;
  final priority =
      registryHealthApiConsistencyConcernPriorityRank(
        b.concern.priority,
      ).compareTo(
        registryHealthApiConsistencyConcernPriorityRank(a.concern.priority),
      );
  if (priority != 0) return priority;
  final contract = a.contractName.compareTo(b.contractName);
  if (contract != 0) return contract;
  return a.concernLabel.compareTo(b.concernLabel);
}

int _apiConformanceStatusRank(RegistryHealthApiConformanceCaseStatus status) {
  switch (status) {
    case RegistryHealthApiConformanceCaseStatus.pass:
      return 0;
    case RegistryHealthApiConformanceCaseStatus.skipped:
      return 1;
    case RegistryHealthApiConformanceCaseStatus.warning:
      return 2;
    case RegistryHealthApiConformanceCaseStatus.fail:
      return 3;
  }
}
