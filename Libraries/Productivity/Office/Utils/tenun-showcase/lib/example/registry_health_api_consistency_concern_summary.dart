import 'registry_health_api_consistency.dart';

class RegistryHealthApiConsistencyConcernSummary {
  final RegistryHealthApiConsistencyConcern concern;
  final List<String> supportedContracts;
  final List<String> requiredMissingContracts;
  final List<String> advisoryMissingContracts;
  final List<String> notApplicableContracts;
  final int requiredAffectedChartCount;
  final int advisoryAffectedChartCount;

  const RegistryHealthApiConsistencyConcernSummary({
    required this.concern,
    required this.supportedContracts,
    required this.requiredMissingContracts,
    required this.advisoryMissingContracts,
    required this.notApplicableContracts,
    required this.requiredAffectedChartCount,
    required this.advisoryAffectedChartCount,
  });

  String get key => concern.key;
  String get label => concern.label;
  RegistryHealthApiConsistencyConcernPriority get priority => concern.priority;
  String get priorityLabel => concern.priorityLabel;
  int get supportedCount => supportedContracts.length;
  int get requiredMissingCount => requiredMissingContracts.length;
  int get advisoryMissingCount => advisoryMissingContracts.length;
  int get notApplicableCount => notApplicableContracts.length;
  int get missingCount => requiredMissingCount + advisoryMissingCount;

  RegistryHealthApiConsistencyStatus get status {
    if (requiredMissingCount > 0) {
      return RegistryHealthApiConsistencyStatus.blocked;
    }
    if (advisoryMissingCount > 0) {
      return RegistryHealthApiConsistencyStatus.warning;
    }
    return RegistryHealthApiConsistencyStatus.ready;
  }

  bool get isReady => status == RegistryHealthApiConsistencyStatus.ready;

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'priority': priority.name,
    'priorityLabel': priorityLabel,
    'status': status.name,
    'supportedCount': supportedCount,
    'requiredMissingCount': requiredMissingCount,
    'advisoryMissingCount': advisoryMissingCount,
    'notApplicableCount': notApplicableCount,
    'missingCount': missingCount,
    'requiredAffectedChartCount': requiredAffectedChartCount,
    'advisoryAffectedChartCount': advisoryAffectedChartCount,
    'supportedContracts': List<String>.from(supportedContracts),
    'requiredMissingContracts': List<String>.from(requiredMissingContracts),
    'advisoryMissingContracts': List<String>.from(advisoryMissingContracts),
    'notApplicableContracts': List<String>.from(notApplicableContracts),
  };
}

class RegistryHealthApiConsistencyConcernSummaryReport {
  final List<RegistryHealthApiConsistencyConcernSummary> summaries;

  const RegistryHealthApiConsistencyConcernSummaryReport({
    required this.summaries,
  });

  int get concernCount => summaries.length;
  int get readyCount => summaries.where((summary) => summary.isReady).length;
  int get requiredGapConcernCount =>
      summaries.where((summary) => summary.requiredMissingCount > 0).length;
  int get advisoryGapConcernCount =>
      summaries.where((summary) => summary.advisoryMissingCount > 0).length;
  int get requiredIssueCount => summaries.fold<int>(
    0,
    (count, summary) => count + summary.requiredMissingCount,
  );
  int get advisoryIssueCount => summaries.fold<int>(
    0,
    (count, summary) => count + summary.advisoryMissingCount,
  );
  int get requiredAffectedChartCount => summaries.fold<int>(
    0,
    (count, summary) => count + summary.requiredAffectedChartCount,
  );
  int get advisoryAffectedChartCount => summaries.fold<int>(
    0,
    (count, summary) => count + summary.advisoryAffectedChartCount,
  );

  List<RegistryHealthApiConsistencyConcernSummary> get attentionSummaries {
    final out = summaries.where((summary) => !summary.isReady).toList();
    out.sort(_compareConcernSummaries);
    return out;
  }

  Map<String, dynamic> toJson({int summaryLimit = 16}) {
    final safeLimit = summaryLimit < 0 ? 0 : summaryLimit;
    final exportedSummaries = attentionSummaries
        .take(safeLimit)
        .toList(growable: false);
    return {
      'concernCount': concernCount,
      'readyCount': readyCount,
      'requiredGapConcernCount': requiredGapConcernCount,
      'advisoryGapConcernCount': advisoryGapConcernCount,
      'requiredIssueCount': requiredIssueCount,
      'advisoryIssueCount': advisoryIssueCount,
      'requiredAffectedChartCount': requiredAffectedChartCount,
      'advisoryAffectedChartCount': advisoryAffectedChartCount,
      'exportedSummaryCount': exportedSummaries.length,
      'hiddenSummaryCount':
          attentionSummaries.length - exportedSummaries.length,
      'summaries': [for (final summary in exportedSummaries) summary.toJson()],
    };
  }
}

RegistryHealthApiConsistencyConcernSummaryReport
registryHealthApiConsistencyConcernSummaryReport(
  RegistryHealthApiConsistencyReport report,
) {
  final summaries = <RegistryHealthApiConsistencyConcernSummary>[];
  for (final concern in report.concerns) {
    final supportedContracts = <String>[];
    final requiredMissingContracts = <String>[];
    final advisoryMissingContracts = <String>[];
    final notApplicableContracts = <String>[];
    var requiredAffectedChartCount = 0;
    var advisoryAffectedChartCount = 0;

    for (final row in report.rows) {
      if (_containsConcern(row.supportedConcerns, concern)) {
        supportedContracts.add(row.contractName);
      } else if (_containsConcern(row.requiredMissingConcerns, concern)) {
        requiredMissingContracts.add(row.contractName);
        requiredAffectedChartCount += row.chartCount;
      } else if (_containsConcern(row.advisoryMissingConcerns, concern)) {
        advisoryMissingContracts.add(row.contractName);
        advisoryAffectedChartCount += row.chartCount;
      } else if (_containsConcern(row.notApplicableConcerns, concern)) {
        notApplicableContracts.add(row.contractName);
      }
    }

    summaries.add(
      RegistryHealthApiConsistencyConcernSummary(
        concern: concern,
        supportedContracts: _sortedStrings(supportedContracts),
        requiredMissingContracts: _sortedStrings(requiredMissingContracts),
        advisoryMissingContracts: _sortedStrings(advisoryMissingContracts),
        notApplicableContracts: _sortedStrings(notApplicableContracts),
        requiredAffectedChartCount: requiredAffectedChartCount,
        advisoryAffectedChartCount: advisoryAffectedChartCount,
      ),
    );
  }

  summaries.sort(_compareConcernSummaries);
  return RegistryHealthApiConsistencyConcernSummaryReport(
    summaries: List<RegistryHealthApiConsistencyConcernSummary>.unmodifiable(
      summaries,
    ),
  );
}

bool _containsConcern(
  List<RegistryHealthApiConsistencyConcern> concerns,
  RegistryHealthApiConsistencyConcern concern,
) {
  return concerns.any((item) => item.key == concern.key);
}

List<String> _sortedStrings(List<String> values) {
  return List<String>.from(values)..sort();
}

int _compareConcernSummaries(
  RegistryHealthApiConsistencyConcernSummary a,
  RegistryHealthApiConsistencyConcernSummary b,
) {
  final status = _statusRank(b.status).compareTo(_statusRank(a.status));
  if (status != 0) return status;
  final required = b.requiredMissingCount.compareTo(a.requiredMissingCount);
  if (required != 0) return required;
  final advisory = b.advisoryMissingCount.compareTo(a.advisoryMissingCount);
  if (advisory != 0) return advisory;
  final requiredCharts = b.requiredAffectedChartCount.compareTo(
    a.requiredAffectedChartCount,
  );
  if (requiredCharts != 0) return requiredCharts;
  final advisoryCharts = b.advisoryAffectedChartCount.compareTo(
    a.advisoryAffectedChartCount,
  );
  if (advisoryCharts != 0) return advisoryCharts;
  final concern = registryHealthApiConsistencyConcernPriorityRank(
    b.priority,
  ).compareTo(registryHealthApiConsistencyConcernPriorityRank(a.priority));
  if (concern != 0) return concern;
  return a.label.compareTo(b.label);
}

int _statusRank(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return 0;
    case RegistryHealthApiConsistencyStatus.warning:
      return 1;
    case RegistryHealthApiConsistencyStatus.blocked:
      return 2;
  }
}
