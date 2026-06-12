import 'package:tenun/tenun_core.dart';

import 'chart_sample_registry_audit.dart';
import 'chart_sample_source_audit.dart';
import 'registry_health_api_consistency.dart';
import 'registry_health_chart_example_matrix.dart';
import 'registry_health_showcase_naming.dart';
import 'registry_health_showcase_rename_plan.dart';
import 'registry_health_showcase_source_map_audit.dart';
import 'registry_health_showcase_thresholds.dart';
import 'simple_charts_showcase_source_audit.dart';

enum RegistryHealthReadinessStatus { ready, warning, blocked }

class RegistryHealthReadinessGate {
  final String key;
  final String label;
  final RegistryHealthReadinessStatus status;
  final String detail;
  final int issueCount;
  final String action;

  const RegistryHealthReadinessGate({
    required this.key,
    required this.label,
    required this.status,
    required this.detail,
    required this.issueCount,
    required this.action,
  });

  bool get needsAttention => status != RegistryHealthReadinessStatus.ready;

  String get statusLabel => registryHealthReadinessStatusLabel(status);

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'status': status.name,
    'statusLabel': statusLabel,
    'detail': detail,
    'issueCount': issueCount,
    'action': action,
    'needsAttention': needsAttention,
  };
}

class RegistryHealthReadinessReport {
  final List<RegistryHealthReadinessGate> gates;

  const RegistryHealthReadinessReport({required this.gates});

  int get gateCount => gates.length;
  int get readyCount => _count(RegistryHealthReadinessStatus.ready);
  int get warningCount => _count(RegistryHealthReadinessStatus.warning);
  int get blockedCount => _count(RegistryHealthReadinessStatus.blocked);
  int get issueCount =>
      gates.fold<int>(0, (count, gate) => count + gate.issueCount);

  bool get isReady => status == RegistryHealthReadinessStatus.ready;

  RegistryHealthReadinessStatus get status {
    if (blockedCount > 0) return RegistryHealthReadinessStatus.blocked;
    if (warningCount > 0) return RegistryHealthReadinessStatus.warning;
    return RegistryHealthReadinessStatus.ready;
  }

  String get statusLabel => registryHealthReadinessStatusLabel(status);

  List<RegistryHealthReadinessGate> get attentionGates {
    final out = gates.where((gate) => gate.needsAttention).toList();
    out.sort(_compareReadinessGates);
    return out;
  }

  List<RegistryHealthReadinessGate> visibleGates({int limit = 8}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return attentionGates.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int gateLimit = 16}) {
    final safeLimit = gateLimit < 0 ? 0 : gateLimit;
    final exportedGates = attentionGates.take(safeLimit).toList();
    return {
      'status': status.name,
      'statusLabel': statusLabel,
      'isReady': isReady,
      'gateCount': gateCount,
      'readyCount': readyCount,
      'warningCount': warningCount,
      'blockedCount': blockedCount,
      'issueCount': issueCount,
      'exportedGateCount': exportedGates.length,
      'hiddenGateCount': attentionGates.length - exportedGates.length,
      'gates': [for (final gate in gates) gate.toJson()],
      'attentionGates': [for (final gate in exportedGates) gate.toJson()],
    };
  }

  int _count(RegistryHealthReadinessStatus status) {
    return gates.where((gate) => gate.status == status).length;
  }
}

RegistryHealthReadinessReport registryHealthReadinessReport({
  required ChartRegistryHealthReport registryReport,
  required RegistryHealthShowcaseThresholdReport thresholdReport,
  required RegistryHealthShowcaseNamingReport namingReport,
  required RegistryHealthShowcaseRenamePlanReport renamePlanReport,
  required ChartSampleRegistryAuditReport sampleAudit,
  required ChartSampleSourceAuditReport sourceAudit,
  required SimpleChartSourceAuditReport simpleSourceAudit,
  required RegistryHealthChartExampleMatrixReport chartExampleMatrix,
  RegistryHealthApiConsistencyReport? apiConsistencyReport,
  RegistryHealthShowcaseSourceMapAuditReport? sourceMapAudit,
  Object? sourceMapError,
  bool sourceMapLoading = false,
}) {
  final apiConsistency =
      apiConsistencyReport ??
      registryHealthApiConsistencyReport(registryReport.capabilities);
  return RegistryHealthReadinessReport(
    gates: List<RegistryHealthReadinessGate>.unmodifiable([
      _registryGate(registryReport),
      _coverageGate(thresholdReport),
      _namingGate(namingReport),
      _renamePlanGate(renamePlanReport),
      _sampleGate(sampleAudit),
      _sourceGate(sourceAudit),
      _simpleSourceGate(simpleSourceAudit),
      _exampleMatrixGate(chartExampleMatrix),
      _apiConsistencyGate(apiConsistency),
      _sourceMapGate(
        sourceMapAudit: sourceMapAudit,
        sourceMapError: sourceMapError,
        sourceMapLoading: sourceMapLoading,
      ),
    ]),
  );
}

String registryHealthReadinessStatusLabel(
  RegistryHealthReadinessStatus status,
) {
  switch (status) {
    case RegistryHealthReadinessStatus.ready:
      return 'Ready';
    case RegistryHealthReadinessStatus.warning:
      return 'Warnings';
    case RegistryHealthReadinessStatus.blocked:
      return 'Blocked';
  }
}

List<RegistryHealthReadinessGate> registryHealthReadinessVisibleGates(
  RegistryHealthReadinessReport report, {
  int limit = 8,
}) {
  return report.visibleGates(limit: limit);
}

Map<String, dynamic> registryHealthReadinessJson(
  RegistryHealthReadinessReport report, {
  int gateLimit = 16,
}) {
  return report.toJson(gateLimit: gateLimit);
}

RegistryHealthReadinessGate _registryGate(ChartRegistryHealthReport report) {
  final errors = report.audit.errors.length;
  final warnings = report.audit.warnings.length;
  return RegistryHealthReadinessGate(
    key: 'registry',
    label: 'Registrations',
    status: errors > 0
        ? RegistryHealthReadinessStatus.blocked
        : warnings > 0
        ? RegistryHealthReadinessStatus.warning
        : RegistryHealthReadinessStatus.ready,
    detail:
        '${report.audit.registrationCount} registrations, $errors errors, '
        '$warnings warnings.',
    issueCount: errors + warnings,
    action: errors > 0
        ? 'Fix registration errors.'
        : warnings > 0
        ? 'Review registration warnings.'
        : 'No action needed.',
  );
}

RegistryHealthReadinessGate _coverageGate(
  RegistryHealthShowcaseThresholdReport report,
) {
  return RegistryHealthReadinessGate(
    key: 'showcaseCoverage',
    label: 'Coverage Gates',
    status: _thresholdStatus(report.status),
    detail:
        '${report.coveredCount}/${report.expectedCount} examples covered, '
        '${report.failCount} failing gates, ${report.warnCount} warnings.',
    issueCount: report.failCount + report.warnCount,
    action: report.failCount > 0
        ? 'Fix failing coverage gates.'
        : report.warnCount > 0
        ? 'Improve warning coverage gates.'
        : 'No action needed.',
  );
}

RegistryHealthReadinessGate _namingGate(
  RegistryHealthShowcaseNamingReport report,
) {
  return RegistryHealthReadinessGate(
    key: 'typeNaming',
    label: 'Type Naming',
    status: report.unknownCount > 0
        ? RegistryHealthReadinessStatus.blocked
        : report.issueCount > 0
        ? RegistryHealthReadinessStatus.warning
        : RegistryHealthReadinessStatus.ready,
    detail:
        '${report.canonicalCount} canonical, ${report.normalizedCount} '
        'normalized, ${report.aliasCount} aliases, ${report.unknownCount} '
        'unknown.',
    issueCount: report.issueCount,
    action: report.unknownCount > 0
        ? 'Register unknown type keys.'
        : report.issueCount > 0
        ? 'Canonicalize drifted type keys.'
        : 'No action needed.',
  );
}

RegistryHealthReadinessGate _renamePlanGate(
  RegistryHealthShowcaseRenamePlanReport report,
) {
  return RegistryHealthReadinessGate(
    key: 'typeCleanup',
    label: 'Type Cleanup',
    status: report.blockers.isNotEmpty
        ? RegistryHealthReadinessStatus.blocked
        : report.items.isNotEmpty
        ? RegistryHealthReadinessStatus.warning
        : RegistryHealthReadinessStatus.ready,
    detail:
        '${report.safeRenameCount} safe renames, '
        '${report.manifestWorkCount} manifest work items.',
    issueCount: report.safeRenameCount + report.manifestWorkCount,
    action: report.blockers.isNotEmpty
        ? 'Resolve manifest blockers.'
        : report.items.isNotEmpty
        ? 'Apply safe rename operations.'
        : 'No action needed.',
  );
}

RegistryHealthReadinessGate _sampleGate(ChartSampleRegistryAuditReport audit) {
  return RegistryHealthReadinessGate(
    key: 'sampleAudit',
    label: 'Sample Audit',
    status: audit.errors.isNotEmpty
        ? RegistryHealthReadinessStatus.blocked
        : audit.warnings.isNotEmpty
        ? RegistryHealthReadinessStatus.warning
        : RegistryHealthReadinessStatus.ready,
    detail:
        '${audit.sampleCount} samples, ${audit.errors.length} errors, '
        '${audit.warnings.length} warnings.',
    issueCount: audit.issues.length,
    action: audit.errors.isNotEmpty
        ? 'Fix sample audit errors.'
        : audit.warnings.isNotEmpty
        ? 'Review sample audit warnings.'
        : 'No action needed.',
  );
}

RegistryHealthReadinessGate _sourceGate(ChartSampleSourceAuditReport audit) {
  return RegistryHealthReadinessGate(
    key: 'sampleSourceAudit',
    label: 'Source Audit',
    status: audit.isValid
        ? RegistryHealthReadinessStatus.ready
        : RegistryHealthReadinessStatus.blocked,
    detail:
        '${audit.checkedSourceCount} generated sources, '
        '${audit.issues.length} issues.',
    issueCount: audit.issues.length,
    action: audit.isValid
        ? 'No action needed.'
        : 'Fix generated source issues.',
  );
}

RegistryHealthReadinessGate _simpleSourceGate(
  SimpleChartSourceAuditReport audit,
) {
  return RegistryHealthReadinessGate(
    key: 'simpleSourceAudit',
    label: 'Simple Sources',
    status: audit.isValid
        ? RegistryHealthReadinessStatus.ready
        : RegistryHealthReadinessStatus.blocked,
    detail:
        '${audit.sourceCount}/${audit.requiredSourceCount} sources, '
        '${audit.issues.length} issues.',
    issueCount: audit.issues.length,
    action: audit.isValid ? 'No action needed.' : 'Fix simple source issues.',
  );
}

RegistryHealthReadinessGate _exampleMatrixGate(
  RegistryHealthChartExampleMatrixReport report,
) {
  return RegistryHealthReadinessGate(
    key: 'chartExampleMatrix',
    label: 'Example Matrix',
    status: report.unknownRowCount > 0 || report.issueRowCount > 0
        ? RegistryHealthReadinessStatus.blocked
        : report.missingSampleCount > 0
        ? RegistryHealthReadinessStatus.warning
        : RegistryHealthReadinessStatus.ready,
    detail:
        '${report.readyCount}/${report.rowCount} ready rows, '
        '${report.issueRowCount} issue rows, '
        '${report.missingSampleCount} missing samples.',
    issueCount: report.attentionCount,
    action: report.isReady
        ? 'No action needed.'
        : 'Work through chart example matrix actions.',
  );
}

RegistryHealthReadinessGate _apiConsistencyGate(
  RegistryHealthApiConsistencyReport report,
) {
  return RegistryHealthReadinessGate(
    key: 'apiConsistency',
    label: 'API Consistency',
    status: _apiConsistencyStatus(report.status),
    detail:
        '${report.readyCount}/${report.contractCount} contracts ready, '
        '${report.requiredIssueCount} required gaps, '
        '${report.advisoryIssueCount} advisory gaps.',
    issueCount: report.issueCount,
    action: report.isReady
        ? 'No action needed.'
        : report.requiredIssueCount > 0
        ? 'Align required API consistency fields across chart contracts.'
        : 'Align API consistency fields across chart contracts.',
  );
}

RegistryHealthReadinessGate _sourceMapGate({
  required RegistryHealthShowcaseSourceMapAuditReport? sourceMapAudit,
  required Object? sourceMapError,
  required bool sourceMapLoading,
}) {
  if (sourceMapAudit != null) {
    return RegistryHealthReadinessGate(
      key: 'sourceMapAudit',
      label: 'Source Map',
      status: _sourceMapStatus(sourceMapAudit.status),
      detail:
          '${sourceMapAudit.mappedSampleCount}/'
          '${sourceMapAudit.expectedSampleCount} samples mapped, '
          '${sourceMapAudit.issueCount} issues.',
      issueCount: sourceMapAudit.issueCount,
      action: sourceMapAudit.isReady
          ? 'No action needed.'
          : 'Fix source-map drift.',
    );
  }

  if (sourceMapLoading) {
    return const RegistryHealthReadinessGate(
      key: 'sourceMapAudit',
      label: 'Source Map',
      status: RegistryHealthReadinessStatus.warning,
      detail: 'Source map audit is still loading.',
      issueCount: 0,
      action: 'Wait for source map audit to load.',
    );
  }

  return RegistryHealthReadinessGate(
    key: 'sourceMapAudit',
    label: 'Source Map',
    status: RegistryHealthReadinessStatus.blocked,
    detail: sourceMapError == null
        ? 'Source map audit is unavailable.'
        : 'Source map audit is unavailable: $sourceMapError',
    issueCount: 1,
    action: 'Restore source map audit asset loading.',
  );
}

RegistryHealthReadinessStatus _thresholdStatus(
  RegistryHealthShowcaseThresholdStatus status,
) {
  switch (status) {
    case RegistryHealthShowcaseThresholdStatus.pass:
      return RegistryHealthReadinessStatus.ready;
    case RegistryHealthShowcaseThresholdStatus.warn:
      return RegistryHealthReadinessStatus.warning;
    case RegistryHealthShowcaseThresholdStatus.fail:
      return RegistryHealthReadinessStatus.blocked;
  }
}

RegistryHealthReadinessStatus _sourceMapStatus(
  RegistryHealthShowcaseSourceMapAuditStatus status,
) {
  switch (status) {
    case RegistryHealthShowcaseSourceMapAuditStatus.ready:
      return RegistryHealthReadinessStatus.ready;
    case RegistryHealthShowcaseSourceMapAuditStatus.warning:
      return RegistryHealthReadinessStatus.warning;
    case RegistryHealthShowcaseSourceMapAuditStatus.broken:
      return RegistryHealthReadinessStatus.blocked;
  }
}

RegistryHealthReadinessStatus _apiConsistencyStatus(
  RegistryHealthApiConsistencyStatus status,
) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return RegistryHealthReadinessStatus.ready;
    case RegistryHealthApiConsistencyStatus.warning:
      return RegistryHealthReadinessStatus.warning;
    case RegistryHealthApiConsistencyStatus.blocked:
      return RegistryHealthReadinessStatus.blocked;
  }
}

int _compareReadinessGates(
  RegistryHealthReadinessGate a,
  RegistryHealthReadinessGate b,
) {
  final status = _readinessRank(b.status).compareTo(_readinessRank(a.status));
  if (status != 0) return status;
  final issues = b.issueCount.compareTo(a.issueCount);
  if (issues != 0) return issues;
  return a.label.compareTo(b.label);
}

int _readinessRank(RegistryHealthReadinessStatus status) {
  switch (status) {
    case RegistryHealthReadinessStatus.ready:
      return 0;
    case RegistryHealthReadinessStatus.warning:
      return 1;
    case RegistryHealthReadinessStatus.blocked:
      return 2;
  }
}
