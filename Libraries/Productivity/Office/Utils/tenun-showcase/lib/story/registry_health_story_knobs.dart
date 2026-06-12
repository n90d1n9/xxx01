import 'package:flutter/widgets.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../example/registry_health_chart_example_matrix.dart';
import '../example/registry_health_example.dart';
import '../example/registry_health_export_options.dart';
import '../example/registry_health_export_presets.dart';
import '../example/registry_health_showcase_backlog.dart';

class RegistryHealthStoryKnobs {
  const RegistryHealthStoryKnobs({
    required this.showcaseBacklogVisibleLimit,
    required this.showcaseBacklogOptions,
    required this.chartExampleMatrixOptions,
    required this.detailOptions,
    required this.sectionOptions,
    required this.exportOptions,
  });

  final int showcaseBacklogVisibleLimit;
  final RegistryHealthShowcaseBacklogPanelOptions showcaseBacklogOptions;
  final RegistryHealthChartExampleMatrixPanelOptions chartExampleMatrixOptions;
  final RegistryHealthDetailOptions detailOptions;
  final RegistryHealthSectionOptions sectionOptions;
  final RegistryHealthExportOptions exportOptions;
}

RegistryHealthStoryKnobs registryHealthStoryKnobs(
  BuildContext context, {
  String initialSectionSet = 'full',
  String initialMatrixViewMode = 'full',
  bool initialShowMatrixTable = true,
  int initialMatrixWorkLimit = 6,
  int initialMatrixAttentionLimit = 8,
  String initialDetailMode = 'full',
  String initialExportPreset = 'full',
  int initialAuditIssueLimit = 8,
  int? initialSplitIssueLimit,
  int initialRenamePlanVisibleLimit = 8,
  String initialBacklogPreviewMode = 'full',
  bool initialShowBacklogMetadata = true,
  int initialBacklogVisibleLimit = 6,
  bool? initialShowPackageBoundary,
  bool? initialShowProReadiness,
}) {
  final initialSections = _registryHealthSectionOptions(initialSectionSet);
  final sectionSet = context.knobs.options<String>(
    label: 'Health Sections',
    initial: initialSectionSet,
    options: const [
      Option(label: 'Full', value: 'full'),
      Option(label: 'Overview', value: 'overview'),
      Option(label: 'Samples', value: 'samples'),
      Option(label: 'Contracts', value: 'contracts'),
      Option(label: 'Split Review', value: 'split'),
    ],
  );
  final showPackageBoundary = context.knobs.boolean(
    label: 'Show Package Boundary',
    initial: initialShowPackageBoundary ?? initialSections.showPackageBoundary,
  );
  final showProReadiness = context.knobs.boolean(
    label: 'Show Pro Readiness',
    initial: initialShowProReadiness ?? initialSections.showProReadiness,
  );
  final matrixViewMode = context.knobs.options<String>(
    label: 'Matrix View',
    initial: initialMatrixViewMode,
    options: const [
      Option(label: 'Full', value: 'full'),
      Option(label: 'Compact', value: 'compact'),
      Option(label: 'Summary', value: 'summary'),
      Option(label: 'Actions', value: 'actions'),
    ],
  );
  final showMatrixTable = context.knobs.boolean(
    label: 'Show Matrix Table',
    initial: initialShowMatrixTable,
  );
  final matrixWorkLimit = context.knobs.sliderInt(
    label: 'Matrix Work Items',
    initial: initialMatrixWorkLimit,
    min: 1,
    max: 12,
    divisions: 11,
  );
  final matrixAttentionLimit = context.knobs.sliderInt(
    label: 'Matrix Attention Items',
    initial: initialMatrixAttentionLimit,
    min: 1,
    max: 12,
    divisions: 11,
  );
  final detailMode = context.knobs.options<String>(
    label: 'Detail Density',
    initial: initialDetailMode,
    options: const [
      Option(label: 'Full', value: 'full'),
      Option(label: 'Compact', value: 'compact'),
    ],
  );
  final exportPreset = context.knobs.options<String>(
    label: 'Export Preset',
    initial: initialExportPreset,
    options: [
      for (final preset in registryHealthExportPresetDescriptors)
        Option(label: preset.label, value: preset.id),
    ],
  );
  final auditIssueLimit = context.knobs.sliderInt(
    label: 'Audit Issues',
    initial: initialAuditIssueLimit,
    min: 0,
    max: 16,
    divisions: 16,
  );
  final splitIssueLimit = context.knobs.sliderInt(
    label: 'Split Issues',
    initial: initialSplitIssueLimit ?? initialAuditIssueLimit,
    min: 0,
    max: 16,
    divisions: 16,
  );
  final renamePlanVisibleLimit = context.knobs.sliderInt(
    label: 'Rename Plan Items',
    initial: initialRenamePlanVisibleLimit,
    min: 0,
    max: 16,
    divisions: 16,
  );
  final backlogPreviewMode = context.knobs.options<String>(
    label: 'Backlog Preview',
    initial: initialBacklogPreviewMode,
    options: const [
      Option(label: 'Full', value: 'full'),
      Option(label: 'Compact', value: 'compact'),
      Option(label: 'JSON Only', value: 'jsonOnly'),
      Option(label: 'No Source', value: 'noSource'),
    ],
  );
  final showBacklogMetadata = context.knobs.boolean(
    label: 'Show Backlog Metadata',
    initial: initialShowBacklogMetadata,
  );
  final backlogVisibleLimit = context.knobs.sliderInt(
    label: 'Backlog Items',
    initial: initialBacklogVisibleLimit,
    min: 1,
    max: 12,
    divisions: 11,
  );

  return RegistryHealthStoryKnobs(
    showcaseBacklogVisibleLimit: backlogVisibleLimit,
    showcaseBacklogOptions: _registryHealthBacklogOptions(
      mode: backlogPreviewMode,
      showMetadata: showBacklogMetadata,
    ),
    chartExampleMatrixOptions: _registryHealthMatrixOptions(
      mode: matrixViewMode,
      showTable: showMatrixTable,
      workLimit: matrixWorkLimit,
      attentionLimit: matrixAttentionLimit,
    ),
    detailOptions: _registryHealthDetailOptions(
      mode: detailMode,
      auditIssueLimit: auditIssueLimit,
      splitIssueLimit: splitIssueLimit,
      renamePlanVisibleLimit: renamePlanVisibleLimit,
    ),
    sectionOptions: _registryHealthSectionOptions(sectionSet).copyWith(
      showPackageBoundary: showPackageBoundary,
      showProReadiness: showProReadiness,
    ),
    exportOptions: _registryHealthExportOptions(exportPreset),
  );
}

RegistryHealthChartExampleMatrixPanelOptions _registryHealthMatrixOptions({
  required String mode,
  required bool showTable,
  required int workLimit,
  required int attentionLimit,
}) {
  final base = switch (mode) {
    'compact' => RegistryHealthChartExampleMatrixPanelOptions.compact,
    'summary' => const RegistryHealthChartExampleMatrixPanelOptions(
      showWorkSections: false,
      showTable: false,
    ),
    'actions' => const RegistryHealthChartExampleMatrixPanelOptions(
      showMetrics: false,
      showBreakdown: false,
      showTable: false,
      prioritySummaryLimit: 4,
      actionSummaryLimit: 4,
    ),
    _ => const RegistryHealthChartExampleMatrixPanelOptions(),
  };

  return base.copyWith(
    showTable: showTable && mode != 'summary' && mode != 'actions',
    prioritySummaryLimit: workLimit,
    actionSummaryLimit: workLimit,
    nextWorkLimit: workLimit,
    attentionLimit: attentionLimit,
  );
}

RegistryHealthDetailOptions _registryHealthDetailOptions({
  required String mode,
  required int auditIssueLimit,
  required int splitIssueLimit,
  required int renamePlanVisibleLimit,
}) {
  final base = switch (mode) {
    'compact' => RegistryHealthDetailOptions.compact,
    _ => const RegistryHealthDetailOptions(),
  };

  return base.copyWith(
    sampleIssueLimit: auditIssueLimit,
    sourceIssueLimit: auditIssueLimit,
    simpleSourceIssueLimit: auditIssueLimit,
    sourceMapIssueLimit: auditIssueLimit,
    packageBoundaryIssueLimit: splitIssueLimit,
    proReadinessIssueLimit: splitIssueLimit,
    renamePlanVisibleLimit: renamePlanVisibleLimit,
  );
}

RegistryHealthSectionOptions _registryHealthSectionOptions(String raw) {
  return switch (raw) {
    'overview' => RegistryHealthSectionOptions.overview,
    'samples' => RegistryHealthSectionOptions.samples,
    'contracts' => RegistryHealthSectionOptions.contracts,
    'split' => const RegistryHealthSectionOptions(
      showShowcaseCoverage: false,
      showSampleDiagnostics: false,
      showExampleMatrix: false,
      showNamingDiagnostics: false,
      showSummaries: false,
      showContractMatrices: false,
      showRuntimeDiagnostics: false,
      showCapabilityMatrix: false,
    ),
    _ => const RegistryHealthSectionOptions(),
  };
}

RegistryHealthExportOptions _registryHealthExportOptions(String raw) {
  return registryHealthExportOptionsForPresetId(raw);
}

RegistryHealthShowcaseBacklogPanelOptions _registryHealthBacklogOptions({
  required String mode,
  required bool showMetadata,
}) {
  final base = switch (mode) {
    'compact' => RegistryHealthShowcaseBacklogPanelOptions.compact,
    'jsonOnly' => RegistryHealthShowcaseBacklogPanelOptions.starterJsonOnly,
    'noSource' => const RegistryHealthShowcaseBacklogPanelOptions(
      showStarterJson: false,
      showDartSample: false,
    ),
    _ => const RegistryHealthShowcaseBacklogPanelOptions(),
  };

  return base.copyWith(showMetadataChips: showMetadata);
}
