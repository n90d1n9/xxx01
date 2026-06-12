import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/registry/chart_registration_bundle.dart'
    show allChartsBundle, coreChartsBundle;
import 'package:tenun/tenun_core.dart' hide coreChartsBundle;
import 'package:tenun_showcase/example/chart_sample_manifest_coverage.dart';
import 'package:tenun_showcase/example/chart_sample_registry_audit.dart';
import 'package:tenun_showcase/example/chart_sample_source_audit.dart';
import 'package:tenun_showcase/example/chart_sample_source_helpers.dart';
import 'package:tenun_showcase/example/chart_samples_registry.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_checklist.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_checklist_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_evidence.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_evidence_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_gate_builder.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_gate_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_gate_text.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_verification.dart';
import 'package:tenun_showcase/example/registry_health_api_conformance_verification_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_action_plan.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_action_plan_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_attention_table.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_concern_summary.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_concern_summary_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_family_remediation.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_family_remediation_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_field_remediation.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_field_remediation_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_implementation_plan.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_implementation_plan_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_overview.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_panel_options.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_pipeline.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_primitive_remediation.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_primitive_remediation_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_release_brief_builder.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_release_brief_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_release_brief_text.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_score_projection.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_score_projection_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_scorecard.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_scorecard_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_checklist.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_checklist_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_milestones.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_milestones_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_plan.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_plan_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_queue.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_queue_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_release_gates.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_release_gates_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_verification.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_source_verification_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_traceability.dart';
import 'package:tenun_showcase/example/registry_health_api_consistency_traceability_panel.dart';
import 'package:tenun_showcase/example/registry_health_api_contract_matrix.dart';
import 'package:tenun_showcase/example/registry_health_api_usage_matrix.dart';
import 'package:tenun_showcase/example/registry_health_capability_matrix.dart';
import 'package:tenun_showcase/example/registry_health_chart_example_matrix.dart';
import 'package:tenun_showcase/example/registry_health_example.dart';
import 'package:tenun_showcase/example/registry_health_export_controls.dart';
import 'package:tenun_showcase/example/registry_health_export_options.dart';
import 'package:tenun_showcase/example/registry_health_export_presets.dart';
import 'package:tenun_showcase/example/registry_health_export_summary.dart';
import 'package:tenun_showcase/example/registry_health_package_boundary_panel.dart';
import 'package:tenun_showcase/example/registry_health_payload_contract_matrix.dart';
import 'package:tenun_showcase/example/registry_health_pro_entrypoint_profiles_panel.dart';
import 'package:tenun_showcase/example/registry_health_pro_readiness_panel.dart';
import 'package:tenun_showcase/example/registry_health_readiness.dart';
import 'package:tenun_showcase/example/registry_health_readiness_action_checklist.dart';
import 'package:tenun_showcase/example/registry_health_readiness_action_plan.dart';
import 'package:tenun_showcase/example/registry_health_readiness_action_plan_panel.dart';
import 'package:tenun_showcase/example/registry_health_readiness_panel.dart';
import 'package:tenun_showcase/example/registry_health_sample_audit.dart';
import 'package:tenun_showcase/example/registry_health_sample_source_audit.dart';
import 'package:tenun_showcase/example/registry_health_simple_source_audit.dart';
import 'package:tenun_showcase/example/registry_health_showcase_backlog.dart';
import 'package:tenun_showcase/example/registry_health_showcase_coverage.dart';
import 'package:tenun_showcase/example/registry_health_showcase_gap_matrix.dart';
import 'package:tenun_showcase/example/registry_health_showcase_naming.dart';
import 'package:tenun_showcase/example/registry_health_showcase_rename_plan.dart';
import 'package:tenun_showcase/example/registry_health_showcase_rename_plan_panel.dart';
import 'package:tenun_showcase/example/registry_health_showcase_source_location.dart';
import 'package:tenun_showcase/example/registry_health_showcase_source_map.dart';
import 'package:tenun_showcase/example/registry_health_showcase_source_map_audit.dart';
import 'package:tenun_showcase/example/registry_health_showcase_source_map_audit_panel.dart';
import 'package:tenun_showcase/example/registry_health_showcase_thresholds.dart';
import 'package:tenun_showcase/example/registry_health_widgets.dart';
import 'package:tenun_showcase/example/showcase_source_panel.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_families.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_source_audit.dart';
import 'package:tenun_pro/tenun_pro.dart'
    show
        TenunPackageBoundaryAudit,
        TenunPackageBoundaryManifestSummary,
        TenunPackageBoundarySectionSummary,
        TenunProCorePublicApiLeak,
        TenunProManifestValidationIssue,
        TenunProManifestValidationReport,
        TenunProManifestValidationSeverity,
        TenunProReleaseReadinessAudit,
        auditTenunPackageBoundary,
        auditTenunProDistributionReadiness,
        auditTenunProMigrationReadiness,
        auditTenunProReleaseReadiness;

void main() {
  test('capability helpers sort rows and expose compact feature labels', () {
    const line = ChartCapabilities(
      type: ChartType.line,
      typeString: 'line',
      dataShape: ChartSeriesDataShape.cartesian,
      isRegistered: true,
      supportsSampling: true,
      supportsZoom: true,
      supportsDrilldown: false,
      supportsLegend: true,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.cartesian,
    );
    const sankey = ChartCapabilities(
      type: ChartType.sankey,
      typeString: 'sankey',
      dataShape: ChartSeriesDataShape.flow,
      isRegistered: true,
      supportsSampling: false,
      supportsZoom: false,
      supportsDrilldown: true,
      supportsLegend: false,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.hierarchyFlow,
    );
    const bar = ChartCapabilities(
      type: ChartType.bar,
      typeString: 'bar',
      dataShape: ChartSeriesDataShape.cartesian,
      isRegistered: true,
      supportsSampling: true,
      supportsZoom: true,
      supportsDrilldown: false,
      supportsLegend: true,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.cartesian,
    );

    final sorted = sortedRegistryHealthCapabilities([line, sankey, bar]);

    expect(sorted.map((item) => item.typeString), ['bar', 'line', 'sankey']);
    expect(registryHealthCapabilityApiLabel(line), 'cartesian');
    expect(registryHealthCapabilityApiLabel(sankey), 'hierarchyFlow');
    expect(registryHealthCapabilityFeatureLabels(line), [
      'sample',
      'zoom',
      'legend',
      'tip',
    ]);
    expect(registryHealthCapabilityFeatureLabels(sankey), ['drill', 'tip']);
  });

  test('package boundary helpers expose status, counts, and json payload', () {
    const cleanAudit = TenunPackageBoundaryAudit(
      coreTypes: {ChartType.line},
      proTypes: {ChartType.candlestick},
      issues: [],
    );
    const issueAudit = TenunPackageBoundaryAudit(
      coreTypes: {ChartType.line},
      proTypes: {ChartType.line, ChartType.candlestick},
      issues: ['line overlaps', 'core tag leak'],
    );
    const manifestAudit = TenunPackageBoundaryAudit(
      coreTypes: {ChartType.line},
      proTypes: {ChartType.candlestick},
      issues: [],
      manifest: TenunPackageBoundaryManifestSummary(
        apacheCorePackage: 'tenun',
        commercialProPackage: 'tenun_pro',
        apacheCoreCount: 1,
        commercialProCount: 1,
        commercialProSectionIds: [
          'financial',
          'enterprise',
          'financial',
          '',
          'hierarchy',
        ],
        commercialProSections: [
          TenunPackageBoundarySectionSummary(
            id: 'financial',
            label: 'Financial',
            entitlement: 'financial',
            chartCount: 2,
            chartTypes: ['ohlc', 'candlestick', 'candlestick'],
          ),
          TenunPackageBoundarySectionSummary(
            id: 'enterprise',
            label: 'Enterprise',
            entitlement: 'enterpriseAnalytics',
            chartCount: 1,
            chartTypes: ['heatmap'],
          ),
          TenunPackageBoundarySectionSummary(
            id: 'financial',
            label: 'Duplicate Financial',
            entitlement: 'financial',
            chartCount: 1,
            chartTypes: ['kagi'],
          ),
          TenunPackageBoundarySectionSummary(
            id: '',
            label: 'Ignored',
            entitlement: 'financial',
            chartCount: 1,
            chartTypes: ['renko'],
          ),
        ],
      ),
    );

    expect(registryHealthPackageBoundaryStatusLabel(cleanAudit), 'Clean');
    expect(
      registryHealthPackageBoundarySummary(cleanAudit),
      'Apache core and Commercial Pro chart types are separated with no catalog overlap.',
    );
    expect(registryHealthPackageBoundaryCountLabel('Core', 1), 'Core: 1 type');
    expect(registryHealthPackageBoundaryCountLabel('Pro', 2), 'Pro: 2 types');
    expect(registryHealthPackageBoundaryStatusLabel(issueAudit), 'Issues');
    expect(registryHealthPackageBoundaryVisibleIssues(issueAudit, limit: 1), [
      'line overlaps',
    ]);

    final json = registryHealthPackageBoundaryJson(issueAudit);

    expect(json, containsPair('status', 'issues'));
    expect(
      json,
      containsPair('summary', '2 package boundary issues need review.'),
    );
    expect(json, containsPair('coreTypes', ['line']));
    expect(json, containsPair('proTypes', ['candlestick', 'line']));
    final ownership = json['ownership'] as Map<String, dynamic>;
    expect(ownership['core'], containsPair('previewLabel', 'Core owns: line'));
    expect(ownership['core'], containsPair('types', ['line']));
    expect(ownership['pro'], containsPair('count', 2));
    expect(ownership['pro'], containsPair('types', ['candlestick', 'line']));
    expect(ownership['overlap'], containsPair('previewLabel', 'Overlap: line'));
    expect(ownership['proSections'], isEmpty);
    expect(
      registryHealthPackageBoundaryManifestLabel(manifestAudit),
      'Manifest: tenun -> tenun_pro',
    );
    expect(registryHealthPackageBoundaryManifestSectionIds(manifestAudit), [
      'financial',
      'enterprise',
      'hierarchy',
    ]);
    expect(
      registryHealthPackageBoundaryManifestSectionsLabel(
        manifestAudit,
        visibleLimit: 2,
      ),
      'Pro sections: financial, enterprise +1',
    );
    final sectionOwnership = registryHealthPackageBoundarySectionOwnerships(
      manifestAudit,
    );
    expect(sectionOwnership.map((section) => section.id), [
      'financial',
      'enterprise',
    ]);
    expect(sectionOwnership.first.chartTypes, ['candlestick', 'ohlc']);
    expect(
      sectionOwnership.first.previewLabel(visibleLimit: 1),
      'Financial: candlestick +1',
    );
    expect(
      registryHealthPackageBoundarySectionOwnershipLabels(
        manifestAudit,
        visibleLimit: 1,
        typeLimit: 1,
      ),
      ['Financial: candlestick +1'],
    );
    expect(
      registryHealthPackageBoundaryTypePreviewLabel('Core owns', {
        ChartType.line,
        ChartType.bar,
        ChartType.area,
      }, visibleLimit: 2),
      'Core owns: area, bar +1',
    );
    expect(
      registryHealthPackageBoundaryTypePreviewLabel(
        'Core owns',
        const <ChartType>{},
      ),
      isNull,
    );
    final compactOwnership = registryHealthPackageBoundaryOwnershipJson(
      issueAudit,
      previewLimit: 1,
    );
    expect(
      compactOwnership['pro'],
      containsPair('previewLabel', 'Pro owns: candlestick +1'),
    );
    expect(
      registryHealthPackageBoundaryOwnershipJson(manifestAudit)['proSections'],
      contains(containsPair('previewLabel', 'Financial: candlestick, ohlc')),
    );
    expect(registryHealthPackageBoundaryManifestLabel(cleanAudit), isNull);

    final liveJson = registryHealthPackageBoundaryJson(
      auditTenunPackageBoundary(),
    );

    expect(liveJson['manifest'], containsPair('apacheCorePackage', 'tenun'));
    expect(liveJson['ownership'], contains('core'));
    expect(liveJson['ownership'], contains('pro'));
    expect(liveJson['ownership'], containsPair('proSections', isNotEmpty));
    expect(
      liveJson['manifest'],
      containsPair('commercialProPackage', 'tenun_pro'),
    );
  });

  testWidgets('package boundary panel limits visible issues', (tester) async {
    const audit = TenunPackageBoundaryAudit(
      coreTypes: {ChartType.line, ChartType.bar},
      proTypes: {ChartType.line, ChartType.candlestick},
      issues: ['line overlaps', 'core tag leak'],
      manifest: TenunPackageBoundaryManifestSummary(
        apacheCorePackage: 'tenun',
        commercialProPackage: 'tenun_pro',
        apacheCoreCount: 2,
        commercialProCount: 2,
        commercialProSectionIds: ['financial', 'enterprise'],
        commercialProSections: [
          TenunPackageBoundarySectionSummary(
            id: 'financial',
            label: 'Financial',
            entitlement: 'financial',
            chartCount: 2,
            chartTypes: ['line', 'candlestick'],
          ),
          TenunPackageBoundarySectionSummary(
            id: 'enterprise',
            label: 'Enterprise',
            entitlement: 'enterpriseAnalytics',
            chartCount: 1,
            chartTypes: ['heatmap'],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryHealthPackageBoundaryPanel(audit: audit, issueLimit: 1),
        ),
      ),
    );

    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Core: 2 types'), findsOneWidget);
    expect(find.text('Pro: 2 types'), findsOneWidget);
    expect(find.text('Overlap: 1 type'), findsOneWidget);
    expect(find.text('Manifest: tenun -> tenun_pro'), findsOneWidget);
    expect(find.text('Pro sections: financial, enterprise'), findsOneWidget);
    expect(find.text('Core owns: bar, line'), findsOneWidget);
    expect(find.text('Pro owns: candlestick, line'), findsOneWidget);
    expect(find.text('Financial: candlestick, line'), findsOneWidget);
    expect(find.text('Enterprise: heatmap'), findsOneWidget);
    expect(find.text('line overlaps'), findsOneWidget);
    expect(find.text('core tag leak'), findsNothing);
    expect(find.text('+1 more'), findsOneWidget);
  });

  test('pro readiness helpers expose status, layers, and json payload', () {
    final cleanAudit = auditTenunProReleaseReadiness();
    final issueAudit = _blockedProReadinessAudit();

    expect(registryHealthProReadinessStatusLabel(cleanAudit), 'Manifest Ready');
    expect(
      registryHealthProReadinessSummary(cleanAudit),
      'Pro manifest, package boundary, adapters, and implementation migration are ready.',
    );
    expect(
      registryHealthProReadinessBooleanLabel('Manifest', true),
      'Manifest: Ready',
    );
    expect(
      registryHealthProReadinessBooleanLabel('Manifest', false),
      'Manifest: Review',
    );
    expect(registryHealthProReadinessStatusLabel(issueAudit), 'Blocked');
    expect(registryHealthProReadinessVisibleIssues(issueAudit, limit: 2), [
      'line overlaps',
      'manifest broken',
    ]);
    expect(
      registryHealthProReadinessNextBatchLabel(cleanAudit),
      'Next implementation batch: none',
    );

    final layerLabel = registryHealthProReadinessLayerLabel(
      cleanAudit.migrationReadiness.layerStatuses.first,
    );
    final profiles = registryHealthProEntrypointProfiles();
    final json = registryHealthProReadinessJson(
      issueAudit,
      entrypointProfiles: profiles,
    );

    expect(layerLabel, startsWith('Public API:'));
    expect(json, containsPair('status', 'blocked'));
    expect(json, containsPair('statusLabel', 'Blocked'));
    expect(json, containsPair('strictReleaseIssueCount', 4));
    expect(json['distributionReadiness'], containsPair('isReady', true));
    expect(json['entrypoints'], containsPair('entrypointCount', 6));
    expect(
      json['entrypoints'],
      containsPair('uniqueChartTypeCount', greaterThan(0)),
    );
    expect(
      json,
      containsPair(
        'runtimeScanNote',
        registryHealthProReadinessRuntimeScanNote,
      ),
    );
    expect(json['layerLabels'], isNotEmpty);
  });

  test('pro entrypoint profile helpers expose labels and export json', () {
    final profiles = registryHealthProEntrypointProfiles();
    final labels = registryHealthProEntrypointProfileLabels(
      profiles,
      visibleLimit: 3,
    );
    final json = registryHealthProEntrypointProfilesJson(
      profiles,
      visibleLimit: 2,
    );

    expect(
      registryHealthProEntrypointProfileSummary(profiles),
      contains('commercial entrypoints'),
    );
    expect(labels.length, 3);
    expect(labels, contains(startsWith('Financial:')));
    expect(labels.join('\n'), contains('registerTenunProFinancialCharts'));
    expect(
      registryHealthProEntrypointProfileLabels(profiles, visibleLimit: 0),
      isEmpty,
    );
    expect(json, containsPair('entrypointCount', profiles.length));
    expect(json, containsPair('uniqueChartTypeCount', greaterThan(0)));
    expect(json['labels'], hasLength(2));
    expect(
      json['registrationFunctions'],
      contains('registerTenunProFinancialCharts'),
    );
    expect(
      json['importStatements'],
      contains("import 'package:tenun_pro/tenun_pro_financial.dart';"),
    );
    expect(
      json['distributionChannels'],
      contains(containsPair('id', 'private_hosted')),
    );
    expect(
      json['distributionChannels'],
      contains(containsPair('id', 'premium_git')),
    );
    expect(
      json['distributionReadiness'],
      containsPair('hasRecommendedPrivateHostedDistribution', true),
    );
    expect(
      json['distributionReadiness'],
      containsPair('channelIds', ['private_hosted', 'premium_git']),
    );
    expect(
      json['packageInstalls'],
      contains(
        containsPair('flutterPubAddCommand', 'flutter pub add tenun_pro'),
      ),
    );
    expect(
      json['packageInstalls'],
      contains(
        containsPair(
          'recommendedDistribution',
          containsPair('id', 'private_hosted'),
        ),
      ),
    );
    expect(
      json['packageInstalls'],
      contains(
        containsPair(
          'distributionOptions',
          contains(containsPair('id', 'premium_git')),
        ),
      ),
    );
    expect(
      json['packageInstalls'],
      contains(
        containsPair(
          'gitPubspecSnippet',
          contains('git@github.com:your-org/tenun_pro.git'),
        ),
      ),
    );
    expect(
      json['onboardingGuides'],
      contains(
        containsPair('stepIds', [
          'install_package',
          'configure_license',
          'import_entrypoint',
          'register_charts',
          'verify_scope',
        ]),
      ),
    );
    expect(
      json['onboardingGuides'],
      contains(
        containsPair(
          'steps',
          contains(
            containsPair('snippet', contains('TenunProLicenseStore.configure')),
          ),
        ),
      ),
    );
    expect(
      json['quickStarts'],
      contains(
        containsPair(
          'permissiveRegistrationCall',
          'registerTenunProFinancialCharts();',
        ),
      ),
    );
    expect(
      json['quickStarts'],
      contains(containsPair('strictSetupSnippet', contains('financial'))),
    );
    expect(
      json['quickStarts'],
      contains(
        containsPair(
          'licensePolicyName',
          'TenunProLicensePolicy.requireConfigured',
        ),
      ),
    );
    expect(
      json['profiles'],
      contains(containsPair('entitlement', 'financial')),
    );
    expect(
      json['profiles'],
      contains(
        containsPair(
          'publicEntrypointPath',
          'tenun_pro/lib/tenun_pro_financial.dart',
        ),
      ),
    );
  });

  testWidgets('pro readiness panel limits strict release issues', (
    tester,
  ) async {
    final audit = _blockedProReadinessAudit();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryHealthProReadinessPanel(
            audit: audit,
            entrypointProfiles: registryHealthProEntrypointProfiles(),
            issueLimit: 1,
          ),
        ),
      ),
    );

    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Manifest: Review'), findsOneWidget);
    expect(find.text('Adapters: Ready'), findsOneWidget);
    expect(find.text('Implementation: Ready'), findsOneWidget);
    expect(find.textContaining('Financial:'), findsOneWidget);
    expect(
      find.textContaining('registerTenunProFinancialCharts'),
      findsOneWidget,
    );
    expect(find.text('line overlaps'), findsOneWidget);
    expect(find.text('manifest broken'), findsNothing);
    expect(find.text('+3 more'), findsOneWidget);
    expect(
      find.text(registryHealthProReadinessRuntimeScanNote),
      findsOneWidget,
    );
  });

  test('payload contract helpers label strategies and compact flags', () {
    const plainData = ChartPayloadContract(
      type: ChartType.line,
      dataShape: ChartSeriesDataShape.cartesian,
      seriesStrategy: ChartPayloadSeriesStrategy.dataFields,
      dataFieldPriority: ['data'],
    );
    const shortcutData = ChartPayloadContract(
      type: ChartType.treemap,
      dataShape: ChartSeriesDataShape.hierarchical,
      seriesStrategy: ChartPayloadSeriesStrategy.dataFields,
      dataFieldPriority: ['nodes', 'data'],
    );
    const nodeLink = ChartPayloadContract(
      type: ChartType.sankey,
      dataShape: ChartSeriesDataShape.flow,
      seriesStrategy: ChartPayloadSeriesStrategy.nodeLink,
    );
    const namedCollection = ChartPayloadContract(
      type: ChartType.choropleth,
      dataShape: ChartSeriesDataShape.geospatial,
      seriesStrategy: ChartPayloadSeriesStrategy.namedCollection,
      namedCollectionField: 'regions',
    );
    const optional = ChartPayloadContract(
      type: ChartType.gauge,
      dataShape: ChartSeriesDataShape.radial,
      seriesStrategy: ChartPayloadSeriesStrategy.dataFields,
      dataFieldPriority: ['data'],
      requiresSeries: false,
    );

    expect(registryHealthPayloadFieldsLabel(plainData), 'data');
    expect(registryHealthPayloadFieldsLabel(shortcutData), 'nodes | data');
    expect(registryHealthPayloadFieldsLabel(nodeLink), 'nodes + links');
    expect(registryHealthPayloadFieldsLabel(namedCollection), 'regions');
    expect(registryHealthHasSpecialShortcutFields(plainData), isFalse);
    expect(registryHealthHasSpecialShortcutFields(shortcutData), isTrue);
    expect(registryHealthHasSpecialShortcutFields(nodeLink), isTrue);
    expect(registryHealthPayloadFlagLabels(plainData), ['series']);
    expect(registryHealthPayloadFlagLabels(shortcutData), [
      'series',
      'shortcut',
    ]);
    expect(registryHealthPayloadFlagLabels(optional), ['optional']);
  });

  test('payload contract sorter groups by shape then chart type', () {
    const contracts = [
      ChartPayloadContract(
        type: ChartType.sankey,
        dataShape: ChartSeriesDataShape.flow,
        seriesStrategy: ChartPayloadSeriesStrategy.nodeLink,
      ),
      ChartPayloadContract(
        type: ChartType.line,
        dataShape: ChartSeriesDataShape.cartesian,
        seriesStrategy: ChartPayloadSeriesStrategy.dataFields,
        dataFieldPriority: ['data'],
      ),
      ChartPayloadContract(
        type: ChartType.bar,
        dataShape: ChartSeriesDataShape.cartesian,
        seriesStrategy: ChartPayloadSeriesStrategy.dataFields,
        dataFieldPriority: ['data'],
      ),
    ];

    final sorted = sortedRegistryHealthPayloadContracts(contracts);

    expect(sorted.map((item) => item.typeString), ['bar', 'line', 'sankey']);
  });

  test('api contract helpers sort families and summarize field coverage', () {
    final sorted = sortedRegistryHealthApiContracts([
      ChartApiContracts.financial,
      ChartApiContracts.simpleWidget,
      ChartApiContracts.optionConfig,
    ]);

    expect(sorted.map((item) => item.name), [
      'optionConfig',
      'simpleWidget',
      'financial',
    ]);
    expect(
      registryHealthApiSupportsCategory(
        ChartApiContracts.simpleWidget,
        ChartApiFieldCategory.accessibility,
      ),
      isTrue,
    );
    expect(
      registryHealthApiSupportsCategory(
        ChartApiContracts.simpleWidget,
        ChartApiFieldCategory.runtime,
      ),
      isFalse,
    );
    expect(registryHealthApiCategoryLabels(ChartApiContracts.simpleWidget), [
      'display 8',
      'interaction 5',
      'a11y 2',
      'motion 2',
      'format 4',
      'layout 5',
    ]);
    expect(registryHealthApiRecommendedLabels(ChartApiContracts.optionConfig), [
      'type',
      'series',
      'theme',
      'tooltip',
      '+1',
    ]);
  });

  test('api usage helpers group chart capabilities by contract family', () {
    const line = ChartCapabilities(
      type: ChartType.line,
      typeString: 'line',
      dataShape: ChartSeriesDataShape.cartesian,
      isRegistered: true,
      supportsSampling: true,
      supportsZoom: true,
      supportsDrilldown: false,
      supportsLegend: true,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.cartesian,
    );
    const bar = ChartCapabilities(
      type: ChartType.bar,
      typeString: 'bar',
      dataShape: ChartSeriesDataShape.cartesian,
      isRegistered: true,
      supportsSampling: true,
      supportsZoom: true,
      supportsDrilldown: false,
      supportsLegend: true,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.cartesian,
    );
    const sankey = ChartCapabilities(
      type: ChartType.sankey,
      typeString: 'sankey',
      dataShape: ChartSeriesDataShape.flow,
      isRegistered: true,
      supportsSampling: false,
      supportsZoom: false,
      supportsDrilldown: true,
      supportsLegend: false,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.hierarchyFlow,
    );

    final rows = registryHealthApiUsageRows([
      sankey,
      line,
      bar,
    ], exampleLimit: 1);

    expect(rows.map((row) => row.contractName), ['cartesian', 'hierarchyFlow']);
    expect(rows.first.chartCount, 2);
    expect(rows.first.shapes, ['cartesian']);
    expect(rows.first.examples, ['bar', '+1']);
    expect(registryHealthApiUsageShapes([sankey, line]), ['cartesian', 'flow']);
  });

  test('api consistency report groups contracts by shared concerns', () {
    const line = ChartCapabilities(
      type: ChartType.line,
      typeString: 'line',
      dataShape: ChartSeriesDataShape.cartesian,
      isRegistered: true,
      supportsSampling: true,
      supportsZoom: true,
      supportsDrilldown: false,
      supportsLegend: true,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.cartesian,
    );
    const gauge = ChartCapabilities(
      type: ChartType.gauge,
      typeString: 'gauge',
      dataShape: ChartSeriesDataShape.radial,
      isRegistered: true,
      supportsSampling: false,
      supportsZoom: false,
      supportsDrilldown: false,
      supportsLegend: true,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.polar,
    );
    const calendar = ChartCapabilities(
      type: ChartType.calendar,
      typeString: 'calendar',
      dataShape: ChartSeriesDataShape.calendar,
      isRegistered: true,
      supportsSampling: false,
      supportsZoom: false,
      supportsDrilldown: false,
      supportsLegend: false,
      supportsTooltip: true,
      supportsRuntimeSwitching: true,
      apiContract: ChartApiContracts.optionConfig,
    );

    final report = registryHealthApiConsistencyReport([
      line,
      gauge,
      calendar,
    ], exampleLimit: 1);
    final optionRow = report.rows.singleWhere(
      (row) => row.contractName == 'optionConfig',
    );
    final actionPlan = registryHealthApiConsistencyActionPlan(report);
    final scorecard = registryHealthApiConsistencyScorecard(report);
    final concernSummary = registryHealthApiConsistencyConcernSummaryReport(
      report,
    );
    final scoreProjection = registryHealthApiConsistencyScoreProjection(
      scorecard: scorecard,
      actionPlan: actionPlan,
    );
    final familyRemediation =
        registryHealthApiConsistencyFamilyRemediationReport(actionPlan);
    final primitiveRemediation =
        registryHealthApiConsistencyPrimitiveRemediationReport(actionPlan);
    final fieldRemediation = registryHealthApiConsistencyFieldRemediationReport(
      actionPlan,
    );
    final implementationPlan = registryHealthApiConsistencyImplementationPlan(
      actionPlan,
    );
    final traceabilityReport = registryHealthApiConsistencyTraceabilityReport(
      implementationPlan,
    );
    final sourceQueueReport = registryHealthApiConsistencySourceQueueReport(
      traceabilityReport,
    );
    final sourcePlanReport = registryHealthApiConsistencySourcePlanReport(
      sourceQueueReport,
    );
    final sourceChecklistReport =
        registryHealthApiConsistencySourceChecklistReport(sourcePlanReport);
    final sourceMilestonesReport =
        registryHealthApiConsistencySourceMilestonesReport(
          sourceChecklistReport,
        );
    final sourceReleaseGatesReport =
        registryHealthApiConsistencySourceReleaseGatesReport(
          sourceMilestonesReport,
        );
    final sourceVerificationReport =
        registryHealthApiConsistencySourceVerificationReport(
          sourceReleaseGatesReport,
        );
    final conformanceReport = registryHealthApiConformanceReport(report);
    final conformanceGateReport = registryHealthApiConformanceGateReport(
      conformanceReport,
    );
    final conformanceVerificationReport =
        registryHealthApiConformanceVerificationReport(conformanceGateReport);
    final conformanceChecklistReport =
        registryHealthApiConformanceChecklistReport(
          conformanceVerificationReport,
        );
    final conformanceEvidenceReport =
        registryHealthApiConformanceEvidenceReport(conformanceChecklistReport);
    final releaseBriefReport = registryHealthApiConsistencyReleaseBriefReport(
      scoreProjection: scoreProjection,
      conformanceGate: conformanceGateReport,
      sourceReleaseGates: sourceReleaseGatesReport,
      sourceVerification: sourceVerificationReport,
      conformanceEvidence: conformanceEvidenceReport,
    );
    final pipeline = registryHealthApiConsistencyPipeline(report);
    final pipelineJsonSections = pipeline.toJsonSections();
    final emptyStateSummary = concernSummary.summaries.singleWhere(
      (summary) => summary.key == 'emptyState',
    );
    final actionPlanJson = actionPlan.toJson(itemLimit: 1);
    final scorecardJson = scorecard.toJson();
    final scoreProjectionJson = scoreProjection.toJson();
    final familyRemediationJson = familyRemediation.toJson(familyLimit: 1);
    final familyChecklistText = registryHealthApiConsistencyFamilyChecklistText(
      familyRemediation,
      familyLimit: 1,
    );
    final primitiveRemediationJson = primitiveRemediation.toJson(
      primitiveLimit: 1,
    );
    final primitiveChecklistText =
        registryHealthApiConsistencyPrimitiveChecklistText(
          primitiveRemediation,
          primitiveLimit: 1,
        );
    final fieldRemediationJson = fieldRemediation.toJson(fieldLimit: 1);
    final fieldChecklistText = registryHealthApiConsistencyFieldChecklistText(
      fieldRemediation,
      fieldLimit: 1,
    );
    final implementationPlanJson = implementationPlan.toJson(
      actionLimit: 1,
      familyLimit: 1,
      primitiveLimit: 1,
      fieldLimit: 1,
    );
    final implementationChecklistText =
        registryHealthApiConsistencyImplementationChecklistText(
          implementationPlan,
          actionLimit: 1,
          familyLimit: 1,
          primitiveLimit: 1,
          fieldLimit: 1,
        );
    final traceabilityJson = traceabilityReport.toJson(traceLimit: 1);
    final traceabilityText = registryHealthApiConsistencyTraceabilityText(
      traceabilityReport,
      traceLimit: 1,
    );
    final sourceQueueJson = sourceQueueReport.toJson(sourceLimit: 1);
    final sourceQueueText = registryHealthApiConsistencySourceQueueText(
      sourceQueueReport,
      sourceLimit: 1,
    );
    final sourcePlanJson = sourcePlanReport.toJson(batchLimit: 1);
    final sourcePlanText = registryHealthApiConsistencySourcePlanText(
      sourcePlanReport,
      batchLimit: 1,
    );
    final sourceChecklistJson = sourceChecklistReport.toJson(stageLimit: 1);
    final sourceChecklistText = registryHealthApiConsistencySourceChecklistText(
      sourceChecklistReport,
      stageLimit: 1,
    );
    final sourceMilestonesJson = sourceMilestonesReport.toJson(
      milestoneLimit: 1,
    );
    final sourceMilestonesText =
        registryHealthApiConsistencySourceMilestonesText(
          sourceMilestonesReport,
          milestoneLimit: 1,
        );
    final sourceReleaseGatesJson = sourceReleaseGatesReport.toJson(
      gateLimit: 1,
    );
    final sourceReleaseGatesText =
        registryHealthApiConsistencySourceReleaseGatesText(
          sourceReleaseGatesReport,
          gateLimit: 1,
        );
    final sourceVerificationJson = sourceVerificationReport.toJson(
      verificationLimit: 1,
    );
    final sourceVerificationText =
        registryHealthApiConsistencySourceVerificationText(
          sourceVerificationReport,
          verificationLimit: 1,
        );
    final conformanceJson = conformanceReport.toJson(caseLimit: 1);
    final conformanceText = registryHealthApiConformanceText(
      conformanceReport,
      caseLimit: 1,
    );
    final conformanceGateJson = conformanceGateReport.toJson(gateLimit: 1);
    final conformanceGateText = registryHealthApiConformanceGateText(
      conformanceGateReport,
      gateLimit: 1,
    );
    final conformanceVerificationJson = conformanceVerificationReport.toJson(
      verificationLimit: 1,
    );
    final conformanceVerificationText =
        registryHealthApiConformanceVerificationText(
          conformanceVerificationReport,
          verificationLimit: 1,
        );
    final conformanceChecklistJson = conformanceChecklistReport.toJson(
      stepLimit: 1,
    );
    final conformanceChecklistText = registryHealthApiConformanceChecklistText(
      conformanceChecklistReport,
      stepLimit: 1,
    );
    final conformanceEvidenceJson = conformanceEvidenceReport.toJson(
      evidenceLimit: 1,
    );
    final conformanceEvidenceText = registryHealthApiConformanceEvidenceText(
      conformanceEvidenceReport,
      evidenceLimit: 1,
    );
    final releaseBriefJson = releaseBriefReport.toJson(itemLimit: 1);
    final releaseBriefText = registryHealthApiConsistencyReleaseBriefText(
      releaseBriefReport,
      itemLimit: 2,
    );
    final concernSummaryJson = concernSummary.toJson(summaryLimit: 1);
    final checklistText = registryHealthApiConsistencyActionChecklistText(
      actionPlan,
      itemLimit: 1,
    );
    final json = report.toJson(rowLimit: 1);

    expect(report.contractCount, 3);
    expect(report.concernCount, registryHealthApiConsistencyConcerns.length);
    expect(report.chartCount, 3);
    expect(report.issueCount, greaterThanOrEqualTo(0));
    expect(optionRow.chartExamples, ['calendar']);
    expect(optionRow.missingConcerns.map((concern) => concern.key), [
      'emptyState',
      'semantics',
      'animation',
      'formatting',
      'interaction',
    ]);
    expect(optionRow.requiredMissingCount, 0);
    expect(optionRow.advisoryMissingCount, 5);
    expect(optionRow.status, RegistryHealthApiConsistencyStatus.warning);
    expect(report.requiredIssueCount, 0);
    expect(report.advisoryIssueCount, 5);
    expect(registryHealthApiConsistencyAction(optionRow), isNotEmpty);
    expect(scorecard.applicableConcernCount, 24);
    expect(scorecard.supportedConcernCount, 19);
    expect(scorecard.requiredGapCount, 0);
    expect(scorecard.advisoryGapCount, 5);
    expect(scorecard.totalWeight, 84);
    expect(scorecard.advisoryPenaltyWeight, closeTo(6.65, 0.001));
    expect(scorecard.scorePercent, 92);
    expect(scorecard.grade, RegistryHealthApiConsistencyScoreGrade.good);
    expect(scorecardJson, containsPair('grade', 'good'));
    expect(scorecardJson, containsPair('scorePercent', 92));
    expect(scoreProjection.totalImpactWeight, closeTo(6.65, 0.001));
    expect(scoreProjection.totalImpactLabel, '6.7');
    expect(scoreProjection.projectedScorePercent, 100);
    expect(scoreProjection.projectedGapCount, 0);
    expect(scoreProjection.projectedRequiredGapCount, 0);
    expect(scoreProjection.projectedAdvisoryGapCount, 0);
    expect(scoreProjection.isProjectedBlocked, isFalse);
    expect(scoreProjection.statusLabel, 'All gaps resolved');
    expect(
      scoreProjection.projectedGrade,
      RegistryHealthApiConsistencyScoreGrade.excellent,
    );
    expect(scoreProjection.steps.map((step) => step.phase), [
      RegistryHealthApiConsistencyActionPhase.later,
    ]);
    expect(scoreProjection.steps.single.phaseGapCount, 5);
    expect(scoreProjection.steps.single.phaseRequiredGapCount, 0);
    expect(scoreProjection.steps.single.phaseAdvisoryGapCount, 5);
    expect(scoreProjection.steps.single.resolvedAdvisoryGapCount, 5);
    expect(scoreProjection.steps.single.projectedAdvisoryGapCount, 0);
    expect(scoreProjection.steps.single.impactWeight, closeTo(6.65, 0.001));
    expect(scoreProjection.steps.single.projectedScorePercent, 100);
    expect(
      scoreProjection.steps.single.resolutionLabel,
      'Resolves 5 advisory gaps',
    );
    expect(scoreProjection.steps.single.statusLabel, 'All gaps resolved');
    expect(
      scoreProjection.steps.single.projectedGrade,
      RegistryHealthApiConsistencyScoreGrade.excellent,
    );
    expect(scoreProjectionJson, containsPair('projectedScorePercent', 100));
    expect(scoreProjectionJson, containsPair('projectedGapCount', 0));
    expect(
      scoreProjectionJson,
      containsPair('statusLabel', 'All gaps resolved'),
    );
    expect(scoreProjectionJson, containsPair('totalImpactLabel', '6.7'));
    expect(
      (scoreProjectionJson['steps'] as List).single,
      containsPair('resolutionLabel', 'Resolves 5 advisory gaps'),
    );
    expect(familyRemediation.familyCount, 1);
    expect(familyRemediation.actionCount, 5);
    expect(familyRemediation.requiredGapCount, 0);
    expect(familyRemediation.advisoryGapCount, 5);
    expect(familyRemediation.scoreImpactWeight, closeTo(6.65, 0.001));
    expect(familyRemediation.scoreImpactLabel, '6.7');
    expect(familyRemediation.topFamily?.familyName, 'optionConfig');
    expect(familyRemediation.items.single.contractNames, ['optionConfig']);
    expect(familyRemediation.items.single.chartCount, 1);
    expect(familyRemediation.items.single.chartExamples, ['calendar']);
    expect(
      familyRemediation.items.single.status,
      RegistryHealthApiConsistencyStatus.warning,
    );
    expect(
      familyRemediation.items.single.leadingPhase,
      RegistryHealthApiConsistencyActionPhase.later,
    );
    expect(familyRemediation.items.single.topConcernLabels, [
      'Empty State',
      'Interaction',
      'Semantics',
    ]);
    expect(
      familyRemediation.items.single.focusLabel,
      'Focus: Empty State, Interaction, Semantics',
    );
    expect(
      familyRemediation.items.single.recipe.targetLabel,
      'Config-driven API parity',
    );
    expect(
      familyRemediation.items.single.recipe.acceptanceLabel,
      'Accept: Config APIs expose shared behavior through typed options and JSON.',
    );
    expect(familyRemediationJson, containsPair('familyCount', 1));
    expect(
      familyRemediationJson,
      containsPair('topFamilyName', 'optionConfig'),
    );
    expect(
      (familyRemediationJson['families'] as List).single,
      containsPair('focusLabel', 'Focus: Empty State, Interaction, Semantics'),
    );
    expect(
      ((familyRemediationJson['families'] as List).single
          as Map<String, dynamic>)['recipe'],
      containsPair('targetLabel', 'Config-driven API parity'),
    );
    expect(
      familyChecklistText,
      contains('# API Family Implementation Checklist'),
    );
    expect(familyChecklistText, contains('## optionConfig'));
    expect(familyChecklistText, contains('- Build: Config-driven API parity'));
    expect(
      familyChecklistText,
      contains(
        '- Accept: Config APIs expose shared behavior through typed options and JSON.',
      ),
    );
    expect(primitiveRemediation.primitiveCount, 5);
    expect(primitiveRemediation.actionCount, 5);
    expect(primitiveRemediation.requiredGapCount, 0);
    expect(primitiveRemediation.advisoryGapCount, 5);
    expect(primitiveRemediation.scoreImpactWeight, closeTo(6.65, 0.001));
    expect(primitiveRemediation.scoreImpactLabel, '6.7');
    expect(primitiveRemediation.topPrimitive?.primitiveKey, 'interaction');
    expect(primitiveRemediation.topPrimitive?.primitiveLabel, 'Interaction');
    expect(primitiveRemediation.items.first.fieldNames, [
      'onElementTap',
      'onSelectionChanged',
      'showActiveElement',
    ]);
    expect(primitiveRemediation.items.first.concernLabels, ['Interaction']);
    expect(primitiveRemediation.items.first.familyNames, ['optionConfig']);
    expect(primitiveRemediation.items.first.contractNames, ['optionConfig']);
    expect(primitiveRemediation.items.first.chartCount, 1);
    expect(
      primitiveRemediation.items.first.status,
      RegistryHealthApiConsistencyStatus.warning,
    );
    expect(
      primitiveRemediation.items.first.leadingPhase,
      RegistryHealthApiConsistencyActionPhase.later,
    );
    expect(
      primitiveRemediation.items.first.fieldLabel,
      'Fields: onElementTap, onSelectionChanged, showActiveElement',
    );
    expect(
      primitiveRemediation.items.first.coverageLabel,
      'Covers: Interaction',
    );
    expect(
      primitiveRemediation.items.first.recipe.targetLabel,
      'Shared interaction contract',
    );
    expect(
      primitiveRemediation.items.first.recipe.acceptanceLabel,
      'Accept: Widget APIs expose tap, selection, and active-element hooks.',
    );
    expect(primitiveRemediationJson, containsPair('primitiveCount', 5));
    expect(
      primitiveRemediationJson,
      containsPair('topPrimitiveKey', 'interaction'),
    );
    expect(
      (primitiveRemediationJson['primitives'] as List).single,
      containsPair('primitiveLabel', 'Interaction'),
    );
    expect(
      ((primitiveRemediationJson['primitives'] as List).single
          as Map<String, dynamic>)['recipe'],
      containsPair('targetLabel', 'Shared interaction contract'),
    );
    expect(
      primitiveChecklistText,
      contains('# API Primitive Implementation Checklist'),
    );
    expect(primitiveChecklistText, contains('## Interaction'));
    expect(
      primitiveChecklistText,
      contains(
        'Fields: onElementTap, onSelectionChanged, showActiveElement '
        '(Later, impact +1.8)',
      ),
    );
    expect(primitiveChecklistText, contains('- Covers: Interaction'));
    expect(
      primitiveChecklistText,
      contains('- Build: Shared interaction contract'),
    );
    expect(
      primitiveChecklistText,
      contains(
        '- Accept: Widget APIs expose tap, selection, and active-element hooks.',
      ),
    );
    expect(primitiveChecklistText, contains('+4 more primitives hidden.'));
    expect(fieldRemediation.fieldOptionCount, 11);
    expect(fieldRemediation.actionCount, 5);
    expect(fieldRemediation.requiredGapCount, 0);
    expect(fieldRemediation.advisoryGapCount, 5);
    expect(fieldRemediation.scoreImpactWeight, closeTo(6.65, 0.001));
    expect(fieldRemediation.scoreImpactLabel, '6.7');
    expect(fieldRemediation.topField?.fieldName, 'emptyBuilder');
    expect(fieldRemediation.items.first.concernLabels, ['Empty State']);
    expect(fieldRemediation.items.first.familyNames, ['optionConfig']);
    expect(fieldRemediation.items.first.contractNames, ['optionConfig']);
    expect(fieldRemediation.items.first.chartCount, 1);
    expect(fieldRemediation.items.first.chartExamples, ['calendar']);
    expect(
      fieldRemediation.items.first.status,
      RegistryHealthApiConsistencyStatus.warning,
    );
    expect(
      fieldRemediation.items.first.leadingPhase,
      RegistryHealthApiConsistencyActionPhase.later,
    );
    expect(fieldRemediation.items.first.coverageLabel, 'Covers: Empty State');
    expect(
      fieldRemediation.items.first.recipe.targetLabel,
      'emptyBuilder field contract',
    );
    expect(
      fieldRemediation.items.first.recipe.acceptanceLabel,
      'Accept: emptyBuilder is exposed through the widget API where supported.',
    );
    expect(fieldRemediationJson, containsPair('fieldOptionCount', 11));
    expect(fieldRemediationJson, containsPair('topFieldName', 'emptyBuilder'));
    expect(
      (fieldRemediationJson['fields'] as List).single,
      containsPair('coverageLabel', 'Covers: Empty State'),
    );
    expect(
      ((fieldRemediationJson['fields'] as List).single
          as Map<String, dynamic>)['recipe'],
      containsPair('targetLabel', 'emptyBuilder field contract'),
    );
    expect(
      fieldChecklistText,
      contains('# API Field Implementation Checklist'),
    );
    expect(fieldChecklistText, contains('## emptyBuilder'));
    expect(
      fieldChecklistText,
      contains('- Build: emptyBuilder field contract'),
    );
    expect(
      fieldChecklistText,
      contains(
        '- Accept: emptyBuilder is exposed through the widget API where supported.',
      ),
    );
    expect(implementationPlan.actionCount, 5);
    expect(implementationPlan.familyCount, 1);
    expect(implementationPlan.primitiveCount, 5);
    expect(implementationPlan.fieldOptionCount, 11);
    expect(implementationPlan.requiredGapCount, 0);
    expect(implementationPlan.advisoryGapCount, 5);
    expect(implementationPlan.scoreImpactLabel, '6.7');
    expect(
      implementationPlan.status,
      RegistryHealthApiConsistencyStatus.warning,
    );
    expect(implementationPlan.topFamily?.familyName, 'optionConfig');
    expect(implementationPlan.topPrimitive?.primitiveKey, 'interaction');
    expect(implementationPlan.topField?.fieldName, 'emptyBuilder');
    expect(
      implementationPlan.recommendedStartLabel,
      'Start with optionConfig: Config-driven API parity.',
    );
    expect(implementationPlanJson, containsPair('actionCount', 5));
    expect(
      implementationPlanJson,
      containsPair(
        'recommendedStartLabel',
        'Start with optionConfig: Config-driven API parity.',
      ),
    );
    expect(
      implementationPlanJson['familyRemediation'],
      containsPair('familyCount', 1),
    );
    expect(
      implementationPlanJson['primitiveRemediation'],
      containsPair('primitiveCount', 5),
    );
    expect(
      implementationPlanJson['fieldRemediation'],
      containsPair('fieldOptionCount', 11),
    );
    expect(
      implementationChecklistText,
      contains('# API Consistency Implementation Bundle'),
    );
    expect(implementationChecklistText, contains('## Start Here'));
    expect(
      implementationChecklistText,
      contains('- Family: optionConfig - Config-driven API parity'),
    );
    expect(
      implementationChecklistText,
      contains('- Primitive: Interaction - Shared interaction contract'),
    );
    expect(
      implementationChecklistText,
      contains('- Field: emptyBuilder - emptyBuilder field contract'),
    );
    expect(implementationChecklistText, contains('## Action Queue'));
    expect(traceabilityReport.traceCount, 17);
    expect(traceabilityReport.familyTraceCount, 1);
    expect(traceabilityReport.primitiveTraceCount, 5);
    expect(traceabilityReport.fieldTraceCount, 11);
    expect(traceabilityReport.actionCount, 5);
    expect(traceabilityReport.scoreImpactLabel, '6.7');
    expect(traceabilityReport.topTrace?.kindLabel, 'Family');
    expect(traceabilityReport.topTrace?.targetId, 'optionConfig');
    expect(
      traceabilityReport.topTrace?.primarySourceFile,
      'Packages/tenun/lib/core/base_config.dart',
    );
    expect(traceabilityJson, containsPair('traceCount', 17));
    expect(
      traceabilityJson,
      containsPair(
        'topPrimarySourceFile',
        'Packages/tenun/lib/core/base_config.dart',
      ),
    );
    expect(
      (traceabilityJson['traces'] as List).single,
      containsPair(
        'primarySourceFile',
        'Packages/tenun/lib/core/base_config.dart',
      ),
    );
    expect(traceabilityText, contains('# API Implementation Traceability'));
    expect(traceabilityText, contains('## Family optionConfig'));
    expect(
      traceabilityText,
      contains('- Primary: Packages/tenun/lib/core/base_config.dart'),
    );
    expect(sourceQueueReport.sourceCount, 7);
    expect(sourceQueueReport.traceCount, 17);
    expect(sourceQueueReport.traceTouchCount, 58);
    expect(sourceQueueReport.actionCount, 5);
    expect(sourceQueueReport.scoreImpactLabel, '6.7');
    expect(
      sourceQueueReport.topSource?.sourceFile,
      'Packages/tenun/lib/core/chart_api_contract.dart',
    );
    expect(sourceQueueReport.topSource?.traceCount, 17);
    expect(
      sourceQueueReport.topSource?.kindSummaryLabel,
      'Family 1, Primitive 5, Field 11',
    );
    expect(sourceQueueJson, containsPair('sourceCount', 7));
    expect(sourceQueueJson, containsPair('traceTouchCount', 58));
    expect(
      sourceQueueJson,
      containsPair(
        'topSourceFile',
        'Packages/tenun/lib/core/chart_api_contract.dart',
      ),
    );
    expect(
      (sourceQueueJson['sources'] as List).single,
      containsPair('traceCount', 17),
    );
    expect(sourceQueueText, contains('# API Source Queue'));
    expect(
      sourceQueueText,
      contains('## Packages/tenun/lib/core/chart_api_contract.dart'),
    );
    expect(sourceQueueText, contains('- Family 1, Primitive 5, Field 11'));
    expect(sourcePlanReport.batchCount, 5);
    expect(sourcePlanReport.sourceCount, 7);
    expect(sourcePlanReport.traceCount, 17);
    expect(sourcePlanReport.traceTouchCount, 58);
    expect(sourcePlanReport.actionCount, 5);
    expect(sourcePlanReport.actionTouchCount, 74);
    expect(sourcePlanReport.scoreImpactLabel, '6.7');
    expect(sourcePlanReport.topBatch?.areaLabel, 'Core Contracts');
    expect(sourcePlanReport.topBatch?.sourceCount, 2);
    expect(sourcePlanReport.topBatch?.traceTouchCount, 28);
    expect(
      sourcePlanReport.topBatch?.kindSummaryLabel,
      'Family 1, Primitive 5, Field 22',
    );
    expect(sourcePlanJson, containsPair('batchCount', 5));
    expect(sourcePlanJson, containsPair('traceTouchCount', 58));
    expect(sourcePlanJson, containsPair('topAreaLabel', 'Core Contracts'));
    expect(
      (sourcePlanJson['batches'] as List).single,
      containsPair('areaLabel', 'Core Contracts'),
    );
    expect(sourcePlanText, contains('# API Source Plan'));
    expect(sourcePlanText, contains('## Core Contracts'));
    expect(
      sourcePlanText,
      contains('- Normalize field specs and API contract membership first.'),
    );
    expect(sourceChecklistReport.stageCount, 5);
    expect(sourceChecklistReport.taskCount, 25);
    expect(sourceChecklistReport.sourceCount, 7);
    expect(sourceChecklistReport.traceTouchCount, 58);
    expect(sourceChecklistReport.actionCount, 5);
    expect(sourceChecklistReport.actionTouchCount, 74);
    expect(sourceChecklistReport.highRiskCount, 1);
    expect(sourceChecklistReport.mediumRiskCount, 4);
    expect(sourceChecklistReport.lowRiskCount, 0);
    expect(sourceChecklistReport.scoreImpactLabel, '6.7');
    expect(sourceChecklistReport.topStage?.stageNumber, 1);
    expect(sourceChecklistReport.topStage?.areaLabel, 'Core Contracts');
    expect(sourceChecklistReport.topStage?.riskLabel, 'High Risk');
    expect(sourceChecklistReport.topStage?.taskCount, 5);
    expect(
      sourceChecklistReport.topStage?.reviewGateLabel,
      'Contract fields compile and chart API coverage remains stable.',
    );
    expect(sourceChecklistJson, containsPair('stageCount', 5));
    expect(sourceChecklistJson, containsPair('taskCount', 25));
    expect(sourceChecklistJson, containsPair('highRiskCount', 1));
    expect(sourceChecklistJson, containsPair('topRiskLabel', 'High Risk'));
    expect(
      (sourceChecklistJson['stages'] as List).single,
      containsPair('titleLabel', 'Stage 1: Core Contracts'),
    );
    expect(sourceChecklistText, contains('# API Source Checklist'));
    expect(sourceChecklistText, contains('## Stage 1: Core Contracts'));
    expect(sourceChecklistText, contains('- Risk: High Risk, Later'));
    expect(
      sourceChecklistText,
      contains(
        '- [ ] Normalize field specs and API contract membership first.',
      ),
    );
    expect(sourceMilestonesReport.milestoneCount, 3);
    expect(sourceMilestonesReport.stageCount, 5);
    expect(sourceMilestonesReport.taskCount, 25);
    expect(sourceMilestonesReport.sourceCount, 7);
    expect(sourceMilestonesReport.traceTouchCount, 58);
    expect(sourceMilestonesReport.actionCount, 5);
    expect(sourceMilestonesReport.actionTouchCount, 74);
    expect(sourceMilestonesReport.highRiskCount, 1);
    expect(sourceMilestonesReport.mediumRiskCount, 2);
    expect(sourceMilestonesReport.lowRiskCount, 0);
    expect(sourceMilestonesReport.scoreImpactLabel, '6.7');
    expect(sourceMilestonesReport.topMilestone?.milestoneLabel, 'Foundation');
    expect(sourceMilestonesReport.topMilestone?.riskLabel, 'High Risk');
    expect(sourceMilestonesReport.topMilestone?.stageCount, 2);
    expect(sourceMilestonesReport.topMilestone?.sourceCount, 4);
    expect(sourceMilestonesJson, containsPair('milestoneCount', 3));
    expect(sourceMilestonesJson, containsPair('stageCount', 5));
    expect(
      sourceMilestonesJson,
      containsPair('topMilestoneLabel', 'Foundation'),
    );
    expect(
      (sourceMilestonesJson['milestones'] as List).single,
      containsPair('milestoneLabel', 'Foundation'),
    );
    expect(sourceMilestonesText, contains('# API Source Milestones'));
    expect(sourceMilestonesText, contains('## Foundation'));
    expect(
      sourceMilestonesText,
      contains(
        '- Stabilize contract shape and config adapters before public API rollout.',
      ),
    );
    expect(sourceReleaseGatesReport.gateCount, 3);
    expect(sourceReleaseGatesReport.milestoneCount, 3);
    expect(sourceReleaseGatesReport.stageCount, 5);
    expect(sourceReleaseGatesReport.taskCount, 25);
    expect(sourceReleaseGatesReport.sourceCount, 7);
    expect(sourceReleaseGatesReport.actionTouchCount, 74);
    expect(sourceReleaseGatesReport.requiredCheckCount, 9);
    expect(sourceReleaseGatesReport.acceptanceCriteriaCount, 9);
    expect(sourceReleaseGatesReport.readyGateCount, 0);
    expect(sourceReleaseGatesReport.reviewGateCount, 3);
    expect(sourceReleaseGatesReport.blockedGateCount, 0);
    expect(sourceReleaseGatesReport.scoreImpactLabel, '6.7');
    expect(sourceReleaseGatesReport.topGate?.gateLabel, 'Gate 1: Foundation');
    expect(sourceReleaseGatesReport.topGate?.statusLabel, 'Review Needed');
    expect(sourceReleaseGatesReport.topGate?.checkCount, 3);
    expect(sourceReleaseGatesJson, containsPair('gateCount', 3));
    expect(sourceReleaseGatesJson, containsPair('requiredCheckCount', 9));
    expect(sourceReleaseGatesJson, containsPair('reviewGateCount', 3));
    expect(
      sourceReleaseGatesJson,
      containsPair('topGateLabel', 'Gate 1: Foundation'),
    );
    expect(
      (sourceReleaseGatesJson['gates'] as List).single,
      containsPair('statusLabel', 'Review Needed'),
    );
    expect(sourceReleaseGatesText, contains('# API Source Release Gates'));
    expect(sourceReleaseGatesText, contains('## Gate 1: Foundation'));
    expect(
      sourceReleaseGatesText,
      contains(
        '- [ ] Validate contract fields, config adapters, and JSON parsing together.',
      ),
    );
    expect(sourceVerificationReport.verificationCount, 5);
    expect(sourceVerificationReport.sharedVerificationCount, 2);
    expect(sourceVerificationReport.gateCount, 3);
    expect(sourceVerificationReport.gateCoverageCount, 9);
    expect(sourceVerificationReport.requiredCheckCount, 9);
    expect(sourceVerificationReport.readyVerificationCount, 0);
    expect(sourceVerificationReport.reviewVerificationCount, 5);
    expect(sourceVerificationReport.blockedVerificationCount, 0);
    expect(sourceVerificationReport.scoreImpactLabel, '6.7');
    expect(sourceVerificationReport.topVerification?.kindLabel, 'Analyzer');
    expect(sourceVerificationReport.topVerification?.gateCount, 3);
    expect(
      sourceVerificationReport.topVerification?.checkLabel,
      'Run dart analyze for tenun and tenun_showcase.',
    );
    expect(sourceVerificationJson, containsPair('verificationCount', 5));
    expect(sourceVerificationJson, containsPair('sharedVerificationCount', 2));
    expect(sourceVerificationJson, containsPair('gateCoverageCount', 9));
    expect(sourceVerificationJson, containsPair('topKindLabel', 'Analyzer'));
    expect(
      (sourceVerificationJson['verifications'] as List).single,
      containsPair(
        'checkLabel',
        'Run dart analyze for tenun and tenun_showcase.',
      ),
    );
    expect(sourceVerificationText, contains('# API Source Verification'));
    expect(sourceVerificationText, contains('## Analyzer'));
    expect(
      sourceVerificationText,
      contains('- Run dart analyze for tenun and tenun_showcase.'),
    );
    expect(conformanceReport.caseCount, 24);
    expect(conformanceReport.contractCount, 3);
    expect(conformanceReport.concernCount, 8);
    expect(conformanceReport.chartCount, 3);
    expect(conformanceReport.passCount, 19);
    expect(conformanceReport.warningCount, 5);
    expect(conformanceReport.failCount, 0);
    expect(conformanceReport.skippedCount, 0);
    expect(conformanceReport.statusLabel, 'Warnings');
    expect(conformanceReport.isPassing, isTrue);
    expect(conformanceReport.topCase?.titleLabel, 'optionConfig: Empty State');
    expect(conformanceReport.topCase?.statusLabel, 'Warning');
    expect(conformanceReport.topCase?.levelLabel, 'Advisory');
    expect(conformanceJson, containsPair('caseCount', 24));
    expect(conformanceJson, containsPair('warningCount', 5));
    expect(
      conformanceJson,
      containsPair('topCaseId', 'optionConfig.emptyState'),
    );
    expect(
      (conformanceJson['cases'] as List).single,
      containsPair('concernLabel', 'Empty State'),
    );
    expect(conformanceText, contains('# API Conformance Harness'));
    expect(conformanceText, contains('## optionConfig: Empty State'));
    expect(conformanceGateReport.gateCount, 3);
    expect(conformanceGateReport.caseCount, 24);
    expect(conformanceGateReport.passCount, 19);
    expect(conformanceGateReport.warningCount, 5);
    expect(conformanceGateReport.failureCount, 0);
    expect(conformanceGateReport.skippedCount, 0);
    expect(conformanceGateReport.requiredCheckCount, 9);
    expect(conformanceGateReport.acceptanceCriteriaCount, 6);
    expect(conformanceGateReport.readyGateCount, 2);
    expect(conformanceGateReport.reviewGateCount, 1);
    expect(conformanceGateReport.blockedGateCount, 0);
    expect(conformanceGateReport.statusLabel, 'Review Needed');
    expect(conformanceGateReport.isPassing, isTrue);
    expect(
      conformanceGateReport.topGate?.gateLabel,
      'Gate 2: Advisory Coverage',
    );
    expect(conformanceGateJson, containsPair('gateCount', 3));
    expect(conformanceGateJson, containsPair('reviewGateCount', 1));
    expect(
      conformanceGateJson,
      containsPair('topGateLabel', 'Gate 2: Advisory Coverage'),
    );
    expect(
      (conformanceGateJson['gates'] as List).single,
      containsPair('kindLabel', 'Required Coverage'),
    );
    expect(conformanceGateText, contains('# API Conformance Gates'));
    expect(conformanceGateText, contains('## Gate 1: Required Coverage'));
    expect(
      conformanceGateText,
      contains(
        '- [ ] Keep required conformance failures at 0 across all chart families.',
      ),
    );
    expect(conformanceVerificationReport.verificationCount, 9);
    expect(conformanceVerificationReport.sharedVerificationCount, 0);
    expect(conformanceVerificationReport.gateCount, 3);
    expect(conformanceVerificationReport.gateCoverageCount, 9);
    expect(conformanceVerificationReport.requiredCheckCount, 9);
    expect(conformanceVerificationReport.readyVerificationCount, 6);
    expect(conformanceVerificationReport.reviewVerificationCount, 3);
    expect(conformanceVerificationReport.blockedVerificationCount, 0);
    expect(
      conformanceVerificationReport.topVerification?.kindLabel,
      'Advisory Review',
    );
    expect(
      conformanceVerificationReport.topVerification?.checkLabel,
      'Review advisory warnings by concern priority.',
    );
    expect(conformanceVerificationJson, containsPair('verificationCount', 9));
    expect(conformanceVerificationJson, containsPair('gateCoverageCount', 9));
    expect(
      conformanceVerificationJson,
      containsPair('topKindLabel', 'Advisory Review'),
    );
    expect(
      (conformanceVerificationJson['verifications'] as List).single,
      containsPair('kindLabel', 'Advisory Review'),
    );
    expect(
      conformanceVerificationText,
      contains('# API Conformance Verification'),
    );
    expect(conformanceVerificationText, contains('## Advisory Review'));
    expect(
      conformanceVerificationText,
      contains('- Review advisory warnings by concern priority.'),
    );
    expect(conformanceChecklistReport.stepCount, 9);
    expect(conformanceChecklistReport.taskCount, 27);
    expect(conformanceChecklistReport.gateCount, 3);
    expect(conformanceChecklistReport.verificationCount, 9);
    expect(conformanceChecklistReport.requiredCheckCount, 9);
    expect(conformanceChecklistReport.highRiskCount, 0);
    expect(conformanceChecklistReport.mediumRiskCount, 3);
    expect(conformanceChecklistReport.lowRiskCount, 6);
    expect(
      conformanceChecklistReport.topStep?.titleLabel,
      'Step 1: Advisory Review',
    );
    expect(conformanceChecklistReport.topStep?.riskLabel, 'Medium Risk');
    expect(
      conformanceChecklistReport.topStep?.reviewGateLabel,
      'Review and owner sign-off are required before release.',
    );
    expect(conformanceChecklistJson, containsPair('stepCount', 9));
    expect(conformanceChecklistJson, containsPair('taskCount', 27));
    expect(
      conformanceChecklistJson,
      containsPair('topKindLabel', 'Advisory Review'),
    );
    expect(
      (conformanceChecklistJson['steps'] as List).single,
      containsPair('riskLabel', 'Medium Risk'),
    );
    expect(conformanceChecklistText, contains('# API Conformance Checklist'));
    expect(conformanceChecklistText, contains('## Step 1: Advisory Review'));
    expect(
      conformanceChecklistText,
      contains('- [ ] Review advisory warnings by concern priority.'),
    );
    expect(conformanceEvidenceReport.evidenceCount, 5);
    expect(conformanceEvidenceReport.stepCount, 9);
    expect(conformanceEvidenceReport.taskCount, 27);
    expect(conformanceEvidenceReport.verificationCount, 9);
    expect(conformanceEvidenceReport.readyEvidenceCount, 4);
    expect(conformanceEvidenceReport.reviewEvidenceCount, 1);
    expect(conformanceEvidenceReport.blockedEvidenceCount, 0);
    expect(conformanceEvidenceReport.mediumRiskCount, 3);
    expect(conformanceEvidenceReport.highRiskCount, 0);
    expect(
      conformanceEvidenceReport.topEvidence?.evidenceLabel,
      'Advisory Follow-up',
    );
    expect(
      conformanceEvidenceReport.topEvidence?.stepSummaryLabel,
      'Steps: Step 1, Step 2, Step 3',
    );
    expect(conformanceEvidenceJson, containsPair('evidenceCount', 5));
    expect(conformanceEvidenceJson, containsPair('reviewEvidenceCount', 1));
    expect(
      conformanceEvidenceJson,
      containsPair('topEvidenceLabel', 'Advisory Follow-up'),
    );
    expect(
      (conformanceEvidenceJson['evidence'] as List).single,
      containsPair('evidenceLabel', 'Advisory Follow-up'),
    );
    expect(conformanceEvidenceText, contains('# API Conformance Evidence'));
    expect(
      conformanceEvidenceText,
      contains('## Evidence 1: Advisory Follow-up'),
    );
    expect(
      conformanceEvidenceText,
      contains('- Collect owner decisions for advisory conformance gaps.'),
    );
    expect(releaseBriefReport.statusLabel, 'Review Needed');
    expect(releaseBriefReport.releaseLabel, 'Review before release');
    expect(releaseBriefReport.itemCount, 5);
    expect(releaseBriefReport.readyItemCount, 1);
    expect(releaseBriefReport.reviewItemCount, 4);
    expect(releaseBriefReport.blockedItemCount, 0);
    expect(releaseBriefReport.currentScorePercent, 92);
    expect(releaseBriefReport.projectedScorePercent, 100);
    expect(releaseBriefReport.scoreLiftPercent, 8);
    expect(releaseBriefReport.scoreLiftLabel, '+8');
    expect(releaseBriefReport.topItem?.kindLabel, 'Conformance Gates');
    expect(releaseBriefJson, containsPair('itemCount', 5));
    expect(releaseBriefJson, containsPair('reviewItemCount', 4));
    expect(releaseBriefJson, containsPair('topKindLabel', 'Conformance Gates'));
    expect(
      (releaseBriefJson['items'] as List).single,
      containsPair('kindLabel', 'Score Recovery'),
    );
    expect(releaseBriefText, contains('# API Release Brief'));
    expect(releaseBriefText, contains('## Score Recovery'));
    expect(releaseBriefText, contains('## Conformance Gates'));
    expect(
      releaseBriefText,
      contains('- 3 conformance gates, 9 required checks.'),
    );
    expect(pipeline.actionPlan.actionCount, actionPlan.actionCount);
    expect(pipeline.scorecard.scorePercent, scorecard.scorePercent);
    expect(pipeline.releaseBrief.itemCount, releaseBriefReport.itemCount);
    expect(pipeline.conformance.caseCount, conformanceReport.caseCount);
    expect(pipeline.conformanceGate.gateCount, conformanceGateReport.gateCount);
    expect(
      pipeline.conformanceVerification.verificationCount,
      conformanceVerificationReport.verificationCount,
    );
    expect(
      pipeline.conformanceChecklist.stepCount,
      conformanceChecklistReport.stepCount,
    );
    expect(
      pipeline.conformanceEvidence.evidenceCount,
      conformanceEvidenceReport.evidenceCount,
    );
    expect(
      pipeline.sourceVerification.verificationCount,
      sourceVerificationReport.verificationCount,
    );
    expect(
      pipelineJsonSections,
      containsPair('apiConsistency', report.toJson()),
    );
    expect(
      pipelineJsonSections['apiConsistencySourceVerification'],
      containsPair('verificationCount', 5),
    );
    expect(
      pipelineJsonSections['apiConsistencySourceReleaseGates'],
      containsPair('gateCount', 3),
    );
    expect(
      pipelineJsonSections['apiConsistencyConcernSummary'],
      containsPair('concernCount', registryHealthApiConsistencyConcerns.length),
    );
    expect(
      pipelineJsonSections['apiConsistencyReleaseBrief'],
      containsPair('itemCount', 5),
    );
    expect(
      pipelineJsonSections['apiConsistencyConformance'],
      containsPair('caseCount', 24),
    );
    expect(
      pipelineJsonSections['apiConsistencyConformanceGate'],
      containsPair('gateCount', 3),
    );
    expect(
      pipelineJsonSections['apiConsistencyConformanceVerification'],
      containsPair('verificationCount', 9),
    );
    expect(
      pipelineJsonSections['apiConsistencyConformanceChecklist'],
      containsPair('stepCount', 9),
    );
    expect(
      pipelineJsonSections['apiConsistencyConformanceEvidence'],
      containsPair('evidenceCount', 5),
    );
    expect(actionPlan.actionCount, 5);
    expect(actionPlan.criticalCount, 0);
    expect(actionPlan.highCount, 0);
    expect(actionPlan.mediumCount, 5);
    expect(actionPlan.scoreImpactWeight, closeTo(6.65, 0.001));
    expect(actionPlan.scoreImpactLabel, '6.7');
    expect(
      actionPlan.phaseCount(RegistryHealthApiConsistencyActionPhase.now),
      0,
    );
    expect(
      actionPlan.phaseCount(RegistryHealthApiConsistencyActionPhase.next),
      0,
    );
    expect(
      actionPlan.phaseCount(RegistryHealthApiConsistencyActionPhase.later),
      5,
    );
    expect(actionPlan.items.first.contractName, 'optionConfig');
    expect(actionPlan.items.first.concernLabel, 'Empty State');
    expect(actionPlan.items.first.scoreImpactWeight, closeTo(1.75, 0.001));
    expect(actionPlan.items.first.scoreImpactLabel, '1.8');
    expect(
      actionPlan.items.first.concernPriority,
      RegistryHealthApiConsistencyConcernPriority.critical,
    );
    expect(
      actionPlan.items.first.level,
      RegistryHealthApiConsistencyConcernLevel.advisory,
    );
    expect(actionPlanJson, containsPair('exportedActionCount', 1));
    expect(actionPlanJson, containsPair('hiddenActionCount', 4));
    expect(actionPlanJson, containsPair('scoreImpactLabel', '6.7'));
    expect(
      (actionPlanJson['items'] as List).single,
      containsPair('level', 'advisory'),
    );
    expect(
      (actionPlanJson['items'] as List).single,
      containsPair('scoreImpactLabel', '1.8'),
    );
    expect(
      (actionPlanJson['items'] as List).single,
      containsPair('concernPriority', 'critical'),
    );
    expect(concernSummary.concernCount, report.concernCount);
    expect(concernSummary.requiredGapConcernCount, 0);
    expect(concernSummary.advisoryGapConcernCount, 5);
    expect(emptyStateSummary.supportedContracts, ['cartesian', 'polar']);
    expect(emptyStateSummary.requiredMissingContracts, isEmpty);
    expect(emptyStateSummary.advisoryMissingContracts, ['optionConfig']);
    expect(emptyStateSummary.advisoryAffectedChartCount, 1);
    expect(
      emptyStateSummary.priority,
      RegistryHealthApiConsistencyConcernPriority.critical,
    );
    expect(concernSummaryJson, containsPair('exportedSummaryCount', 1));
    expect(concernSummaryJson, containsPair('hiddenSummaryCount', 4));
    expect(
      (concernSummaryJson['summaries'] as List).single,
      containsPair('priority', 'critical'),
    );
    expect(
      (json['concerns'] as List).singleWhere(
        (entry) => (entry as Map<String, dynamic>)['key'] == 'emptyState',
      ),
      containsPair('priority', 'critical'),
    );
    expect(checklistText, contains('# API Consistency Action Checklist'));
    expect(checklistText, contains('## Later'));
    expect(checklistText, contains('optionConfig: Empty State'));
    expect(checklistText, contains('impact +1.8'));
    expect(
      registryHealthApiConsistencySummary(report),
      contains('API contracts'),
    );
    expect(json, containsPair('status', report.status.name));
    expect(json, containsPair('requiredIssueCount', 0));
    expect(json, containsPair('advisoryIssueCount', 5));
    expect(json, containsPair('exportedRowCount', 1));
  });

  test('api consistency score projection tracks blocker recovery by phase', () {
    const scorecard = RegistryHealthApiConsistencyScorecard(
      applicableConcernCount: 3,
      supportedConcernCount: 0,
      requiredGapCount: 2,
      advisoryGapCount: 1,
      totalWeight: 10,
      requiredPenaltyWeight: 8,
      advisoryPenaltyWeight: 1,
    );
    const actionPlan = RegistryHealthApiConsistencyActionPlan(
      items: [
        RegistryHealthApiConsistencyActionItem(
          id: 'cartesian.emptyState',
          contractName: 'cartesian',
          familyName: 'cartesian',
          concernKey: 'emptyState',
          concernLabel: 'Empty State',
          fieldOptions: ['emptyBuilder'],
          chartCount: 3,
          chartExamples: ['area', 'bar', 'line'],
          level: RegistryHealthApiConsistencyConcernLevel.required,
          concernPriority: RegistryHealthApiConsistencyConcernPriority.critical,
          priority: RegistryHealthApiConsistencyActionPriority.critical,
          phase: RegistryHealthApiConsistencyActionPhase.now,
          scoreImpactWeight: 5,
          action: 'Expose an empty-state builder for no-data cases.',
        ),
        RegistryHealthApiConsistencyActionItem(
          id: 'cartesian.formatting',
          contractName: 'cartesian',
          familyName: 'cartesian',
          concernKey: 'formatting',
          concernLabel: 'Formatting',
          fieldOptions: ['valueFormatter'],
          chartCount: 3,
          chartExamples: ['area', 'bar', 'line'],
          level: RegistryHealthApiConsistencyConcernLevel.advisory,
          concernPriority: RegistryHealthApiConsistencyConcernPriority.high,
          priority: RegistryHealthApiConsistencyActionPriority.critical,
          phase: RegistryHealthApiConsistencyActionPhase.now,
          scoreImpactWeight: 1,
          action: 'Expose formatting hooks.',
        ),
        RegistryHealthApiConsistencyActionItem(
          id: 'cartesian.semantics',
          contractName: 'cartesian',
          familyName: 'cartesian',
          concernKey: 'semantics',
          concernLabel: 'Semantics',
          fieldOptions: ['semanticLabel'],
          chartCount: 3,
          chartExamples: ['area', 'bar', 'line'],
          level: RegistryHealthApiConsistencyConcernLevel.required,
          concernPriority: RegistryHealthApiConsistencyConcernPriority.critical,
          priority: RegistryHealthApiConsistencyActionPriority.high,
          phase: RegistryHealthApiConsistencyActionPhase.next,
          scoreImpactWeight: 3,
          action: 'Expose semantics hooks.',
        ),
      ],
    );
    final projection = registryHealthApiConsistencyScoreProjection(
      scorecard: scorecard,
      actionPlan: actionPlan,
    );
    final now = projection.steps.first;
    final next = projection.steps.last;

    expect(projection.steps.map((step) => step.phase), [
      RegistryHealthApiConsistencyActionPhase.now,
      RegistryHealthApiConsistencyActionPhase.next,
    ]);
    expect(now.phaseGapCount, 2);
    expect(now.phaseRequiredGapCount, 1);
    expect(now.phaseAdvisoryGapCount, 1);
    expect(now.resolvedGapCount, 2);
    expect(now.projectedRequiredGapCount, 1);
    expect(now.projectedAdvisoryGapCount, 0);
    expect(now.projectedScorePercent, 70);
    expect(now.projectedGrade, RegistryHealthApiConsistencyScoreGrade.blocked);
    expect(now.resolutionLabel, 'Resolves 1 required gap and 1 advisory gap');
    expect(now.statusLabel, '1 required gap remains');
    expect(next.phaseGapCount, 1);
    expect(next.resolvedRequiredGapCount, 2);
    expect(next.resolvedAdvisoryGapCount, 1);
    expect(next.projectedGapCount, 0);
    expect(next.projectedScorePercent, 100);
    expect(
      next.projectedGrade,
      RegistryHealthApiConsistencyScoreGrade.excellent,
    );
    expect(next.statusLabel, 'All gaps resolved');
    expect(projection.projectedGapCount, 0);
    expect(projection.statusLabel, 'All gaps resolved');
    expect(projection.toJson(), containsPair('isProjectedBlocked', false));
  });

  testWidgets('api consistency panel renders missing concerns', (tester) async {
    final report = registryHealthApiConsistencyReport([
      const ChartCapabilities(
        type: ChartType.calendar,
        typeString: 'calendar',
        dataShape: ChartSeriesDataShape.calendar,
        isRegistered: true,
        supportsSampling: false,
        supportsZoom: false,
        supportsDrilldown: false,
        supportsLegend: false,
        supportsTooltip: true,
        supportsRuntimeSwitching: true,
        apiContract: ChartApiContracts.optionConfig,
      ),
    ], exampleLimit: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencyPanel(
              report: report,
              options: const RegistryHealthApiConsistencyPanelOptions(
                rowLimit: 1,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('API contracts cover'), findsOneWidget);
    expect(find.text('Scorecard'), findsOneWidget);
    expect(find.text('Score: 76%'), findsOneWidget);
    expect(find.text('Grade: Good'), findsOneWidget);
    expect(find.text('Score Projection'), findsOneWidget);
    expect(find.text('Current: 76%'), findsWidgets);
    expect(find.text('Projected: 100%'), findsWidgets);
    expect(find.text('Recover: +6.7'), findsOneWidget);
    expect(find.text('Status: All gaps resolved'), findsOneWidget);
    expect(find.text('100% Excellent'), findsOneWidget);
    expect(find.text('Resolves 5 advisory gaps'), findsOneWidget);
    expect(find.text('All gaps resolved'), findsWidgets);
    expect(find.text('Release Brief'), findsOneWidget);
    expect(find.text('Status: Review Needed'), findsWidgets);
    expect(find.text('Current: 76%'), findsWidgets);
    expect(find.text('Projected: 100%'), findsWidgets);
    expect(find.text('Review before release'), findsOneWidget);
    expect(find.text('Score Recovery'), findsOneWidget);
    expect(find.text('Conformance Gates'), findsWidgets);
    expect(
      find.text('Projects API consistency score from 76% to 100%.'),
      findsOneWidget,
    );
    expect(find.text('Conformance Harness'), findsWidgets);
    expect(find.text('Cases: 8'), findsOneWidget);
    expect(find.text('Pass: 3'), findsOneWidget);
    expect(find.text('Warnings: 5'), findsOneWidget);
    expect(find.text('Failures: 0'), findsOneWidget);
    expect(find.text('optionConfig: Empty State'), findsWidgets);
    expect(find.text('Conformance Gates'), findsWidgets);
    expect(find.text('Gates: 3'), findsWidgets);
    expect(find.text('Ready: 2'), findsOneWidget);
    expect(find.text('Review: 1'), findsWidgets);
    expect(find.text('Blocked: 0'), findsWidgets);
    expect(find.text('Gate 1: Required Coverage'), findsOneWidget);
    expect(find.text('Gate 2: Advisory Coverage'), findsOneWidget);
    expect(find.text('Conformance Verification'), findsOneWidget);
    expect(find.text('Verifications: 9'), findsOneWidget);
    expect(find.text('Shared: 0'), findsOneWidget);
    expect(find.text('Gate Links: 9'), findsWidgets);
    expect(find.text('Advisory Review'), findsWidgets);
    expect(
      find.text('Review advisory warnings by concern priority.'),
      findsOneWidget,
    );
    expect(find.text('Conformance Checklist'), findsOneWidget);
    expect(find.text('Steps: 9'), findsWidgets);
    expect(find.text('Tasks: 27'), findsOneWidget);
    expect(find.text('Medium Risk: 3'), findsWidgets);
    expect(find.text('High Risk: 0'), findsOneWidget);
    expect(find.text('Step 1: Advisory Review'), findsOneWidget);
    expect(
      find.text(
        'Review gate: Review and owner sign-off are required before release.',
      ),
      findsWidgets,
    );
    expect(find.text('Conformance Evidence'), findsOneWidget);
    expect(find.text('Evidence: 5'), findsOneWidget);
    expect(find.text('Medium Risk: 3'), findsWidgets);
    expect(find.text('Evidence 1: Advisory Follow-up'), findsOneWidget);
    expect(
      find.text('Collect owner decisions for advisory conformance gaps.'),
      findsOneWidget,
    );
    expect(find.text('Steps: Step 1, Step 2, Step 3'), findsOneWidget);
    expect(find.text('Implementation Bundle'), findsOneWidget);
    expect(
      find.text('Start with optionConfig: Config-driven API parity.'),
      findsOneWidget,
    );
    expect(find.text('Top Family'), findsOneWidget);
    expect(find.text('Top Primitive'), findsOneWidget);
    expect(find.text('Top Field'), findsOneWidget);
    expect(find.text('Implementation Traceability'), findsOneWidget);
    expect(find.text('Traces: 17'), findsWidgets);
    expect(
      find.text('Primary: Packages/tenun/lib/core/base_config.dart'),
      findsWidgets,
    );
    expect(find.text('Source Queue'), findsOneWidget);
    expect(find.text('Sources: 7'), findsWidgets);
    expect(find.text('Touches: 58'), findsWidgets);
    expect(
      find.text('Packages/tenun/lib/core/chart_api_contract.dart'),
      findsWidgets,
    );
    expect(find.text('Source Plan'), findsOneWidget);
    expect(find.text('Batches: 5'), findsOneWidget);
    expect(find.text('Core Contracts'), findsWidgets);
    expect(find.text('28 trace touches'), findsWidgets);
    expect(find.text('Source Checklist'), findsOneWidget);
    expect(find.text('Stages: 5'), findsWidgets);
    expect(find.text('Tasks: 25'), findsWidgets);
    expect(find.text('High Risk: 1'), findsWidgets);
    expect(find.text('Stage 1: Core Contracts'), findsOneWidget);
    expect(find.text('Source Milestones'), findsOneWidget);
    expect(find.text('Milestones: 3'), findsOneWidget);
    expect(find.text('Stages: 5'), findsWidgets);
    expect(find.text('Tasks: 25'), findsWidgets);
    expect(find.text('High Risk: 1'), findsWidgets);
    expect(find.text('Foundation'), findsOneWidget);
    expect(find.text('Source Release Gates'), findsWidgets);
    expect(find.text('Gates: 3'), findsWidgets);
    expect(find.text('Review: 3'), findsWidgets);
    expect(find.text('Blocked: 0'), findsWidgets);
    expect(find.text('Checks: 9'), findsWidgets);
    expect(find.text('Gate 1: Foundation'), findsOneWidget);
    expect(find.text('Review Needed'), findsWidgets);
    expect(find.text('Source Verification'), findsWidgets);
    expect(find.text('Verifications: 5'), findsOneWidget);
    expect(find.text('Shared: 2'), findsOneWidget);
    expect(find.text('Gate Links: 9'), findsWidgets);
    expect(find.text('Review: 5'), findsOneWidget);
    expect(find.text('Analyzer'), findsOneWidget);
    expect(find.text('Family Remediation'), findsOneWidget);
    expect(find.text('Families: 1'), findsWidgets);
    expect(
      find.text('Focus: Empty State, Interaction, Semantics'),
      findsWidgets,
    );
    expect(find.text('Contracts: optionConfig'), findsOneWidget);
    expect(find.text('Primitive Plan'), findsOneWidget);
    expect(find.text('Primitives: 5'), findsWidgets);
    expect(find.text('Interaction'), findsWidgets);
    expect(
      find.text('Fields: onElementTap, onSelectionChanged, showActiveElement'),
      findsWidgets,
    );
    expect(find.text('Covers: Interaction'), findsWidgets);
    expect(find.text('Field Remediation'), findsOneWidget);
    expect(find.text('Fields: 11'), findsWidgets);
    expect(find.text('emptyBuilder'), findsWidgets);
    expect(find.text('Covers: Empty State'), findsWidgets);
    expect(find.text('Families: optionConfig'), findsWidgets);
    expect(find.text('Concern Coverage'), findsOneWidget);
    expect(find.text('Status: Warnings'), findsWidgets);
    expect(find.text('Required Gaps: 0'), findsOneWidget);
    expect(find.text('Advisory: 5'), findsWidgets);
    expect(find.text('optionConfig'), findsWidgets);
    expect(find.text('Empty State (Advisory)'), findsOneWidget);
    expect(find.text('Action Plan'), findsOneWidget);
    expect(find.text('Copy Checklist'), findsWidgets);
    expect(find.text('Actions: 5'), findsWidgets);
    expect(find.text('Impact: +6.7'), findsWidgets);
    expect(find.text('Later: 5'), findsOneWidget);
    expect(find.text('optionConfig: Empty State'), findsWidgets);
    expect(find.text('Impact +1.8'), findsWidgets);
    expect(find.text('Advisory'), findsWidgets);
    expect(find.textContaining('Expose an empty-state builder'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency panel release preset renders merge focus', (
    tester,
  ) async {
    final report = registryHealthApiConsistencyReport([
      const ChartCapabilities(
        type: ChartType.calendar,
        typeString: 'calendar',
        dataShape: ChartSeriesDataShape.calendar,
        isRegistered: true,
        supportsSampling: false,
        supportsZoom: false,
        supportsDrilldown: false,
        supportsLegend: false,
        supportsTooltip: true,
        supportsRuntimeSwitching: true,
        apiContract: ChartApiContracts.optionConfig,
      ),
    ], exampleLimit: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencyPanel(
              report: report,
              options: RegistryHealthApiConsistencyPanelOptions.release,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('API contracts cover'), findsOneWidget);
    expect(find.text('Scorecard'), findsOneWidget);
    expect(find.text('Score Projection'), findsOneWidget);
    expect(find.text('Release Brief'), findsOneWidget);
    expect(find.text('Conformance Gates'), findsWidgets);
    expect(find.text('Conformance Verification'), findsOneWidget);
    expect(find.text('Conformance Evidence'), findsOneWidget);
    expect(find.text('Source Release Gates'), findsWidgets);
    expect(find.text('Source Verification'), findsWidgets);
    expect(find.text('Action Plan'), findsOneWidget);
    expect(find.text('Cases: 8'), findsNothing);
    expect(find.text('Pass: 3'), findsNothing);
    expect(find.text('Warnings: 5'), findsNothing);
    expect(find.text('Conformance Checklist'), findsNothing);
    expect(find.text('Implementation Bundle'), findsNothing);
    expect(find.text('Implementation Traceability'), findsNothing);
    expect(find.text('Source Plan'), findsNothing);
    expect(find.text('Concern Coverage'), findsNothing);
    expect(find.byType(DataTable), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency overview renders headline metrics', (
    tester,
  ) async {
    final report = registryHealthApiConsistencyReport([
      const ChartCapabilities(
        type: ChartType.calendar,
        typeString: 'calendar',
        dataShape: ChartSeriesDataShape.calendar,
        isRegistered: true,
        supportsSampling: false,
        supportsZoom: false,
        supportsDrilldown: false,
        supportsLegend: false,
        supportsTooltip: true,
        supportsRuntimeSwitching: true,
        apiContract: ChartApiContracts.optionConfig,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryHealthApiConsistencyOverview(report: report),
        ),
      ),
    );

    expect(find.textContaining('API contracts cover'), findsOneWidget);
    expect(find.text('Status: Warnings'), findsOneWidget);
    expect(find.text('Contracts: 1'), findsOneWidget);
    expect(find.text('Ready: 0'), findsOneWidget);
    expect(find.text('Required Gaps: 0'), findsOneWidget);
    expect(find.text('Advisory: 5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency attention table renders action rows', (
    tester,
  ) async {
    final report = registryHealthApiConsistencyReport([
      const ChartCapabilities(
        type: ChartType.calendar,
        typeString: 'calendar',
        dataShape: ChartSeriesDataShape.calendar,
        isRegistered: true,
        supportsSampling: false,
        supportsZoom: false,
        supportsDrilldown: false,
        supportsLegend: false,
        supportsTooltip: true,
        supportsRuntimeSwitching: true,
        apiContract: ChartApiContracts.optionConfig,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencyAttentionTable(report: report),
          ),
        ),
      ),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Contract'), findsOneWidget);
    expect(find.text('optionConfig'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(find.text('Empty State (Advisory)'), findsOneWidget);
    expect(
      find.textContaining('Expose an empty-state builder'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency concern summary panel renders concern rollup', (
    tester,
  ) async {
    final report = registryHealthApiConsistencyConcernSummaryReport(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryHealthApiConsistencyConcernSummaryPanel(
            report: report,
            summaryLimit: 1,
          ),
        ),
      ),
    );

    expect(find.text('Concern Coverage'), findsOneWidget);
    expect(find.text('Concerns: 8'), findsOneWidget);
    expect(find.text('Advisory: 5'), findsOneWidget);
    expect(find.text('Empty State'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Advisory optionConfig'), findsOneWidget);
    expect(find.text('+4 more concerns'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency scorecard panel renders weighted grade', (
    tester,
  ) async {
    final scorecard = registryHealthApiConsistencyScorecard(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryHealthApiConsistencyScorecardPanel(
            scorecard: scorecard,
          ),
        ),
      ),
    );

    expect(find.text('Scorecard'), findsOneWidget);
    expect(find.text('Score: 76%'), findsOneWidget);
    expect(find.text('Grade: Good'), findsOneWidget);
    expect(find.text('Required Penalty: 0'), findsOneWidget);
    expect(find.text('Advisory Penalty: 6.7'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'api consistency score projection panel renders phase projection',
    (tester) async {
      final report = registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]);
      final actionPlan = registryHealthApiConsistencyActionPlan(report);
      final scorecard = registryHealthApiConsistencyScorecard(report);
      final projection = registryHealthApiConsistencyScoreProjection(
        scorecard: scorecard,
        actionPlan: actionPlan,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistryHealthApiConsistencyScoreProjectionPanel(
              projection: projection,
            ),
          ),
        ),
      );

      expect(find.text('Score Projection'), findsOneWidget);
      expect(find.text('Current: 76%'), findsOneWidget);
      expect(find.text('Projected: 100%'), findsOneWidget);
      expect(find.text('Grade: Excellent'), findsOneWidget);
      expect(find.text('Status: All gaps resolved'), findsOneWidget);
      expect(find.text('Recover: +6.7'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('+6.7'), findsOneWidget);
      expect(find.text('100% Excellent'), findsOneWidget);
      expect(find.text('Resolves 5 advisory gaps'), findsOneWidget);
      expect(find.text('All gaps resolved'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('api consistency release brief panel renders merge summary', (
    tester,
  ) async {
    final report = registryHealthApiConsistencyPipeline(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    ).releaseBrief;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencyReleaseBriefPanel(
              report: report,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Release Brief'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Brief'), findsOneWidget);
    expect(find.text('Status: Review Needed'), findsOneWidget);
    expect(find.text('Current: 76%'), findsOneWidget);
    expect(find.text('Projected: 100%'), findsOneWidget);
    expect(find.text('Review: 4'), findsOneWidget);
    expect(find.text('Blocked: 0'), findsOneWidget);
    expect(find.text('Review before release'), findsOneWidget);
    expect(find.text('Score Recovery'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('1 phase'), findsOneWidget);
    expect(find.text('+24 pts'), findsOneWidget);
    expect(
      find.text('Projects API consistency score from 76% to 100%.'),
      findsOneWidget,
    );
    expect(find.text('All gaps resolved'), findsOneWidget);
    expect(find.text('Conformance Gates'), findsOneWidget);
    expect(find.text('Review Needed'), findsWidgets);
    expect(find.text('3 gates'), findsWidgets);
    expect(find.text('9 checks'), findsWidgets);
    expect(
      find.text('3 conformance gates, 9 required checks.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Gate 2: Advisory Coverage: Advisory gaps remain visible before they become debt.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('api conformance panel renders case harness', (tester) async {
    final report = registryHealthApiConformanceReport(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConformancePanel(report: report),
          ),
        ),
      ),
    );

    expect(find.text('Conformance Harness'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Cases'), findsOneWidget);
    expect(find.text('Cases: 8'), findsOneWidget);
    expect(find.text('Pass: 3'), findsOneWidget);
    expect(find.text('Warnings: 5'), findsOneWidget);
    expect(find.text('Failures: 0'), findsOneWidget);
    expect(find.text('Skipped: 0'), findsOneWidget);
    expect(find.text('optionConfig: Empty State'), findsOneWidget);
    expect(find.text('Warning'), findsWidgets);
    expect(find.text('Advisory'), findsWidgets);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Fields: emptyBuilder'), findsOneWidget);
    expect(find.text('Charts: calendar'), findsWidgets);
    expect(
      find.text('Expose an empty-state builder for no-data cases.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('api conformance gate panel renders release gates', (
    tester,
  ) async {
    final report = registryHealthApiConformanceGateReport(
      registryHealthApiConformanceReport(
        registryHealthApiConsistencyReport([
          const ChartCapabilities(
            type: ChartType.calendar,
            typeString: 'calendar',
            dataShape: ChartSeriesDataShape.calendar,
            isRegistered: true,
            supportsSampling: false,
            supportsZoom: false,
            supportsDrilldown: false,
            supportsLegend: false,
            supportsTooltip: true,
            supportsRuntimeSwitching: true,
            apiContract: ChartApiContracts.optionConfig,
          ),
        ]),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConformanceGatePanel(report: report),
          ),
        ),
      ),
    );

    expect(find.text('Conformance Gates'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Gates'), findsOneWidget);
    expect(find.text('Gates: 3'), findsOneWidget);
    expect(find.text('Ready: 2'), findsOneWidget);
    expect(find.text('Review: 1'), findsOneWidget);
    expect(find.text('Blocked: 0'), findsOneWidget);
    expect(find.text('Checks: 9'), findsOneWidget);
    expect(find.text('Gate 1: Required Coverage'), findsOneWidget);
    expect(find.text('Gate 2: Advisory Coverage'), findsOneWidget);
    expect(find.text('Gate 3: Export Contract'), findsOneWidget);
    expect(find.text('Review Needed'), findsOneWidget);
    expect(find.text('3 cases, 0 warnings, 0 failures'), findsOneWidget);
    expect(find.text('5 cases, 5 warnings, 0 failures'), findsOneWidget);
    expect(find.text('8 cases, 5 warnings, 0 failures'), findsOneWidget);
    expect(
      find.text('Required contract behavior must stay release-clean.'),
      findsOneWidget,
    );
    expect(
      find.text('Advisory gaps remain visible before they become debt.'),
      findsOneWidget,
    );
    expect(
      find.text('Registry exports carry the conformance signal forward.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Keep required conformance failures at 0 across all chart families.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Start review with optionConfig: Empty State.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('api conformance verification panel renders gate checks', (
    tester,
  ) async {
    final report = registryHealthApiConformanceVerificationReport(
      registryHealthApiConformanceGateReport(
        registryHealthApiConformanceReport(
          registryHealthApiConsistencyReport([
            const ChartCapabilities(
              type: ChartType.calendar,
              typeString: 'calendar',
              dataShape: ChartSeriesDataShape.calendar,
              isRegistered: true,
              supportsSampling: false,
              supportsZoom: false,
              supportsDrilldown: false,
              supportsLegend: false,
              supportsTooltip: true,
              supportsRuntimeSwitching: true,
              apiContract: ChartApiContracts.optionConfig,
            ),
          ]),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConformanceVerificationPanel(
              report: report,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Conformance Verification'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Matrix'), findsOneWidget);
    expect(find.text('Verifications: 9'), findsOneWidget);
    expect(find.text('Shared: 0'), findsOneWidget);
    expect(find.text('Gate Links: 9'), findsOneWidget);
    expect(find.text('Review: 3'), findsOneWidget);
    expect(find.text('Blocked: 0'), findsOneWidget);
    expect(find.text('Advisory Review'), findsWidgets);
    expect(find.text('Conformance Harness'), findsOneWidget);
    expect(find.text('Review Needed'), findsWidgets);
    expect(find.text('1 gate, 1 review gate'), findsWidgets);
    expect(
      find.text('Review advisory warnings by concern priority.'),
      findsOneWidget,
    );
    expect(
      find.text('Start review with optionConfig: Empty State.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Run API conformance harness before publishing chart API changes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Gates: Gate 2: Advisory Coverage'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api conformance checklist panel renders release steps', (
    tester,
  ) async {
    final report = registryHealthApiConformanceChecklistReport(
      registryHealthApiConformanceVerificationReport(
        registryHealthApiConformanceGateReport(
          registryHealthApiConformanceReport(
            registryHealthApiConsistencyReport([
              const ChartCapabilities(
                type: ChartType.calendar,
                typeString: 'calendar',
                dataShape: ChartSeriesDataShape.calendar,
                isRegistered: true,
                supportsSampling: false,
                supportsZoom: false,
                supportsDrilldown: false,
                supportsLegend: false,
                supportsTooltip: true,
                supportsRuntimeSwitching: true,
                apiContract: ChartApiContracts.optionConfig,
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConformanceChecklistPanel(report: report),
          ),
        ),
      ),
    );

    expect(find.text('Conformance Checklist'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Checklist'), findsOneWidget);
    expect(find.text('Steps: 9'), findsOneWidget);
    expect(find.text('Tasks: 27'), findsOneWidget);
    expect(find.text('Medium Risk: 3'), findsOneWidget);
    expect(find.text('High Risk: 0'), findsOneWidget);
    expect(find.text('Checks: 9'), findsOneWidget);
    expect(find.text('Step 1: Advisory Review'), findsOneWidget);
    expect(find.text('Medium Risk'), findsWidgets);
    expect(find.text('Review Needed'), findsWidgets);
    expect(find.text('3 tasks'), findsWidgets);
    expect(find.text('Gates: Gate 2: Advisory Coverage'), findsWidgets);
    expect(
      find.text(
        'Review gate: Review and owner sign-off are required before release.',
      ),
      findsWidgets,
    );
    expect(
      find.text(
        'Handoff: Route advisory follow-up into the implementation queue.',
      ),
      findsWidgets,
    );
    expect(
      find.textContaining('Review advisory warnings by concern priority.'),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('api conformance evidence panel renders release bundle', (
    tester,
  ) async {
    final report = registryHealthApiConformanceEvidenceReport(
      registryHealthApiConformanceChecklistReport(
        registryHealthApiConformanceVerificationReport(
          registryHealthApiConformanceGateReport(
            registryHealthApiConformanceReport(
              registryHealthApiConsistencyReport([
                const ChartCapabilities(
                  type: ChartType.calendar,
                  typeString: 'calendar',
                  dataShape: ChartSeriesDataShape.calendar,
                  isRegistered: true,
                  supportsSampling: false,
                  supportsZoom: false,
                  supportsDrilldown: false,
                  supportsLegend: false,
                  supportsTooltip: true,
                  supportsRuntimeSwitching: true,
                  apiContract: ChartApiContracts.optionConfig,
                ),
              ]),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConformanceEvidencePanel(report: report),
          ),
        ),
      ),
    );

    expect(find.text('Conformance Evidence'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Evidence'), findsOneWidget);
    expect(find.text('Evidence: 5'), findsOneWidget);
    expect(find.text('Steps: 9'), findsOneWidget);
    expect(find.text('Review: 1'), findsOneWidget);
    expect(find.text('Blocked: 0'), findsOneWidget);
    expect(find.text('Medium Risk: 3'), findsOneWidget);
    expect(find.text('Evidence 1: Advisory Follow-up'), findsOneWidget);
    expect(find.text('Review Needed'), findsOneWidget);
    expect(find.text('3 steps'), findsOneWidget);
    expect(find.text('3 medium risk, 0 high risk'), findsOneWidget);
    expect(
      find.text('Collect owner decisions for advisory conformance gaps.'),
      findsOneWidget,
    );
    expect(find.text('Steps: Step 1, Step 2, Step 3'), findsOneWidget);
    expect(
      find.text(
        'Handoff: Route advisory follow-up into the implementation queue.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Review advisory warnings by concern priority.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'api consistency family remediation panel renders ranked families',
    (tester) async {
      final actionPlan = registryHealthApiConsistencyActionPlan(
        registryHealthApiConsistencyReport([
          const ChartCapabilities(
            type: ChartType.calendar,
            typeString: 'calendar',
            dataShape: ChartSeriesDataShape.calendar,
            isRegistered: true,
            supportsSampling: false,
            supportsZoom: false,
            supportsDrilldown: false,
            supportsLegend: false,
            supportsTooltip: true,
            supportsRuntimeSwitching: true,
            apiContract: ChartApiContracts.optionConfig,
          ),
        ]),
      );
      final report = registryHealthApiConsistencyFamilyRemediationReport(
        actionPlan,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RegistryHealthApiConsistencyFamilyRemediationPanel(
                report: report,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Family Remediation'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
      expect(find.text('Copy Checklist'), findsOneWidget);
      expect(find.text('Families: 1'), findsOneWidget);
      expect(find.text('Actions: 5'), findsOneWidget);
      expect(find.text('Required: 0'), findsOneWidget);
      expect(find.text('Impact: +6.7'), findsOneWidget);
      expect(find.text('optionConfig'), findsOneWidget);
      expect(find.text('Warnings'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('5 actions'), findsOneWidget);
      expect(find.text('Impact +6.7'), findsOneWidget);
      expect(
        find.text('Focus: Empty State, Interaction, Semantics'),
        findsOneWidget,
      );
      expect(find.text('Config-driven API parity'), findsOneWidget);
      expect(
        find.text(
          'Accept: Config APIs expose shared behavior through typed options and JSON.',
        ),
        findsOneWidget,
      );
      expect(find.text('Contracts: optionConfig'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'api consistency implementation plan panel renders bundled guidance',
    (tester) async {
      final actionPlan = registryHealthApiConsistencyActionPlan(
        registryHealthApiConsistencyReport([
          const ChartCapabilities(
            type: ChartType.calendar,
            typeString: 'calendar',
            dataShape: ChartSeriesDataShape.calendar,
            isRegistered: true,
            supportsSampling: false,
            supportsZoom: false,
            supportsDrilldown: false,
            supportsLegend: false,
            supportsTooltip: true,
            supportsRuntimeSwitching: true,
            apiContract: ChartApiContracts.optionConfig,
          ),
        ]),
      );
      final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RegistryHealthApiConsistencyImplementationPlanPanel(
                plan: plan,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Implementation Bundle'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
      expect(find.text('Copy Checklist'), findsOneWidget);
      expect(find.text('Status: Warnings'), findsOneWidget);
      expect(find.text('Actions: 5'), findsOneWidget);
      expect(find.text('Families: 1'), findsOneWidget);
      expect(find.text('Primitives: 5'), findsOneWidget);
      expect(find.text('Fields: 11'), findsOneWidget);
      expect(find.text('Impact: +6.7'), findsOneWidget);
      expect(
        find.text('Start with optionConfig: Config-driven API parity.'),
        findsOneWidget,
      );
      expect(find.text('Top Family'), findsOneWidget);
      expect(find.text('optionConfig'), findsOneWidget);
      expect(find.text('Config-driven API parity'), findsOneWidget);
      expect(
        find.text('Focus: Empty State, Interaction, Semantics'),
        findsOneWidget,
      );
      expect(find.text('Top Primitive'), findsOneWidget);
      expect(find.text('Interaction'), findsOneWidget);
      expect(find.text('Shared interaction contract'), findsOneWidget);
      expect(find.text('Top Field'), findsOneWidget);
      expect(find.text('emptyBuilder'), findsOneWidget);
      expect(find.text('emptyBuilder field contract'), findsOneWidget);
      expect(find.text('the widget API, Widget builder'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('api consistency traceability panel renders source targets', (
    tester,
  ) async {
    final actionPlan = registryHealthApiConsistencyActionPlan(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );
    final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);
    final report = registryHealthApiConsistencyTraceabilityReport(plan);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencyTraceabilityPanel(
              report: report,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Implementation Traceability'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Targets'), findsOneWidget);
    expect(find.text('Traces: 17'), findsOneWidget);
    expect(find.text('Families: 1'), findsOneWidget);
    expect(find.text('Primitives: 5'), findsOneWidget);
    expect(find.text('Fields: 11'), findsOneWidget);
    expect(find.text('Impact: +6.7'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('optionConfig'), findsOneWidget);
    expect(find.text('Warnings'), findsWidgets);
    expect(find.text('Later'), findsWidgets);
    expect(find.text('Impact +6.7'), findsOneWidget);
    expect(find.text('Config-driven API parity'), findsOneWidget);
    expect(
      find.text('Primary: Packages/tenun/lib/core/base_config.dart'),
      findsOneWidget,
    );
    expect(find.text('4 source targets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency source queue panel renders source work queue', (
    tester,
  ) async {
    final actionPlan = registryHealthApiConsistencyActionPlan(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );
    final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);
    final traceability = registryHealthApiConsistencyTraceabilityReport(plan);
    final report = registryHealthApiConsistencySourceQueueReport(traceability);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencySourceQueuePanel(report: report),
          ),
        ),
      ),
    );

    expect(find.text('Source Queue'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Queue'), findsOneWidget);
    expect(find.text('Sources: 7'), findsOneWidget);
    expect(find.text('Traces: 17'), findsOneWidget);
    expect(find.text('Touches: 58'), findsOneWidget);
    expect(find.text('Actions: 5'), findsOneWidget);
    expect(find.text('Impact: +6.7'), findsOneWidget);
    expect(
      find.text('Packages/tenun/lib/core/chart_api_contract.dart'),
      findsOneWidget,
    );
    expect(find.text('Warnings'), findsWidgets);
    expect(find.text('Later'), findsWidgets);
    expect(find.text('17 traces'), findsOneWidget);
    expect(find.text('21 action touches'), findsOneWidget);
    expect(find.text('Family 1, Primitive 5, Field 11'), findsOneWidget);
    expect(
      find.text(
        'Targets: accessibility, animation, animationCurve, animationDuration, +13 more',
      ),
      findsOneWidget,
    );
    expect(find.text('Shared API family field definitions.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'api consistency source plan panel renders implementation batches',
    (tester) async {
      final actionPlan = registryHealthApiConsistencyActionPlan(
        registryHealthApiConsistencyReport([
          const ChartCapabilities(
            type: ChartType.calendar,
            typeString: 'calendar',
            dataShape: ChartSeriesDataShape.calendar,
            isRegistered: true,
            supportsSampling: false,
            supportsZoom: false,
            supportsDrilldown: false,
            supportsLegend: false,
            supportsTooltip: true,
            supportsRuntimeSwitching: true,
            apiContract: ChartApiContracts.optionConfig,
          ),
        ]),
      );
      final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);
      final traceability = registryHealthApiConsistencyTraceabilityReport(plan);
      final queue = registryHealthApiConsistencySourceQueueReport(traceability);
      final report = registryHealthApiConsistencySourcePlanReport(queue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RegistryHealthApiConsistencySourcePlanPanel(
                report: report,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Source Plan'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
      expect(find.text('Copy Plan'), findsOneWidget);
      expect(find.text('Batches: 5'), findsOneWidget);
      expect(find.text('Sources: 7'), findsOneWidget);
      expect(find.text('Touches: 58'), findsOneWidget);
      expect(find.text('Actions: 5'), findsOneWidget);
      expect(find.text('Impact: +6.7'), findsOneWidget);
      expect(find.text('Core Contracts'), findsOneWidget);
      expect(find.text('Warnings'), findsWidgets);
      expect(find.text('Later'), findsWidgets);
      expect(find.text('2 sources'), findsWidgets);
      expect(find.text('28 trace touches'), findsOneWidget);
      expect(find.text('32 action touches'), findsOneWidget);
      expect(
        find.text('Normalize field specs and API contract membership first.'),
        findsOneWidget,
      );
      expect(find.text('Family 1, Primitive 5, Field 22'), findsOneWidget);
      expect(
        find.text(
          'Sources: Packages/tenun/lib/core/chart_api_contract.dart, Packages/tenun/lib/core/chart_api_fields.dart',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('api consistency source checklist panel renders staged tasks', (
    tester,
  ) async {
    final actionPlan = registryHealthApiConsistencyActionPlan(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.line,
          typeString: 'line',
          dataShape: ChartSeriesDataShape.cartesian,
          isRegistered: true,
          supportsSampling: true,
          supportsZoom: true,
          supportsDrilldown: false,
          supportsLegend: true,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );
    final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);
    final traceability = registryHealthApiConsistencyTraceabilityReport(plan);
    final queue = registryHealthApiConsistencySourceQueueReport(traceability);
    final sourcePlan = registryHealthApiConsistencySourcePlanReport(queue);
    final report = registryHealthApiConsistencySourceChecklistReport(
      sourcePlan,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencySourceChecklistPanel(
              report: report,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Source Checklist'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Checklist'), findsOneWidget);
    expect(find.text('Stages: 5'), findsOneWidget);
    expect(find.text('Tasks: 25'), findsOneWidget);
    expect(find.text('Sources: 7'), findsOneWidget);
    expect(find.text('High Risk: 1'), findsOneWidget);
    expect(find.text('Impact: +6.7'), findsOneWidget);
    expect(find.text('Stage 1: Core Contracts'), findsOneWidget);
    expect(find.text('High Risk'), findsOneWidget);
    expect(find.text('Later'), findsWidgets);
    expect(find.text('5 tasks'), findsWidgets);
    expect(find.text('2 sources, 28 trace touches'), findsOneWidget);
    expect(find.text('32 action touches'), findsOneWidget);
    expect(
      find.text(
        'Review gate: Contract fields compile and chart API coverage remains stable.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Handoff: Handoff to config adapters after contract shape is stable.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Normalize field specs and API contract membership first.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency source milestones panel renders roadmap groups', (
    tester,
  ) async {
    final actionPlan = registryHealthApiConsistencyActionPlan(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.line,
          typeString: 'line',
          dataShape: ChartSeriesDataShape.cartesian,
          isRegistered: true,
          supportsSampling: true,
          supportsZoom: true,
          supportsDrilldown: false,
          supportsLegend: true,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );
    final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);
    final traceability = registryHealthApiConsistencyTraceabilityReport(plan);
    final queue = registryHealthApiConsistencySourceQueueReport(traceability);
    final sourcePlan = registryHealthApiConsistencySourcePlanReport(queue);
    final checklist = registryHealthApiConsistencySourceChecklistReport(
      sourcePlan,
    );
    final report = registryHealthApiConsistencySourceMilestonesReport(
      checklist,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencySourceMilestonesPanel(
              report: report,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Source Milestones'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Roadmap'), findsOneWidget);
    expect(find.text('Milestones: 3'), findsOneWidget);
    expect(find.text('Stages: 5'), findsOneWidget);
    expect(find.text('Tasks: 25'), findsOneWidget);
    expect(find.text('High Risk: 1'), findsOneWidget);
    expect(find.text('Impact: +6.7'), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);
    expect(find.text('High Risk'), findsOneWidget);
    expect(find.text('10 tasks'), findsWidgets);
    expect(
      find.text(
        'Stabilize contract shape and config adapters before public API rollout.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('4 sources'), findsOneWidget);
    expect(find.text('48 action touches'), findsOneWidget);
    expect(
      find.textContaining(
        'Review gate: Contracts and adapters pass analyzer, JSON, and registry health checks.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Handoff: Move next to public surface only after contract and config shape settle.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency source release gates panel renders merge gates', (
    tester,
  ) async {
    final actionPlan = registryHealthApiConsistencyActionPlan(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.line,
          typeString: 'line',
          dataShape: ChartSeriesDataShape.cartesian,
          isRegistered: true,
          supportsSampling: true,
          supportsZoom: true,
          supportsDrilldown: false,
          supportsLegend: true,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );
    final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);
    final traceability = registryHealthApiConsistencyTraceabilityReport(plan);
    final queue = registryHealthApiConsistencySourceQueueReport(traceability);
    final sourcePlan = registryHealthApiConsistencySourcePlanReport(queue);
    final checklist = registryHealthApiConsistencySourceChecklistReport(
      sourcePlan,
    );
    final milestones = registryHealthApiConsistencySourceMilestonesReport(
      checklist,
    );
    final report = registryHealthApiConsistencySourceReleaseGatesReport(
      milestones,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencySourceReleaseGatesPanel(
              report: report,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Source Release Gates'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Gates'), findsOneWidget);
    expect(find.text('Gates: 3'), findsOneWidget);
    expect(find.text('Review: 3'), findsOneWidget);
    expect(find.text('Blocked: 0'), findsOneWidget);
    expect(find.text('Checks: 9'), findsOneWidget);
    expect(find.text('Impact: +6.7'), findsOneWidget);
    expect(find.text('Gate 1: Foundation'), findsOneWidget);
    expect(find.text('Review Needed'), findsWidgets);
    expect(find.text('High Risk'), findsOneWidget);
    expect(find.text('3 checks'), findsWidgets);
    expect(find.text('2 stages, 4 sources, 10 tasks'), findsOneWidget);
    expect(
      find.text(
        'Validation: Analyzer, registry health widget tests, and Foundation export review.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Run dart analyze for tenun and tenun_showcase.'),
      findsWidgets,
    );
    expect(
      find.textContaining(
        'Acceptance: No required API consistency gaps are introduced in Foundation.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'api consistency source verification panel renders deduped checks',
    (tester) async {
      final actionPlan = registryHealthApiConsistencyActionPlan(
        registryHealthApiConsistencyReport([
          const ChartCapabilities(
            type: ChartType.line,
            typeString: 'line',
            dataShape: ChartSeriesDataShape.cartesian,
            isRegistered: true,
            supportsSampling: true,
            supportsZoom: true,
            supportsDrilldown: false,
            supportsLegend: true,
            supportsTooltip: true,
            supportsRuntimeSwitching: true,
            apiContract: ChartApiContracts.optionConfig,
          ),
        ]),
      );
      final plan = registryHealthApiConsistencyImplementationPlan(actionPlan);
      final traceability = registryHealthApiConsistencyTraceabilityReport(plan);
      final queue = registryHealthApiConsistencySourceQueueReport(traceability);
      final sourcePlan = registryHealthApiConsistencySourcePlanReport(queue);
      final checklist = registryHealthApiConsistencySourceChecklistReport(
        sourcePlan,
      );
      final milestones = registryHealthApiConsistencySourceMilestonesReport(
        checklist,
      );
      final gates = registryHealthApiConsistencySourceReleaseGatesReport(
        milestones,
      );
      final report = registryHealthApiConsistencySourceVerificationReport(
        gates,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RegistryHealthApiConsistencySourceVerificationPanel(
                report: report,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Source Verification'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
      expect(find.text('Copy Matrix'), findsOneWidget);
      expect(find.text('Verifications: 5'), findsOneWidget);
      expect(find.text('Shared: 2'), findsOneWidget);
      expect(find.text('Gate Links: 9'), findsOneWidget);
      expect(find.text('Review: 5'), findsOneWidget);
      expect(find.text('Impact: +6.7'), findsOneWidget);
      expect(find.text('Analyzer'), findsOneWidget);
      expect(find.text('Review Needed'), findsWidgets);
      expect(find.text('3 gates, 3 milestones'), findsWidgets);
      expect(
        find.text('Run dart analyze for tenun and tenun_showcase.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Gates: Gate 1: Foundation, Gate 2: Public Surface, Gate 3: Adoption & Routing',
        ),
        findsWidgets,
      );
      expect(
        find.text('Milestones: Foundation, Public Surface, Adoption & Routing'),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'api consistency primitive remediation panel renders shared primitives',
    (tester) async {
      final actionPlan = registryHealthApiConsistencyActionPlan(
        registryHealthApiConsistencyReport([
          const ChartCapabilities(
            type: ChartType.calendar,
            typeString: 'calendar',
            dataShape: ChartSeriesDataShape.calendar,
            isRegistered: true,
            supportsSampling: false,
            supportsZoom: false,
            supportsDrilldown: false,
            supportsLegend: false,
            supportsTooltip: true,
            supportsRuntimeSwitching: true,
            apiContract: ChartApiContracts.optionConfig,
          ),
        ]),
      );
      final report = registryHealthApiConsistencyPrimitiveRemediationReport(
        actionPlan,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RegistryHealthApiConsistencyPrimitiveRemediationPanel(
                report: report,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Primitive Plan'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
      expect(find.text('Copy Checklist'), findsOneWidget);
      expect(find.text('Primitives: 5'), findsOneWidget);
      expect(find.text('Actions: 5'), findsOneWidget);
      expect(find.text('Required: 0'), findsOneWidget);
      expect(find.text('Impact: +6.7'), findsOneWidget);
      expect(find.text('Interaction'), findsOneWidget);
      expect(find.text('Warnings'), findsWidgets);
      expect(find.text('Later'), findsWidgets);
      expect(find.text('1 actions'), findsWidgets);
      expect(find.text('Impact +1.8'), findsWidgets);
      expect(
        find.text(
          'Fields: onElementTap, onSelectionChanged, showActiveElement',
        ),
        findsOneWidget,
      );
      expect(find.text('Covers: Interaction'), findsOneWidget);
      expect(find.text('Shared interaction contract'), findsOneWidget);
      expect(
        find.text(
          'Accept: Widget APIs expose tap, selection, and active-element hooks.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('api consistency field remediation panel renders ranked fields', (
    tester,
  ) async {
    final actionPlan = registryHealthApiConsistencyActionPlan(
      registryHealthApiConsistencyReport([
        const ChartCapabilities(
          type: ChartType.calendar,
          typeString: 'calendar',
          dataShape: ChartSeriesDataShape.calendar,
          isRegistered: true,
          supportsSampling: false,
          supportsZoom: false,
          supportsDrilldown: false,
          supportsLegend: false,
          supportsTooltip: true,
          supportsRuntimeSwitching: true,
          apiContract: ChartApiContracts.optionConfig,
        ),
      ]),
    );
    final report = registryHealthApiConsistencyFieldRemediationReport(
      actionPlan,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthApiConsistencyFieldRemediationPanel(
              report: report,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Field Remediation'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Checklist'), findsOneWidget);
    expect(find.text('Fields: 11'), findsOneWidget);
    expect(find.text('Actions: 5'), findsOneWidget);
    expect(find.text('Required: 0'), findsOneWidget);
    expect(find.text('Impact: +6.7'), findsOneWidget);
    expect(find.text('emptyBuilder'), findsOneWidget);
    expect(find.text('Warnings'), findsWidgets);
    expect(find.text('Later'), findsWidgets);
    expect(find.text('1 actions'), findsWidgets);
    expect(find.text('Impact +1.8'), findsWidgets);
    expect(find.text('Covers: Empty State'), findsOneWidget);
    expect(find.text('emptyBuilder field contract'), findsOneWidget);
    expect(
      find.text(
        'Accept: emptyBuilder is exposed through the widget API where supported.',
      ),
      findsOneWidget,
    );
    expect(find.text('Families: optionConfig'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('api consistency action plan panel can render compact queue', (
    tester,
  ) async {
    const plan = RegistryHealthApiConsistencyActionPlan(
      items: [
        RegistryHealthApiConsistencyActionItem(
          id: 'optionConfig.emptyState',
          contractName: 'optionConfig',
          familyName: 'optionConfig',
          concernKey: 'emptyState',
          concernLabel: 'Empty State',
          fieldOptions: ['emptyBuilder'],
          chartCount: 1,
          chartExamples: ['calendar'],
          priority: RegistryHealthApiConsistencyActionPriority.critical,
          phase: RegistryHealthApiConsistencyActionPhase.now,
          scoreImpactWeight: 5,
          action: 'Expose an empty-state builder for no-data cases.',
        ),
        RegistryHealthApiConsistencyActionItem(
          id: 'optionConfig.formatting',
          contractName: 'optionConfig',
          familyName: 'optionConfig',
          concernKey: 'formatting',
          concernLabel: 'Formatting',
          fieldOptions: ['valueFormatter'],
          chartCount: 1,
          chartExamples: ['calendar'],
          priority: RegistryHealthApiConsistencyActionPriority.high,
          phase: RegistryHealthApiConsistencyActionPhase.next,
          scoreImpactWeight: 3,
          action: 'Expose formatting hooks.',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryHealthApiConsistencyActionPlanPanel(
            plan: plan,
            actionLimit: 1,
          ),
        ),
      ),
    );

    expect(find.text('Action Plan'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Checklist'), findsOneWidget);
    expect(find.text('Actions: 2'), findsOneWidget);
    expect(find.text('Impact: +8'), findsOneWidget);
    expect(find.text('Critical: 1'), findsOneWidget);
    expect(find.text('Now: 1'), findsOneWidget);
    expect(find.text('optionConfig: Empty State'), findsOneWidget);
    expect(find.text('Impact +5'), findsOneWidget);
    expect(find.text('optionConfig: Formatting'), findsNothing);
    expect(find.text('+1 more actions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('showcase coverage helpers summarize ratios and grouped gaps', () {
    final coverage = ChartFamilyManifests.available(
      bundle: coreChartsBundle,
    ).showcaseCoverage(['bar', 'line', 'unknown', 'bar']);
    final rows = registryHealthCoverageRows(coverage.dataShapeCoverage);

    expect(registryHealthCoverageRatioLabel(coverage.coverageRatio), '29%');
    expect(registryHealthCoverageRatioLabel(double.nan), '0%');
    expect(
      registryHealthCoveragePreview([
        'bar',
        'line',
        'scatter',
      ], visibleLimit: 2),
      'bar, line +1',
    );
    expect(registryHealthCoveragePreview([]), '-');
    expect(rows.map((row) => row.name), ['cartesian', 'pieLike']);
    expect(rows.first.expected, 5);
    expect(rows.first.covered, 2);
    expect(rows.first.missing, 3);
    expect(registryHealthCoverageRatioLabel(rows.first.ratio), '40%');
  });

  test(
    'chart example matrix joins sample and source coverage by chart type',
    () {
      final sampleAudit = auditFocusedChartSamples(
        requireRegisteredTypes: true,
        includeValidationWarnings: false,
      );
      final sourceAudit = auditFocusedChartSampleSources();
      final report = focusedRegistryHealthChartExampleMatrixReport(
        sampleAudit: sampleAudit,
        sourceAudit: sourceAudit,
      );
      final sampled = report.rows.firstWhere(
        (row) => row.hasRegistryEntry && row.sampleCount > 0,
      );
      final json = report.toJson();
      final attentionRows =
          registryHealthChartExampleMatrixVisibleAttentionRows(
            report,
            limit: 3,
          );
      final actionSummaries =
          registryHealthChartExampleMatrixVisibleActionSummaries(
            report,
            limit: 3,
          );
      final prioritySummaries =
          registryHealthChartExampleMatrixVisiblePrioritySummaries(
            report,
            limit: 3,
          );
      final nextWorkItems = registryHealthChartExampleMatrixNextWorkItems(
        report,
        limit: 3,
      );

      expect(report.rowCount, greaterThan(0));
      expect(report.unknownRowCount, 0);
      expect(
        report.attentionCount,
        report.missingSampleCount +
            report.issueRowCount +
            report.unknownRowCount,
      );
      expect(report.statusSummaryCount, report.statusSummaries.length);
      expect(report.statusCounts, {
        'ready': report.readyCount,
        'missingSample': report.missingSampleCount,
        'issue': report.issueRowCount,
        'unknown': report.unknownRowCount,
      });
      expect(report.actionSummaryCount, report.actionSummaries.length);
      expect(report.prioritySummaryCount, report.prioritySummaries.length);
      expect(
        report.attentionPrioritySummaryCount,
        report.attentionPrioritySummaries.length,
      );
      expect(report.nextWorkItemCount, report.nextWorkItems.length);
      expect(report.nextWorkItemCount, report.attentionCount);
      expect(report.readinessRatio, inInclusiveRange(0, 1));
      expect(report.attentionRatio, inInclusiveRange(0, 1));
      expect(report.readinessLabel, isNotEmpty);
      expect(report.attentionRatioLabel, isNotEmpty);
      expect(
        report.actionSummaries.fold<int>(
          0,
          (count, summary) => count + summary.rowCount,
        ),
        report.attentionCount,
      );
      expect(
        report.actionSummaries.every(
          (summary) =>
              summary.action.isNotEmpty && summary.statusLabel.isNotEmpty,
        ),
        isTrue,
      );
      expect(
        report.prioritySummaries.fold<int>(
          0,
          (count, summary) => count + summary.rowCount,
        ),
        report.rowCount,
      );
      expect(
        report.attentionPrioritySummaries.fold<int>(
          0,
          (count, summary) => count + summary.attentionCount,
        ),
        report.attentionCount,
      );
      expect(
        report.statusSummaries.fold<int>(
          0,
          (count, summary) => count + summary.count,
        ),
        report.rowCount,
      );
      expect(report.statusSummaries.map((summary) => summary.bucketLabel), [
        'Ready',
        'Gaps',
        'Issues',
        'Unknown',
      ]);
      expect(
        report.prioritySummaries.every(
          (summary) => summary.priorityLabel.isNotEmpty,
        ),
        isTrue,
      );
      expect(actionSummaries.length, lessThanOrEqualTo(3));
      expect(prioritySummaries.length, lessThanOrEqualTo(3));
      expect(nextWorkItems.length, lessThanOrEqualTo(3));
      expect(attentionRows.length, lessThanOrEqualTo(3));
      expect(
        attentionRows.every(
          (row) => row.status != RegistryHealthChartExampleMatrixStatus.ready,
        ),
        isTrue,
      );
      if (attentionRows.isNotEmpty) {
        expect(attentionRows.first.nextAction, isNotEmpty);
        expect(attentionRows.first.statusLabel, isNotEmpty);
        expect(attentionRows.first.priorityLabel, isNotEmpty);
      }
      if (nextWorkItems.isNotEmpty) {
        expect(nextWorkItems.first.rank, 1);
        expect(nextWorkItems.first.typeString, isNotEmpty);
        expect(nextWorkItems.first.action, isNotEmpty);
        expect(nextWorkItems.first.priorityLabel, isNotEmpty);
        expect(nextWorkItems.first.statusLabel, isNotEmpty);
      }
      expect(sampled.hasRegistryEntry, isTrue);
      expect(sampled.sampleCount, greaterThan(0));
      expect(
        sampled.sourceCheckCount,
        sampled.sampleCount * sourceAudit.caseCount,
      );
      expect(sampled.nextAction, isNotEmpty);
      expect(sampled.statusLabel, isNotEmpty);
      expect(sampled.priorityRank, greaterThanOrEqualTo(0));
      expect(sampled.priorityLabel, isNotEmpty);
      expect(
        sampled.status,
        isNot(RegistryHealthChartExampleMatrixStatus.missingSample),
      );
      expect(
        sampled.status,
        isNot(RegistryHealthChartExampleMatrixStatus.unknown),
      );
      expect(json, containsPair('rowCount', report.rowCount));
      expect(json, containsPair('attentionCount', report.attentionCount));
      expect(
        json,
        containsPair('actionSummaryCount', report.actionSummaryCount),
      );
      expect(
        json,
        containsPair('prioritySummaryCount', report.prioritySummaryCount),
      );
      expect(
        json,
        containsPair(
          'attentionPrioritySummaryCount',
          report.attentionPrioritySummaryCount,
        ),
      );
      expect(json, containsPair('nextWorkItemCount', report.nextWorkItemCount));
      expect(
        json,
        containsPair(
          'nextWorkItemsExportedCount',
          lessThanOrEqualTo(report.nextWorkItemCount),
        ),
      );
      expect(
        json,
        containsPair('nextWorkItemsHiddenCount', greaterThanOrEqualTo(0)),
      );
      expect(json, containsPair('readinessRatio', report.readinessRatio));
      expect(json, containsPair('readinessLabel', report.readinessLabel));
      expect(json, containsPair('attentionRatio', report.attentionRatio));
      expect(
        json,
        containsPair('attentionRatioLabel', report.attentionRatioLabel),
      );
      expect(json, containsPair('statusCounts', report.statusCounts));
      expect(
        json,
        containsPair('statusSummaryCount', report.statusSummaryCount),
      );
      expect(
        (json['statusSummaries'] as List).length,
        report.statusSummaryCount,
      );
      expect(
        (json['actionSummaries'] as List).length,
        report.actionSummaryCount,
      );
      expect(
        (json['prioritySummaries'] as List).length,
        report.prioritySummaryCount,
      );
      expect(
        (json['attentionPrioritySummaries'] as List).length,
        report.attentionPrioritySummaryCount,
      );
      expect((json['nextWorkItems'] as List).length, lessThanOrEqualTo(12));
      if ((json['nextWorkItems'] as List).isNotEmpty) {
        expect((json['nextWorkItems'] as List).first, containsPair('rank', 1));
        expect(
          (json['nextWorkItems'] as List).first,
          containsPair('action', isNotEmpty),
        );
      }
      if ((json['prioritySummaries'] as List).isNotEmpty) {
        expect(
          (json['prioritySummaries'] as List).first,
          containsPair('priorityLabel', isNotEmpty),
        );
        expect(
          (json['prioritySummaries'] as List).first,
          containsPair('attentionCount', isA<int>()),
        );
      }
      if ((json['actionSummaries'] as List).isNotEmpty) {
        expect(
          (json['actionSummaries'] as List).first,
          containsPair('action', isNotEmpty),
        );
        expect(
          (json['actionSummaries'] as List).first,
          containsPair('statusLabel', isNotEmpty),
        );
      }
      expect((json['attentionRows'] as List).length, report.attentionCount);
      expect((json['rows'] as List).first, containsPair('status', isNotEmpty));
      expect(
        (json['rows'] as List).first,
        containsPair('statusLabel', isNotEmpty),
      );
      expect(
        (json['rows'] as List).first,
        containsPair('nextAction', isNotEmpty),
      );
      expect(
        (json['rows'] as List).first,
        containsPair('priorityRank', isA<int>()),
      );
      expect(
        (json['rows'] as List).first,
        containsPair('priorityLabel', isNotEmpty),
      );
      expect(
        registryHealthChartExampleMatrixStatusLabel(report),
        report.issueRowCount > 0
            ? 'Issues'
            : report.missingSampleCount > 0
            ? 'Gaps'
            : 'Ready',
      );
    },
  );

  test('chart example matrix prioritizes actionable attention rows', () {
    const report = RegistryHealthChartExampleMatrixReport(
      rows: [
        RegistryHealthChartExampleMatrixRow(
          typeString: 'sankey',
          displayName: 'Sankey',
          dataShape: 'flow',
          bundleName: 'flow',
          bundleNames: ['flow'],
          hasRegistryEntry: true,
          sampleCount: 0,
          customCodeCount: 0,
          sourceCheckCount: 0,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'bar',
          displayName: 'Bar',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 0,
          customCodeCount: 0,
          sourceCheckCount: 0,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'madeUp',
          displayName: 'madeUp',
          dataShape: 'unknown',
          bundleName: 'unknown',
          bundleNames: [],
          hasRegistryEntry: false,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'heatmap',
          displayName: 'Heatmap',
          dataShape: 'matrix',
          bundleName: 'common',
          bundleNames: ['common'],
          hasRegistryEntry: true,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 1,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'line',
          displayName: 'Line',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 2,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'area',
          displayName: 'Area',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
      ],
    );

    expect(report.readyCount, 1);
    expect(report.rowCount, 6);
    expect(report.readinessRatio, closeTo(1 / 6, 0.0001));
    expect(report.attentionRatio, closeTo(5 / 6, 0.0001));
    expect(report.readinessLabel, '17%');
    expect(report.attentionRatioLabel, '83%');
    expect(registryHealthChartExampleMatrixRatioLabel(double.nan), '0%');
    expect(registryHealthChartExampleMatrixRatioLabel(1.2), '100%');
    expect(report.statusSummaries.map((summary) => summary.bucketLabel), [
      'Ready',
      'Gaps',
      'Issues',
      'Unknown',
    ]);
    expect(report.statusSummaries.map((summary) => summary.count), [
      1,
      2,
      2,
      1,
    ]);
    expect(report.statusSummaries.map((summary) => summary.ratioLabel), [
      '17%',
      '33%',
      '33%',
      '17%',
    ]);
    expect(report.statusSummaries.map((summary) => summary.needsAttention), [
      false,
      true,
      true,
      true,
    ]);
    expect(report.attentionRows.map((row) => row.typeString), [
      'line',
      'heatmap',
      'madeUp',
      'bar',
      'sankey',
    ]);
    expect(report.attentionRows.map((row) => row.priorityLabel), [
      'Core',
      'Common',
      'Unmapped',
      'Core',
      'Specialized',
    ]);
    expect(
      registryHealthChartExampleMatrixVisibleAttentionRows(
        report,
        limit: 2,
      ).map((row) => row.typeString),
      ['line', 'heatmap'],
    );
    expect(
      (report.toJson()['attentionRows'] as List).first,
      containsPair('priorityLabel', 'Core'),
    );
    expect(
      (report.toJson()['attentionRows'] as List).first,
      containsPair('priorityRank', 0),
    );
    expect(report.prioritySummaries.map((summary) => summary.priorityLabel), [
      'Unmapped',
      'Core',
      'Common',
      'Specialized',
    ]);
    expect(report.attentionPrioritySummaryCount, 4);
    expect(
      report.prioritySummaries.first.toJson(),
      containsPair('unknownRowCount', 1),
    );
    expect(
      report.prioritySummaries
          .firstWhere((summary) => summary.priorityLabel == 'Core')
          .toJson(),
      containsPair('attentionCount', 2),
    );
    expect(
      registryHealthChartExampleMatrixVisiblePrioritySummaries(
        report,
        limit: 2,
      ).map((summary) => summary.priorityLabel),
      ['Unmapped', 'Core'],
    );
    expect(report.nextWorkItems.map((item) => item.typeString), [
      'line',
      'heatmap',
      'madeUp',
      'bar',
      'sankey',
    ]);
    expect(report.nextWorkItems.map((item) => item.rank), [1, 2, 3, 4, 5]);
    expect(
      registryHealthChartExampleMatrixNextWorkItems(
        report,
        limit: 2,
      ).map((item) => item.typeString),
      ['line', 'heatmap'],
    );
    expect(
      registryHealthChartExampleMatrixNextWorkItems(report, limit: 0),
      isEmpty,
    );
    final limitedJson = report.toJson(nextWorkItemLimit: 2);
    expect(limitedJson, containsPair('nextWorkItemCount', 5));
    expect(limitedJson, containsPair('nextWorkItemsExportedCount', 2));
    expect(limitedJson, containsPair('nextWorkItemsHiddenCount', 3));
    expect(limitedJson, containsPair('readinessLabel', '17%'));
    expect(
      (limitedJson['statusSummaries'] as List).first,
      containsPair('bucketLabel', 'Ready'),
    );
    expect(
      (limitedJson['nextWorkItems'] as List).first,
      containsPair('rank', 1),
    );
  });

  testWidgets('chart example matrix panel renders ranked next work items', (
    tester,
  ) async {
    const report = RegistryHealthChartExampleMatrixReport(
      rows: [
        RegistryHealthChartExampleMatrixRow(
          typeString: 'bar',
          displayName: 'Bar',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 0,
          customCodeCount: 0,
          sourceCheckCount: 0,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'line',
          displayName: 'Line',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 2,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthChartExampleMatrixPanel(report: report),
          ),
        ),
      ),
    );

    expect(find.text('Next Work'), findsOneWidget);
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('Readiness Breakdown'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Ready 0'), findsOneWidget);
    expect(find.text('Gaps 1'), findsOneWidget);
    expect(find.text('Issues 1'), findsOneWidget);
    expect(find.text('Unknown 0'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.textContaining('line: Core Issue'), findsWidgets);
    expect(find.textContaining('Fix source audit issues'), findsWidgets);
    expect(find.textContaining('bar: Core Gap'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chart example matrix panel options hide and limit sections', (
    tester,
  ) async {
    const report = RegistryHealthChartExampleMatrixReport(
      rows: [
        RegistryHealthChartExampleMatrixRow(
          typeString: 'bar',
          displayName: 'Bar',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 0,
          customCodeCount: 0,
          sourceCheckCount: 0,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'line',
          displayName: 'Line',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 2,
        ),
      ],
    );
    const options = RegistryHealthChartExampleMatrixPanelOptions(
      showMetrics: false,
      showBreakdown: false,
      showTable: false,
      actionSummaryLimit: 1,
      nextWorkLimit: 1,
      attentionLimit: 1,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthChartExampleMatrixPanel(
              report: report,
              options: options,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Readiness'), findsNothing);
    expect(find.text('Readiness Breakdown'), findsNothing);
    expect(find.text('Type'), findsNothing);
    expect(find.text('Next Work'), findsOneWidget);
    expect(find.text('Attention Queue'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsNothing);
    expect(find.text('+1 more'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('registry health example forwards chart matrix options', (
    tester,
  ) async {
    _setRegistryHealthTestViewport(tester);
    ChartRegistry.clear();
    allChartsBundle.register();
    const detailOptions = RegistryHealthDetailOptions(
      readinessGateLimit: 6,
      readinessActionLimit: 7,
      sampleIssueLimit: 1,
      sourceIssueLimit: 2,
      simpleSourceIssueLimit: 3,
      sourceMapIssueLimit: 4,
      renamePlanVisibleLimit: 5,
      apiConsistencyRowLimit: 6,
      apiConsistencyActionLimit: 7,
      apiConsistencyConcernLimit: 8,
      apiConsistencyFamilyLimit: 9,
      apiConsistencyPrimitiveLimit: 8,
      apiConsistencyFieldLimit: 10,
      proReadinessEntrypointLimit: 3,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryHealthExample(
            showcaseBacklogVisibleLimit: 1,
            showcaseBacklogOptions: RegistryHealthShowcaseBacklogPanelOptions(
              showStarterJson: false,
              showDartSample: false,
            ),
            chartExampleMatrixOptions:
                RegistryHealthChartExampleMatrixPanelOptions(
                  showMetrics: false,
                  showBreakdown: false,
                  showWorkSections: false,
                  showTable: false,
                ),
            detailOptions: detailOptions,
            sectionOptions: RegistryHealthSectionOptions(
              showContractMatrices: false,
              showRuntimeDiagnostics: false,
              showCapabilityMatrix: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await _waitForRegistryHealthSourceMapAudit(tester);

    expect(find.text('Chart Example Matrix'), findsOneWidget);
    expect(
      find.byType(RegistryHealthChartExampleMatrixMetricStrip),
      findsNothing,
    );
    expect(
      find.byType(RegistryHealthChartExampleMatrixStatusBreakdown),
      findsNothing,
    );
    expect(
      find.byType(RegistryHealthChartExampleMatrixWorkSections),
      findsNothing,
    );
    expect(find.byType(RegistryHealthChartExampleMatrixTable), findsNothing);
    expect(
      tester
          .widget<RegistryHealthReadinessPanel>(
            find.byType(RegistryHealthReadinessPanel),
          )
          .gateLimit,
      6,
    );
    expect(
      tester
          .widget<RegistryHealthReadinessPanel>(
            find.byType(RegistryHealthReadinessPanel),
          )
          .actionLimit,
      7,
    );
    expect(
      tester
          .widget<RegistryHealthSampleAuditPanel>(
            find.byType(RegistryHealthSampleAuditPanel),
          )
          .issueLimit,
      1,
    );
    expect(
      tester
          .widget<RegistryHealthSampleSourceAuditPanel>(
            find.byType(RegistryHealthSampleSourceAuditPanel),
          )
          .issueLimit,
      2,
    );
    expect(
      tester
          .widget<RegistryHealthSimpleSourceAuditPanel>(
            find.byType(RegistryHealthSimpleSourceAuditPanel),
          )
          .issueLimit,
      3,
    );
    expect(
      tester
          .widget<RegistryHealthShowcaseRenamePlanPanel>(
            find.byType(RegistryHealthShowcaseRenamePlanPanel),
          )
          .visibleLimit,
      5,
    );
    expect(
      tester
          .widget<RegistryHealthShowcaseSourceMapAuditPanel>(
            find.byType(RegistryHealthShowcaseSourceMapAuditPanel),
          )
          .issueLimit,
      4,
    );
    expect(
      tester
          .widget<RegistryHealthProReadinessPanel>(
            find.byType(RegistryHealthProReadinessPanel),
          )
          .entrypointLimit,
      3,
    );
    expect(find.text('Sample Audit'), findsWidgets);
    expect(find.text('API Contract Matrix'), findsNothing);
    expect(find.text('Runtime Switch Groups'), findsNothing);
    expect(find.text('Capability Matrix'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('registry health detail options expose reusable presets', () {
    const compact = RegistryHealthDetailOptions.compact;
    final custom = compact.copyWith(
      readinessGateLimit: 6,
      readinessActionLimit: 5,
      sourceIssueLimit: 7,
      renamePlanVisibleLimit: 3,
      apiConsistencyRowLimit: 6,
      apiConsistencyActionLimit: 5,
      apiConsistencyConcernLimit: 4,
      apiConsistencyFamilyLimit: 3,
      apiConsistencyPrimitiveLimit: 5,
      apiConsistencyFieldLimit: 2,
      packageBoundaryIssueLimit: 1,
      proReadinessIssueLimit: 2,
      proReadinessEntrypointLimit: 2,
    );

    expect(compact.readinessGateLimit, 4);
    expect(compact.readinessActionLimit, 3);
    expect(compact.sampleIssueLimit, 4);
    expect(compact.sourceMapIssueLimit, 4);
    expect(compact.apiConsistencyRowLimit, 4);
    expect(compact.apiConsistencyActionLimit, 3);
    expect(compact.apiConsistencyConcernLimit, 3);
    expect(compact.apiConsistencyFamilyLimit, 3);
    expect(compact.apiConsistencyPrimitiveLimit, 3);
    expect(compact.apiConsistencyFieldLimit, 4);
    expect(compact.packageBoundaryIssueLimit, 4);
    expect(compact.proReadinessIssueLimit, 4);
    expect(compact.proReadinessEntrypointLimit, 3);
    expect(compact.apiConsistencyPanelOptions.rowLimit, 4);
    expect(compact.apiConsistencyPanelOptions.actionLimit, 3);
    expect(compact.apiConsistencyPanelOptions.concernLimit, 3);
    expect(compact.apiConsistencyPanelOptions.familyLimit, 3);
    expect(compact.apiConsistencyPanelOptions.primitiveLimit, 3);
    expect(compact.apiConsistencyPanelOptions.fieldLimit, 4);
    expect(custom.readinessGateLimit, 6);
    expect(custom.readinessActionLimit, 5);
    expect(custom.sampleIssueLimit, 4);
    expect(custom.sourceIssueLimit, 7);
    expect(custom.renamePlanVisibleLimit, 3);
    expect(custom.apiConsistencyRowLimit, 6);
    expect(custom.apiConsistencyActionLimit, 5);
    expect(custom.apiConsistencyConcernLimit, 4);
    expect(custom.apiConsistencyFamilyLimit, 3);
    expect(custom.apiConsistencyPrimitiveLimit, 5);
    expect(custom.apiConsistencyFieldLimit, 2);
    expect(custom.packageBoundaryIssueLimit, 1);
    expect(custom.proReadinessIssueLimit, 2);
    expect(custom.proReadinessEntrypointLimit, 2);
    expect(custom.apiConsistencyPanelOptions.rowLimit, 6);
    expect(custom.apiConsistencyPanelOptions.actionLimit, 5);
    expect(custom.apiConsistencyPanelOptions.concernLimit, 4);
    expect(custom.apiConsistencyPanelOptions.familyLimit, 3);
    expect(custom.apiConsistencyPanelOptions.primitiveLimit, 5);
    expect(custom.apiConsistencyPanelOptions.fieldLimit, 2);
  });

  test('api consistency panel options expose focused presets', () {
    const compact = RegistryHealthApiConsistencyPanelOptions.compact;
    const release = RegistryHealthApiConsistencyPanelOptions.release;
    const planning = RegistryHealthApiConsistencyPanelOptions.planning;
    final custom = release.copyWith(
      rowLimit: 2,
      releaseBriefLimit: 3,
      showSourcePlan: true,
      showAttentionTable: true,
    );

    expect(compact.rowLimit, 4);
    expect(compact.releaseBriefLimit, 4);
    expect(compact.showConformance, isFalse);
    expect(compact.showSourcePlan, isFalse);
    expect(compact.showAttentionTable, isFalse);
    expect(release.rowLimit, 0);
    expect(release.showReleaseBrief, isTrue);
    expect(release.showConformanceGate, isTrue);
    expect(release.showConformanceChecklist, isFalse);
    expect(release.showSourceReleaseGates, isTrue);
    expect(release.showImplementationPlan, isFalse);
    expect(release.showAttentionTable, isFalse);
    expect(planning.showReleaseBrief, isFalse);
    expect(planning.showConformanceGate, isFalse);
    expect(planning.showImplementationPlan, isTrue);
    expect(planning.showTraceability, isTrue);
    expect(planning.showAttentionTable, isTrue);
    expect(custom.rowLimit, 2);
    expect(custom.releaseBriefLimit, 3);
    expect(custom.showSourcePlan, isTrue);
    expect(custom.showAttentionTable, isTrue);
    expect(custom.showConformanceChecklist, isFalse);
  });

  test('registry health section options expose focused presets', () {
    const overview = RegistryHealthSectionOptions.overview;
    const samples = RegistryHealthSectionOptions.samples;
    const contracts = RegistryHealthSectionOptions.contracts;
    final custom = overview.copyWith(
      showReadiness: false,
      showRuntimeDiagnostics: true,
      showPackageBoundary: false,
      showProReadiness: false,
    );

    expect(overview.showReadiness, isTrue);
    expect(overview.showShowcaseCoverage, isTrue);
    expect(overview.showSampleDiagnostics, isFalse);
    expect(overview.showContractMatrices, isFalse);
    expect(overview.showPackageBoundary, isTrue);
    expect(overview.showProReadiness, isTrue);
    expect(samples.showReadiness, isTrue);
    expect(samples.showSampleDiagnostics, isTrue);
    expect(samples.showSummaries, isFalse);
    expect(samples.showPackageBoundary, isFalse);
    expect(samples.showProReadiness, isFalse);
    expect(contracts.showReadiness, isFalse);
    expect(contracts.showContractMatrices, isTrue);
    expect(contracts.showExampleMatrix, isFalse);
    expect(contracts.showPackageBoundary, isFalse);
    expect(contracts.showProReadiness, isFalse);
    expect(custom.showReadiness, isFalse);
    expect(custom.showRuntimeDiagnostics, isTrue);
    expect(custom.showSampleDiagnostics, isFalse);
    expect(custom.showPackageBoundary, isFalse);
    expect(custom.showProReadiness, isFalse);
  });

  testWidgets('chart example matrix work sections render action queues', (
    tester,
  ) async {
    const report = RegistryHealthChartExampleMatrixReport(
      rows: [
        RegistryHealthChartExampleMatrixRow(
          typeString: 'bar',
          displayName: 'Bar',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 0,
          customCodeCount: 0,
          sourceCheckCount: 0,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'line',
          displayName: 'Line',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 2,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthChartExampleMatrixWorkSections(report: report),
          ),
        ),
      ),
    );

    expect(find.text('Priority Summary'), findsOneWidget);
    expect(find.text('Action Summary'), findsOneWidget);
    expect(find.text('Next Work'), findsOneWidget);
    expect(find.text('Attention Queue'), findsOneWidget);
    expect(find.textContaining('Core - 2/2 need work'), findsOneWidget);
    expect(find.textContaining('Fix source audit issues'), findsWidgets);
    expect(find.textContaining('Add focused showcase sample'), findsWidgets);
    expect(find.textContaining('line: Core Issue'), findsWidgets);
    expect(find.textContaining('bar: Core Gap'), findsWidgets);
    expect(find.text('#1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chart example matrix table renders row details', (tester) async {
    const rows = [
      RegistryHealthChartExampleMatrixRow(
        typeString: 'line',
        displayName: 'Line',
        dataShape: 'cartesian',
        bundleName: 'cartesian',
        bundleNames: ['cartesian', 'core'],
        hasRegistryEntry: true,
        sampleCount: 1,
        customCodeCount: 1,
        sourceCheckCount: 1,
        sampleIssueCount: 0,
        sourceIssueCount: 2,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RegistryHealthChartExampleMatrixTable(rows: rows)),
      ),
    );

    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Shape'), findsOneWidget);
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Samples'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('line'), findsOneWidget);
    expect(find.text('cartesian'), findsOneWidget);
    expect(find.text('Core'), findsOneWidget);
    expect(find.text('Issue'), findsOneWidget);
    expect(find.text('Fix source audit issues'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chart example matrix metric strip renders headline counts', (
    tester,
  ) async {
    const report = RegistryHealthChartExampleMatrixReport(
      rows: [
        RegistryHealthChartExampleMatrixRow(
          typeString: 'bar',
          displayName: 'Bar',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 1,
          customCodeCount: 1,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'line',
          displayName: 'Line',
          dataShape: 'cartesian',
          bundleName: 'cartesian',
          bundleNames: ['cartesian', 'core'],
          hasRegistryEntry: true,
          sampleCount: 0,
          customCodeCount: 0,
          sourceCheckCount: 0,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
        RegistryHealthChartExampleMatrixRow(
          typeString: 'madeUp',
          displayName: 'Made Up',
          dataShape: 'unknown',
          bundleName: 'unknown',
          bundleNames: [],
          hasRegistryEntry: false,
          sampleCount: 1,
          customCodeCount: 0,
          sourceCheckCount: 1,
          sampleIssueCount: 0,
          sourceIssueCount: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryHealthChartExampleMatrixMetricStrip(report: report),
        ),
      ),
    );

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Gaps'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Unknown'), findsNWidgets(2));
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(3));
    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chart example matrix status breakdown renders summaries', (
    tester,
  ) async {
    const summaries = [
      RegistryHealthChartExampleMatrixStatusSummary(
        status: RegistryHealthChartExampleMatrixStatus.ready,
        count: 3,
        ratio: 0.5,
      ),
      RegistryHealthChartExampleMatrixStatusSummary(
        status: RegistryHealthChartExampleMatrixStatus.missingSample,
        count: 2,
        ratio: 1 / 3,
      ),
      RegistryHealthChartExampleMatrixStatusSummary(
        status: RegistryHealthChartExampleMatrixStatus.issue,
        count: 1,
        ratio: 1 / 6,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryHealthChartExampleMatrixStatusBreakdown(
            title: 'Status Mix',
            summaries: summaries,
          ),
        ),
      ),
    );

    expect(find.text('Status Mix'), findsOneWidget);
    expect(find.text('Ready 3'), findsOneWidget);
    expect(find.text('Gaps 2'), findsOneWidget);
    expect(find.text('Issues 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('showcase threshold helpers separate hard failures from warnings', () {
    final coverage = ChartFamilyManifests.available(
      bundle: coreChartsBundle,
    ).showcaseCoverage(['bar', 'line', 'unknown', 'bar']);
    final report = registryHealthShowcaseThresholdReport(
      coverage,
      minimumOverallCoverage: 0.5,
      bundleMinimums: {'core': 0.75},
      dataShapeMinimums: {'cartesian': 0.5},
    );
    final completeCoverage =
        ChartFamilyManifests.available(
          bundle: coreChartsBundle,
        ).showcaseCoverage(
          coreChartsBundle.registrations.map((entry) => entry.typeString),
        );
    final completeReport = registryHealthShowcaseThresholdReport(
      completeCoverage,
      minimumOverallCoverage: 1,
      bundleMinimums: {'core': 1},
    );

    expect(report.status, RegistryHealthShowcaseThresholdStatus.fail);
    expect(registryHealthShowcaseThresholdReportLabel(report), 'Failing');
    expect(report.failCount, 2);
    expect(report.warnCount, 3);
    expect(
      report.checks.map((check) => check.key),
      containsAll([
        'unknown_examples',
        'duplicate_examples',
        'overall_coverage',
        'bundle_core',
        'shape_cartesian',
      ]),
    );
    expect(report.toJson(), containsPair('statusLabel', 'Failing'));
    expect(registryHealthShowcaseThresholdRatioLabel(double.nan), '0%');
    expect(completeReport.status, RegistryHealthShowcaseThresholdStatus.pass);
    expect(
      registryHealthShowcaseThresholdReportLabel(completeReport),
      'Passing',
    );
  });

  test('showcase gap helpers expose missing-family queue metadata', () {
    final coverage = ChartFamilyManifests.available(
      bundle: coreChartsBundle,
    ).showcaseCoverage(['bar', 'line']);
    final rows = registryHealthShowcaseGapRows(coverage.missingEntries);

    expect(rows.map((row) => row.typeString), [
      'area',
      'bubble',
      'scatter',
      'donut',
      'pie',
    ]);
    expect(rows.first.shapeName, 'cartesian');
    expect(rows.first.bundleName, 'cartesian');
    expect(rows.first.apiContractName, 'cartesian');
    expect(rows.first.capabilities, containsAll(['sample', 'zoom', 'tip']));
    expect(
      registryHealthShowcaseGapCapabilityLabels(coverage.missingEntries.first),
      rows.first.capabilities,
    );
  });

  test('showcase naming helpers classify canonical, alias, and drifted keys', () {
    const family = ChartShowcaseFamily(
      id: 'naming',
      title: 'Naming',
      description: 'Naming samples.',
      samples: [
        ChartShowcaseSample('Canonical Bar', 180, {'type': 'bar'}),
        ChartShowcaseSample('Camel Bar Race', 180, {'type': 'barRace'}),
        ChartShowcaseSample('ROC Alias', 180, {'type': 'roc'}),
        ChartShowcaseSample('Missing Type', 180, {'type': 'madeUp'}),
      ],
    );
    const readyFamily = ChartShowcaseFamily(
      id: 'ready',
      title: 'Ready',
      description: 'Renameable samples.',
      samples: [
        ChartShowcaseSample('Camel Bar Race', 180, {'type': 'barRace'}),
      ],
    );
    const cleanFamily = ChartShowcaseFamily(
      id: 'clean',
      title: 'Clean',
      description: 'Canonical samples.',
      samples: [
        ChartShowcaseSample('Canonical Bar', 180, {'type': 'bar'}),
      ],
    );
    final report = registryHealthShowcaseNamingReport([family]);
    final readyReport = registryHealthShowcaseNamingReport([readyFamily]);
    final cleanReport = registryHealthShowcaseNamingReport([cleanFamily]);
    final visibleRows = registryHealthShowcaseNamingVisibleRows(report);
    final renamePlanReport = registryHealthShowcaseRenamePlanReport(report);
    final renameItems = renamePlanReport.items;
    final renameBlockers = renamePlanReport.blockers;
    final patchOperations = renamePlanReport.patchOperations;
    final duplicatePatchReport = RegistryHealthShowcaseRenamePlanReport(
      items: [renameItems.first, renameItems.first],
      blockers: const [],
    );
    final renameJson = renamePlanReport.toJson(itemLimit: 1, blockerLimit: 1);

    expect(report.sampleCount, 4);
    expect(report.canonicalCount, 1);
    expect(report.normalizedCount, 1);
    expect(report.aliasCount, 1);
    expect(report.unknownCount, 1);
    expect(report.issueCount, 3);
    expect(registryHealthShowcaseNamingReportLabel(report), 'Unknowns');
    expect(
      registryHealthShowcaseRenamePlanStatus(report),
      RegistryHealthShowcaseRenamePlanStatus.blocked,
    );
    expect(
      renamePlanReport.status,
      RegistryHealthShowcaseRenamePlanStatus.blocked,
    );
    expect(renamePlanReport.statusLabel, 'Blocked');
    expect(renamePlanReport.safeRenameCount, 2);
    expect(renamePlanReport.manifestWorkCount, 1);
    expect(renamePlanReport.patchOperationCount, 2);
    expect(renamePlanReport.patchIsValid, isTrue);
    expect(renamePlanReport.patchIssueCount, 0);
    expect(renamePlanReport.visibleItems(limit: 1).single.fromType, 'barRace');
    expect(
      renamePlanReport.visiblePatchOperations(limit: 1).single.path,
      'families[0].samples[1].json.type',
    );
    expect(
      renamePlanReport.visiblePatchPreviewLines(limit: 1).single,
      'rename:0:1:type families[0].samples[1].json.type: "barRace" -> "barrace"',
    );
    expect(
      renamePlanReport.visibleBlockers(limit: 1).single.providedType,
      'madeUp',
    );
    expect(registryHealthShowcaseRenamePlanStatusLabel(report), 'Blocked');
    expect(
      registryHealthShowcaseRenamePlanStatus(readyReport),
      RegistryHealthShowcaseRenamePlanStatus.ready,
    );
    expect(
      registryHealthShowcaseRenamePlanStatus(cleanReport),
      RegistryHealthShowcaseRenamePlanStatus.clean,
    );
    expect(visibleRows.map((row) => row.status), [
      RegistryHealthShowcaseNamingStatus.unknown,
      RegistryHealthShowcaseNamingStatus.normalized,
      RegistryHealthShowcaseNamingStatus.alias,
    ]);
    expect(visibleRows.first.providedKey, 'madeUp');
    expect(report.rows[1].familyIndex, 0);
    expect(report.rows[1].sampleIndex, 1);
    expect(report.rows[1].canonicalKey, 'barrace');
    expect(report.rows[1].suggestion, contains('"barrace"'));
    expect(report.rows[2].canonicalKey, 'rocCurve');
    expect(report.toJson(), containsPair('unknownCount', 1));
    expect(renameItems.map((item) => item.fromType), ['barRace', 'roc']);
    expect(renameItems.map((item) => item.toType), ['barrace', 'rocCurve']);
    expect(renameItems.first.jsonPath, 'type');
    expect(renameItems.first.targetPath, 'families[0].samples[1].json.type');
    expect(
      renameItems.first.sourceLocation.registryPath,
      'ChartSamplesRegistry.focusedFamilies[0].samples[1].json.type',
    );
    expect(renameItems.first.sampleIndex, 1);
    expect(renameItems.first.reason, contains('normalization'));
    expect(patchOperations.map((operation) => operation.path), [
      'families[0].samples[1].json.type',
      'families[0].samples[2].json.type',
    ]);
    expect(patchOperations.first.op, 'replace');
    expect(patchOperations.first.id, 'rename:0:1:type');
    expect(patchOperations.first.oldValue, 'barRace');
    expect(patchOperations.first.value, 'barrace');
    expect(
      patchOperations.first.sourceLocation.sourceFile,
      registryHealthChartSamplesRegistrySourceFile,
    );
    expect(
      patchOperations.first.sourceLocation.registryPath,
      'ChartSamplesRegistry.focusedFamilies[0].samples[1].json.type',
    );
    expect(
      patchOperations.first.preview,
      'rename:0:1:type families[0].samples[1].json.type: "barRace" -> "barrace"',
    );
    expect(duplicatePatchReport.patchIsValid, isFalse);
    expect(duplicatePatchReport.patchIssues.map((issue) => issue.code), [
      'DUPLICATE_PATCH_ID',
      'DUPLICATE_PATCH_PATH',
    ]);
    expect(
      (duplicatePatchReport.toJson()['patchIssues'] as List).first,
      containsPair('operationId', 'rename:0:1:type'),
    );
    expect(renameBlockers.map((item) => item.providedType), ['madeUp']);
    expect(renameBlockers.first.sampleIndex, 3);
    expect(
      renameBlockers.first.sourceLocation.registryPath,
      'ChartSamplesRegistry.focusedFamilies[0].samples[3].json.type',
    );
    expect(renameBlockers.first.reason, contains('No manifest entry'));
    expect(renameJson, containsPair('status', 'blocked'));
    expect(renameJson, containsPair('statusLabel', 'Blocked'));
    expect(renameJson, containsPair('count', 2));
    expect(renameJson, containsPair('safeRenameCount', 2));
    expect(renameJson, containsPair('exportedCount', 1));
    expect(renameJson, containsPair('hiddenCount', 1));
    expect(renameJson, containsPair('patchOperationCount', 2));
    expect(renameJson, containsPair('patchOperationsExportedCount', 1));
    expect(renameJson, containsPair('patchOperationsHiddenCount', 1));
    expect(renameJson, containsPair('patchIsValid', true));
    expect(renameJson, containsPair('patchIssueCount', 0));
    expect(renameJson, containsPair('manifestWorkCount', 1));
    expect(renameJson, containsPair('manifestWorkExportedCount', 1));
    expect(renameJson, containsPair('manifestWorkHiddenCount', 0));
    expect(renameJson, containsPair('isReady', false));
    expect(
      (renameJson['items'] as List).first,
      containsPair('toType', 'barrace'),
    );
    expect(
      (renameJson['items'] as List).first,
      containsPair('targetPath', 'families[0].samples[1].json.type'),
    );
    expect(
      ((renameJson['items'] as List).first
          as Map<String, dynamic>)['sourceLocation'],
      containsPair(
        'registryPath',
        'ChartSamplesRegistry.focusedFamilies[0].samples[1].json.type',
      ),
    );
    expect(
      (renameJson['patchOperations'] as List).first,
      containsPair('id', 'rename:0:1:type'),
    );
    expect(
      (renameJson['patchOperations'] as List).first,
      containsPair('path', 'families[0].samples[1].json.type'),
    );
    expect(
      (renameJson['patchOperations'] as List).first,
      containsPair('value', 'barrace'),
    );
    expect(
      ((renameJson['patchOperations'] as List).first
          as Map<String, dynamic>)['sourceLocation'],
      containsPair('sourceFile', registryHealthChartSamplesRegistrySourceFile),
    );
    expect((renameJson['patchPreview'] as List).first, contains('barRace'));
    expect(
      (renameJson['manifestWorkItems'] as List).first,
      containsPair('providedType', 'madeUp'),
    );
    expect(
      ((renameJson['manifestWorkItems'] as List).first
          as Map<String, dynamic>)['sourceLocation'],
      containsPair(
        'registryPath',
        'ChartSamplesRegistry.focusedFamilies[0].samples[3].json.type',
      ),
    );
    expect(
      registryHealthShowcaseRenamePlanJson(
        report,
        itemLimit: 1,
        blockerLimit: 1,
      ),
      renameJson,
    );
  });

  test('showcase source location helpers expose registry paths', () {
    final location = registryHealthShowcaseFocusedSampleSourceLocation(
      familyId: 'naming',
      familyTitle: 'Naming',
      familyIndex: 0,
      sampleTitle: 'Camel Bar Race',
      sampleIndex: 1,
      jsonPath: 'type',
      chartType: 'barRace',
    );
    final fallbackPath = registryHealthShowcaseFocusedSampleRegistryPath(
      familyId: 'Naming Family',
      familyIndex: null,
      sampleTitle: 'Camel Bar Race',
      sampleIndex: null,
      jsonPath: 'type',
    );

    expect(location.sourceFile, registryHealthChartSamplesRegistrySourceFile);
    expect(location.hasExactPosition, isFalse);
    expect(
      location.registryPath,
      'ChartSamplesRegistry.focusedFamilies[0].samples[1].json.type',
    );
    expect(
      registryHealthShowcaseSourceDisplayPath(location),
      'lib/example/chart_samples_registry.dart::'
      'ChartSamplesRegistry.focusedFamilies[0].samples[1].json.type',
    );
    expect(location.toJson(), containsPair('chartType', 'barRace'));
    expect(
      fallbackPath,
      'ChartSamplesRegistry.focusedFamilies.naming-family.samples.'
      'camel-bar-race.json.type',
    );
  });

  test('showcase source maps resolve focused samples to exact positions', () {
    final sourceMap = registryHealthShowcaseSourceMapFromText(
      _sourceMapFixture,
      sourceFile: 'lib/example/chart_samples_registry.dart',
    );
    final location = sourceMap.locationFor(
      familyId: 'naming',
      familyTitle: 'Naming',
      familyIndex: 0,
      sampleTitle: 'Camel Bar Race',
      sampleIndex: 0,
      jsonPath: 'type',
      chartType: 'barRace',
    );
    const item = RegistryHealthShowcaseRenamePlanItem(
      familyId: 'naming',
      familyTitle: 'Naming',
      familyIndex: 0,
      sampleTitle: 'Camel Bar Race',
      sampleIndex: 0,
      jsonPath: 'type',
      fromType: 'barRace',
      toType: 'barrace',
      status: RegistryHealthShowcaseNamingStatus.normalized,
      reason: 'Matches manifest after normalization.',
    );
    const blocker = RegistryHealthShowcaseRenameBlocker(
      familyId: 'naming',
      familyTitle: 'Naming',
      familyIndex: 0,
      sampleTitle: 'Missing Type',
      sampleIndex: 1,
      jsonPath: 'type',
      providedType: 'madeUp',
      status: RegistryHealthShowcaseNamingStatus.unknown,
      reason: 'No manifest entry matches this type key.',
      suggestedAction: 'Add a manifest alias or chart registration.',
    );
    const report = RegistryHealthShowcaseRenamePlanReport(
      items: [item],
      blockers: [blocker],
    );
    final itemJson = item.toJson(sourceMap: sourceMap);
    final patchJson = item.patchOperation.toJson(sourceMap: sourceMap);
    final blockerJson = blocker.toJson(sourceMap: sourceMap);
    final reportJson = report.toJson(sourceMap: sourceMap);

    expect(sourceMap.entries, hasLength(2));
    expect(sourceMap.entries.first.sampleJsonSymbol, 'barRace');
    expect(location.hasExactPosition, isTrue);
    expect(location.line, 4);
    expect(location.column, 5);
    expect(location.toJson(), containsPair('chartType', 'barRace'));
    expect(
      itemJson['sourceLocation'],
      containsPair('displayPath', contains(':4:5::')),
    );
    expect(
      patchJson['sourceLocation'],
      containsPair(
        'registryPath',
        'ChartSamplesRegistry.focusedFamilies[0].samples[0].json.type',
      ),
    );
    expect(blockerJson['sourceLocation'], containsPair('line', 7));
    expect(
      ((reportJson['patchOperations'] as List).first
          as Map<String, dynamic>)['sourceLocation'],
      containsPair('line', 4),
    );
    expect(
      ((reportJson['manifestWorkItems'] as List).first
          as Map<String, dynamic>)['sourceLocation'],
      containsPair('line', 7),
    );
  });

  test('showcase source map audit catches registry drift', () {
    const family = ChartShowcaseFamily(
      id: 'naming',
      title: 'Naming',
      description: 'Naming samples.',
      samples: [
        ChartShowcaseSample('Camel Bar Race', 180, {'type': 'barRace'}),
        ChartShowcaseSample('Missing Type', 180, {'type': 'madeUp'}),
      ],
    );
    const driftedFamily = ChartShowcaseFamily(
      id: 'naming',
      title: 'Naming',
      description: 'Naming samples.',
      samples: [
        ChartShowcaseSample('Camel Bar Race', 180, {'type': 'bar'}),
        ChartShowcaseSample('Missing Type', 180, {'type': 'madeUp'}),
      ],
    );
    final sourceMap = registryHealthShowcaseSourceMapFromText(
      _sourceMapFixture,
      sourceFile: 'lib/example/chart_samples_registry.dart',
    );
    final report = registryHealthShowcaseSourceMapAuditReport(sourceMap, [
      family,
    ]);
    final driftReport = registryHealthShowcaseSourceMapAuditReport(sourceMap, [
      driftedFamily,
    ]);
    final reportJson = report.toJson();

    expect(report.status, RegistryHealthShowcaseSourceMapAuditStatus.ready);
    expect(registryHealthShowcaseSourceMapAuditReportLabel(report), 'Ready');
    expect(report.isReady, isTrue);
    expect(report.expectedSampleCount, 2);
    expect(report.mappedSampleCount, 2);
    expect(report.exactTypePositionCount, 2);
    expect(report.mappedRatio, 1);
    expect(report.exactTypePositionRatio, 1);
    expect(report.issueCount, 0);
    expect(reportJson, containsPair('status', 'ready'));
    expect(
      reportJson,
      containsPair('sourceFile', 'lib/example/chart_samples_registry.dart'),
    );
    expect(
      registryHealthShowcaseSourceMapAuditExportJson(report: report),
      containsPair('status', 'ready'),
    );
    expect(
      registryHealthShowcaseSourceMapAuditExportJson(isLoading: true),
      containsPair('status', 'loading'),
    );
    expect(
      registryHealthShowcaseSourceMapAuditExportJson(error: 'missing asset'),
      containsPair('status', 'unavailable'),
    );

    expect(
      driftReport.status,
      RegistryHealthShowcaseSourceMapAuditStatus.broken,
    );
    expect(driftReport.errorCount, 1);
    expect(
      registryHealthShowcaseSourceMapAuditVisibleIssues(
        driftReport,
      ).map((issue) => issue.code),
      contains('CHART_TYPE_MISMATCH'),
    );
    expect(
      registryHealthShowcaseSourceMapAuditJson(sourceMap, [
        driftedFamily,
      ])['issues'],
      isNotEmpty,
    );
  });

  test('showcase source map audit matches real focused registry source', () {
    final source = File(
      'lib/example/chart_samples_registry.dart',
    ).readAsStringSync();
    final sourceMap = registryHealthShowcaseSourceMapFromText(source);
    final report = focusedRegistryHealthShowcaseSourceMapAuditReport(sourceMap);
    final focusedSampleCount = ChartSamplesRegistry.focusedFamilies.fold<int>(
      0,
      (count, family) => count + family.samples.length,
    );

    expect(report.status, RegistryHealthShowcaseSourceMapAuditStatus.ready);
    expect(report.issueCount, 0);
    expect(report.expectedSampleCount, focusedSampleCount);
    expect(report.mappedSampleCount, focusedSampleCount);
    expect(report.exactTypePositionCount, focusedSampleCount);
  });

  test('registry health readiness report rolls up audit gates', () {
    ChartRegistry.clear();
    allChartsBundle.register();

    final registryReport = chartRegistryHealthReport();
    final coverage = focusedChartSampleCoverage();
    final thresholds = registryHealthShowcaseThresholdReport(coverage);
    final naming = focusedRegistryHealthShowcaseNamingReport();
    final renamePlan = registryHealthShowcaseRenamePlanReport(naming);
    final sampleAudit = auditFocusedChartSamples(
      requireRegisteredTypes: true,
      includeValidationWarnings: false,
    );
    final sourceAudit = auditFocusedChartSampleSources();
    final simpleSourceAudit = auditSimpleChartShowcaseSources();
    final chartExampleMatrix = focusedRegistryHealthChartExampleMatrixReport(
      manifest: coverage.manifest,
      sampleAudit: sampleAudit,
      sourceAudit: sourceAudit,
    );
    final apiConsistency = registryHealthApiConsistencyReport(
      registryReport.capabilities,
    );
    final source = File(
      'lib/example/chart_samples_registry.dart',
    ).readAsStringSync();
    final sourceMapAudit = focusedRegistryHealthShowcaseSourceMapAuditReport(
      registryHealthShowcaseSourceMapFromText(source),
    );

    RegistryHealthReadinessReport buildReport({
      RegistryHealthShowcaseSourceMapAuditReport? sourceMapAudit,
      Object? sourceMapError,
      bool sourceMapLoading = false,
    }) {
      return registryHealthReadinessReport(
        registryReport: registryReport,
        thresholdReport: thresholds,
        namingReport: naming,
        renamePlanReport: renamePlan,
        sampleAudit: sampleAudit,
        sourceAudit: sourceAudit,
        simpleSourceAudit: simpleSourceAudit,
        chartExampleMatrix: chartExampleMatrix,
        apiConsistencyReport: apiConsistency,
        sourceMapAudit: sourceMapAudit,
        sourceMapError: sourceMapError,
        sourceMapLoading: sourceMapLoading,
      );
    }

    final readiness = buildReport(sourceMapAudit: sourceMapAudit);
    final loading = buildReport(sourceMapLoading: true);
    final unavailable = buildReport(sourceMapError: 'missing asset');
    final expectedApiConsistencyStatus = switch (apiConsistency.status) {
      RegistryHealthApiConsistencyStatus.ready =>
        RegistryHealthReadinessStatus.ready,
      RegistryHealthApiConsistencyStatus.warning =>
        RegistryHealthReadinessStatus.warning,
      RegistryHealthApiConsistencyStatus.blocked =>
        RegistryHealthReadinessStatus.blocked,
    };

    expect(readiness.gateCount, 10);
    expect(readiness.gates.map((gate) => gate.key), [
      'registry',
      'showcaseCoverage',
      'typeNaming',
      'typeCleanup',
      'sampleAudit',
      'sampleSourceAudit',
      'simpleSourceAudit',
      'chartExampleMatrix',
      'apiConsistency',
      'sourceMapAudit',
    ]);
    expect(
      readiness.readyCount + readiness.warningCount + readiness.blockedCount,
      readiness.gateCount,
    );
    expect(readiness.toJson(), containsPair('status', readiness.status.name));
    expect(
      registryHealthReadinessJson(readiness),
      containsPair('gateCount', 10),
    );
    expect(
      readiness.gates
          .singleWhere((gate) => gate.key == 'apiConsistency')
          .status,
      expectedApiConsistencyStatus,
    );
    expect(
      readiness.gates
          .singleWhere((gate) => gate.key == 'apiConsistency')
          .detail,
      contains('contracts ready'),
    );
    expect(
      registryHealthReadinessVisibleGates(readiness, limit: 1).length,
      lessThanOrEqualTo(1),
    );
    expect(
      loading.gates.singleWhere((gate) => gate.key == 'sourceMapAudit').status,
      RegistryHealthReadinessStatus.warning,
    );
    expect(
      unavailable.gates
          .singleWhere((gate) => gate.key == 'sourceMapAudit')
          .status,
      RegistryHealthReadinessStatus.blocked,
    );
  });

  testWidgets('registry health readiness panel renders attention gates', (
    tester,
  ) async {
    const report = RegistryHealthReadinessReport(
      gates: [
        RegistryHealthReadinessGate(
          key: 'registry',
          label: 'Registrations',
          status: RegistryHealthReadinessStatus.ready,
          detail: '2 registrations, 0 errors, 0 warnings.',
          issueCount: 0,
          action: 'No action needed.',
        ),
        RegistryHealthReadinessGate(
          key: 'coverage',
          label: 'Coverage Gates',
          status: RegistryHealthReadinessStatus.warning,
          detail: '7/9 examples covered, 0 failing gates, 1 warning.',
          issueCount: 1,
          action: 'Improve warning coverage gates.',
        ),
        RegistryHealthReadinessGate(
          key: 'source',
          label: 'Source Audit',
          status: RegistryHealthReadinessStatus.blocked,
          detail: '4 generated sources, 2 issues.',
          issueCount: 2,
          action: 'Fix generated source issues.',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryHealthReadinessPanel(
            report: report,
            gateLimit: 1,
            showActionPlan: false,
          ),
        ),
      ),
    );

    expect(find.textContaining('1/3 readiness gates ready'), findsOneWidget);
    expect(find.text('Status: Blocked'), findsOneWidget);
    expect(find.textContaining('Source Audit'), findsOneWidget);
    expect(find.textContaining('Coverage Gates'), findsNothing);
    expect(find.text('+1 more gates'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('registry health readiness action plan prioritizes gates', () {
    const report = RegistryHealthReadinessReport(
      gates: [
        RegistryHealthReadinessGate(
          key: 'registry',
          label: 'Registrations',
          status: RegistryHealthReadinessStatus.ready,
          detail: '2 registrations, 0 errors, 0 warnings.',
          issueCount: 0,
          action: 'No action needed.',
        ),
        RegistryHealthReadinessGate(
          key: 'coverage',
          label: 'Coverage Gates',
          status: RegistryHealthReadinessStatus.warning,
          detail: '7/9 examples covered, 0 failing gates, 1 warning.',
          issueCount: 1,
          action: 'Improve warning coverage gates.',
        ),
        RegistryHealthReadinessGate(
          key: 'source',
          label: 'Source Audit',
          status: RegistryHealthReadinessStatus.blocked,
          detail: '4 generated sources, 2 issues.',
          issueCount: 2,
          action: 'Fix generated source issues.',
        ),
      ],
    );
    final plan = registryHealthReadinessActionPlan(report);
    final limitedJson = registryHealthReadinessActionPlanJson(
      plan,
      itemLimit: 1,
    );
    final highJson = registryHealthReadinessActionPlanJson(
      plan,
      itemLimit: 1,
      filter: RegistryHealthReadinessActionFilter.high,
    );
    final checklist = registryHealthReadinessActionChecklist(plan);
    final checklistJson = checklist.toJson(itemLimit: 1);
    final checklistText = registryHealthReadinessActionChecklistText(
      plan,
      itemLimit: 1,
    );

    expect(plan.actionCount, 2);
    expect(plan.filteredCount(RegistryHealthReadinessActionFilter.critical), 1);
    expect(plan.filteredCount(RegistryHealthReadinessActionFilter.high), 1);
    expect(plan.criticalCount, 1);
    expect(plan.highCount, 1);
    expect(plan.mediumCount, 0);
    expect(plan.issueCount, 3);
    expect(plan.items.first.gateKey, 'source');
    expect(
      plan.items.first.priority,
      RegistryHealthReadinessActionPriority.critical,
    );
    expect(
      registryHealthReadinessActionPriorityLabel(plan.items.first.priority),
      'Critical',
    );
    expect(
      registryHealthReadinessActionFilterLabel(
        RegistryHealthReadinessActionFilter.high,
      ),
      'High',
    );
    expect(
      registryHealthReadinessActionFilterMatches(
        RegistryHealthReadinessActionFilter.high,
        plan.items.last,
      ),
      isTrue,
    );
    expect(registryHealthReadinessVisibleActionItems(plan, limit: 1).length, 1);
    expect(
      registryHealthReadinessVisibleActionItems(
        plan,
        limit: 1,
        filter: RegistryHealthReadinessActionFilter.high,
      ).single.gateKey,
      'coverage',
    );
    expect(limitedJson, containsPair('actionCount', 2));
    expect(limitedJson, containsPair('filter', 'all'));
    expect(limitedJson, containsPair('filteredActionCount', 2));
    expect(limitedJson, containsPair('exportedActionCount', 1));
    expect(limitedJson, containsPair('hiddenActionCount', 1));
    expect(highJson, containsPair('filter', 'high'));
    expect(highJson, containsPair('filteredActionCount', 1));
    expect(highJson, containsPair('hiddenActionCount', 0));
    expect(
      registryHealthReadinessActionPhaseForPriority(
        RegistryHealthReadinessActionPriority.critical,
      ),
      RegistryHealthReadinessActionPhase.now,
    );
    expect(checklist.phaseCount(RegistryHealthReadinessActionPhase.now), 1);
    expect(checklist.phaseCount(RegistryHealthReadinessActionPhase.next), 1);
    expect(checklist.phaseCount(RegistryHealthReadinessActionPhase.later), 0);
    expect(
      checklist.visibleGroups(itemLimit: 1).single.phase,
      RegistryHealthReadinessActionPhase.now,
    );
    expect(checklistJson, containsPair('actionCount', 2));
    expect(checklistJson, containsPair('hiddenActionCount', 1));
    expect(checklistJson['phaseCounts'], containsPair('now', 1));
    expect(checklistText, contains('# Registry Health Action Checklist'));
    expect(checklistText, contains('## Now'));
    expect(checklistText, contains('Source Audit'));
    expect(checklistText, contains('+1 more actions hidden by export limit.'));
  });

  testWidgets('registry health readiness action plan panel renders queue', (
    tester,
  ) async {
    const plan = RegistryHealthReadinessActionPlan(
      items: [
        RegistryHealthReadinessActionItem(
          id: 'source.blocked',
          gateKey: 'source',
          title: 'Source Audit',
          priority: RegistryHealthReadinessActionPriority.critical,
          status: RegistryHealthReadinessStatus.blocked,
          issueCount: 2,
          impact: 'Generated source examples may drift from sample payloads.',
          action: 'Fix generated source issues.',
        ),
        RegistryHealthReadinessActionItem(
          id: 'coverage.warning',
          gateKey: 'coverage',
          title: 'Coverage Gates',
          priority: RegistryHealthReadinessActionPriority.high,
          status: RegistryHealthReadinessStatus.warning,
          issueCount: 1,
          impact: 'Showcase coverage gates are not release-ready.',
          action: 'Improve warning coverage gates.',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RegistryHealthReadinessActionPlanPanel(
            plan: plan,
            actionLimit: 1,
          ),
        ),
      ),
    );

    expect(find.text('Action Plan'), findsOneWidget);
    expect(find.text('Copy JSON'), findsOneWidget);
    expect(find.text('Copy Checklist'), findsOneWidget);
    expect(find.text('Actions: 2'), findsOneWidget);
    expect(find.text('Critical: 1'), findsOneWidget);
    expect(find.text('High: 1'), findsOneWidget);
    expect(find.text('Now: 1'), findsOneWidget);
    expect(find.text('Next: 1'), findsOneWidget);
    expect(find.text('Later: 0'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Now · 1 actions'), findsOneWidget);
    expect(find.text('Source Audit'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Coverage Gates'), findsNothing);
    expect(find.text('+1 more actions'), findsOneWidget);

    await tester.tap(find.text('High').first);
    await tester.pumpAndSettle();

    expect(find.text('Source Audit'), findsNothing);
    expect(find.text('Coverage Gates'), findsOneWidget);
    expect(find.text('Next · 1 actions'), findsOneWidget);
    expect(find.text('High'), findsWidgets);
    expect(find.text('+1 more actions'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'showcase source map audit panel renders status and copy action',
    (tester) async {
      const family = ChartShowcaseFamily(
        id: 'naming',
        title: 'Naming',
        description: 'Naming samples.',
        samples: [
          ChartShowcaseSample('Camel Bar Race', 180, {'type': 'barRace'}),
          ChartShowcaseSample('Missing Type', 180, {'type': 'madeUp'}),
        ],
      );
      final sourceMap = registryHealthShowcaseSourceMapFromText(
        _sourceMapFixture,
        sourceFile: 'lib/example/chart_samples_registry.dart',
      );
      final report = registryHealthShowcaseSourceMapAuditReport(sourceMap, [
        family,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistryHealthShowcaseSourceMapAuditPanel(report: report),
          ),
        ),
      );

      expect(
        registryHealthShowcaseSourceMapAuditSummary(report),
        contains('2/2'),
      );
      expect(registryHealthShowcaseSourceMapAuditRatioLabel(1), '100%');
      expect(
        registryHealthShowcaseSourceMapAuditIssueLocation(
          const RegistryHealthShowcaseSourceMapAuditIssue(
            severity: RegistryHealthShowcaseSourceMapAuditSeverity.error,
            code: 'CHART_TYPE_MISMATCH',
            message: 'Types differ.',
            familyId: 'naming',
            familyTitle: 'Naming',
            familyIndex: 0,
            sampleTitle: 'Camel Bar Race',
            sampleIndex: 0,
            chartType: 'barRace',
            sourceChartType: 'bar',
          ),
        ),
        'Naming / Camel Bar Race (barRace)',
      );
      expect(find.textContaining('2/2 focused samples mapped'), findsOneWidget);
      expect(find.text('Status: Ready'), findsOneWidget);
      expect(find.text('Mapped: 2/2'), findsOneWidget);
      expect(find.text('Exact: 100%'), findsOneWidget);
      expect(find.text('Copy Source Map Audit JSON'), findsOneWidget);
      expect(find.text('No source-map drift detected.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('showcase backlog builds copy-ready starter templates', () {
    final coreCoverage = ChartFamilyManifests.available(
      bundle: coreChartsBundle,
    ).showcaseCoverage(['bar']);
    final coreItems = registryHealthShowcaseBacklogItems(
      coreCoverage.missingEntries,
    );
    final manifest = ChartFamilyManifests.available();
    final sankey = manifest.entryForType(ChartType.sankey)!;
    final choropleth = manifest.entryForType(ChartType.choropleth)!;
    final sankeyJson = registryHealthShowcaseStarterJson(sankey);
    final choroplethJson = registryHealthShowcaseStarterJson(choropleth);
    final backlogJson = registryHealthShowcaseBacklogJson(
      coreCoverage.missingEntries,
      itemLimit: 2,
    );

    expect(coreItems.map((item) => item.entry.showcaseExampleKey), [
      'area',
      'bubble',
      'line',
      'scatter',
      'donut',
      'pie',
    ]);
    expect(coreItems.first.priorityLabel, 'Core');
    expect(coreItems.first.suggestedFamilyId, 'canonical_mixed');
    expect(coreItems.first.json['type'], 'area');
    expect(coreItems.first.json['series'], isA<List>());
    expect(coreItems.first.jsonText, contains('"type": "area"'));
    expect(coreItems.first.codeText, contains('TenunChartFromJson'));
    expect(
      RegistryHealthShowcaseBacklogPanelOptions.compact.sourcePanelHeight,
      160,
    );
    expect(
      RegistryHealthShowcaseBacklogPanelOptions.starterJsonOnly.showDartSample,
      isFalse,
    );
    expect(
      RegistryHealthShowcaseBacklogPanelOptions.starterJsonOnly
          .copyWith(showStarterJson: false)
          .showSourcePanels,
      isFalse,
    );
    expect(backlogJson['count'], 6);
    expect(backlogJson['exportedCount'], 2);
    expect(backlogJson['hiddenCount'], 4);
    expect(
      (backlogJson['items'] as List).first,
      containsPair('suggestedFamilyId', 'canonical_mixed'),
    );
    expect(
      (backlogJson['items'] as List).first,
      containsPair('starterJson', isA<Map<String, dynamic>>()),
    );

    expect(registryHealthShowcaseSuggestedFamilyId(sankey), 'flow');
    expect(sankeyJson['nodes'], isA<List>());
    expect(sankeyJson['links'], isA<List>());
    expect(registryHealthShowcaseSuggestedFamilyId(choropleth), 'geo');
    expect(choroplethJson['regions'], isA<List>());
    expect(
      registryHealthShowcaseStarterCodeText(choropleth),
      contains('"regions"'),
    );
  });

  testWidgets('showcase backlog panel options tune starter previews', (
    tester,
  ) async {
    _setRegistryHealthTestViewport(tester);
    final coverage = ChartFamilyManifests.available(
      bundle: coreChartsBundle,
    ).showcaseCoverage(['bar']);
    const options = RegistryHealthShowcaseBacklogPanelOptions(
      showMetadataChips: false,
      showDartSample: false,
      sourcePanelHeight: 160,
      sourcePanelMinWidth: 320,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthShowcaseBacklogPanel(
              entries: coverage.missingEntries,
              visibleLimit: 1,
              options: options,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Area Starter'), findsOneWidget);
    expect(
      find.text(
        '+5 more starter templates available from the coverage report.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Area Starter'));
    await tester.pumpAndSettle();

    final sourcePanel = tester.widget<ShowcaseSourceTextPanel>(
      find.byType(ShowcaseSourceTextPanel),
    );

    expect(find.text('Starter JSON'), findsOneWidget);
    expect(find.text('Dart Sample'), findsNothing);
    expect(find.text('type.area'), findsNothing);
    expect(sourcePanel.height, 160);
    expect(sourcePanel.text, contains('"type": "area"'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('showcase coverage panel forwards backlog options', (
    tester,
  ) async {
    _setRegistryHealthTestViewport(tester);
    final coverage = ChartFamilyManifests.available(
      bundle: coreChartsBundle,
    ).showcaseCoverage(['bar']);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthShowcaseCoveragePanel(
              coverage: coverage,
              backlogVisibleLimit: 1,
              backlogOptions: const RegistryHealthShowcaseBacklogPanelOptions(
                showMetadataChips: false,
                showStarterJson: false,
                showDartSample: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Starter Template Backlog'), findsOneWidget);
    expect(find.text('Area Starter'), findsOneWidget);
    expect(
      find.text(
        '+5 more starter templates available from the coverage report.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Area Starter'));
    await tester.pumpAndSettle();

    expect(find.text('Starter JSON'), findsNothing);
    expect(find.text('Dart Sample'), findsNothing);
    expect(find.text('type.area'), findsNothing);
    expect(find.byType(ShowcaseSourceTextPanel), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('sample audit helpers summarize status and issue context', () {
    const family = ChartShowcaseFamily(
      id: 'ops',
      title: 'Operations',
      description: 'Operational samples.',
      samples: [
        ChartShowcaseSample('Latency Bars', 180, {'type': 'bar', 'series': []}),
      ],
    );
    const warning = ChartSampleRegistryAuditIssue(
      severity: ChartSampleRegistryAuditSeverity.warning,
      code: 'LOW_SAMPLING_THRESHOLD',
      message: 'Sampling threshold is low.',
      familyId: 'ops',
      familyTitle: 'Operations',
      sampleTitle: 'Latency Bars',
      chartType: 'bar',
    );
    const error = ChartSampleRegistryAuditIssue(
      severity: ChartSampleRegistryAuditSeverity.error,
      code: 'MISSING_TYPE',
      message: 'Missing required field: "type".',
      familyId: 'ops',
      familyTitle: 'Operations',
      sampleTitle: 'Broken Sample',
    );
    const report = ChartSampleRegistryAuditReport(
      families: [family],
      issues: [warning, error],
    );

    expect(registryHealthSampleAuditStatusLabel(report), 'Errors');
    expect(
      registryHealthSampleAuditSummary(report),
      '1 focused sample across 1 family checked for registry integrity.',
    );
    expect(
      registryHealthSampleAuditVisibleIssues(report).map((issue) => issue.code),
      ['MISSING_TYPE', 'LOW_SAMPLING_THRESHOLD'],
    );
    expect(
      registryHealthSampleAuditIssueLocation(warning),
      'Operations / Latency Bars (bar)',
    );
    expect(report.toJson(), containsPair('warningCount', 1));
  });

  test('sample source audit helpers summarize status and issue context', () {
    const family = ChartShowcaseFamily(
      id: 'ops',
      title: 'Operations',
      description: 'Operational samples.',
      samples: [
        ChartShowcaseSample('Latency Bars', 180, {'type': 'bar', 'series': []}),
      ],
    );
    const auditCase = ChartSampleSourceAuditCase(
      id: 'default',
      label: 'Default',
      options: ChartSampleShowcaseOptions(),
    );
    const issue = ChartSampleSourceAuditIssue(
      code: 'SOURCE_JSON_INVALID',
      message: 'Generated JSON is invalid.',
      familyId: 'ops',
      familyTitle: 'Operations',
      sampleTitle: 'Latency Bars',
      chartType: 'bar',
      caseId: 'default',
      caseLabel: 'Default',
    );
    const repeatedIssue = ChartSampleSourceAuditIssue(
      code: 'SOURCE_JSON_INVALID',
      message: 'Another generated JSON payload is invalid.',
      familyId: 'ops',
      familyTitle: 'Operations',
      sampleTitle: 'Throughput Line',
      chartType: 'line',
      caseId: 'default',
      caseLabel: 'Default',
    );
    const codeIssue = ChartSampleSourceAuditIssue(
      code: 'SOURCE_CODE_EMPTY',
      message: 'Generated code is empty.',
      familyId: 'ops',
      familyTitle: 'Operations',
      sampleTitle: 'Latency Bars',
      chartType: 'bar',
      caseId: 'default',
      caseLabel: 'Default',
    );
    const familyResult = ChartSampleSourceAuditFamilyResult(
      id: 'ops',
      title: 'Operations',
      sampleCount: 1,
      checkedSourceCount: 1,
      issueCount: 3,
    );
    const caseResult = ChartSampleSourceAuditCaseResult(
      id: 'default',
      label: 'Default',
      checkedSourceCount: 1,
      issueCount: 3,
    );
    const healthyFamilyResult = ChartSampleSourceAuditFamilyResult(
      id: 'ops',
      title: 'Operations',
      sampleCount: 1,
      checkedSourceCount: 1,
      issueCount: 0,
    );
    const healthyCaseResult = ChartSampleSourceAuditCaseResult(
      id: 'default',
      label: 'Default',
      checkedSourceCount: 1,
      issueCount: 0,
    );
    const report = ChartSampleSourceAuditReport(
      families: [family],
      cases: [auditCase],
      issues: [issue, repeatedIssue, codeIssue],
      familyResults: [familyResult],
      caseResults: [caseResult],
    );
    const healthy = ChartSampleSourceAuditReport(
      families: [family],
      cases: [auditCase],
      issues: [],
      familyResults: [healthyFamilyResult],
      caseResults: [healthyCaseResult],
    );

    expect(registryHealthSampleSourceAuditStatusLabel(report), 'Issues');
    expect(registryHealthSampleSourceAuditStatusLabel(healthy), 'Ready');
    expect(
      registryHealthSampleSourceAuditSummary(healthy),
      '1 generated source across 1 focused sample checked for copy-ready JSON and code.',
    );
    expect(
      registryHealthSampleSourceAuditVisibleIssues(
        report,
      ).map((issue) => issue.code),
      ['SOURCE_CODE_EMPTY', 'SOURCE_JSON_INVALID', 'SOURCE_JSON_INVALID'],
    );
    expect(
      registryHealthSampleSourceAuditVisibleIssueCodes(
        report,
      ).map((entry) => '${entry.key}:${entry.value}'),
      ['SOURCE_JSON_INVALID:2', 'SOURCE_CODE_EMPTY:1'],
    );
    expect(
      registryHealthSampleSourceAuditResultLabel(
        checkedSourceCount: caseResult.checkedSourceCount,
        issueCount: caseResult.issueCount,
      ),
      '1 check, 3 issues',
    );
    expect(
      registryHealthSampleSourceAuditResultLabel(
        checkedSourceCount: healthyCaseResult.checkedSourceCount,
        issueCount: healthyCaseResult.issueCount,
      ),
      '1 check',
    );
    expect(
      registryHealthSampleSourceAuditIssueLocation(issue),
      'Operations / Latency Bars (bar) / Default',
    );
    expect(report.toJson(), containsPair('checkedSourceCount', 1));
    expect(report.toJson()['issueCodeCounts'], {
      'SOURCE_CODE_EMPTY': 1,
      'SOURCE_JSON_INVALID': 2,
    });
    expect(
      (report.toJson()['caseResults'] as List).single,
      containsPair('issueCount', 3),
    );
    expect(
      (report.toJson()['familyResults'] as List).single,
      containsPair('checkedSourceCount', 1),
    );
  });

  test('simple source audit helpers summarize status and issue context', () {
    final auditCase = SimpleChartSourceAuditCase(
      id: 'default',
      label: 'Default',
      options: simpleChartSourceAuditOptions(),
    );
    const family = SimpleChartSourceAuditFamilyResult(
      id: 'core',
      title: 'Core Simple Charts',
      tier: SimpleChartsShowcaseTier.core,
      panelCount: 1,
      sourceCount: 1,
      expectedSourceCount: 1,
      chartTypes: ['SimpleBarChart'],
    );
    const proFamily = SimpleChartSourceAuditFamilyResult(
      id: 'advanced_dashboard',
      title: 'Pro Dashboard Simple Charts',
      tier: SimpleChartsShowcaseTier.pro,
      panelCount: 2,
      sourceCount: 2,
      expectedSourceCount: 2,
      chartTypes: ['SimpleBulletChart', 'SimpleGaugeChart'],
    );
    const caseResult = SimpleChartSourceAuditCaseResult(
      id: 'default',
      label: 'Default',
      panelCount: 1,
      sourceCount: 1,
      requiredSourceCount: 1,
    );
    const issue = SimpleChartSourceAuditIssue(
      code: 'SOURCE_CODE_EMPTY',
      message: 'Dart sample source is empty.',
      familyId: 'core',
      familyTitle: 'Core Simple Charts',
      caseId: 'default',
      caseLabel: 'Default',
      panelIndex: 0,
      panelTitle: 'Regional Growth',
      chartType: 'SimpleBarChart',
    );
    const repeatedIssue = SimpleChartSourceAuditIssue(
      code: 'SOURCE_CODE_EMPTY',
      message: 'Another Dart sample source is empty.',
      familyId: 'core',
      familyTitle: 'Core Simple Charts',
      caseId: 'default',
      caseLabel: 'Default',
      panelIndex: 1,
      panelTitle: 'Segment Growth',
      chartType: 'SimpleBarChart',
    );
    const metadataIssue = SimpleChartSourceAuditIssue(
      code: 'PANEL_TITLE_EMPTY',
      message: 'Panel title is empty.',
      familyId: 'core',
      familyTitle: 'Core Simple Charts',
      caseId: 'default',
      caseLabel: 'Default',
      panelIndex: 2,
      panelTitle: '',
      chartType: 'SimpleBarChart',
    );
    final report = SimpleChartSourceAuditReport(
      families: [family],
      issues: [issue, metadataIssue, repeatedIssue],
      cases: [auditCase],
      caseResults: [caseResult],
    );
    final healthy = SimpleChartSourceAuditReport(
      families: [family],
      issues: [],
      cases: [auditCase],
      caseResults: [caseResult],
    );

    expect(registryHealthSimpleSourceAuditStatusLabel(report), 'Issues');
    expect(registryHealthSimpleSourceAuditStatusLabel(healthy), 'Ready');
    expect(
      registryHealthSimpleSourceAuditSummary(healthy),
      '1/1 simple chart source across 1 panel, 1 family, and 1 knob case checked for copy-ready JSON and Dart code.',
    );
    expect(
      registryHealthSimpleSourceAuditVisibleIssues(
        report,
      ).map((issue) => issue.code),
      ['SOURCE_CODE_EMPTY', 'SOURCE_CODE_EMPTY', 'PANEL_TITLE_EMPTY'],
    );
    expect(
      registryHealthSimpleSourceAuditVisibleIssueCodes(
        report,
      ).map((entry) => '${entry.key}:${entry.value}'),
      ['SOURCE_CODE_EMPTY:2', 'PANEL_TITLE_EMPTY:1'],
    );
    final tierReport = SimpleChartSourceAuditReport(
      families: [family, proFamily],
      issues: const [],
    );
    expect(
      registryHealthSimpleSourceAuditTierCounts(
        tierReport,
      ).map((entry) => '${entry.key.label}:${entry.value}'),
      ['Core:1', 'Pro:1'],
    );
    expect(registryHealthSimpleSourceAuditFamilyCountLabel(1), '1 family');
    expect(registryHealthSimpleSourceAuditFamilyCountLabel(2), '2 families');
    expect(
      registryHealthSimpleSourceAuditIssueLocation(issue),
      'Core Simple Charts / Regional Growth (SimpleBarChart) / Default',
    );
    expect(
      registryHealthSimpleSourceAuditCoverageLabel(
        sourceCount: 1,
        requiredSourceCount: 1,
      ),
      '1/1',
    );
    expect(
      registryHealthSimpleSourceAuditCoverageLabel(
        sourceCount: 0,
        requiredSourceCount: 0,
        unexpectedSourceCount: 1,
      ),
      '0/0 +1',
    );
    expect(report.toJson(), containsPair('sourceCount', 1));
    expect(report.toJson(), containsPair('caseCount', 1));
    expect(report.toJson()['issueCodeCounts'], {
      'PANEL_TITLE_EMPTY': 1,
      'SOURCE_CODE_EMPTY': 2,
    });
    expect(
      (report.toJson()['caseResults'] as List).single,
      containsPair('label', 'Default'),
    );
  });

  testWidgets('simple source audit panel renders tier coverage', (
    tester,
  ) async {
    const coreFamily = SimpleChartSourceAuditFamilyResult(
      id: 'core',
      title: 'Core Simple Charts',
      tier: SimpleChartsShowcaseTier.core,
      panelCount: 1,
      sourceCount: 1,
      expectedSourceCount: 1,
      chartTypes: ['SimpleBarChart'],
    );
    const proFamily = SimpleChartSourceAuditFamilyResult(
      id: 'advanced_dashboard',
      title: 'Pro Dashboard Simple Charts',
      tier: SimpleChartsShowcaseTier.pro,
      panelCount: 2,
      sourceCount: 2,
      expectedSourceCount: 2,
      chartTypes: ['SimpleBulletChart', 'SimpleGaugeChart'],
    );
    const report = SimpleChartSourceAuditReport(
      families: [coreFamily, proFamily],
      issues: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegistryHealthSimpleSourceAuditPanel(audit: report),
          ),
        ),
      ),
    );

    expect(find.text('Tier Coverage'), findsOneWidget);
    expect(find.text('Core: 1 family'), findsOneWidget);
    expect(find.text('Pro: 1 family'), findsOneWidget);
    expect(find.text('No simple source audit issues.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('registry health export includes optional report sections', () {
    final report = chartRegistryHealthReport();
    final json = registryHealthExportJson(
      report,
      extraSections: {
        'showcaseCoverage': {'coveredCount': 2},
        'showcaseBacklog': {'count': 3},
        'showcaseThresholds': {'status': 'warn'},
        'showcaseNaming': {'issueCount': 1},
        'showcaseRenamePlan': {
          'status': 'blocked',
          'safeRenameCount': 2,
          'manifestWorkCount': 1,
        },
        'chartExampleMatrix': {'rowCount': 4},
        'apiConsistency': {'status': 'ready'},
        'apiConsistencyScorecard': {'scorePercent': 100},
        'apiConsistencyScoreProjection': {'projectedScorePercent': 100},
        'apiConsistencyReleaseBrief': {'itemCount': 0},
        'apiConsistencyConformance': {'caseCount': 0},
        'apiConsistencyConformanceGate': {'gateCount': 0},
        'apiConsistencyConformanceVerification': {'verificationCount': 0},
        'apiConsistencyConformanceChecklist': {'stepCount': 0},
        'apiConsistencyConformanceEvidence': {'evidenceCount': 0},
        'apiConsistencyActionPlan': {'actionCount': 0},
        'apiConsistencyImplementationPlan': {'actionCount': 0},
        'apiConsistencyTraceability': {'traceCount': 0},
        'apiConsistencySourceQueue': {'sourceCount': 0},
        'apiConsistencySourcePlan': {'batchCount': 0},
        'apiConsistencySourceChecklist': {'stageCount': 0},
        'apiConsistencySourceMilestones': {'milestoneCount': 0},
        'apiConsistencySourceReleaseGates': {'gateCount': 0},
        'apiConsistencySourceVerification': {'verificationCount': 0},
        'apiConsistencyFamilyRemediation': {'familyCount': 0},
        'apiConsistencyPrimitiveRemediation': {'primitiveCount': 0},
        'apiConsistencyFieldRemediation': {'fieldOptionCount': 0},
        'apiConsistencyConcernSummary': {'concernCount': 8},
        'packageBoundary': {'status': 'clean'},
        'proEntrypoints': {'entrypointCount': 6},
        'proReadiness': {'status': 'manifest_ready'},
        'sampleAudit': {'errorCount': 0},
        'sampleSourceAudit': {'issueCount': 0},
        'simpleSourceAudit': {'issueCount': 0},
        'readiness': {'status': 'ready'},
        'readinessActionPlan': {'actionCount': 0},
        'readinessActionChecklist': {'actionCount': 0},
        'sourceMapAudit': {'status': 'ready'},
        ' ': {'ignored': true},
      },
    );
    final text = registryHealthExportText(
      report,
      extraSections: {
        'showcaseCoverage': {'missingCount': 1},
        'showcaseBacklog': {'exportedCount': 2},
        'showcaseThresholds': {'failCount': 0},
        'showcaseNaming': {'unknownCount': 0},
        'showcaseRenamePlan': {'hiddenCount': 0},
        'chartExampleMatrix': {'readyCount': 3},
        'apiConsistency': {'issueCount': 0},
        'apiConsistencyScorecard': {'grade': 'excellent'},
        'apiConsistencyScoreProjection': {'projectedGrade': 'excellent'},
        'apiConsistencyReleaseBrief': {'hiddenItemCount': 0},
        'apiConsistencyConformance': {'hiddenCaseCount': 0},
        'apiConsistencyConformanceGate': {'hiddenGateCount': 0},
        'apiConsistencyConformanceVerification': {'hiddenVerificationCount': 0},
        'apiConsistencyConformanceChecklist': {'hiddenStepCount': 0},
        'apiConsistencyConformanceEvidence': {'hiddenEvidenceCount': 0},
        'apiConsistencyActionPlan': {'hiddenActionCount': 0},
        'apiConsistencyImplementationPlan': {'familyCount': 0},
        'apiConsistencyTraceability': {'hiddenTraceCount': 0},
        'apiConsistencySourceQueue': {'hiddenSourceCount': 0},
        'apiConsistencySourcePlan': {'hiddenBatchCount': 0},
        'apiConsistencySourceChecklist': {'hiddenStageCount': 0},
        'apiConsistencySourceMilestones': {'hiddenMilestoneCount': 0},
        'apiConsistencySourceReleaseGates': {'hiddenGateCount': 0},
        'apiConsistencySourceVerification': {'hiddenVerificationCount': 0},
        'apiConsistencyFamilyRemediation': {'hiddenFamilyCount': 0},
        'apiConsistencyPrimitiveRemediation': {'hiddenPrimitiveCount': 0},
        'apiConsistencyFieldRemediation': {'hiddenFieldCount': 0},
        'apiConsistencyConcernSummary': {'readyCount': 8},
        'packageBoundary': {'isClean': true},
        'proEntrypoints': {'uniqueChartTypeCount': 42},
        'proReadiness': {'isReadyForRelease': true},
        'sampleAudit': {'isValid': true},
        'sampleSourceAudit': {'isValid': true},
        'simpleSourceAudit': {'isValid': true},
        'readiness': {'isReady': true},
        'readinessActionPlan': {'hiddenActionCount': 0},
        'readinessActionChecklist': {'hiddenActionCount': 0},
        'sourceMapAudit': {'isReady': true},
      },
    );

    expect(json, containsPair('capabilityCount', report.capabilityCount));
    expect(json, containsPair('showcaseCoverage', {'coveredCount': 2}));
    expect(json, containsPair('showcaseBacklog', {'count': 3}));
    expect(json, containsPair('showcaseThresholds', {'status': 'warn'}));
    expect(json, containsPair('showcaseNaming', {'issueCount': 1}));
    expect(
      json,
      containsPair('showcaseRenamePlan', {
        'status': 'blocked',
        'safeRenameCount': 2,
        'manifestWorkCount': 1,
      }),
    );
    expect(json, containsPair('chartExampleMatrix', {'rowCount': 4}));
    expect(json, containsPair('apiConsistency', {'status': 'ready'}));
    expect(
      json,
      containsPair('apiConsistencyScorecard', {'scorePercent': 100}),
    );
    expect(
      json,
      containsPair('apiConsistencyScoreProjection', {
        'projectedScorePercent': 100,
      }),
    );
    expect(json, containsPair('apiConsistencyReleaseBrief', {'itemCount': 0}));
    expect(json, containsPair('apiConsistencyConformance', {'caseCount': 0}));
    expect(
      json,
      containsPair('apiConsistencyConformanceGate', {'gateCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencyConformanceVerification', {
        'verificationCount': 0,
      }),
    );
    expect(
      json,
      containsPair('apiConsistencyConformanceChecklist', {'stepCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencyConformanceEvidence', {'evidenceCount': 0}),
    );
    expect(json, containsPair('apiConsistencyActionPlan', {'actionCount': 0}));
    expect(
      json,
      containsPair('apiConsistencyImplementationPlan', {'actionCount': 0}),
    );
    expect(json, containsPair('apiConsistencyTraceability', {'traceCount': 0}));
    expect(json, containsPair('apiConsistencySourceQueue', {'sourceCount': 0}));
    expect(json, containsPair('apiConsistencySourcePlan', {'batchCount': 0}));
    expect(
      json,
      containsPair('apiConsistencySourceChecklist', {'stageCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencySourceMilestones', {'milestoneCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencySourceReleaseGates', {'gateCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencySourceVerification', {
        'verificationCount': 0,
      }),
    );
    expect(
      json,
      containsPair('apiConsistencyFamilyRemediation', {'familyCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencyPrimitiveRemediation', {'primitiveCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencyFieldRemediation', {'fieldOptionCount': 0}),
    );
    expect(
      json,
      containsPair('apiConsistencyConcernSummary', {'concernCount': 8}),
    );
    expect(json, containsPair('packageBoundary', {'status': 'clean'}));
    expect(json, containsPair('proEntrypoints', {'entrypointCount': 6}));
    expect(json, containsPair('proReadiness', {'status': 'manifest_ready'}));
    expect(json, containsPair('sampleAudit', {'errorCount': 0}));
    expect(json, containsPair('sampleSourceAudit', {'issueCount': 0}));
    expect(json, containsPair('simpleSourceAudit', {'issueCount': 0}));
    expect(json, containsPair('readiness', {'status': 'ready'}));
    expect(json, containsPair('readinessActionPlan', {'actionCount': 0}));
    expect(json, containsPair('readinessActionChecklist', {'actionCount': 0}));
    expect(json, containsPair('sourceMapAudit', {'status': 'ready'}));
    expect(json, isNot(contains('')));
    expect(text, contains('"showcaseCoverage"'));
    expect(text, contains('"showcaseBacklog"'));
    expect(text, contains('"showcaseThresholds"'));
    expect(text, contains('"showcaseNaming"'));
    expect(text, contains('"showcaseRenamePlan"'));
    expect(text, contains('"chartExampleMatrix"'));
    expect(text, contains('"apiConsistency"'));
    expect(text, contains('"apiConsistencyScorecard"'));
    expect(text, contains('"apiConsistencyScoreProjection"'));
    expect(text, contains('"apiConsistencyReleaseBrief"'));
    expect(text, contains('"apiConsistencyConformance"'));
    expect(text, contains('"apiConsistencyConformanceGate"'));
    expect(text, contains('"apiConsistencyConformanceVerification"'));
    expect(text, contains('"apiConsistencyConformanceChecklist"'));
    expect(text, contains('"apiConsistencyConformanceEvidence"'));
    expect(text, contains('"apiConsistencyActionPlan"'));
    expect(text, contains('"apiConsistencyImplementationPlan"'));
    expect(text, contains('"apiConsistencyTraceability"'));
    expect(text, contains('"apiConsistencySourceQueue"'));
    expect(text, contains('"apiConsistencySourcePlan"'));
    expect(text, contains('"apiConsistencySourceChecklist"'));
    expect(text, contains('"apiConsistencySourceMilestones"'));
    expect(text, contains('"apiConsistencySourceReleaseGates"'));
    expect(text, contains('"apiConsistencySourceVerification"'));
    expect(text, contains('"apiConsistencyFamilyRemediation"'));
    expect(text, contains('"apiConsistencyPrimitiveRemediation"'));
    expect(text, contains('"apiConsistencyFieldRemediation"'));
    expect(text, contains('"apiConsistencyConcernSummary"'));
    expect(text, contains('"packageBoundary"'));
    expect(text, contains('"proEntrypoints"'));
    expect(text, contains('"proReadiness"'));
    expect(text, contains('"sampleAudit"'));
    expect(text, contains('"sampleSourceAudit"'));
    expect(text, contains('"simpleSourceAudit"'));
    expect(text, contains('"readiness"'));
    expect(text, contains('"readinessActionPlan"'));
    expect(text, contains('"readinessActionChecklist"'));
    expect(text, contains('"sourceMapAudit"'));
    expect(text, contains('"missingCount": 1'));
  });

  test('registry health export options filter optional sections by preset', () {
    final report = chartRegistryHealthReport();
    final extraSections = {
      'showcaseCoverage': {'coveredCount': 2},
      'showcaseBacklog': {'count': 3},
      'apiConsistencyReleaseBrief': {'itemCount': 5},
      'apiConsistencyConformanceGate': {'gateCount': 3},
      'apiConsistencyImplementationPlan': {'actionCount': 5},
      'apiConsistencySourcePlan': {'batchCount': 5},
      'packageBoundary': {'status': 'clean'},
      'proReadiness': {'status': 'manifest_ready'},
      'sourceMapAudit': {'isReady': true},
      ' ': {'ignored': true},
    };

    final full = registryHealthExportJson(report, extraSections: extraSections);
    final compact = registryHealthExportJson(
      report,
      extraSections: extraSections,
      options: RegistryHealthExportOptions.compact,
    );
    final release = registryHealthExportJson(
      report,
      extraSections: extraSections,
      options: RegistryHealthExportOptions.release,
    );
    final planning = registryHealthExportJson(
      report,
      extraSections: extraSections,
      options: RegistryHealthExportOptions.planning,
    );
    final custom = registryHealthExportJson(
      report,
      extraSections: extraSections,
      options: RegistryHealthExportOptions.compact.copyWith(
        includedExtraSectionKeys: {'apiConsistencyImplementationPlan'},
        excludedExtraSectionKeys: {'apiConsistencyReleaseBrief'},
      ),
    );
    final releaseText = registryHealthExportText(
      report,
      extraSections: extraSections,
      options: RegistryHealthExportOptions.release,
    );

    expect(RegistryHealthExportOptions.full.name, 'full');
    expect(RegistryHealthExportOptions.compact.name, 'compact');
    expect(RegistryHealthExportOptions.release.name, 'release');
    expect(RegistryHealthExportOptions.planning.name, 'planning');
    expect(RegistryHealthExportOptions.presets.map((item) => item.name), [
      'full',
      'compact',
      'release',
      'planning',
    ]);
    expect(full, containsPair('showcaseBacklog', {'count': 3}));
    expect(
      full,
      containsPair('apiConsistencyImplementationPlan', {'actionCount': 5}),
    );
    expect(full, containsPair('apiConsistencyReleaseBrief', {'itemCount': 5}));
    expect(full, isNot(contains('')));
    expect(compact, containsPair('showcaseCoverage', {'coveredCount': 2}));
    expect(compact, containsPair('sourceMapAudit', {'isReady': true}));
    expect(
      compact,
      containsPair('apiConsistencyReleaseBrief', {'itemCount': 5}),
    );
    expect(compact, containsPair('packageBoundary', {'status': 'clean'}));
    expect(compact, containsPair('proReadiness', {'status': 'manifest_ready'}));
    expect(compact, isNot(contains('showcaseBacklog')));
    expect(compact, isNot(contains('apiConsistencyConformanceGate')));
    expect(compact, isNot(contains('apiConsistencyImplementationPlan')));
    expect(
      release,
      containsPair('apiConsistencyReleaseBrief', {'itemCount': 5}),
    );
    expect(
      release,
      containsPair('apiConsistencyConformanceGate', {'gateCount': 3}),
    );
    expect(release, containsPair('sourceMapAudit', {'isReady': true}));
    expect(release, containsPair('packageBoundary', {'status': 'clean'}));
    expect(release, containsPair('proReadiness', {'status': 'manifest_ready'}));
    expect(release, isNot(contains('showcaseBacklog')));
    expect(release, isNot(contains('apiConsistencyImplementationPlan')));
    expect(release, isNot(contains('apiConsistencySourcePlan')));
    expect(
      planning,
      containsPair('apiConsistencyImplementationPlan', {'actionCount': 5}),
    );
    expect(
      planning,
      containsPair('apiConsistencySourcePlan', {'batchCount': 5}),
    );
    expect(planning, containsPair('showcaseBacklog', {'count': 3}));
    expect(planning, containsPair('packageBoundary', {'status': 'clean'}));
    expect(
      planning,
      containsPair('proReadiness', {'status': 'manifest_ready'}),
    );
    expect(planning, isNot(contains('apiConsistencyConformanceGate')));
    expect(planning, isNot(contains('apiConsistencyReleaseBrief')));
    expect(
      custom,
      containsPair('apiConsistencyImplementationPlan', {'actionCount': 5}),
    );
    expect(custom, isNot(contains('apiConsistencyReleaseBrief')));
    expect(custom, isNot(contains('showcaseCoverage')));
    expect(releaseText, contains('"apiConsistencyReleaseBrief"'));
    expect(releaseText, contains('"apiConsistencyConformanceGate"'));
    expect(releaseText, isNot(contains('"apiConsistencyImplementationPlan"')));
  });

  test('registry health export preset controls order and label presets', () {
    final ordered = registryHealthOrderedExportPresets([
      RegistryHealthExportOptions.full,
      RegistryHealthExportOptions.compact,
      RegistryHealthExportOptions.release,
    ], primaryOptions: RegistryHealthExportOptions.planning);

    expect(ordered.map((item) => item.name), [
      'planning',
      'full',
      'compact',
      'release',
    ]);
    expect(
      registryHealthExportPresetCopyLabel(RegistryHealthExportOptions.full),
      'Copy Health JSON',
    );
    expect(
      registryHealthExportPresetCopyLabel(RegistryHealthExportOptions.compact),
      'Copy Compact JSON',
    );
    expect(
      registryHealthExportPresetCopyLabel(
        RegistryHealthExportOptions(name: 'field_audit'),
      ),
      'Copy Field Audit JSON',
    );
    expect(registryHealthExportPresetDescriptors.map((item) => item.id), [
      'full',
      'compact',
      'release',
      'planning',
    ]);
    expect(
      registryHealthExportPresetDescriptors.map((item) => item.options.name),
      RegistryHealthExportOptions.presets.map((item) => item.name),
    );
    expect(registryHealthExportOptionsForPresetId('release').name, 'release');
    expect(registryHealthExportOptionsForPresetId('unknown').name, 'full');
  });

  test('registry health export preset summary reports scope and size', () {
    final report = chartRegistryHealthReport();
    final summary = registryHealthExportPresetSummary(
      report,
      extraSections: {
        'showcaseCoverage': {'coveredCount': 2},
        'showcaseBacklog': {'count': 3},
        'sourceMapAudit': {'isReady': true},
        ' ': {'ignored': true},
      },
      options: RegistryHealthExportOptions.compact,
    );

    expect(summary.options.name, 'compact');
    expect(summary.extraSectionKeys, ['showcaseCoverage', 'sourceMapAudit']);
    expect(summary.extraSectionCount, 2);
    expect(summary.topLevelKeyCount, greaterThan(summary.extraSectionCount));
    expect(summary.payloadBytes, greaterThan(0));
    expect(registryHealthFormatExportBytes(512), '512 B');
    expect(registryHealthFormatExportBytes(1536), '1.5 KB');
    expect(registryHealthFormatExportBytes(2048), '2 KB');
    expect(registryHealthExportPresetTooltip(summary), startsWith('Compact'));
  });

  testWidgets('registry health copy button uses export preset labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryHealthCopyButton(
            report: chartRegistryHealthReport(),
            extraSections: {
              'showcaseCoverage': {'coveredCount': 2},
              'sourceMapAudit': {'isReady': true},
            },
            exportOptions: RegistryHealthExportOptions.release,
          ),
        ),
      ),
    );

    expect(find.text('Copy Release JSON'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message != null &&
            widget.message!.startsWith('Release export:'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('registry health export preset controls render copy choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegistryHealthExportPresetControls(
            report: chartRegistryHealthReport(),
            extraSections: {
              'showcaseCoverage': {'coveredCount': 2},
              'sourceMapAudit': {'isReady': true},
            },
          ),
        ),
      ),
    );

    expect(find.text('Copy Health JSON'), findsOneWidget);
    expect(find.text('Copy Compact JSON'), findsOneWidget);
    expect(find.text('Copy Release JSON'), findsOneWidget);
    expect(find.text('Copy Planning JSON'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message != null &&
            widget.message!.startsWith('Full export:'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('source map audit export covers loading and unavailable states', () {
    final loading = registryHealthShowcaseSourceMapAuditExportJson(
      isLoading: true,
    );
    final unavailable = registryHealthShowcaseSourceMapAuditExportJson(
      error: StateError('source map fixture missing'),
    );

    expect(loading, containsPair('status', 'loading'));
    expect(loading, containsPair('isReady', false));
    expect(loading, containsPair('issueCount', 0));
    expect(unavailable, containsPair('status', 'unavailable'));
    expect(unavailable, containsPair('issueCount', 1));
    expect(
      unavailable['error'].toString(),
      contains('source map fixture missing'),
    );
  });
}

void _setRegistryHealthTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

TenunProReleaseReadinessAudit _blockedProReadinessAudit() {
  return TenunProReleaseReadinessAudit(
    packageBoundary: const TenunPackageBoundaryAudit(
      coreTypes: {ChartType.line},
      proTypes: {ChartType.line, ChartType.candlestick},
      issues: ['line overlaps'],
    ),
    distributionReadiness: auditTenunProDistributionReadiness(),
    migrationReadiness: auditTenunProMigrationReadiness(),
    manifestValidation: const TenunProManifestValidationReport(
      issues: [
        TenunProManifestValidationIssue(
          code: 'broken_manifest',
          message: 'manifest broken',
          severity: TenunProManifestValidationSeverity.error,
        ),
      ],
    ),
    corePublicApiLeaks: const [
      TenunProCorePublicApiLeak(
        exportPath: 'charts/candle/simple_candlestick_chart.dart',
      ),
    ],
    legacyPublicApiLeaks: const [
      TenunProCorePublicApiLeak(
        exportPath: 'charts/pie/pie_chart_variants.dart',
      ),
    ],
  );
}

Future<void> _waitForRegistryHealthSourceMapAudit(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    if (find
        .byType(RegistryHealthShowcaseSourceMapAuditPanel)
        .evaluate()
        .isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
}

final String _sourceMapFixture = [
  '// source-map fixture',
  'class ChartSamplesRegistry {',
  '  static const Map<String, dynamic> barRace = {',
  "    'type': 'barRace',",
  '  };',
  '  static const Map<String, dynamic> madeUp = {',
  "    'type': 'madeUp',",
  '  };',
  '  static const List<ChartShowcaseSample> naming = [',
  "    ChartShowcaseSample('Camel Bar Race', 180, barRace),",
  "    ChartShowcaseSample('Missing Type', 180, madeUp),",
  '  ];',
  '  static const ChartShowcaseFamily namingFamily = ChartShowcaseFamily(',
  "    id: 'naming',",
  "    title: 'Naming',",
  "    description: 'Naming samples.',",
  '    samples: naming,',
  '  );',
  '  static const List<ChartShowcaseFamily> focusedFamilies = [',
  '    namingFamily,',
  '  ];',
  '}',
].join('\n');
