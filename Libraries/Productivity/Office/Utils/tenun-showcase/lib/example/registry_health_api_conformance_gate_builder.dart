import 'registry_health_api_conformance.dart';
import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_consistency.dart';

RegistryHealthApiConformanceGateReport registryHealthApiConformanceGateReport(
  RegistryHealthApiConformanceReport conformanceReport,
) {
  if (conformanceReport.isClear) {
    return const RegistryHealthApiConformanceGateReport(
      items: [],
      caseCount: 0,
      passCount: 0,
      warningCount: 0,
      failureCount: 0,
      skippedCount: 0,
    );
  }

  final requiredCases = _casesForLevel(
    conformanceReport,
    RegistryHealthApiConsistencyConcernLevel.required,
  );
  final advisoryCases = _casesForLevel(
    conformanceReport,
    RegistryHealthApiConsistencyConcernLevel.advisory,
  );
  final allCases = conformanceReport.cases;

  final items = <RegistryHealthApiConformanceGateItem>[
    RegistryHealthApiConformanceGateItem(
      gateNumber: 1,
      kind: RegistryHealthApiConformanceGateKind.requiredCoverage,
      status: _requiredCoverageStatus(requiredCases),
      summaryLabel: 'Required contract behavior must stay release-clean.',
      cases: requiredCases,
      topCase: _topConformanceGateCase(requiredCases),
      requiredChecks: _requiredCoverageChecks(requiredCases),
      acceptanceCriteria: _requiredCoverageAcceptance(requiredCases),
    ),
    RegistryHealthApiConformanceGateItem(
      gateNumber: 2,
      kind: RegistryHealthApiConformanceGateKind.advisoryCoverage,
      status: _advisoryCoverageStatus(advisoryCases),
      summaryLabel: 'Advisory gaps remain visible before they become debt.',
      cases: advisoryCases,
      topCase: _topConformanceGateCase(advisoryCases),
      requiredChecks: _advisoryCoverageChecks(advisoryCases),
      acceptanceCriteria: _advisoryCoverageAcceptance(advisoryCases),
    ),
    RegistryHealthApiConformanceGateItem(
      gateNumber: 3,
      kind: RegistryHealthApiConformanceGateKind.exportContract,
      status: _exportContractStatus(conformanceReport),
      summaryLabel: 'Registry exports carry the conformance signal forward.',
      cases: allCases,
      topCase: conformanceReport.topCase ?? _topConformanceGateCase(allCases),
      requiredChecks: _exportContractChecks(),
      acceptanceCriteria: _exportContractAcceptance(),
    ),
  ];

  return RegistryHealthApiConformanceGateReport(
    items: List<RegistryHealthApiConformanceGateItem>.unmodifiable(items),
    caseCount: conformanceReport.caseCount,
    passCount: conformanceReport.passCount,
    warningCount: conformanceReport.warningCount,
    failureCount: conformanceReport.failCount,
    skippedCount: conformanceReport.skippedCount,
  );
}

List<RegistryHealthApiConformanceCase> _casesForLevel(
  RegistryHealthApiConformanceReport report,
  RegistryHealthApiConsistencyConcernLevel level,
) => List<RegistryHealthApiConformanceCase>.unmodifiable(
  report.cases.where((item) => item.level == level),
);

RegistryHealthApiConformanceGateStatus _requiredCoverageStatus(
  List<RegistryHealthApiConformanceCase> cases,
) {
  if (_caseStatusCount(cases, RegistryHealthApiConformanceCaseStatus.fail) >
      0) {
    return RegistryHealthApiConformanceGateStatus.blocked;
  }
  return RegistryHealthApiConformanceGateStatus.ready;
}

RegistryHealthApiConformanceGateStatus _advisoryCoverageStatus(
  List<RegistryHealthApiConformanceCase> cases,
) {
  if (_caseStatusCount(cases, RegistryHealthApiConformanceCaseStatus.fail) >
      0) {
    return RegistryHealthApiConformanceGateStatus.blocked;
  }
  if (_caseStatusCount(cases, RegistryHealthApiConformanceCaseStatus.warning) >
      0) {
    return RegistryHealthApiConformanceGateStatus.review;
  }
  return RegistryHealthApiConformanceGateStatus.ready;
}

RegistryHealthApiConformanceGateStatus _exportContractStatus(
  RegistryHealthApiConformanceReport report,
) {
  if (report.caseCount == 0 || report.failCount > 0) {
    return RegistryHealthApiConformanceGateStatus.blocked;
  }
  return RegistryHealthApiConformanceGateStatus.ready;
}

List<String> _requiredCoverageChecks(
  List<RegistryHealthApiConformanceCase> cases,
) {
  final failureCount = _caseStatusCount(
    cases,
    RegistryHealthApiConformanceCaseStatus.fail,
  );
  return List<String>.unmodifiable([
    'Run API conformance harness before publishing chart API changes.',
    'Keep required conformance failures at 0 across all chart families.',
    failureCount > 0
        ? 'Resolve $failureCount failing required conformance cases.'
        : 'Confirm required cases remain green after contract changes.',
  ]);
}

List<String> _requiredCoverageAcceptance(
  List<RegistryHealthApiConformanceCase> cases,
) => List<String>.unmodifiable([
  'Failures remain 0 for all required conformance cases.',
  'Required case count remains ${cases.length} or changes intentionally.',
]);

List<String> _advisoryCoverageChecks(
  List<RegistryHealthApiConformanceCase> cases,
) {
  final topCase = _topConformanceGateCase(cases);
  return List<String>.unmodifiable([
    'Review advisory warnings by concern priority.',
    topCase == null
        ? 'Confirm no advisory warnings need follow-up.'
        : 'Start review with ${topCase.titleLabel}.',
    'Document intentional advisory gaps in the implementation plan.',
  ]);
}

List<String> _advisoryCoverageAcceptance(
  List<RegistryHealthApiConformanceCase> cases,
) {
  final warningCount = _caseStatusCount(
    cases,
    RegistryHealthApiConformanceCaseStatus.warning,
  );
  return List<String>.unmodifiable([
    warningCount == 0
        ? 'No advisory warnings remain.'
        : '$warningCount advisory warnings are triaged before release.',
    'Top advisory case remains visible in conformance output.',
  ]);
}

List<String> _exportContractChecks() => List<String>.unmodifiable([
  'Copy conformance JSON and case text from the showcase panel.',
  'Verify exported counts match the registry health pipeline.',
  'Keep widget tests covering conformance JSON, text, and panel output.',
]);

List<String> _exportContractAcceptance() => List<String>.unmodifiable([
  'apiConsistencyConformance and apiConsistencyConformanceGate are exported.',
  'Copy actions render in the showcase without widget exceptions.',
]);

RegistryHealthApiConformanceCase? _topConformanceGateCase(
  List<RegistryHealthApiConformanceCase> cases,
) {
  if (cases.isEmpty) return null;
  final sorted = List<RegistryHealthApiConformanceCase>.from(cases)
    ..sort(_compareConformanceCases);
  return sorted.first;
}

int _caseStatusCount(
  List<RegistryHealthApiConformanceCase> cases,
  RegistryHealthApiConformanceCaseStatus status,
) => cases.where((item) => item.status == status).length;

int _compareConformanceCases(
  RegistryHealthApiConformanceCase a,
  RegistryHealthApiConformanceCase b,
) {
  final status = _conformanceCaseStatusRank(
    b.status,
  ).compareTo(_conformanceCaseStatusRank(a.status));
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

int _conformanceCaseStatusRank(RegistryHealthApiConformanceCaseStatus status) {
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
