import 'registry_health_api_consistency_source_release_gates.dart';

enum RegistryHealthApiConsistencySourceVerificationKind {
  analyzer,
  widgetTests,
  milestoneReview,
  other,
}

class RegistryHealthApiConsistencySourceVerificationItem {
  final RegistryHealthApiConsistencySourceVerificationKind kind;
  final String checkLabel;
  final List<String> gateLabels;
  final List<String> milestoneLabels;
  final int readyGateCount;
  final int reviewGateCount;
  final int blockedGateCount;

  const RegistryHealthApiConsistencySourceVerificationItem({
    required this.kind,
    required this.checkLabel,
    required this.gateLabels,
    required this.milestoneLabels,
    required this.readyGateCount,
    required this.reviewGateCount,
    required this.blockedGateCount,
  });

  String get kindKey => kind.name;

  String get kindLabel => _sourceVerificationKindLabel(kind);

  int get gateCount => gateLabels.length;

  bool get isShared => gateCount > 1;

  RegistryHealthApiConsistencySourceReleaseGateStatus get status {
    if (blockedGateCount > 0) {
      return RegistryHealthApiConsistencySourceReleaseGateStatus.blocked;
    }
    if (reviewGateCount > 0) {
      return RegistryHealthApiConsistencySourceReleaseGateStatus.review;
    }
    return RegistryHealthApiConsistencySourceReleaseGateStatus.ready;
  }

  String get statusLabel =>
      registryHealthApiConsistencySourceReleaseGateStatusLabel(status);

  String get gateCoverageLabel {
    if (gateLabels.isEmpty) return 'Gates: none';
    final visibleGates = gateLabels.take(3).join(', ');
    final hiddenCount = gateLabels.length - 3;
    return hiddenCount > 0
        ? 'Gates: $visibleGates, +$hiddenCount more'
        : 'Gates: $visibleGates';
  }

  String get milestoneCoverageLabel {
    if (milestoneLabels.isEmpty) return 'Milestones: none';
    final visibleMilestones = milestoneLabels.take(3).join(', ');
    final hiddenCount = milestoneLabels.length - 3;
    return hiddenCount > 0
        ? 'Milestones: $visibleMilestones, +$hiddenCount more'
        : 'Milestones: $visibleMilestones';
  }

  String get coverageLabel =>
      '${_sourceVerificationCount(gateCount, 'gate', 'gates')}, '
      '${_sourceVerificationCount(milestoneLabels.length, 'milestone', 'milestones')}';

  Map<String, dynamic> toJson() => {
    'kind': kindKey,
    'kindLabel': kindLabel,
    'checkLabel': checkLabel,
    'gateCount': gateCount,
    'isShared': isShared,
    'coverageLabel': coverageLabel,
    'gateLabels': List<String>.from(gateLabels),
    'gateCoverageLabel': gateCoverageLabel,
    'milestoneLabels': List<String>.from(milestoneLabels),
    'milestoneCoverageLabel': milestoneCoverageLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'statusCounts': {
      'ready': readyGateCount,
      'review': reviewGateCount,
      'blocked': blockedGateCount,
    },
  };
}

class RegistryHealthApiConsistencySourceVerificationReport {
  final List<RegistryHealthApiConsistencySourceVerificationItem> items;
  final int gateCount;
  final int requiredCheckCount;
  final double scoreImpactWeight;
  final String scoreImpactLabel;

  const RegistryHealthApiConsistencySourceVerificationReport({
    required this.items,
    required this.gateCount,
    required this.requiredCheckCount,
    required this.scoreImpactWeight,
    required this.scoreImpactLabel,
  });

  bool get isClear => items.isEmpty;

  int get verificationCount => items.length;

  int get sharedVerificationCount =>
      items.where((item) => item.isShared).length;

  int get gateCoverageCount =>
      items.fold<int>(0, (total, item) => total + item.gateCount);

  int get readyVerificationCount =>
      _statusCount(RegistryHealthApiConsistencySourceReleaseGateStatus.ready);

  int get reviewVerificationCount =>
      _statusCount(RegistryHealthApiConsistencySourceReleaseGateStatus.review);

  int get blockedVerificationCount =>
      _statusCount(RegistryHealthApiConsistencySourceReleaseGateStatus.blocked);

  RegistryHealthApiConsistencySourceVerificationItem? get topVerification {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencySourceVerificationItem> visibleItems({
    int limit = 6,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int verificationLimit = 12}) {
    final safeLimit = verificationLimit < 0 ? 0 : verificationLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'verificationCount': verificationCount,
      'sharedVerificationCount': sharedVerificationCount,
      'gateCount': gateCount,
      'gateCoverageCount': gateCoverageCount,
      'requiredCheckCount': requiredCheckCount,
      'readyVerificationCount': readyVerificationCount,
      'reviewVerificationCount': reviewVerificationCount,
      'blockedVerificationCount': blockedVerificationCount,
      'scoreImpactWeight': scoreImpactWeight,
      'scoreImpactLabel': scoreImpactLabel,
      'topKind': topVerification?.kindKey,
      'topKindLabel': topVerification?.kindLabel,
      'topCheckLabel': topVerification?.checkLabel,
      'topGateCount': topVerification?.gateCount,
      'exportedVerificationCount': exportedItems.length,
      'hiddenVerificationCount': items.length - exportedItems.length,
      'verifications': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _statusCount(
    RegistryHealthApiConsistencySourceReleaseGateStatus status,
  ) => items.where((item) => item.status == status).length;
}

RegistryHealthApiConsistencySourceVerificationReport
registryHealthApiConsistencySourceVerificationReport(
  RegistryHealthApiConsistencySourceReleaseGatesReport gatesReport,
) {
  final buckets = <String, _SourceVerificationBucket>{};
  for (final gate in gatesReport.items) {
    for (final check in gate.requiredChecks) {
      buckets
          .putIfAbsent(
            check,
            () => _SourceVerificationBucket(
              kind: _sourceVerificationKind(check),
              checkLabel: check,
            ),
          )
          .add(gate);
    }
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_compareSourceVerificationItems);

  return RegistryHealthApiConsistencySourceVerificationReport(
    items:
        List<RegistryHealthApiConsistencySourceVerificationItem>.unmodifiable(
          items,
        ),
    gateCount: gatesReport.gateCount,
    requiredCheckCount: gatesReport.requiredCheckCount,
    scoreImpactWeight: gatesReport.scoreImpactWeight,
    scoreImpactLabel: gatesReport.scoreImpactLabel,
  );
}

String registryHealthApiConsistencySourceVerificationText(
  RegistryHealthApiConsistencySourceVerificationReport report, {
  int verificationLimit = 12,
}) {
  final lines = <String>[
    '# API Source Verification',
    '',
    'Verifications: ${report.verificationCount}',
    'Shared: ${report.sharedVerificationCount}',
    'Gate links: ${report.gateCoverageCount}',
    'Required checks: ${report.requiredCheckCount}',
    'Review: ${report.reviewVerificationCount}',
    'Blocked: ${report.blockedVerificationCount}',
    'Impact: +${report.scoreImpactLabel}',
    '',
  ];
  final visibleItems = report.visibleItems(limit: verificationLimit);
  for (final item in visibleItems) {
    lines
      ..add('## ${item.kindLabel}')
      ..add('')
      ..add('- ${item.checkLabel}')
      ..add('- Status: ${item.statusLabel}')
      ..add('- Coverage: ${item.coverageLabel}')
      ..add('- ${item.gateCoverageLabel}')
      ..add('- ${item.milestoneCoverageLabel}')
      ..add('');
  }

  final hiddenCount = report.verificationCount - visibleItems.length;
  if (hiddenCount > 0) {
    lines
      ..add('+$hiddenCount more verifications hidden.')
      ..add('');
  }

  return lines.join('\n').trimRight();
}

class _SourceVerificationBucket {
  final RegistryHealthApiConsistencySourceVerificationKind kind;
  final String checkLabel;
  final List<String> gateLabels = [];
  final Set<String> _gateLabelSet = {};
  final List<String> milestoneLabels = [];
  final Set<String> _milestoneLabelSet = {};
  int readyGateCount = 0;
  int reviewGateCount = 0;
  int blockedGateCount = 0;

  _SourceVerificationBucket({required this.kind, required this.checkLabel});

  void add(RegistryHealthApiConsistencySourceReleaseGateItem gate) {
    if (_gateLabelSet.add(gate.gateLabel)) {
      gateLabels.add(gate.gateLabel);
    }
    if (_milestoneLabelSet.add(gate.milestone.milestoneLabel)) {
      milestoneLabels.add(gate.milestone.milestoneLabel);
    }
    switch (gate.status) {
      case RegistryHealthApiConsistencySourceReleaseGateStatus.ready:
        readyGateCount += 1;
      case RegistryHealthApiConsistencySourceReleaseGateStatus.review:
        reviewGateCount += 1;
      case RegistryHealthApiConsistencySourceReleaseGateStatus.blocked:
        blockedGateCount += 1;
    }
  }

  RegistryHealthApiConsistencySourceVerificationItem toItem() =>
      RegistryHealthApiConsistencySourceVerificationItem(
        kind: kind,
        checkLabel: checkLabel,
        gateLabels: List<String>.unmodifiable(gateLabels),
        milestoneLabels: List<String>.unmodifiable(milestoneLabels),
        readyGateCount: readyGateCount,
        reviewGateCount: reviewGateCount,
        blockedGateCount: blockedGateCount,
      );
}

RegistryHealthApiConsistencySourceVerificationKind _sourceVerificationKind(
  String checkLabel,
) {
  if (checkLabel.startsWith('Run dart analyze')) {
    return RegistryHealthApiConsistencySourceVerificationKind.analyzer;
  }
  if (checkLabel.contains('widget tests')) {
    return RegistryHealthApiConsistencySourceVerificationKind.widgetTests;
  }
  if (checkLabel.startsWith('Validate ')) {
    return RegistryHealthApiConsistencySourceVerificationKind.milestoneReview;
  }
  return RegistryHealthApiConsistencySourceVerificationKind.other;
}

String _sourceVerificationKindLabel(
  RegistryHealthApiConsistencySourceVerificationKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConsistencySourceVerificationKind.analyzer:
      return 'Analyzer';
    case RegistryHealthApiConsistencySourceVerificationKind.widgetTests:
      return 'Widget Tests';
    case RegistryHealthApiConsistencySourceVerificationKind.milestoneReview:
      return 'Milestone Review';
    case RegistryHealthApiConsistencySourceVerificationKind.other:
      return 'Other Verification';
  }
}

int _compareSourceVerificationItems(
  RegistryHealthApiConsistencySourceVerificationItem a,
  RegistryHealthApiConsistencySourceVerificationItem b,
) {
  final gates = b.gateCount.compareTo(a.gateCount);
  if (gates != 0) return gates;
  final kind = _sourceVerificationKindRank(
    a.kind,
  ).compareTo(_sourceVerificationKindRank(b.kind));
  if (kind != 0) return kind;
  return a.checkLabel.compareTo(b.checkLabel);
}

int _sourceVerificationKindRank(
  RegistryHealthApiConsistencySourceVerificationKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConsistencySourceVerificationKind.analyzer:
      return 0;
    case RegistryHealthApiConsistencySourceVerificationKind.widgetTests:
      return 1;
    case RegistryHealthApiConsistencySourceVerificationKind.milestoneReview:
      return 2;
    case RegistryHealthApiConsistencySourceVerificationKind.other:
      return 3;
  }
}

String _sourceVerificationCount(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';
