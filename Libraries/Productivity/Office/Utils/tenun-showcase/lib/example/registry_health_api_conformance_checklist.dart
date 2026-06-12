import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_conformance_verification.dart';

enum RegistryHealthApiConformanceChecklistRisk { low, medium, high }

class RegistryHealthApiConformanceChecklistItem {
  final int stepNumber;
  final RegistryHealthApiConformanceVerificationItem verification;
  final RegistryHealthApiConformanceChecklistRisk risk;
  final List<String> checklistItems;
  final String reviewGateLabel;
  final String handoffLabel;

  const RegistryHealthApiConformanceChecklistItem({
    required this.stepNumber,
    required this.verification,
    required this.risk,
    required this.checklistItems,
    required this.reviewGateLabel,
    required this.handoffLabel,
  });

  String get stepLabel => 'Step $stepNumber';

  String get titleLabel => '$stepLabel: ${verification.kindLabel}';

  String get riskLabel => registryHealthApiConformanceChecklistRiskLabel(risk);

  String get statusLabel => verification.statusLabel;

  String get checkLabel => verification.checkLabel;

  String get gateCoverageLabel => verification.gateCoverageLabel;

  int get gateCount => verification.gateCount;

  int get taskCount => checklistItems.length;

  String get taskSummaryLabel {
    if (checklistItems.isEmpty) return 'No checklist tasks';
    final visibleTasks = checklistItems.take(2).join(' ');
    final hiddenCount = checklistItems.length - 2;
    return hiddenCount > 0
        ? '$visibleTasks +$hiddenCount more tasks'
        : visibleTasks;
  }

  Map<String, dynamic> toJson() => {
    'stepNumber': stepNumber,
    'stepLabel': stepLabel,
    'titleLabel': titleLabel,
    'kind': verification.kindKey,
    'kindLabel': verification.kindLabel,
    'risk': risk.name,
    'riskLabel': riskLabel,
    'status': verification.status.name,
    'statusLabel': statusLabel,
    'gateCount': gateCount,
    'gateCoverageLabel': gateCoverageLabel,
    'taskCount': taskCount,
    'taskSummaryLabel': taskSummaryLabel,
    'checkLabel': checkLabel,
    'checklistItems': List<String>.from(checklistItems),
    'reviewGateLabel': reviewGateLabel,
    'handoffLabel': handoffLabel,
  };
}

class RegistryHealthApiConformanceChecklistReport {
  final List<RegistryHealthApiConformanceChecklistItem> items;
  final int gateCount;
  final int verificationCount;
  final int requiredCheckCount;

  const RegistryHealthApiConformanceChecklistReport({
    required this.items,
    required this.gateCount,
    required this.verificationCount,
    required this.requiredCheckCount,
  });

  bool get isClear => items.isEmpty;

  int get stepCount => items.length;

  int get taskCount =>
      items.fold<int>(0, (total, item) => total + item.taskCount);

  int get highRiskCount =>
      _riskCount(RegistryHealthApiConformanceChecklistRisk.high);

  int get mediumRiskCount =>
      _riskCount(RegistryHealthApiConformanceChecklistRisk.medium);

  int get lowRiskCount =>
      _riskCount(RegistryHealthApiConformanceChecklistRisk.low);

  RegistryHealthApiConformanceChecklistItem? get topStep {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConformanceChecklistItem> visibleItems({
    int limit = 6,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int stepLimit = 12}) {
    final safeLimit = stepLimit < 0 ? 0 : stepLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'stepCount': stepCount,
      'taskCount': taskCount,
      'gateCount': gateCount,
      'verificationCount': verificationCount,
      'requiredCheckCount': requiredCheckCount,
      'highRiskCount': highRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'lowRiskCount': lowRiskCount,
      'topStepNumber': topStep?.stepNumber,
      'topKind': topStep?.verification.kindKey,
      'topKindLabel': topStep?.verification.kindLabel,
      'topRisk': topStep?.risk.name,
      'topRiskLabel': topStep?.riskLabel,
      'exportedStepCount': exportedItems.length,
      'hiddenStepCount': items.length - exportedItems.length,
      'steps': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _riskCount(RegistryHealthApiConformanceChecklistRisk risk) =>
      items.where((item) => item.risk == risk).length;
}

RegistryHealthApiConformanceChecklistReport
registryHealthApiConformanceChecklistReport(
  RegistryHealthApiConformanceVerificationReport verificationReport,
) {
  final items = <RegistryHealthApiConformanceChecklistItem>[];
  for (final entry in verificationReport.items.asMap().entries) {
    final verification = entry.value;
    items.add(
      RegistryHealthApiConformanceChecklistItem(
        stepNumber: entry.key + 1,
        verification: verification,
        risk: _conformanceChecklistRisk(verification.status),
        checklistItems: _conformanceChecklistTasks(verification),
        reviewGateLabel: _conformanceChecklistReviewGate(verification),
        handoffLabel: _conformanceChecklistHandoff(verification),
      ),
    );
  }

  return RegistryHealthApiConformanceChecklistReport(
    items: List<RegistryHealthApiConformanceChecklistItem>.unmodifiable(items),
    gateCount: verificationReport.gateCount,
    verificationCount: verificationReport.verificationCount,
    requiredCheckCount: verificationReport.requiredCheckCount,
  );
}

String registryHealthApiConformanceChecklistText(
  RegistryHealthApiConformanceChecklistReport report, {
  int stepLimit = 12,
}) {
  final lines = <String>[
    '# API Conformance Checklist',
    '',
    'Steps: ${report.stepCount}',
    'Tasks: ${report.taskCount}',
    'Verifications: ${report.verificationCount}',
    'Gate links: ${report.gateCount}',
    'High risk: ${report.highRiskCount}',
    'Medium risk: ${report.mediumRiskCount}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: stepLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.titleLabel}')
      ..add('')
      ..add('- Risk: ${item.riskLabel}, ${item.statusLabel}')
      ..add('- ${item.gateCoverageLabel}')
      ..add('- Review gate: ${item.reviewGateLabel}')
      ..add('- Handoff: ${item.handoffLabel}');
    for (final task in item.checklistItems) {
      lines.add('- [ ] $task');
    }
    lines.add('');
  }

  final hiddenCount = report.stepCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more checklist steps hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

String registryHealthApiConformanceChecklistRiskLabel(
  RegistryHealthApiConformanceChecklistRisk risk,
) {
  switch (risk) {
    case RegistryHealthApiConformanceChecklistRisk.low:
      return 'Low Risk';
    case RegistryHealthApiConformanceChecklistRisk.medium:
      return 'Medium Risk';
    case RegistryHealthApiConformanceChecklistRisk.high:
      return 'High Risk';
  }
}

RegistryHealthApiConformanceChecklistRisk _conformanceChecklistRisk(
  RegistryHealthApiConformanceGateStatus status,
) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.blocked:
      return RegistryHealthApiConformanceChecklistRisk.high;
    case RegistryHealthApiConformanceGateStatus.review:
      return RegistryHealthApiConformanceChecklistRisk.medium;
    case RegistryHealthApiConformanceGateStatus.ready:
      return RegistryHealthApiConformanceChecklistRisk.low;
  }
}

List<String> _conformanceChecklistTasks(
  RegistryHealthApiConformanceVerificationItem verification,
) => List<String>.unmodifiable([
  verification.checkLabel,
  'Confirm ${verification.gateCoverageLabel}.',
  'Record ${verification.statusLabel.toLowerCase()} outcome before release.',
]);

String _conformanceChecklistReviewGate(
  RegistryHealthApiConformanceVerificationItem verification,
) {
  switch (verification.status) {
    case RegistryHealthApiConformanceGateStatus.blocked:
      return 'Blocked conformance checks must be fixed before release.';
    case RegistryHealthApiConformanceGateStatus.review:
      return 'Review and owner sign-off are required before release.';
    case RegistryHealthApiConformanceGateStatus.ready:
      return 'Ready checks can pass with standard release verification.';
  }
}

String _conformanceChecklistHandoff(
  RegistryHealthApiConformanceVerificationItem verification,
) {
  switch (verification.kind) {
    case RegistryHealthApiConformanceVerificationKind.harness:
      return 'Attach harness result to the release evidence bundle.';
    case RegistryHealthApiConformanceVerificationKind.requiredCoverage:
      return 'Route required coverage changes through API contract review.';
    case RegistryHealthApiConformanceVerificationKind.advisoryReview:
      return 'Route advisory follow-up into the implementation queue.';
    case RegistryHealthApiConformanceVerificationKind.exportSync:
      return 'Route export updates through registry health consumers.';
    case RegistryHealthApiConformanceVerificationKind.widgetTests:
      return 'Route UI assertions through the showcase widget tests.';
    case RegistryHealthApiConformanceVerificationKind.other:
      return 'Route the check to the owning chart API maintainer.';
  }
}
