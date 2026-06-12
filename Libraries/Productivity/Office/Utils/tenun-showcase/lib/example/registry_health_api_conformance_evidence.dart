import 'registry_health_api_conformance_checklist.dart';
import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_conformance_verification.dart';

enum RegistryHealthApiConformanceEvidenceKind {
  advisoryFollowUp,
  harnessResult,
  requiredCoverage,
  exportSync,
  widgetTests,
  other,
}

class RegistryHealthApiConformanceEvidenceItem {
  final int evidenceNumber;
  final RegistryHealthApiConformanceEvidenceKind kind;
  final List<RegistryHealthApiConformanceChecklistItem> steps;

  const RegistryHealthApiConformanceEvidenceItem({
    required this.evidenceNumber,
    required this.kind,
    required this.steps,
  });

  String get kindKey => kind.name;

  String get evidenceLabel =>
      registryHealthApiConformanceEvidenceKindLabel(kind);

  String get titleLabel => 'Evidence $evidenceNumber: $evidenceLabel';

  String get summaryLabel => _conformanceEvidenceSummary(kind);

  int get stepCount => steps.length;

  int get taskCount =>
      steps.fold<int>(0, (total, item) => total + item.taskCount);

  int get highRiskCount =>
      _riskCount(RegistryHealthApiConformanceChecklistRisk.high);

  int get mediumRiskCount =>
      _riskCount(RegistryHealthApiConformanceChecklistRisk.medium);

  int get lowRiskCount =>
      _riskCount(RegistryHealthApiConformanceChecklistRisk.low);

  RegistryHealthApiConformanceGateStatus get status {
    if (steps.any(
      (item) =>
          item.verification.status ==
          RegistryHealthApiConformanceGateStatus.blocked,
    )) {
      return RegistryHealthApiConformanceGateStatus.blocked;
    }
    if (steps.any(
      (item) =>
          item.verification.status ==
          RegistryHealthApiConformanceGateStatus.review,
    )) {
      return RegistryHealthApiConformanceGateStatus.review;
    }
    return RegistryHealthApiConformanceGateStatus.ready;
  }

  String get statusLabel => registryHealthApiConformanceGateStatusLabel(status);

  String get riskSummaryLabel =>
      '${_conformanceEvidenceCount(mediumRiskCount, 'medium risk', 'medium risk')}, '
      '${_conformanceEvidenceCount(highRiskCount, 'high risk', 'high risk')}';

  String get stepSummaryLabel {
    if (steps.isEmpty) return 'Steps: none';
    final visibleSteps = steps.take(3).map((item) => item.stepLabel).join(', ');
    final hiddenCount = steps.length - 3;
    return hiddenCount > 0
        ? 'Steps: $visibleSteps, +$hiddenCount more'
        : 'Steps: $visibleSteps';
  }

  String get checkSummaryLabel {
    if (steps.isEmpty) return 'Checks: none';
    final visibleChecks = steps
        .take(2)
        .map((item) => item.checkLabel)
        .join(' ');
    final hiddenCount = steps.length - 2;
    return hiddenCount > 0
        ? '$visibleChecks +$hiddenCount more checks'
        : visibleChecks;
  }

  String get handoffLabel {
    if (steps.isEmpty) return 'No handoff required.';
    return steps.first.handoffLabel;
  }

  Map<String, dynamic> toJson() => {
    'evidenceNumber': evidenceNumber,
    'kind': kindKey,
    'evidenceLabel': evidenceLabel,
    'titleLabel': titleLabel,
    'summaryLabel': summaryLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'stepCount': stepCount,
    'taskCount': taskCount,
    'highRiskCount': highRiskCount,
    'mediumRiskCount': mediumRiskCount,
    'lowRiskCount': lowRiskCount,
    'riskSummaryLabel': riskSummaryLabel,
    'stepSummaryLabel': stepSummaryLabel,
    'checkSummaryLabel': checkSummaryLabel,
    'handoffLabel': handoffLabel,
    'steps': [for (final item in steps) item.toJson()],
  };

  int _riskCount(RegistryHealthApiConformanceChecklistRisk risk) =>
      steps.where((item) => item.risk == risk).length;
}

class RegistryHealthApiConformanceEvidenceReport {
  final List<RegistryHealthApiConformanceEvidenceItem> items;
  final int stepCount;
  final int taskCount;
  final int verificationCount;

  const RegistryHealthApiConformanceEvidenceReport({
    required this.items,
    required this.stepCount,
    required this.taskCount,
    required this.verificationCount,
  });

  bool get isClear => items.isEmpty;

  int get evidenceCount => items.length;

  int get readyEvidenceCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.ready);

  int get reviewEvidenceCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.review);

  int get blockedEvidenceCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.blocked);

  int get highRiskCount =>
      items.fold<int>(0, (total, item) => total + item.highRiskCount);

  int get mediumRiskCount =>
      items.fold<int>(0, (total, item) => total + item.mediumRiskCount);

  RegistryHealthApiConformanceEvidenceItem? get topEvidence {
    final attention = attentionItems;
    if (attention.isNotEmpty) return attention.first;
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConformanceEvidenceItem> get attentionItems {
    final out = items
        .where(
          (item) => item.status != RegistryHealthApiConformanceGateStatus.ready,
        )
        .toList();
    out.sort(_compareConformanceEvidenceItems);
    return out;
  }

  List<RegistryHealthApiConformanceEvidenceItem> visibleItems({int limit = 6}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int evidenceLimit = 12}) {
    final safeLimit = evidenceLimit < 0 ? 0 : evidenceLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'evidenceCount': evidenceCount,
      'stepCount': stepCount,
      'taskCount': taskCount,
      'verificationCount': verificationCount,
      'readyEvidenceCount': readyEvidenceCount,
      'reviewEvidenceCount': reviewEvidenceCount,
      'blockedEvidenceCount': blockedEvidenceCount,
      'highRiskCount': highRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'topEvidenceKind': topEvidence?.kindKey,
      'topEvidenceLabel': topEvidence?.evidenceLabel,
      'topStatus': topEvidence?.status.name,
      'topStatusLabel': topEvidence?.statusLabel,
      'exportedEvidenceCount': exportedItems.length,
      'hiddenEvidenceCount': items.length - exportedItems.length,
      'evidence': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _statusCount(RegistryHealthApiConformanceGateStatus status) =>
      items.where((item) => item.status == status).length;
}

RegistryHealthApiConformanceEvidenceReport
registryHealthApiConformanceEvidenceReport(
  RegistryHealthApiConformanceChecklistReport checklistReport,
) {
  final buckets =
      <
        RegistryHealthApiConformanceEvidenceKind,
        List<RegistryHealthApiConformanceChecklistItem>
      >{};
  for (final item in checklistReport.items) {
    buckets.putIfAbsent(_conformanceEvidenceKind(item), () => []).add(item);
  }

  final items = <RegistryHealthApiConformanceEvidenceItem>[];
  var evidenceNumber = 1;
  for (final kind in RegistryHealthApiConformanceEvidenceKind.values) {
    final steps = buckets[kind];
    if (steps == null || steps.isEmpty) continue;
    items.add(
      RegistryHealthApiConformanceEvidenceItem(
        evidenceNumber: evidenceNumber,
        kind: kind,
        steps: List<RegistryHealthApiConformanceChecklistItem>.unmodifiable(
          steps,
        ),
      ),
    );
    evidenceNumber += 1;
  }
  items.sort(_compareConformanceEvidenceItems);

  return RegistryHealthApiConformanceEvidenceReport(
    items: List<RegistryHealthApiConformanceEvidenceItem>.unmodifiable(items),
    stepCount: checklistReport.stepCount,
    taskCount: checklistReport.taskCount,
    verificationCount: checklistReport.verificationCount,
  );
}

String registryHealthApiConformanceEvidenceText(
  RegistryHealthApiConformanceEvidenceReport report, {
  int evidenceLimit = 12,
}) {
  final lines = <String>[
    '# API Conformance Evidence',
    '',
    'Evidence: ${report.evidenceCount}',
    'Steps: ${report.stepCount}',
    'Tasks: ${report.taskCount}',
    'Review: ${report.reviewEvidenceCount}',
    'Blocked: ${report.blockedEvidenceCount}',
    'Medium risk: ${report.mediumRiskCount}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: evidenceLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.titleLabel}')
      ..add('')
      ..add('- Status: ${item.statusLabel}')
      ..add('- ${item.summaryLabel}')
      ..add('- ${item.stepSummaryLabel}')
      ..add('- Handoff: ${item.handoffLabel}')
      ..add('- [ ] ${item.checkSummaryLabel}')
      ..add('');
  }

  final hiddenCount = report.evidenceCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more evidence items hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

String registryHealthApiConformanceEvidenceKindLabel(
  RegistryHealthApiConformanceEvidenceKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConformanceEvidenceKind.advisoryFollowUp:
      return 'Advisory Follow-up';
    case RegistryHealthApiConformanceEvidenceKind.harnessResult:
      return 'Harness Result';
    case RegistryHealthApiConformanceEvidenceKind.requiredCoverage:
      return 'Required Coverage Evidence';
    case RegistryHealthApiConformanceEvidenceKind.exportSync:
      return 'Export Sync Evidence';
    case RegistryHealthApiConformanceEvidenceKind.widgetTests:
      return 'Widget Test Evidence';
    case RegistryHealthApiConformanceEvidenceKind.other:
      return 'Other Evidence';
  }
}

RegistryHealthApiConformanceEvidenceKind _conformanceEvidenceKind(
  RegistryHealthApiConformanceChecklistItem item,
) {
  switch (item.verification.kind) {
    case RegistryHealthApiConformanceVerificationKind.advisoryReview:
      return RegistryHealthApiConformanceEvidenceKind.advisoryFollowUp;
    case RegistryHealthApiConformanceVerificationKind.harness:
      return RegistryHealthApiConformanceEvidenceKind.harnessResult;
    case RegistryHealthApiConformanceVerificationKind.requiredCoverage:
      return RegistryHealthApiConformanceEvidenceKind.requiredCoverage;
    case RegistryHealthApiConformanceVerificationKind.exportSync:
      return RegistryHealthApiConformanceEvidenceKind.exportSync;
    case RegistryHealthApiConformanceVerificationKind.widgetTests:
      return RegistryHealthApiConformanceEvidenceKind.widgetTests;
    case RegistryHealthApiConformanceVerificationKind.other:
      return RegistryHealthApiConformanceEvidenceKind.other;
  }
}

String _conformanceEvidenceSummary(
  RegistryHealthApiConformanceEvidenceKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConformanceEvidenceKind.advisoryFollowUp:
      return 'Collect owner decisions for advisory conformance gaps.';
    case RegistryHealthApiConformanceEvidenceKind.harnessResult:
      return 'Attach the latest conformance harness output.';
    case RegistryHealthApiConformanceEvidenceKind.requiredCoverage:
      return 'Preserve required coverage proof for API contract review.';
    case RegistryHealthApiConformanceEvidenceKind.exportSync:
      return 'Prove registry health exports and copied text stay aligned.';
    case RegistryHealthApiConformanceEvidenceKind.widgetTests:
      return 'Attach showcase widget test evidence for conformance panels.';
    case RegistryHealthApiConformanceEvidenceKind.other:
      return 'Capture remaining verification evidence for maintainers.';
  }
}

int _compareConformanceEvidenceItems(
  RegistryHealthApiConformanceEvidenceItem a,
  RegistryHealthApiConformanceEvidenceItem b,
) {
  final status = _conformanceEvidenceStatusRank(
    b.status,
  ).compareTo(_conformanceEvidenceStatusRank(a.status));
  if (status != 0) return status;
  final risk = b.mediumRiskCount.compareTo(a.mediumRiskCount);
  if (risk != 0) return risk;
  final kind = _conformanceEvidenceKindRank(
    a.kind,
  ).compareTo(_conformanceEvidenceKindRank(b.kind));
  if (kind != 0) return kind;
  return a.evidenceLabel.compareTo(b.evidenceLabel);
}

int _conformanceEvidenceStatusRank(
  RegistryHealthApiConformanceGateStatus status,
) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.ready:
      return 0;
    case RegistryHealthApiConformanceGateStatus.review:
      return 1;
    case RegistryHealthApiConformanceGateStatus.blocked:
      return 2;
  }
}

int _conformanceEvidenceKindRank(
  RegistryHealthApiConformanceEvidenceKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConformanceEvidenceKind.advisoryFollowUp:
      return 0;
    case RegistryHealthApiConformanceEvidenceKind.harnessResult:
      return 1;
    case RegistryHealthApiConformanceEvidenceKind.requiredCoverage:
      return 2;
    case RegistryHealthApiConformanceEvidenceKind.exportSync:
      return 3;
    case RegistryHealthApiConformanceEvidenceKind.widgetTests:
      return 4;
    case RegistryHealthApiConformanceEvidenceKind.other:
      return 5;
  }
}

String _conformanceEvidenceCount(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';
