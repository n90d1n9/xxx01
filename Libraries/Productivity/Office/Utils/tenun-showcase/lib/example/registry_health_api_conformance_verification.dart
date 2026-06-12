import 'registry_health_api_conformance_gate.dart';

enum RegistryHealthApiConformanceVerificationKind {
  harness,
  requiredCoverage,
  advisoryReview,
  exportSync,
  widgetTests,
  other,
}

class RegistryHealthApiConformanceVerificationItem {
  final RegistryHealthApiConformanceVerificationKind kind;
  final String checkLabel;
  final List<String> gateLabels;
  final int readyGateCount;
  final int reviewGateCount;
  final int blockedGateCount;

  const RegistryHealthApiConformanceVerificationItem({
    required this.kind,
    required this.checkLabel,
    required this.gateLabels,
    required this.readyGateCount,
    required this.reviewGateCount,
    required this.blockedGateCount,
  });

  String get kindKey => kind.name;

  String get kindLabel => _conformanceVerificationKindLabel(kind);

  int get gateCount => gateLabels.length;

  bool get isShared => gateCount > 1;

  RegistryHealthApiConformanceGateStatus get status {
    if (blockedGateCount > 0) {
      return RegistryHealthApiConformanceGateStatus.blocked;
    }
    if (reviewGateCount > 0) {
      return RegistryHealthApiConformanceGateStatus.review;
    }
    return RegistryHealthApiConformanceGateStatus.ready;
  }

  String get statusLabel => registryHealthApiConformanceGateStatusLabel(status);

  String get gateCoverageLabel {
    if (gateLabels.isEmpty) return 'Gates: none';
    final visibleGates = gateLabels.take(3).join(', ');
    final hiddenCount = gateLabels.length - 3;
    return hiddenCount > 0
        ? 'Gates: $visibleGates, +$hiddenCount more'
        : 'Gates: $visibleGates';
  }

  String get coverageLabel =>
      '${_conformanceVerificationCount(gateCount, 'gate', 'gates')}, '
      '${_conformanceVerificationCount(reviewGateCount, 'review gate', 'review gates')}';

  Map<String, dynamic> toJson() => {
    'kind': kindKey,
    'kindLabel': kindLabel,
    'checkLabel': checkLabel,
    'gateCount': gateCount,
    'isShared': isShared,
    'coverageLabel': coverageLabel,
    'gateLabels': List<String>.from(gateLabels),
    'gateCoverageLabel': gateCoverageLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'statusCounts': {
      'ready': readyGateCount,
      'review': reviewGateCount,
      'blocked': blockedGateCount,
    },
  };
}

class RegistryHealthApiConformanceVerificationReport {
  final List<RegistryHealthApiConformanceVerificationItem> items;
  final int gateCount;
  final int requiredCheckCount;

  const RegistryHealthApiConformanceVerificationReport({
    required this.items,
    required this.gateCount,
    required this.requiredCheckCount,
  });

  bool get isClear => items.isEmpty;

  int get verificationCount => items.length;

  int get sharedVerificationCount =>
      items.where((item) => item.isShared).length;

  int get gateCoverageCount =>
      items.fold<int>(0, (total, item) => total + item.gateCount);

  int get readyVerificationCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.ready);

  int get reviewVerificationCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.review);

  int get blockedVerificationCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.blocked);

  RegistryHealthApiConformanceVerificationItem? get topVerification {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConformanceVerificationItem> visibleItems({
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
      'topKind': topVerification?.kindKey,
      'topKindLabel': topVerification?.kindLabel,
      'topCheckLabel': topVerification?.checkLabel,
      'topGateCount': topVerification?.gateCount,
      'exportedVerificationCount': exportedItems.length,
      'hiddenVerificationCount': items.length - exportedItems.length,
      'verifications': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _statusCount(RegistryHealthApiConformanceGateStatus status) =>
      items.where((item) => item.status == status).length;
}

RegistryHealthApiConformanceVerificationReport
registryHealthApiConformanceVerificationReport(
  RegistryHealthApiConformanceGateReport gatesReport,
) {
  final buckets = <String, _ConformanceVerificationBucket>{};
  for (final gate in gatesReport.items) {
    for (final check in gate.requiredChecks) {
      buckets
          .putIfAbsent(
            check,
            () => _ConformanceVerificationBucket(
              kind: _conformanceVerificationKind(check),
              checkLabel: check,
            ),
          )
          .add(gate);
    }
  }

  final items = buckets.values.map((bucket) => bucket.toItem()).toList()
    ..sort(_compareConformanceVerificationItems);

  return RegistryHealthApiConformanceVerificationReport(
    items: List<RegistryHealthApiConformanceVerificationItem>.unmodifiable(
      items,
    ),
    gateCount: gatesReport.gateCount,
    requiredCheckCount: gatesReport.requiredCheckCount,
  );
}

String registryHealthApiConformanceVerificationText(
  RegistryHealthApiConformanceVerificationReport report, {
  int verificationLimit = 12,
}) {
  final lines = <String>[
    '# API Conformance Verification',
    '',
    'Verifications: ${report.verificationCount}',
    'Shared: ${report.sharedVerificationCount}',
    'Gate links: ${report.gateCoverageCount}',
    'Required checks: ${report.requiredCheckCount}',
    'Review: ${report.reviewVerificationCount}',
    'Blocked: ${report.blockedVerificationCount}',
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

class _ConformanceVerificationBucket {
  final RegistryHealthApiConformanceVerificationKind kind;
  final String checkLabel;
  final List<String> gateLabels = [];
  final Set<String> _gateLabelSet = {};
  int readyGateCount = 0;
  int reviewGateCount = 0;
  int blockedGateCount = 0;

  _ConformanceVerificationBucket({
    required this.kind,
    required this.checkLabel,
  });

  void add(RegistryHealthApiConformanceGateItem gate) {
    if (_gateLabelSet.add(gate.gateLabel)) {
      gateLabels.add(gate.gateLabel);
    }
    switch (gate.status) {
      case RegistryHealthApiConformanceGateStatus.ready:
        readyGateCount += 1;
      case RegistryHealthApiConformanceGateStatus.review:
        reviewGateCount += 1;
      case RegistryHealthApiConformanceGateStatus.blocked:
        blockedGateCount += 1;
    }
  }

  RegistryHealthApiConformanceVerificationItem toItem() =>
      RegistryHealthApiConformanceVerificationItem(
        kind: kind,
        checkLabel: checkLabel,
        gateLabels: List<String>.unmodifiable(gateLabels),
        readyGateCount: readyGateCount,
        reviewGateCount: reviewGateCount,
        blockedGateCount: blockedGateCount,
      );
}

RegistryHealthApiConformanceVerificationKind _conformanceVerificationKind(
  String checkLabel,
) {
  if (checkLabel.startsWith('Run API conformance harness')) {
    return RegistryHealthApiConformanceVerificationKind.harness;
  }
  if (checkLabel.contains('required conformance') ||
      checkLabel.contains('required cases')) {
    return RegistryHealthApiConformanceVerificationKind.requiredCoverage;
  }
  if (checkLabel.contains('advisory') ||
      checkLabel.startsWith('Start review')) {
    return RegistryHealthApiConformanceVerificationKind.advisoryReview;
  }
  if (checkLabel.contains('widget tests')) {
    return RegistryHealthApiConformanceVerificationKind.widgetTests;
  }
  if (checkLabel.contains('JSON') ||
      checkLabel.contains('copied') ||
      checkLabel.contains('exported')) {
    return RegistryHealthApiConformanceVerificationKind.exportSync;
  }
  return RegistryHealthApiConformanceVerificationKind.other;
}

String _conformanceVerificationKindLabel(
  RegistryHealthApiConformanceVerificationKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConformanceVerificationKind.harness:
      return 'Conformance Harness';
    case RegistryHealthApiConformanceVerificationKind.requiredCoverage:
      return 'Required Coverage';
    case RegistryHealthApiConformanceVerificationKind.advisoryReview:
      return 'Advisory Review';
    case RegistryHealthApiConformanceVerificationKind.exportSync:
      return 'Export Sync';
    case RegistryHealthApiConformanceVerificationKind.widgetTests:
      return 'Widget Tests';
    case RegistryHealthApiConformanceVerificationKind.other:
      return 'Other Verification';
  }
}

int _compareConformanceVerificationItems(
  RegistryHealthApiConformanceVerificationItem a,
  RegistryHealthApiConformanceVerificationItem b,
) {
  final status = _conformanceVerificationStatusRank(
    b.status,
  ).compareTo(_conformanceVerificationStatusRank(a.status));
  if (status != 0) return status;
  final shared = b.gateCount.compareTo(a.gateCount);
  if (shared != 0) return shared;
  final kind = _conformanceVerificationKindRank(
    a.kind,
  ).compareTo(_conformanceVerificationKindRank(b.kind));
  if (kind != 0) return kind;
  final check = _conformanceVerificationCheckRank(
    a.checkLabel,
  ).compareTo(_conformanceVerificationCheckRank(b.checkLabel));
  if (check != 0) return check;
  return a.checkLabel.compareTo(b.checkLabel);
}

int _conformanceVerificationStatusRank(
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

int _conformanceVerificationKindRank(
  RegistryHealthApiConformanceVerificationKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConformanceVerificationKind.harness:
      return 0;
    case RegistryHealthApiConformanceVerificationKind.requiredCoverage:
      return 1;
    case RegistryHealthApiConformanceVerificationKind.advisoryReview:
      return 2;
    case RegistryHealthApiConformanceVerificationKind.exportSync:
      return 3;
    case RegistryHealthApiConformanceVerificationKind.widgetTests:
      return 4;
    case RegistryHealthApiConformanceVerificationKind.other:
      return 5;
  }
}

String _conformanceVerificationCount(
  int count,
  String singular,
  String plural,
) => count == 1 ? '1 $singular' : '$count $plural';

int _conformanceVerificationCheckRank(String checkLabel) {
  if (checkLabel.startsWith('Review advisory')) return 0;
  if (checkLabel.startsWith('Start review')) return 1;
  if (checkLabel.startsWith('Document intentional advisory')) return 2;
  if (checkLabel.startsWith('Run API conformance harness')) return 0;
  if (checkLabel.startsWith('Keep required conformance')) return 1;
  if (checkLabel.startsWith('Confirm required')) return 2;
  return 3;
}
