import 'registry_health_api_conformance.dart';

enum RegistryHealthApiConformanceGateKind {
  requiredCoverage,
  advisoryCoverage,
  exportContract,
}

enum RegistryHealthApiConformanceGateStatus { ready, review, blocked }

class RegistryHealthApiConformanceGateItem {
  final int gateNumber;
  final RegistryHealthApiConformanceGateKind kind;
  final RegistryHealthApiConformanceGateStatus status;
  final String summaryLabel;
  final List<RegistryHealthApiConformanceCase> cases;
  final RegistryHealthApiConformanceCase? topCase;
  final List<String> requiredChecks;
  final List<String> acceptanceCriteria;

  const RegistryHealthApiConformanceGateItem({
    required this.gateNumber,
    required this.kind,
    required this.status,
    required this.summaryLabel,
    required this.cases,
    required this.topCase,
    required this.requiredChecks,
    required this.acceptanceCriteria,
  });

  String get kindKey => kind.name;

  String get kindLabel => registryHealthApiConformanceGateKindLabel(kind);

  String get gateLabel => 'Gate $gateNumber: $kindLabel';

  String get statusLabel => registryHealthApiConformanceGateStatusLabel(status);

  int get caseCount => cases.length;

  int get passCount =>
      _caseStatusCount(cases, RegistryHealthApiConformanceCaseStatus.pass);

  int get warningCount =>
      _caseStatusCount(cases, RegistryHealthApiConformanceCaseStatus.warning);

  int get failureCount =>
      _caseStatusCount(cases, RegistryHealthApiConformanceCaseStatus.fail);

  int get skippedCount =>
      _caseStatusCount(cases, RegistryHealthApiConformanceCaseStatus.skipped);

  int get checkCount => requiredChecks.length;

  int get acceptanceCount => acceptanceCriteria.length;

  String get caseScopeLabel =>
      '${_conformanceGateCount(caseCount, 'case', 'cases')}, '
      '${_conformanceGateCount(warningCount, 'warning', 'warnings')}, '
      '${_conformanceGateCount(failureCount, 'failure', 'failures')}';

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
    'kind': kindKey,
    'kindLabel': kindLabel,
    'gateLabel': gateLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'summaryLabel': summaryLabel,
    'caseCount': caseCount,
    'passCount': passCount,
    'warningCount': warningCount,
    'failureCount': failureCount,
    'skippedCount': skippedCount,
    'caseScopeLabel': caseScopeLabel,
    'topCaseId': topCase?.id,
    'topCaseLabel': topCase?.titleLabel,
    'checkCount': checkCount,
    'acceptanceCount': acceptanceCount,
    'requiredChecks': List<String>.from(requiredChecks),
    'acceptanceCriteria': List<String>.from(acceptanceCriteria),
    'checkSummaryLabel': checkSummaryLabel,
  };
}

class RegistryHealthApiConformanceGateReport {
  final List<RegistryHealthApiConformanceGateItem> items;
  final int caseCount;
  final int passCount;
  final int warningCount;
  final int failureCount;
  final int skippedCount;

  const RegistryHealthApiConformanceGateReport({
    required this.items,
    required this.caseCount,
    required this.passCount,
    required this.warningCount,
    required this.failureCount,
    required this.skippedCount,
  });

  bool get isClear => items.isEmpty;

  int get gateCount => items.length;

  int get requiredCheckCount =>
      items.fold<int>(0, (total, item) => total + item.checkCount);

  int get acceptanceCriteriaCount =>
      items.fold<int>(0, (total, item) => total + item.acceptanceCount);

  int get readyGateCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.ready);

  int get reviewGateCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.review);

  int get blockedGateCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.blocked);

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

  bool get isPassing => blockedGateCount == 0;

  RegistryHealthApiConformanceGateItem? get topGate {
    final attention = attentionItems;
    if (attention.isNotEmpty) return attention.first;
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConformanceGateItem> get attentionItems {
    final out = items
        .where(
          (item) => item.status != RegistryHealthApiConformanceGateStatus.ready,
        )
        .toList();
    out.sort(_compareConformanceGateItems);
    return out;
  }

  List<RegistryHealthApiConformanceGateItem> visibleItems({int limit = 4}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int gateLimit = 8}) {
    final safeLimit = gateLimit < 0 ? 0 : gateLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'status': status.name,
      'statusLabel': statusLabel,
      'isPassing': isPassing,
      'gateCount': gateCount,
      'caseCount': caseCount,
      'passCount': passCount,
      'warningCount': warningCount,
      'failureCount': failureCount,
      'skippedCount': skippedCount,
      'requiredCheckCount': requiredCheckCount,
      'acceptanceCriteriaCount': acceptanceCriteriaCount,
      'readyGateCount': readyGateCount,
      'reviewGateCount': reviewGateCount,
      'blockedGateCount': blockedGateCount,
      'topGateLabel': topGate?.gateLabel,
      'topStatus': topGate?.status.name,
      'topStatusLabel': topGate?.statusLabel,
      'exportedGateCount': exportedItems.length,
      'hiddenGateCount': items.length - exportedItems.length,
      'gates': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _statusCount(RegistryHealthApiConformanceGateStatus status) =>
      items.where((item) => item.status == status).length;
}

String registryHealthApiConformanceGateKindLabel(
  RegistryHealthApiConformanceGateKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConformanceGateKind.requiredCoverage:
      return 'Required Coverage';
    case RegistryHealthApiConformanceGateKind.advisoryCoverage:
      return 'Advisory Coverage';
    case RegistryHealthApiConformanceGateKind.exportContract:
      return 'Export Contract';
  }
}

String registryHealthApiConformanceGateStatusLabel(
  RegistryHealthApiConformanceGateStatus status,
) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.ready:
      return 'Ready';
    case RegistryHealthApiConformanceGateStatus.review:
      return 'Review Needed';
    case RegistryHealthApiConformanceGateStatus.blocked:
      return 'Blocked';
  }
}

int _caseStatusCount(
  List<RegistryHealthApiConformanceCase> cases,
  RegistryHealthApiConformanceCaseStatus status,
) => cases.where((item) => item.status == status).length;

int _compareConformanceGateItems(
  RegistryHealthApiConformanceGateItem a,
  RegistryHealthApiConformanceGateItem b,
) {
  final status = _conformanceGateStatusRank(
    b.status,
  ).compareTo(_conformanceGateStatusRank(a.status));
  if (status != 0) return status;
  return a.gateNumber.compareTo(b.gateNumber);
}

int _conformanceGateStatusRank(RegistryHealthApiConformanceGateStatus status) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.ready:
      return 0;
    case RegistryHealthApiConformanceGateStatus.review:
      return 1;
    case RegistryHealthApiConformanceGateStatus.blocked:
      return 2;
  }
}

String _conformanceGateCount(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';
