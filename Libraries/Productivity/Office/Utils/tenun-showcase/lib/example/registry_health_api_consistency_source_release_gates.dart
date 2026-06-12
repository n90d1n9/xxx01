import 'registry_health_api_consistency_source_checklist.dart';
import 'registry_health_api_consistency_source_milestones.dart';

enum RegistryHealthApiConsistencySourceReleaseGateStatus {
  ready,
  review,
  blocked,
}

class RegistryHealthApiConsistencySourceReleaseGateItem {
  final int gateNumber;
  final RegistryHealthApiConsistencySourceMilestoneItem milestone;
  final RegistryHealthApiConsistencySourceReleaseGateStatus status;
  final List<String> requiredChecks;
  final List<String> acceptanceCriteria;
  final String validationLabel;

  const RegistryHealthApiConsistencySourceReleaseGateItem({
    required this.gateNumber,
    required this.milestone,
    required this.status,
    required this.requiredChecks,
    required this.acceptanceCriteria,
    required this.validationLabel,
  });

  String get gateLabel => 'Gate $gateNumber: ${milestone.milestoneLabel}';

  String get statusLabel =>
      registryHealthApiConsistencySourceReleaseGateStatusLabel(status);

  String get riskLabel => milestone.riskLabel;

  int get checkCount => requiredChecks.length;

  int get acceptanceCount => acceptanceCriteria.length;

  int get stageCount => milestone.stageCount;

  int get sourceCount => milestone.sourceCount;

  int get taskCount => milestone.taskCount;

  int get actionTouchCount => milestone.actionTouchCount;

  String get scopeLabel =>
      '${_sourceReleaseGateCount(stageCount, 'stage', 'stages')}, '
      '${_sourceReleaseGateCount(sourceCount, 'source', 'sources')}, '
      '${_sourceReleaseGateCount(taskCount, 'task', 'tasks')}';

  String get checkSummaryLabel {
    if (requiredChecks.isEmpty) return 'Checks: none';
    final visibleChecks = requiredChecks.take(2).join(' ');
    final hiddenCount = requiredChecks.length - 2;
    return hiddenCount > 0
        ? '$visibleChecks +$hiddenCount more checks'
        : visibleChecks;
  }

  Map<String, dynamic> toJson() => {
    'gateNumber': gateNumber,
    'gateLabel': gateLabel,
    'milestone': milestone.milestoneKey,
    'milestoneLabel': milestone.milestoneLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'risk': milestone.risk.name,
    'riskLabel': riskLabel,
    'stageCount': stageCount,
    'sourceCount': sourceCount,
    'taskCount': taskCount,
    'actionTouchCount': actionTouchCount,
    'scopeLabel': scopeLabel,
    'checkCount': checkCount,
    'acceptanceCount': acceptanceCount,
    'requiredChecks': List<String>.from(requiredChecks),
    'acceptanceCriteria': List<String>.from(acceptanceCriteria),
    'validationLabel': validationLabel,
    'checkSummaryLabel': checkSummaryLabel,
  };
}

class RegistryHealthApiConsistencySourceReleaseGatesReport {
  final List<RegistryHealthApiConsistencySourceReleaseGateItem> items;
  final int milestoneCount;
  final int stageCount;
  final int taskCount;
  final int sourceCount;
  final int actionTouchCount;
  final double scoreImpactWeight;
  final String scoreImpactLabel;

  const RegistryHealthApiConsistencySourceReleaseGatesReport({
    required this.items,
    required this.milestoneCount,
    required this.stageCount,
    required this.taskCount,
    required this.sourceCount,
    required this.actionTouchCount,
    required this.scoreImpactWeight,
    required this.scoreImpactLabel,
  });

  bool get isClear => items.isEmpty;

  int get gateCount => items.length;

  int get requiredCheckCount =>
      items.fold<int>(0, (total, item) => total + item.checkCount);

  int get acceptanceCriteriaCount =>
      items.fold<int>(0, (total, item) => total + item.acceptanceCount);

  int get readyGateCount =>
      _statusCount(RegistryHealthApiConsistencySourceReleaseGateStatus.ready);

  int get reviewGateCount =>
      _statusCount(RegistryHealthApiConsistencySourceReleaseGateStatus.review);

  int get blockedGateCount =>
      _statusCount(RegistryHealthApiConsistencySourceReleaseGateStatus.blocked);

  RegistryHealthApiConsistencySourceReleaseGateItem? get topGate {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencySourceReleaseGateItem> visibleItems({
    int limit = 4,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int gateLimit = 8}) {
    final safeLimit = gateLimit < 0 ? 0 : gateLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'gateCount': gateCount,
      'milestoneCount': milestoneCount,
      'stageCount': stageCount,
      'taskCount': taskCount,
      'sourceCount': sourceCount,
      'actionTouchCount': actionTouchCount,
      'requiredCheckCount': requiredCheckCount,
      'acceptanceCriteriaCount': acceptanceCriteriaCount,
      'readyGateCount': readyGateCount,
      'reviewGateCount': reviewGateCount,
      'blockedGateCount': blockedGateCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topGateLabel': topGate?.gateLabel,
      'topStatus': topGate?.status.name,
      'topStatusLabel': topGate?.statusLabel,
      'exportedGateCount': exportedItems.length,
      'hiddenGateCount': items.length - exportedItems.length,
      'gates': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _statusCount(
    RegistryHealthApiConsistencySourceReleaseGateStatus status,
  ) => items.where((item) => item.status == status).length;
}

RegistryHealthApiConsistencySourceReleaseGatesReport
registryHealthApiConsistencySourceReleaseGatesReport(
  RegistryHealthApiConsistencySourceMilestonesReport milestonesReport,
) {
  final items = <RegistryHealthApiConsistencySourceReleaseGateItem>[];
  for (final entry in milestonesReport.items.asMap().entries) {
    final milestone = entry.value;
    items.add(
      RegistryHealthApiConsistencySourceReleaseGateItem(
        gateNumber: entry.key + 1,
        milestone: milestone,
        status: _sourceReleaseGateStatus(milestone),
        requiredChecks: _sourceReleaseGateChecks(milestone),
        acceptanceCriteria: _sourceReleaseGateAcceptance(milestone),
        validationLabel: _sourceReleaseGateValidation(milestone),
      ),
    );
  }

  return RegistryHealthApiConsistencySourceReleaseGatesReport(
    items: List<RegistryHealthApiConsistencySourceReleaseGateItem>.unmodifiable(
      items,
    ),
    milestoneCount: milestonesReport.milestoneCount,
    stageCount: milestonesReport.stageCount,
    taskCount: milestonesReport.taskCount,
    sourceCount: milestonesReport.sourceCount,
    actionTouchCount: milestonesReport.actionTouchCount,
    scoreImpactWeight: milestonesReport.scoreImpactWeight,
    scoreImpactLabel: milestonesReport.scoreImpactLabel,
  );
}

String registryHealthApiConsistencySourceReleaseGatesText(
  RegistryHealthApiConsistencySourceReleaseGatesReport report, {
  int gateLimit = 8,
}) {
  final lines = <String>[
    '# API Source Release Gates',
    '',
    'Gates: ${report.gateCount}',
    'Review: ${report.reviewGateCount}',
    'Blocked: ${report.blockedGateCount}',
    'Checks: ${report.requiredCheckCount}',
    'Acceptance: ${report.acceptanceCriteriaCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: gateLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.gateLabel}')
      ..add('')
      ..add('- Status: ${item.statusLabel}, ${item.riskLabel}')
      ..add('- Scope: ${item.scopeLabel}')
      ..add('- Validation: ${item.validationLabel}');
    for (final check in item.requiredChecks) {
      lines.add('- [ ] $check');
    }
    for (final criterion in item.acceptanceCriteria) {
      lines.add('- Accept: $criterion');
    }
    lines.add('');
  }

  final hiddenCount = report.gateCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more gates hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

String registryHealthApiConsistencySourceReleaseGateStatusLabel(
  RegistryHealthApiConsistencySourceReleaseGateStatus status,
) {
  switch (status) {
    case RegistryHealthApiConsistencySourceReleaseGateStatus.ready:
      return 'Ready';
    case RegistryHealthApiConsistencySourceReleaseGateStatus.review:
      return 'Review Needed';
    case RegistryHealthApiConsistencySourceReleaseGateStatus.blocked:
      return 'Blocked';
  }
}

RegistryHealthApiConsistencySourceReleaseGateStatus _sourceReleaseGateStatus(
  RegistryHealthApiConsistencySourceMilestoneItem milestone,
) {
  final hasBlockedStage = milestone.stages.any(
    (stage) => stage.batch.blockedCount > 0,
  );
  if (hasBlockedStage) {
    return RegistryHealthApiConsistencySourceReleaseGateStatus.blocked;
  }
  if (milestone.risk != RegistryHealthApiConsistencySourceChecklistRisk.low ||
      milestone.actionTouchCount > 0) {
    return RegistryHealthApiConsistencySourceReleaseGateStatus.review;
  }
  return RegistryHealthApiConsistencySourceReleaseGateStatus.ready;
}

List<String> _sourceReleaseGateChecks(
  RegistryHealthApiConsistencySourceMilestoneItem milestone,
) => List<String>.unmodifiable([
  'Run dart analyze for tenun and tenun_showcase.',
  'Run registry health widget tests for the API consistency panels.',
  _sourceReleaseGateMilestoneCheck(milestone),
]);

List<String> _sourceReleaseGateAcceptance(
  RegistryHealthApiConsistencySourceMilestoneItem milestone,
) => List<String>.unmodifiable([
  'No required API consistency gaps are introduced in ${milestone.milestoneLabel}.',
  'Registry health JSON exports include the updated source planning sections.',
  'Review gate passes: ${milestone.reviewGateLabel}',
]);

String _sourceReleaseGateValidation(
  RegistryHealthApiConsistencySourceMilestoneItem milestone,
) =>
    'Analyzer, registry health widget tests, and ${milestone.milestoneLabel} export review.';

String _sourceReleaseGateMilestoneCheck(
  RegistryHealthApiConsistencySourceMilestoneItem milestone,
) {
  switch (milestone.kind) {
    case RegistryHealthApiConsistencySourceMilestoneKind.foundation:
      return 'Validate contract fields, config adapters, and JSON parsing together.';
    case RegistryHealthApiConsistencySourceMilestoneKind.publicSurface:
      return 'Validate widget APIs and shared primitives expose matching options.';
    case RegistryHealthApiConsistencySourceMilestoneKind.adoptionRouting:
      return 'Validate chart families and registry routing consume the adopted APIs.';
    case RegistryHealthApiConsistencySourceMilestoneKind.triage:
      return 'Validate uncategorized source ownership before release.';
  }
}

String _sourceReleaseGateCount(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';
