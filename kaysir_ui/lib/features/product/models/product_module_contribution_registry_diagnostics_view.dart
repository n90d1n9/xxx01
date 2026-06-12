import 'product_module_contribution_manifest.dart';
import 'product_module_contribution_registry_diagnostic_detail.dart';
import 'product_module_contribution_registry_health_summary.dart';
import 'product_module_contribution_registry_triage_plan.dart';

/// Severity filter used by the product module registry diagnostics view.
enum ProductModuleContributionRegistryDiagnosticFilter {
  all,
  errors,
  warnings;

  bool get includesErrors {
    return switch (this) {
      ProductModuleContributionRegistryDiagnosticFilter.all => true,
      ProductModuleContributionRegistryDiagnosticFilter.errors => true,
      ProductModuleContributionRegistryDiagnosticFilter.warnings => false,
    };
  }

  bool get includesWarnings {
    return switch (this) {
      ProductModuleContributionRegistryDiagnosticFilter.all => true,
      ProductModuleContributionRegistryDiagnosticFilter.errors => false,
      ProductModuleContributionRegistryDiagnosticFilter.warnings => true,
    };
  }

  String labelFor(ProductModuleContributionRegistryHealthSummary summary) {
    return switch (this) {
      ProductModuleContributionRegistryDiagnosticFilter.all =>
        'All (${summary.issueCount})',
      ProductModuleContributionRegistryDiagnosticFilter.errors =>
        'Errors (${summary.errorCount})',
      ProductModuleContributionRegistryDiagnosticFilter.warnings =>
        'Warnings (${summary.warningCount})',
    };
  }

  String get emptyTitle {
    return switch (this) {
      ProductModuleContributionRegistryDiagnosticFilter.all =>
        'No registry diagnostics match this filter',
      ProductModuleContributionRegistryDiagnosticFilter.errors =>
        'No errors in this filter',
      ProductModuleContributionRegistryDiagnosticFilter.warnings =>
        'No warnings in this filter',
    };
  }

  String get reportLabel {
    return switch (this) {
      ProductModuleContributionRegistryDiagnosticFilter.all =>
        'All diagnostics',
      ProductModuleContributionRegistryDiagnosticFilter.errors => 'Errors',
      ProductModuleContributionRegistryDiagnosticFilter.warnings => 'Warnings',
    };
  }
}

/// Presentation model for filtered product module registry diagnostics.
class ProductModuleContributionRegistryDiagnosticsView {
  ProductModuleContributionRegistryDiagnosticsView({
    required this.filter,
    required this.healthSummary,
    List<ProductModuleContributionIgnoredManifestDiagnostic>
        ignoredManifestDiagnostics =
        const [],
    List<ProductModuleContributionDuplicateHookDiagnostic>
        duplicateHookDiagnostics =
        const [],
  }) : ignoredManifestDiagnostics = List.unmodifiable(
         ignoredManifestDiagnostics,
       ),
       duplicateHookDiagnostics = List.unmodifiable(duplicateHookDiagnostics);

  final ProductModuleContributionRegistryDiagnosticFilter filter;
  final ProductModuleContributionRegistryHealthSummary healthSummary;
  final List<ProductModuleContributionIgnoredManifestDiagnostic>
  ignoredManifestDiagnostics;
  final List<ProductModuleContributionDuplicateHookDiagnostic>
  duplicateHookDiagnostics;

  List<ProductModuleContributionIgnoredManifestDiagnostic>
  get visibleIgnoredManifestDiagnostics {
    if (!filter.includesErrors) {
      return const <ProductModuleContributionIgnoredManifestDiagnostic>[];
    }

    return ignoredManifestDiagnostics;
  }

  List<ProductModuleContributionDuplicateHookDiagnostic>
  get visibleDuplicateHookDiagnostics {
    if (!filter.includesWarnings) {
      return const <ProductModuleContributionDuplicateHookDiagnostic>[];
    }

    return duplicateHookDiagnostics;
  }

  bool get hasVisibleIgnoredManifestDiagnostics {
    return visibleIgnoredManifestDiagnostics.isNotEmpty;
  }

  bool get hasVisibleDuplicateHookDiagnostics {
    return visibleDuplicateHookDiagnostics.isNotEmpty;
  }

  int get visibleErrorCount => visibleIgnoredManifestDiagnostics.length;
  int get visibleWarningCount => visibleDuplicateHookDiagnostics.length;
  int get visibleDiagnosticCount => visibleErrorCount + visibleWarningCount;

  List<ProductModuleContributionRegistryDiagnosticDetail>
  get visibleDiagnosticDetails {
    return List.unmodifiable([
      for (final diagnostic in visibleIgnoredManifestDiagnostics)
        ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
          diagnostic,
        ),
      for (final diagnostic in visibleDuplicateHookDiagnostics)
        ProductModuleContributionRegistryDiagnosticDetail.fromDuplicateHook(
          diagnostic,
        ),
    ]);
  }

  ProductModuleContributionRegistryTriagePlan get visibleTriagePlan {
    return ProductModuleContributionRegistryTriagePlan.fromDiagnostics(
      visibleDiagnosticDetails,
    );
  }

  bool get hasVisibleDiagnostics {
    return hasVisibleIgnoredManifestDiagnostics ||
        hasVisibleDuplicateHookDiagnostics;
  }

  bool get shouldSeparateVisibleNotices {
    return hasVisibleIgnoredManifestDiagnostics &&
        hasVisibleDuplicateHookDiagnostics;
  }

  String get emptyTitle => filter.emptyTitle;

  String get visibleDiagnosticCountLabel {
    return _countLabel(visibleDiagnosticCount, 'visible issue');
  }

  String get visibleSummaryLabel {
    return switch (filter) {
      ProductModuleContributionRegistryDiagnosticFilter.all =>
        'Showing all registry diagnostics',
      ProductModuleContributionRegistryDiagnosticFilter.errors =>
        hasVisibleDiagnostics
            ? 'Showing registry errors'
            : 'No registry errors in view',
      ProductModuleContributionRegistryDiagnosticFilter.warnings =>
        hasVisibleDiagnostics
            ? 'Showing registry warnings'
            : 'No registry warnings in view',
    };
  }

  String get visibleReportText {
    final buffer =
        StringBuffer()
          ..writeln('Product module registry diagnostics')
          ..writeln('Filter: ${filter.reportLabel}')
          ..writeln('Visible issues: $visibleDiagnosticCount')
          ..writeln(
            'Severity breakdown: ${healthSummary.severityBreakdownLabel}',
          );

    if (!hasVisibleDiagnostics) {
      buffer.writeln('No diagnostics visible for this filter.');
      return buffer.toString().trimRight();
    }

    for (var index = 0; index < visibleDiagnosticDetails.length; index += 1) {
      buffer
        ..writeln()
        ..writeln('--- Diagnostic ${index + 1} ---')
        ..writeln(visibleDiagnosticDetails[index].reportText);
    }

    return buffer.toString().trimRight();
  }
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
