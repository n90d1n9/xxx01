class RegistryHealthExportOptions {
  const RegistryHealthExportOptions({
    this.name = 'full',
    this.includedExtraSectionKeys,
    this.excludedExtraSectionKeys = const <String>{},
  });

  static const full = RegistryHealthExportOptions();

  static const compact = RegistryHealthExportOptions(
    name: 'compact',
    includedExtraSectionKeys: {
      'showcaseCoverage',
      'showcaseThresholds',
      'showcaseNaming',
      'chartExampleMatrix',
      'apiConsistency',
      'apiConsistencyScorecard',
      'apiConsistencyScoreProjection',
      'apiConsistencyReleaseBrief',
      'packageBoundary',
      'proReadiness',
      'sampleAudit',
      'sampleSourceAudit',
      'simpleSourceAudit',
      'readiness',
      'sourceMapAudit',
    },
  );

  static const release = RegistryHealthExportOptions(
    name: 'release',
    includedExtraSectionKeys: {
      'showcaseCoverage',
      'showcaseThresholds',
      'showcaseNaming',
      'showcaseRenamePlan',
      'apiConsistency',
      'apiConsistencyScorecard',
      'apiConsistencyScoreProjection',
      'apiConsistencyReleaseBrief',
      'apiConsistencyConformanceGate',
      'apiConsistencyConformanceVerification',
      'apiConsistencyConformanceEvidence',
      'apiConsistencySourceReleaseGates',
      'apiConsistencySourceVerification',
      'packageBoundary',
      'proReadiness',
      'sampleAudit',
      'sampleSourceAudit',
      'simpleSourceAudit',
      'readiness',
      'readinessActionPlan',
      'readinessActionChecklist',
      'sourceMapAudit',
    },
  );

  static const planning = RegistryHealthExportOptions(
    name: 'planning',
    includedExtraSectionKeys: {
      'showcaseCoverage',
      'showcaseBacklog',
      'showcaseThresholds',
      'chartExampleMatrix',
      'apiConsistency',
      'apiConsistencyScorecard',
      'apiConsistencyScoreProjection',
      'apiConsistencyActionPlan',
      'apiConsistencyImplementationPlan',
      'apiConsistencyTraceability',
      'apiConsistencySourceQueue',
      'apiConsistencySourcePlan',
      'apiConsistencySourceChecklist',
      'apiConsistencySourceMilestones',
      'apiConsistencyFamilyRemediation',
      'apiConsistencyPrimitiveRemediation',
      'apiConsistencyFieldRemediation',
      'apiConsistencyConcernSummary',
      'packageBoundary',
      'proReadiness',
      'readiness',
      'readinessActionPlan',
      'readinessActionChecklist',
      'sourceMapAudit',
    },
  );

  static const presets = <RegistryHealthExportOptions>[
    full,
    compact,
    release,
    planning,
  ];

  final String name;
  final Set<String>? includedExtraSectionKeys;
  final Set<String> excludedExtraSectionKeys;

  bool includesExtraSection(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty || excludedExtraSectionKeys.contains(trimmed)) {
      return false;
    }
    final included = includedExtraSectionKeys;
    return included == null || included.contains(trimmed);
  }

  RegistryHealthExportOptions copyWith({
    String? name,
    Set<String>? includedExtraSectionKeys,
    Set<String>? excludedExtraSectionKeys,
  }) {
    return RegistryHealthExportOptions(
      name: name ?? this.name,
      includedExtraSectionKeys:
          includedExtraSectionKeys ?? this.includedExtraSectionKeys,
      excludedExtraSectionKeys:
          excludedExtraSectionKeys ?? this.excludedExtraSectionKeys,
    );
  }
}

Map<String, dynamic> registryHealthFilterExtraSections(
  Map<String, dynamic> extraSections, {
  RegistryHealthExportOptions options = RegistryHealthExportOptions.full,
}) {
  final out = <String, dynamic>{};
  for (final entry in extraSections.entries) {
    final key = entry.key.trim();
    if (options.includesExtraSection(key)) {
      out[key] = entry.value;
    }
  }
  return out;
}
