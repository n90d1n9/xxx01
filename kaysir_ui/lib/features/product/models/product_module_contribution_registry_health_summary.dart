import 'product_module_contribution_manifest.dart';

/// Aggregated health signal for product module registry diagnostics.
class ProductModuleContributionRegistryHealthSummary {
  const ProductModuleContributionRegistryHealthSummary({
    this.errorCount = 0,
    this.warningCount = 0,
    this.infoCount = 0,
    this.primaryNextAction = '',
  }) : assert(errorCount >= 0),
       assert(warningCount >= 0),
       assert(infoCount >= 0);

  factory ProductModuleContributionRegistryHealthSummary.fromDiagnostics({
    List<ProductModuleContributionIgnoredManifestDiagnostic>
        ignoredManifestDiagnostics =
        const [],
    List<ProductModuleContributionDuplicateHookDiagnostic>
        duplicateHookDiagnostics =
        const [],
  }) {
    final sources = [
      for (final diagnostic in ignoredManifestDiagnostics)
        _RegistryHealthDiagnosticSource(
          severity: diagnostic.severity,
          resolutionGuidance: diagnostic.resolutionGuidance,
        ),
      for (final diagnostic in duplicateHookDiagnostics)
        _RegistryHealthDiagnosticSource(
          severity: diagnostic.severity,
          resolutionGuidance: diagnostic.resolutionGuidance,
        ),
    ];
    final sortedSources = [...sources]..sort(
      (first, second) =>
          first.severity.sortRank.compareTo(second.severity.sortRank),
    );

    return ProductModuleContributionRegistryHealthSummary(
      errorCount: _countSeverity(
        sources,
        ProductModuleContributionDiagnosticSeverity.error,
      ),
      warningCount: _countSeverity(
        sources,
        ProductModuleContributionDiagnosticSeverity.warning,
      ),
      infoCount: _countSeverity(
        sources,
        ProductModuleContributionDiagnosticSeverity.info,
      ),
      primaryNextAction: _primaryNextAction(sortedSources),
    );
  }

  final int errorCount;
  final int warningCount;
  final int infoCount;
  final String primaryNextAction;

  int get issueCount => errorCount + warningCount + infoCount;
  bool get hasIssues => issueCount > 0;
  bool get hasErrors => errorCount > 0;
  bool get hasWarnings => warningCount > 0;

  ProductModuleContributionDiagnosticSeverity get highestSeverity {
    if (hasErrors) return ProductModuleContributionDiagnosticSeverity.error;
    if (hasWarnings) return ProductModuleContributionDiagnosticSeverity.warning;

    return ProductModuleContributionDiagnosticSeverity.info;
  }

  String get statusLabel {
    if (!hasIssues) return 'Registry healthy';

    return switch (highestSeverity) {
      ProductModuleContributionDiagnosticSeverity.error => 'Registry blocked',
      ProductModuleContributionDiagnosticSeverity.warning => 'Registry review',
      ProductModuleContributionDiagnosticSeverity.info => 'Registry notice',
    };
  }

  String get countLabel => _countLabel(issueCount, 'registry issue');

  String get severityBreakdownLabel {
    final labels = [
      if (errorCount > 0) _countLabel(errorCount, 'error'),
      if (warningCount > 0) _countLabel(warningCount, 'warning'),
      if (infoCount > 0) _countLabel(infoCount, 'info note'),
    ];

    if (labels.isEmpty) return 'No registry issues';

    return labels.join(', ');
  }

  String get primaryNextActionLabel {
    final normalized = primaryNextAction.trim();
    if (normalized.isEmpty) return 'No registry action needed';

    return normalized;
  }

  String get tooltipLabel {
    if (!hasIssues) return 'Module registry has no diagnostics.';

    return '$severityBreakdownLabel. $primaryNextActionLabel';
  }
}

class _RegistryHealthDiagnosticSource {
  const _RegistryHealthDiagnosticSource({
    required this.severity,
    required this.resolutionGuidance,
  });

  final ProductModuleContributionDiagnosticSeverity severity;
  final String resolutionGuidance;
}

int _countSeverity(
  List<_RegistryHealthDiagnosticSource> sources,
  ProductModuleContributionDiagnosticSeverity severity,
) {
  return sources.where((source) => source.severity == severity).length;
}

String _primaryNextAction(List<_RegistryHealthDiagnosticSource> sources) {
  for (final source in sources) {
    final guidance = source.resolutionGuidance.trim();
    if (guidance.isNotEmpty) return guidance;
  }

  return '';
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
