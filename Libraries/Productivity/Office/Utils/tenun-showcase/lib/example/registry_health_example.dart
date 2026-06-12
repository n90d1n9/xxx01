import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tenun/tenun_core.dart' hide Align;
import 'package:tenun_pro/tenun_pro.dart'
    show
        TenunPackageBoundaryAudit,
        TenunProEntrypointProfile,
        TenunProReleaseReadinessAudit,
        auditTenunPackageBoundary,
        auditTenunProReleaseReadiness;

import 'chart_sample_manifest_coverage.dart';
import 'chart_sample_registry_audit.dart';
import 'chart_sample_source_audit.dart';
import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_overview.dart';
import 'registry_health_api_consistency_panel.dart';
import 'registry_health_api_consistency_panel_options.dart';
import 'registry_health_api_consistency_pipeline.dart';
import 'registry_health_chart_example_matrix.dart';
import 'registry_health_api_contract_matrix.dart';
import 'registry_health_api_usage_matrix.dart';
import 'registry_health_capability_matrix.dart';
import 'registry_health_export_controls.dart';
import 'registry_health_export_options.dart';
import 'registry_health_package_boundary_panel.dart';
import 'registry_health_payload_contract_matrix.dart';
import 'registry_health_pro_entrypoint_profiles_panel.dart';
import 'registry_health_pro_readiness_panel.dart';
import 'registry_health_readiness.dart';
import 'registry_health_readiness_action_checklist.dart';
import 'registry_health_readiness_action_plan.dart';
import 'registry_health_readiness_panel.dart';
import 'registry_health_sample_audit.dart';
import 'registry_health_sample_source_audit.dart';
import 'registry_health_simple_source_audit.dart';
import 'registry_health_showcase_backlog.dart';
import 'registry_health_showcase_coverage.dart';
import 'registry_health_showcase_naming.dart';
import 'registry_health_showcase_rename_plan.dart';
import 'registry_health_showcase_rename_plan_panel.dart';
import 'registry_health_showcase_rename_plan_style.dart';
import 'registry_health_showcase_source_location.dart';
import 'registry_health_showcase_source_map.dart';
import 'registry_health_showcase_source_map_audit.dart';
import 'registry_health_showcase_source_map_audit_panel.dart';
import 'registry_health_showcase_thresholds.dart';
import 'registry_health_switch_groups.dart';
import 'registry_health_widgets.dart';
import 'simple_charts_showcase_source_audit.dart';

class RegistryHealthExample extends StatelessWidget {
  const RegistryHealthExample({
    super.key,
    this.showcaseBacklogVisibleLimit = 6,
    this.showcaseBacklogOptions =
        const RegistryHealthShowcaseBacklogPanelOptions(),
    this.chartExampleMatrixOptions =
        const RegistryHealthChartExampleMatrixPanelOptions(),
    this.detailOptions = const RegistryHealthDetailOptions(),
    this.sectionOptions = const RegistryHealthSectionOptions(),
    this.exportOptions = RegistryHealthExportOptions.full,
  });

  final int showcaseBacklogVisibleLimit;
  final RegistryHealthShowcaseBacklogPanelOptions showcaseBacklogOptions;
  final RegistryHealthChartExampleMatrixPanelOptions chartExampleMatrixOptions;
  final RegistryHealthDetailOptions detailOptions;
  final RegistryHealthSectionOptions sectionOptions;
  final RegistryHealthExportOptions exportOptions;

  static final Future<_RegistryHealthSourceMapAuditLoadState>
  _sourceMapAuditFuture = _loadSourceMapAudit();
  static _RegistryHealthSnapshot? _cachedSnapshot;

  @override
  Widget build(BuildContext context) {
    final snapshot = _registryHealthSnapshot();
    final report = snapshot.report;
    final audit = report.audit;
    final capabilities = report.capabilities;
    final payloadContracts = report.payloadContracts;
    final apiContracts = report.apiContracts;
    final switchGroups = report.switchGroups;
    final byShape = report.shapeCounts;
    final featureCounts = report.featureCounts;
    final payloadStrategyCounts = report.payloadStrategyCounts;
    final payloadFeatureCounts = report.payloadFeatureCounts;
    final apiContractUsageCounts = report.apiContractUsageCounts;
    final apiFieldCategoryCounts = report.apiFieldCategoryCounts;
    final showcaseCoverage = snapshot.showcaseCoverage;
    final showcaseThresholds = snapshot.showcaseThresholds;
    final namingReport = snapshot.namingReport;
    final renamePlanReport = snapshot.renamePlanReport;
    final sampleAudit = snapshot.sampleAudit;
    final sourceAudit = snapshot.sourceAudit;
    final simpleSourceAudit = snapshot.simpleSourceAudit;
    final chartExampleMatrix = snapshot.chartExampleMatrix;
    final apiConsistencyReport = snapshot.apiConsistencyReport;
    final packageBoundary = snapshot.packageBoundary;
    final proReadiness = snapshot.proReadiness;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registry Health',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Audit bundle registration, shape grouping, and runtime feature capability metadata.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          _RegistryHealthExportControls(
            snapshot: snapshot,
            sourceMapAuditFuture: _sourceMapAuditFuture,
            exportOptions: exportOptions,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              RegistryHealthMetricCard(
                label: 'Registrations',
                value: audit.registrationCount.toString(),
                icon: Icons.inventory_2_outlined,
              ),
              RegistryHealthMetricCard(
                label: 'Audit Errors',
                value: audit.errors.length.toString(),
                icon: audit.hasErrors
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                color: audit.hasErrors
                    ? Colors.red.shade700
                    : Colors.green.shade700,
              ),
              RegistryHealthMetricCard(
                label: 'Warnings',
                value: audit.warnings.length.toString(),
                icon: Icons.report_problem_outlined,
                color: audit.warnings.isEmpty
                    ? Colors.green.shade700
                    : Colors.orange.shade800,
              ),
              RegistryHealthMetricCard(
                label: 'Capability Rows',
                value: capabilities.length.toString(),
                icon: Icons.view_list_outlined,
              ),
              RegistryHealthMetricCard(
                label: 'Payload Contracts',
                value: payloadContracts.length.toString(),
                icon: Icons.schema_outlined,
              ),
              RegistryHealthMetricCard(
                label: 'API Contracts',
                value: apiContracts.length.toString(),
                icon: Icons.extension_outlined,
              ),
              RegistryHealthMetricCard(
                label: 'API Consistency',
                value: apiConsistencyReport.statusLabel,
                icon: Icons.schema_outlined,
                color: registryHealthApiConsistencyStatusColor(
                  apiConsistencyReport.status,
                ),
              ),
              RegistryHealthMetricCard(
                label: 'Package Split',
                value: registryHealthPackageBoundaryStatusLabel(
                  packageBoundary,
                ),
                icon: packageBoundary.isClean
                    ? Icons.call_split_outlined
                    : Icons.error_outline,
                color: registryHealthPackageBoundaryStatusColor(
                  packageBoundary,
                ),
              ),
              RegistryHealthMetricCard(
                label: 'Pro Readiness',
                value: registryHealthProReadinessStatusLabel(proReadiness),
                icon: registryHealthProReadinessStatusIcon(proReadiness),
                color: registryHealthProReadinessStatusColor(proReadiness),
              ),
              RegistryHealthMetricCard(
                label: 'Switch Groups',
                value: switchGroups.length.toString(),
                icon: Icons.swap_horiz_outlined,
              ),
              RegistryHealthMetricCard(
                label: 'Showcase Coverage',
                value: registryHealthCoverageRatioLabel(
                  showcaseCoverage.coverageRatio,
                ),
                icon: Icons.auto_graph_outlined,
                color: showcaseCoverage.unknownExampleKeys.isNotEmpty
                    ? Colors.red.shade700
                    : showcaseCoverage.missingEntries.isEmpty
                    ? Colors.green.shade700
                    : Colors.orange.shade800,
              ),
              RegistryHealthMetricCard(
                label: 'Coverage Gates',
                value: registryHealthShowcaseThresholdReportLabel(
                  showcaseThresholds,
                ),
                icon: Icons.rule_outlined,
                color: registryHealthShowcaseThresholdReportColor(
                  showcaseThresholds,
                ),
              ),
              _RegistryHealthReadinessMetricCard(
                snapshot: snapshot,
                sourceMapAuditFuture: _sourceMapAuditFuture,
              ),
              RegistryHealthMetricCard(
                label: 'Type Naming',
                value: registryHealthShowcaseNamingReportLabel(namingReport),
                icon: Icons.spellcheck_outlined,
                color: registryHealthShowcaseNamingReportColor(namingReport),
              ),
              RegistryHealthMetricCard(
                label: 'Type Cleanup',
                value: registryHealthShowcaseRenamePlanReportLabel(
                  renamePlanReport,
                ),
                icon: Icons.rule_folder_outlined,
                color: registryHealthShowcaseRenamePlanReportColor(
                  renamePlanReport,
                ),
              ),
              RegistryHealthMetricCard(
                label: 'Sample Audit',
                value: registryHealthSampleAuditStatusLabel(sampleAudit),
                icon: sampleAudit.isValid
                    ? Icons.fact_check_outlined
                    : Icons.error_outline,
                color: registryHealthSampleAuditStatusColor(sampleAudit),
              ),
              RegistryHealthMetricCard(
                label: 'Example Matrix',
                value: registryHealthChartExampleMatrixStatusLabel(
                  chartExampleMatrix,
                ),
                icon: chartExampleMatrix.isReady
                    ? Icons.grid_view_outlined
                    : Icons.error_outline,
                color: registryHealthChartExampleMatrixStatusColor(
                  chartExampleMatrix,
                ),
              ),
              RegistryHealthMetricCard(
                label: 'Source Audit',
                value: registryHealthSampleSourceAuditStatusLabel(sourceAudit),
                icon: sourceAudit.isValid
                    ? Icons.integration_instructions_outlined
                    : Icons.error_outline,
                color: registryHealthSampleSourceAuditStatusColor(sourceAudit),
              ),
              RegistryHealthMetricCard(
                label: 'Simple Sources',
                value: registryHealthSimpleSourceAuditStatusLabel(
                  simpleSourceAudit,
                ),
                icon: simpleSourceAudit.isValid
                    ? Icons.widgets_outlined
                    : Icons.error_outline,
                color: registryHealthSimpleSourceAuditStatusColor(
                  simpleSourceAudit,
                ),
              ),
              _RegistryHealthSourceMapAuditMetricCard(
                sourceMapAuditFuture: _sourceMapAuditFuture,
              ),
            ],
          ),
          if (sectionOptions.showReadiness) ...[
            const SizedBox(height: 16),
            RegistryHealthSectionCard(
              title: 'Readiness Gates',
              child: _RegistryHealthReadinessAssetPanel(
                snapshot: snapshot,
                sourceMapAuditFuture: _sourceMapAuditFuture,
                gateLimit: detailOptions.readinessGateLimit,
                actionLimit: detailOptions.readinessActionLimit,
              ),
            ),
          ],
          if (sectionOptions.showPackageBoundary) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Package Boundary',
              child: RegistryHealthPackageBoundaryPanel(
                audit: packageBoundary,
                issueLimit: detailOptions.packageBoundaryIssueLimit,
              ),
            ),
          ],
          if (sectionOptions.showProReadiness) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Pro Readiness',
              child: RegistryHealthProReadinessPanel(
                audit: proReadiness,
                entrypointProfiles: snapshot.proEntrypointProfiles,
                issueLimit: detailOptions.proReadinessIssueLimit,
                entrypointLimit: detailOptions.proReadinessEntrypointLimit,
              ),
            ),
          ],
          if (sectionOptions.showShowcaseCoverage) ...[
            const SizedBox(height: 16),
            RegistryHealthSectionCard(
              title: 'Showcase Coverage',
              child: RegistryHealthShowcaseCoveragePanel(
                coverage: showcaseCoverage,
                thresholdReport: showcaseThresholds,
                backlogVisibleLimit: showcaseBacklogVisibleLimit,
                backlogOptions: showcaseBacklogOptions,
              ),
            ),
          ],
          if (sectionOptions.showSampleDiagnostics) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Sample Audit',
              child: RegistryHealthSampleAuditPanel(
                audit: sampleAudit,
                issueLimit: detailOptions.sampleIssueLimit,
              ),
            ),
          ],
          if (sectionOptions.showExampleMatrix) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Chart Example Matrix',
              child: RegistryHealthChartExampleMatrixPanel(
                report: chartExampleMatrix,
                options: chartExampleMatrixOptions,
              ),
            ),
          ],
          if (sectionOptions.showSampleDiagnostics) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Source Audit',
              child: RegistryHealthSampleSourceAuditPanel(
                audit: sourceAudit,
                issueLimit: detailOptions.sourceIssueLimit,
              ),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Simple Source Audit',
              child: RegistryHealthSimpleSourceAuditPanel(
                audit: simpleSourceAudit,
                issueLimit: detailOptions.simpleSourceIssueLimit,
              ),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Source Map Audit',
              child: _RegistryHealthSourceMapAuditAssetPanel(
                sourceMapAuditFuture: _sourceMapAuditFuture,
                issueLimit: detailOptions.sourceMapIssueLimit,
              ),
            ),
          ],
          if (sectionOptions.showNamingDiagnostics) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Type Naming',
              child: RegistryHealthShowcaseNamingPanel(report: namingReport),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Rename Plan',
              child: RegistryHealthShowcaseRenamePlanPanel(
                report: namingReport,
                renamePlan: renamePlanReport,
                visibleLimit: detailOptions.renamePlanVisibleLimit,
              ),
            ),
          ],
          if (sectionOptions.showSummaries) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Capability Summary',
              child: _RegistryHealthSummaryChips(entries: featureCounts),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Payload Contract Summary',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._summaryChips(payloadFeatureCounts),
                  ..._summaryChips(
                    payloadStrategyCounts,
                    labelPrefix: 'strategy.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'API Contract Summary',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._summaryChips(
                    apiContractUsageCounts,
                    labelPrefix: 'contract.',
                  ),
                  ..._summaryChips(
                    apiFieldCategoryCounts,
                    labelPrefix: 'field.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Data Shape Groups',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in byShape.entries)
                    InputChip(
                      label: Text('${entry.key.name}: ${entry.value}'),
                      avatar: CircleAvatar(
                        radius: 10,
                        child: Text(entry.value.toString()),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (sectionOptions.showContractMatrices) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'API Consistency',
              child: RegistryHealthApiConsistencyPanel(
                report: apiConsistencyReport,
                options: detailOptions.apiConsistencyPanelOptions,
              ),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'API Contract Usage Matrix',
              child: RegistryHealthApiUsageMatrix(capabilities: capabilities),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'API Contract Matrix',
              child: RegistryHealthApiContractMatrix(contracts: apiContracts),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Payload Contract Matrix',
              child: RegistryHealthPayloadContractMatrix(
                contracts: payloadContracts,
              ),
            ),
          ],
          if (sectionOptions.showRuntimeDiagnostics) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Runtime Switch Groups',
              child: RegistryHealthSwitchGroupList(groups: switchGroups),
            ),
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Audit Warnings',
              child: audit.warnings.isEmpty
                  ? const Text('No warnings.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: audit.warnings
                          .take(8)
                          .map((issue) => RegistryHealthIssueRow(issue: issue))
                          .toList(),
                    ),
            ),
          ],
          if (sectionOptions.showCapabilityMatrix) ...[
            const SizedBox(height: 12),
            RegistryHealthSectionCard(
              title: 'Capability Matrix',
              child: RegistryHealthCapabilityMatrix(capabilities: capabilities),
            ),
          ],
        ],
      ),
    );
  }

  static _RegistryHealthSnapshot _registryHealthSnapshot() {
    final registryGeneration = ChartRegistry.generation;
    final cached = _cachedSnapshot;
    if (cached != null && cached.registryGeneration == registryGeneration) {
      return cached;
    }

    final snapshot = _RegistryHealthSnapshot.build(registryGeneration);
    _cachedSnapshot = snapshot;
    return snapshot;
  }

  static Future<_RegistryHealthSourceMapAuditLoadState>
  _loadSourceMapAudit() async {
    try {
      final source = await rootBundle.loadString(
        registryHealthChartSamplesRegistrySourceFile,
      );
      return _sourceMapAuditLoadStateFromSource(source);
    } catch (error) {
      return _RegistryHealthSourceMapAuditLoadState(report: null, error: error);
    }
  }
}

class _RegistryHealthSnapshot {
  final int registryGeneration;
  final ChartRegistryHealthReport report;
  final ChartFamilyShowcaseCoverageReport showcaseCoverage;
  final RegistryHealthShowcaseThresholdReport showcaseThresholds;
  final RegistryHealthShowcaseNamingReport namingReport;
  final RegistryHealthShowcaseRenamePlanReport renamePlanReport;
  final ChartSampleRegistryAuditReport sampleAudit;
  final ChartSampleSourceAuditReport sourceAudit;
  final SimpleChartSourceAuditReport simpleSourceAudit;
  final RegistryHealthChartExampleMatrixReport chartExampleMatrix;
  final RegistryHealthApiConsistencyReport apiConsistencyReport;
  final TenunPackageBoundaryAudit packageBoundary;
  final TenunProReleaseReadinessAudit proReadiness;
  final List<TenunProEntrypointProfile> proEntrypointProfiles;
  final Map<String, dynamic> healthExtraSections;

  const _RegistryHealthSnapshot({
    required this.registryGeneration,
    required this.report,
    required this.showcaseCoverage,
    required this.showcaseThresholds,
    required this.namingReport,
    required this.renamePlanReport,
    required this.sampleAudit,
    required this.sourceAudit,
    required this.simpleSourceAudit,
    required this.chartExampleMatrix,
    required this.apiConsistencyReport,
    required this.packageBoundary,
    required this.proReadiness,
    required this.proEntrypointProfiles,
    required this.healthExtraSections,
  });

  factory _RegistryHealthSnapshot.build(int registryGeneration) {
    final report = chartRegistryHealthReport();
    final showcaseCoverage = focusedChartSampleCoverage();
    final showcaseThresholds = registryHealthShowcaseThresholdReport(
      showcaseCoverage,
    );
    final namingReport = focusedRegistryHealthShowcaseNamingReport();
    final renamePlanReport = registryHealthShowcaseRenamePlanReport(
      namingReport,
    );
    final sampleAudit = auditFocusedChartSamples(
      requireRegisteredTypes: true,
      includeValidationWarnings: false,
    );
    final sourceAudit = auditFocusedChartSampleSources();
    final simpleSourceAudit = auditSimpleChartShowcaseSources();
    final chartExampleMatrix = focusedRegistryHealthChartExampleMatrixReport(
      manifest: showcaseCoverage.manifest,
      sampleAudit: sampleAudit,
      sourceAudit: sourceAudit,
    );
    final apiConsistencyReport = registryHealthApiConsistencyReport(
      report.capabilities,
    );
    final apiConsistencyPipeline = registryHealthApiConsistencyPipeline(
      apiConsistencyReport,
    );
    final packageBoundary = auditTenunPackageBoundary();
    final proReadiness = auditTenunProReleaseReadiness();
    final proEntrypointProfiles = registryHealthProEntrypointProfiles();
    final healthExtraSections = <String, dynamic>{
      'showcaseCoverage': showcaseCoverage.toJson(),
      'showcaseBacklog': registryHealthShowcaseBacklogJson(
        showcaseCoverage.missingEntries,
      ),
      'showcaseThresholds': showcaseThresholds.toJson(),
      'showcaseNaming': namingReport.toJson(),
      'showcaseRenamePlan': renamePlanReport.toJson(),
      'chartExampleMatrix': chartExampleMatrix.toJson(),
      ...apiConsistencyPipeline.toJsonSections(),
      'packageBoundary': registryHealthPackageBoundaryJson(packageBoundary),
      'proEntrypoints': registryHealthProEntrypointProfilesJson(
        proEntrypointProfiles,
      ),
      'proReadiness': registryHealthProReadinessJson(
        proReadiness,
        entrypointProfiles: proEntrypointProfiles,
      ),
      'sampleAudit': sampleAudit.toJson(),
      'sampleSourceAudit': sourceAudit.toJson(),
      'simpleSourceAudit': simpleSourceAudit.toJson(),
    };

    return _RegistryHealthSnapshot(
      registryGeneration: registryGeneration,
      report: report,
      showcaseCoverage: showcaseCoverage,
      showcaseThresholds: showcaseThresholds,
      namingReport: namingReport,
      renamePlanReport: renamePlanReport,
      sampleAudit: sampleAudit,
      sourceAudit: sourceAudit,
      simpleSourceAudit: simpleSourceAudit,
      chartExampleMatrix: chartExampleMatrix,
      apiConsistencyReport: apiConsistencyReport,
      packageBoundary: packageBoundary,
      proReadiness: proReadiness,
      proEntrypointProfiles: proEntrypointProfiles,
      healthExtraSections: Map<String, dynamic>.unmodifiable(
        healthExtraSections,
      ),
    );
  }
}

class RegistryHealthDetailOptions {
  const RegistryHealthDetailOptions({
    this.readinessGateLimit = 8,
    this.readinessActionLimit = 6,
    this.sampleIssueLimit = 8,
    this.sourceIssueLimit = 8,
    this.simpleSourceIssueLimit = 8,
    this.sourceMapIssueLimit = 8,
    this.renamePlanVisibleLimit = 8,
    this.apiConsistencyRowLimit = 8,
    this.apiConsistencyActionLimit = 6,
    this.apiConsistencyConcernLimit = 6,
    this.apiConsistencyFamilyLimit = 4,
    this.apiConsistencyPrimitiveLimit = 5,
    this.apiConsistencyFieldLimit = 6,
    this.packageBoundaryIssueLimit = 6,
    this.proReadinessIssueLimit = 6,
    this.proReadinessEntrypointLimit = 3,
  }) : assert(readinessGateLimit >= 0),
       assert(readinessActionLimit >= 0),
       assert(sampleIssueLimit >= 0),
       assert(sourceIssueLimit >= 0),
       assert(simpleSourceIssueLimit >= 0),
       assert(sourceMapIssueLimit >= 0),
       assert(renamePlanVisibleLimit >= 0),
       assert(apiConsistencyRowLimit >= 0),
       assert(apiConsistencyActionLimit >= 0),
       assert(apiConsistencyConcernLimit >= 0),
       assert(apiConsistencyFamilyLimit >= 0),
       assert(apiConsistencyPrimitiveLimit >= 0),
       assert(apiConsistencyFieldLimit >= 0),
       assert(packageBoundaryIssueLimit >= 0),
       assert(proReadinessIssueLimit >= 0),
       assert(proReadinessEntrypointLimit >= 0);

  static const compact = RegistryHealthDetailOptions(
    readinessGateLimit: 4,
    readinessActionLimit: 3,
    sampleIssueLimit: 4,
    sourceIssueLimit: 4,
    simpleSourceIssueLimit: 4,
    sourceMapIssueLimit: 4,
    renamePlanVisibleLimit: 4,
    apiConsistencyRowLimit: 4,
    apiConsistencyActionLimit: 3,
    apiConsistencyConcernLimit: 3,
    apiConsistencyFamilyLimit: 3,
    apiConsistencyPrimitiveLimit: 3,
    apiConsistencyFieldLimit: 4,
    packageBoundaryIssueLimit: 4,
    proReadinessIssueLimit: 4,
    proReadinessEntrypointLimit: 3,
  );

  final int readinessGateLimit;
  final int readinessActionLimit;
  final int sampleIssueLimit;
  final int sourceIssueLimit;
  final int simpleSourceIssueLimit;
  final int sourceMapIssueLimit;
  final int renamePlanVisibleLimit;
  final int apiConsistencyRowLimit;
  final int apiConsistencyActionLimit;
  final int apiConsistencyConcernLimit;
  final int apiConsistencyFamilyLimit;
  final int apiConsistencyPrimitiveLimit;
  final int apiConsistencyFieldLimit;
  final int packageBoundaryIssueLimit;
  final int proReadinessIssueLimit;
  final int proReadinessEntrypointLimit;

  RegistryHealthApiConsistencyPanelOptions get apiConsistencyPanelOptions =>
      RegistryHealthApiConsistencyPanelOptions(
        rowLimit: apiConsistencyRowLimit,
        actionLimit: apiConsistencyActionLimit,
        concernLimit: apiConsistencyConcernLimit,
        familyLimit: apiConsistencyFamilyLimit,
        primitiveLimit: apiConsistencyPrimitiveLimit,
        fieldLimit: apiConsistencyFieldLimit,
      );

  RegistryHealthDetailOptions copyWith({
    int? readinessGateLimit,
    int? readinessActionLimit,
    int? sampleIssueLimit,
    int? sourceIssueLimit,
    int? simpleSourceIssueLimit,
    int? sourceMapIssueLimit,
    int? renamePlanVisibleLimit,
    int? apiConsistencyRowLimit,
    int? apiConsistencyActionLimit,
    int? apiConsistencyConcernLimit,
    int? apiConsistencyFamilyLimit,
    int? apiConsistencyPrimitiveLimit,
    int? apiConsistencyFieldLimit,
    int? packageBoundaryIssueLimit,
    int? proReadinessIssueLimit,
    int? proReadinessEntrypointLimit,
  }) {
    return RegistryHealthDetailOptions(
      readinessGateLimit: readinessGateLimit ?? this.readinessGateLimit,
      readinessActionLimit: readinessActionLimit ?? this.readinessActionLimit,
      sampleIssueLimit: sampleIssueLimit ?? this.sampleIssueLimit,
      sourceIssueLimit: sourceIssueLimit ?? this.sourceIssueLimit,
      simpleSourceIssueLimit:
          simpleSourceIssueLimit ?? this.simpleSourceIssueLimit,
      sourceMapIssueLimit: sourceMapIssueLimit ?? this.sourceMapIssueLimit,
      renamePlanVisibleLimit:
          renamePlanVisibleLimit ?? this.renamePlanVisibleLimit,
      apiConsistencyRowLimit:
          apiConsistencyRowLimit ?? this.apiConsistencyRowLimit,
      apiConsistencyActionLimit:
          apiConsistencyActionLimit ?? this.apiConsistencyActionLimit,
      apiConsistencyConcernLimit:
          apiConsistencyConcernLimit ?? this.apiConsistencyConcernLimit,
      apiConsistencyFamilyLimit:
          apiConsistencyFamilyLimit ?? this.apiConsistencyFamilyLimit,
      apiConsistencyPrimitiveLimit:
          apiConsistencyPrimitiveLimit ?? this.apiConsistencyPrimitiveLimit,
      apiConsistencyFieldLimit:
          apiConsistencyFieldLimit ?? this.apiConsistencyFieldLimit,
      packageBoundaryIssueLimit:
          packageBoundaryIssueLimit ?? this.packageBoundaryIssueLimit,
      proReadinessIssueLimit:
          proReadinessIssueLimit ?? this.proReadinessIssueLimit,
      proReadinessEntrypointLimit:
          proReadinessEntrypointLimit ?? this.proReadinessEntrypointLimit,
    );
  }
}

class RegistryHealthSectionOptions {
  const RegistryHealthSectionOptions({
    this.showReadiness = true,
    this.showShowcaseCoverage = true,
    this.showSampleDiagnostics = true,
    this.showExampleMatrix = true,
    this.showNamingDiagnostics = true,
    this.showSummaries = true,
    this.showContractMatrices = true,
    this.showRuntimeDiagnostics = true,
    this.showCapabilityMatrix = true,
    this.showPackageBoundary = true,
    this.showProReadiness = true,
  });

  static const overview = RegistryHealthSectionOptions(
    showSampleDiagnostics: false,
    showNamingDiagnostics: false,
    showContractMatrices: false,
    showRuntimeDiagnostics: false,
    showCapabilityMatrix: false,
  );

  static const samples = RegistryHealthSectionOptions(
    showSummaries: false,
    showContractMatrices: false,
    showRuntimeDiagnostics: false,
    showCapabilityMatrix: false,
    showPackageBoundary: false,
    showProReadiness: false,
  );

  static const contracts = RegistryHealthSectionOptions(
    showReadiness: false,
    showShowcaseCoverage: false,
    showSampleDiagnostics: false,
    showExampleMatrix: false,
    showNamingDiagnostics: false,
    showRuntimeDiagnostics: false,
    showPackageBoundary: false,
    showProReadiness: false,
  );

  final bool showReadiness;
  final bool showShowcaseCoverage;
  final bool showSampleDiagnostics;
  final bool showExampleMatrix;
  final bool showNamingDiagnostics;
  final bool showSummaries;
  final bool showContractMatrices;
  final bool showRuntimeDiagnostics;
  final bool showCapabilityMatrix;
  final bool showPackageBoundary;
  final bool showProReadiness;

  RegistryHealthSectionOptions copyWith({
    bool? showReadiness,
    bool? showShowcaseCoverage,
    bool? showSampleDiagnostics,
    bool? showExampleMatrix,
    bool? showNamingDiagnostics,
    bool? showSummaries,
    bool? showContractMatrices,
    bool? showRuntimeDiagnostics,
    bool? showCapabilityMatrix,
    bool? showPackageBoundary,
    bool? showProReadiness,
  }) {
    return RegistryHealthSectionOptions(
      showReadiness: showReadiness ?? this.showReadiness,
      showShowcaseCoverage: showShowcaseCoverage ?? this.showShowcaseCoverage,
      showSampleDiagnostics:
          showSampleDiagnostics ?? this.showSampleDiagnostics,
      showExampleMatrix: showExampleMatrix ?? this.showExampleMatrix,
      showNamingDiagnostics:
          showNamingDiagnostics ?? this.showNamingDiagnostics,
      showSummaries: showSummaries ?? this.showSummaries,
      showContractMatrices: showContractMatrices ?? this.showContractMatrices,
      showRuntimeDiagnostics:
          showRuntimeDiagnostics ?? this.showRuntimeDiagnostics,
      showCapabilityMatrix: showCapabilityMatrix ?? this.showCapabilityMatrix,
      showPackageBoundary: showPackageBoundary ?? this.showPackageBoundary,
      showProReadiness: showProReadiness ?? this.showProReadiness,
    );
  }
}

class _RegistryHealthExportControls extends StatelessWidget {
  const _RegistryHealthExportControls({
    required this.snapshot,
    required this.sourceMapAuditFuture,
    required this.exportOptions,
  });

  final _RegistryHealthSnapshot snapshot;
  final Future<_RegistryHealthSourceMapAuditLoadState> sourceMapAuditFuture;
  final RegistryHealthExportOptions exportOptions;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RegistryHealthSourceMapAuditLoadState>(
      future: sourceMapAuditFuture,
      builder: (context, snapshot) {
        final state = _sourceMapAuditLoadStateFromSnapshot(snapshot);
        return RegistryHealthExportPresetControls(
          report: this.snapshot.report,
          extraSections: _registryHealthExportSectionsWithAsyncReports(
            this.snapshot,
            state,
          ),
          primaryOptions: exportOptions,
        );
      },
    );
  }
}

class _RegistryHealthReadinessMetricCard extends StatelessWidget {
  const _RegistryHealthReadinessMetricCard({
    required this.snapshot,
    required this.sourceMapAuditFuture,
  });

  final _RegistryHealthSnapshot snapshot;
  final Future<_RegistryHealthSourceMapAuditLoadState> sourceMapAuditFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RegistryHealthSourceMapAuditLoadState>(
      future: sourceMapAuditFuture,
      builder: (context, sourceMapSnapshot) {
        final state = _sourceMapAuditLoadStateFromSnapshot(sourceMapSnapshot);
        final report = _registryHealthReadinessReportForState(snapshot, state);

        return RegistryHealthMetricCard(
          label: 'Readiness',
          value: report.statusLabel,
          icon: report.isReady ? Icons.verified_outlined : Icons.rule_outlined,
          color: registryHealthReadinessStatusColor(report.status),
        );
      },
    );
  }
}

class _RegistryHealthSourceMapAuditMetricCard extends StatelessWidget {
  const _RegistryHealthSourceMapAuditMetricCard({
    required this.sourceMapAuditFuture,
  });

  final Future<_RegistryHealthSourceMapAuditLoadState> sourceMapAuditFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RegistryHealthSourceMapAuditLoadState>(
      future: sourceMapAuditFuture,
      builder: (context, snapshot) {
        final state = _sourceMapAuditLoadStateFromSnapshot(snapshot);
        final report = state.report;

        return RegistryHealthMetricCard(
          label: 'Source Map',
          value: report == null
              ? state.isUnavailable
                    ? 'Unavailable'
                    : 'Loading'
              : registryHealthShowcaseSourceMapAuditReportLabel(report),
          icon: report == null
              ? Icons.map_outlined
              : report.isReady
              ? Icons.map_outlined
              : Icons.error_outline,
          color: report == null
              ? state.isUnavailable
                    ? Colors.orange.shade800
                    : Colors.blueGrey.shade600
              : registryHealthShowcaseSourceMapAuditStatusColor(report),
        );
      },
    );
  }
}

class _RegistryHealthReadinessAssetPanel extends StatelessWidget {
  const _RegistryHealthReadinessAssetPanel({
    required this.snapshot,
    required this.sourceMapAuditFuture,
    required this.gateLimit,
    required this.actionLimit,
  });

  final _RegistryHealthSnapshot snapshot;
  final Future<_RegistryHealthSourceMapAuditLoadState> sourceMapAuditFuture;
  final int gateLimit;
  final int actionLimit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RegistryHealthSourceMapAuditLoadState>(
      future: sourceMapAuditFuture,
      builder: (context, sourceMapSnapshot) {
        final state = _sourceMapAuditLoadStateFromSnapshot(sourceMapSnapshot);
        return RegistryHealthReadinessPanel(
          report: _registryHealthReadinessReportForState(snapshot, state),
          gateLimit: gateLimit,
          actionLimit: actionLimit,
        );
      },
    );
  }
}

class _RegistryHealthSourceMapAuditAssetPanel extends StatelessWidget {
  const _RegistryHealthSourceMapAuditAssetPanel({
    required this.sourceMapAuditFuture,
    required this.issueLimit,
  });

  final Future<_RegistryHealthSourceMapAuditLoadState> sourceMapAuditFuture;
  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RegistryHealthSourceMapAuditLoadState>(
      future: sourceMapAuditFuture,
      builder: (context, snapshot) {
        final state = _sourceMapAuditLoadStateFromSnapshot(snapshot);
        final report = state.report;
        if (report != null) {
          return RegistryHealthShowcaseSourceMapAuditPanel(
            report: report,
            issueLimit: issueLimit,
          );
        }

        if (state.error != null) {
          return Text(
            'Source map audit unavailable: ${state.error}',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading source map audit...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

class _RegistryHealthSourceMapAuditLoadState {
  final RegistryHealthShowcaseSourceMapAuditReport? report;
  final Object? error;

  const _RegistryHealthSourceMapAuditLoadState({
    required this.report,
    required this.error,
  });

  bool get isUnavailable => error != null;
  bool get isLoading => report == null && error == null;
}

Map<String, dynamic> _registryHealthExportSectionsWithAsyncReports(
  _RegistryHealthSnapshot snapshot,
  _RegistryHealthSourceMapAuditLoadState state,
) {
  final readinessReport = _registryHealthReadinessReportForState(
    snapshot,
    state,
  );
  final readinessActionPlan = registryHealthReadinessActionPlan(
    readinessReport,
  );
  return {
    ...snapshot.healthExtraSections,
    'readiness': readinessReport.toJson(),
    'readinessActionPlan': readinessActionPlan.toJson(),
    'readinessActionChecklist': registryHealthReadinessActionChecklist(
      readinessActionPlan,
    ).toJson(),
    'sourceMapAudit': registryHealthShowcaseSourceMapAuditExportJson(
      report: state.report,
      error: state.error,
      isLoading: state.isLoading,
    ),
  };
}

RegistryHealthReadinessReport _registryHealthReadinessReportForState(
  _RegistryHealthSnapshot snapshot,
  _RegistryHealthSourceMapAuditLoadState state,
) {
  return registryHealthReadinessReport(
    registryReport: snapshot.report,
    thresholdReport: snapshot.showcaseThresholds,
    namingReport: snapshot.namingReport,
    renamePlanReport: snapshot.renamePlanReport,
    sampleAudit: snapshot.sampleAudit,
    sourceAudit: snapshot.sourceAudit,
    simpleSourceAudit: snapshot.simpleSourceAudit,
    chartExampleMatrix: snapshot.chartExampleMatrix,
    apiConsistencyReport: snapshot.apiConsistencyReport,
    sourceMapAudit: state.report,
    sourceMapError: state.error,
    sourceMapLoading: state.isLoading,
  );
}

_RegistryHealthSourceMapAuditLoadState _sourceMapAuditLoadStateFromSnapshot(
  AsyncSnapshot<_RegistryHealthSourceMapAuditLoadState> snapshot,
) {
  if (snapshot.hasError) {
    return _RegistryHealthSourceMapAuditLoadState(
      report: null,
      error: snapshot.error,
    );
  }

  return snapshot.data ??
      const _RegistryHealthSourceMapAuditLoadState(report: null, error: null);
}

_RegistryHealthSourceMapAuditLoadState _sourceMapAuditLoadStateFromSource(
  String source,
) {
  try {
    final sourceMap = registryHealthShowcaseSourceMapFromText(source);
    return _RegistryHealthSourceMapAuditLoadState(
      report: focusedRegistryHealthShowcaseSourceMapAuditReport(sourceMap),
      error: null,
    );
  } catch (error) {
    return _RegistryHealthSourceMapAuditLoadState(report: null, error: error);
  }
}

class _RegistryHealthSummaryChips extends StatelessWidget {
  const _RegistryHealthSummaryChips({required this.entries});

  final Map<String, int> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: _summaryChips(entries));
  }
}

List<Widget> _summaryChips(
  Map<String, int> entries, {
  String labelPrefix = '',
}) {
  return [
    for (final entry in entries.entries)
      Chip(
        label: Text('$labelPrefix${entry.key}: ${entry.value}'),
        visualDensity: VisualDensity.compact,
      ),
  ];
}
