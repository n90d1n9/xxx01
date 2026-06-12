import 'registry_health_api_conformance_gate.dart';

enum RegistryHealthApiConsistencyReleaseBriefKind {
  scoreRecovery,
  conformanceGates,
  sourceReleaseGates,
  sourceVerification,
  evidenceHandoff,
}

class RegistryHealthApiConsistencyReleaseBriefItem {
  final RegistryHealthApiConsistencyReleaseBriefKind kind;
  final RegistryHealthApiConformanceGateStatus status;
  final String summaryLabel;
  final String detailLabel;
  final List<String> metrics;

  const RegistryHealthApiConsistencyReleaseBriefItem({
    required this.kind,
    required this.status,
    required this.summaryLabel,
    required this.detailLabel,
    required this.metrics,
  });

  String get kindKey => kind.name;

  String get kindLabel =>
      registryHealthApiConsistencyReleaseBriefKindLabel(kind);

  String get statusLabel => registryHealthApiConformanceGateStatusLabel(status);

  String get metricSummaryLabel {
    if (metrics.isEmpty) return 'No metrics';
    return metrics.join(', ');
  }

  Map<String, dynamic> toJson() => {
    'kind': kindKey,
    'kindLabel': kindLabel,
    'status': status.name,
    'statusLabel': statusLabel,
    'summaryLabel': summaryLabel,
    'detailLabel': detailLabel,
    'metrics': List<String>.from(metrics),
    'metricSummaryLabel': metricSummaryLabel,
  };
}

class RegistryHealthApiConsistencyReleaseBriefReport {
  final List<RegistryHealthApiConsistencyReleaseBriefItem> items;
  final int currentScorePercent;
  final int projectedScorePercent;

  const RegistryHealthApiConsistencyReleaseBriefReport({
    required this.items,
    required this.currentScorePercent,
    required this.projectedScorePercent,
  });

  bool get isClear => items.isEmpty;

  int get itemCount => items.length;

  int get scoreLiftPercent => projectedScorePercent - currentScorePercent;

  String get scoreLiftLabel {
    if (scoreLiftPercent == 0) return '0';
    return scoreLiftPercent > 0 ? '+$scoreLiftPercent' : '$scoreLiftPercent';
  }

  int get readyItemCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.ready);

  int get reviewItemCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.review);

  int get blockedItemCount =>
      _statusCount(RegistryHealthApiConformanceGateStatus.blocked);

  RegistryHealthApiConformanceGateStatus get status {
    if (blockedItemCount > 0) {
      return RegistryHealthApiConformanceGateStatus.blocked;
    }
    if (reviewItemCount > 0) {
      return RegistryHealthApiConformanceGateStatus.review;
    }
    return RegistryHealthApiConformanceGateStatus.ready;
  }

  String get statusLabel => registryHealthApiConformanceGateStatusLabel(status);

  String get releaseLabel {
    switch (status) {
      case RegistryHealthApiConformanceGateStatus.ready:
        return 'Ready for release';
      case RegistryHealthApiConformanceGateStatus.review:
        return 'Review before release';
      case RegistryHealthApiConformanceGateStatus.blocked:
        return 'Blocked before release';
    }
  }

  RegistryHealthApiConsistencyReleaseBriefItem? get topItem {
    final attention = attentionItems;
    if (attention.isNotEmpty) return attention.first;
    if (items.isEmpty) return null;
    return items.first;
  }

  List<RegistryHealthApiConsistencyReleaseBriefItem> get attentionItems {
    final out = items
        .where(
          (item) => item.status != RegistryHealthApiConformanceGateStatus.ready,
        )
        .toList();
    out.sort(_compareReleaseBriefItems);
    return out;
  }

  List<RegistryHealthApiConsistencyReleaseBriefItem> visibleItems({
    int limit = 5,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({int itemLimit = 8}) {
    final safeLimit = itemLimit < 0 ? 0 : itemLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'status': status.name,
      'statusLabel': statusLabel,
      'releaseLabel': releaseLabel,
      'itemCount': itemCount,
      'readyItemCount': readyItemCount,
      'reviewItemCount': reviewItemCount,
      'blockedItemCount': blockedItemCount,
      'currentScorePercent': currentScorePercent,
      'projectedScorePercent': projectedScorePercent,
      'scoreLiftPercent': scoreLiftPercent,
      'scoreLiftLabel': scoreLiftLabel,
      'topKind': topItem?.kindKey,
      'topKindLabel': topItem?.kindLabel,
      'topStatus': topItem?.status.name,
      'topStatusLabel': topItem?.statusLabel,
      'exportedItemCount': exportedItems.length,
      'hiddenItemCount': items.length - exportedItems.length,
      'items': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _statusCount(RegistryHealthApiConformanceGateStatus status) =>
      items.where((item) => item.status == status).length;
}

String registryHealthApiConsistencyReleaseBriefKindLabel(
  RegistryHealthApiConsistencyReleaseBriefKind kind,
) {
  switch (kind) {
    case RegistryHealthApiConsistencyReleaseBriefKind.scoreRecovery:
      return 'Score Recovery';
    case RegistryHealthApiConsistencyReleaseBriefKind.conformanceGates:
      return 'Conformance Gates';
    case RegistryHealthApiConsistencyReleaseBriefKind.sourceReleaseGates:
      return 'Source Release Gates';
    case RegistryHealthApiConsistencyReleaseBriefKind.sourceVerification:
      return 'Source Verification';
    case RegistryHealthApiConsistencyReleaseBriefKind.evidenceHandoff:
      return 'Evidence Handoff';
  }
}

int _compareReleaseBriefItems(
  RegistryHealthApiConsistencyReleaseBriefItem a,
  RegistryHealthApiConsistencyReleaseBriefItem b,
) {
  final status = _releaseBriefStatusRank(
    b.status,
  ).compareTo(_releaseBriefStatusRank(a.status));
  if (status != 0) return status;
  return _releaseBriefKindRank(a.kind).compareTo(_releaseBriefKindRank(b.kind));
}

int _releaseBriefStatusRank(RegistryHealthApiConformanceGateStatus status) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.ready:
      return 0;
    case RegistryHealthApiConformanceGateStatus.review:
      return 1;
    case RegistryHealthApiConformanceGateStatus.blocked:
      return 2;
  }
}

int _releaseBriefKindRank(RegistryHealthApiConsistencyReleaseBriefKind kind) {
  switch (kind) {
    case RegistryHealthApiConsistencyReleaseBriefKind.scoreRecovery:
      return 0;
    case RegistryHealthApiConsistencyReleaseBriefKind.conformanceGates:
      return 1;
    case RegistryHealthApiConsistencyReleaseBriefKind.sourceReleaseGates:
      return 2;
    case RegistryHealthApiConsistencyReleaseBriefKind.sourceVerification:
      return 3;
    case RegistryHealthApiConsistencyReleaseBriefKind.evidenceHandoff:
      return 4;
  }
}
