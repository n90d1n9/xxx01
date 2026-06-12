import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/states/billing_route_contract_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_execution_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_page_builder_registry.dart';

void main() {
  test(
    'billingRouteContractRouteDefinitionsProvider exposes sidebar routes',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final definitions = container.read(
        billingRouteContractRouteDefinitionsProvider,
      );

      expect(definitions, BillingRoutes.sidebarRoutes);
      expect(definitions.length, BillingRoutes.sidebarRoutes.length);
    },
  );

  test('billingRouteContractReportProvider exposes registry report', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final report = container.read(billingRouteContractReportProvider);

    expect(report.isComplete, isTrue);
    expect(
      report.summaryLabel,
      'Billing route contract is complete across '
      '${BillingRoutes.sidebarRoutes.length} routes.',
    );
  });

  test(
    'billingRouteContractRouteDefinitionsProvider composes extension routes',
    () {
      final container = ProviderContainer(
        overrides: [
          billingRouteContractExtensionRouteDefinitionsProvider
              .overrideWithValue([_entitlementsRoute]),
        ],
      );
      addTearDown(container.dispose);

      final definitions = container.read(
        billingRouteContractRouteDefinitionsProvider,
      );
      final report = container.read(billingRouteContractReportProvider);
      final plan = container.read(billingRouteContractRemediationPlanProvider);

      expect(definitions.length, BillingRoutes.sidebarRoutes.length + 1);
      expect(definitions.last, _entitlementsRoute);
      expect(report.isComplete, isTrue, reason: report.summaryLabel);
      expect(
        report.summaryLabel,
        'Billing route contract is complete across '
        '${BillingRoutes.sidebarRoutes.length + 1} routes.',
      );
      expect(report.expectedSidebarPaths, contains(_entitlementsRoute.path));
      expect(plan.isEmpty, isTrue);
    },
  );

  test('billingRouteDefinitionRegistryProvider composes extension routes', () {
    final container = ProviderContainer(
      overrides: [
        billingRouteContractExtensionRouteDefinitionsProvider.overrideWithValue(
          [_entitlementsRoute],
        ),
      ],
    );
    addTearDown(container.dispose);

    final registry = container.read(billingRouteDefinitionRegistryProvider);

    expect(registry.hasExtensions, isTrue);
    expect(registry.routeCount, BillingRoutes.sidebarRoutes.length + 1);
    expect(
      registry.definitionForRouteIdentityKey('billingEntitlements'),
      _entitlementsRoute,
    );
    expect(registry.routeDefinitions.last, _entitlementsRoute);
  });

  test(
    'billingRouteContractReportProvider detects duplicate extension route identity',
    () {
      final container = ProviderContainer(
        overrides: [
          billingRouteContractExtensionRouteDefinitionsProvider
              .overrideWithValue([_diagnosticsAliasRoute]),
        ],
      );
      addTearDown(container.dispose);

      final report = container.read(billingRouteContractReportProvider);
      final plan = container.read(billingRouteContractRemediationPlanProvider);

      expect(report.isComplete, isFalse);
      expect(
        report.hasIssueKind(BillingRouteContractIssueKind.duplicateRouteName),
        isFalse,
      );
      expect(
        report.hasIssueKind(BillingRouteContractIssueKind.duplicatePath),
        isFalse,
      );
      expect(
        report.hasIssueKind(BillingRouteContractIssueKind.duplicateDestination),
        isTrue,
      );
      expect(plan.blockerActions.length, 1);
      expect(
        plan.blockerActions.single.detail,
        'Keep BillingRoutes.sidebarRoutes unique for names, paths, and route identities.',
      );
    },
  );

  test(
    'billingRouteExecutionReportProvider detects missing extension builders',
    () {
      final container = ProviderContainer(
        overrides: [
          billingRouteContractExtensionRouteDefinitionsProvider
              .overrideWithValue([_entitlementsRoute]),
        ],
      );
      addTearDown(container.dispose);

      final report = container.read(billingRouteExecutionReportProvider);

      expect(report.isReady, isFalse);
      expect(report.fallbackBuilderCount, 1);
      expect(
        report.issues.single.kind,
        BillingRouteExecutionIssueKind.missingExplicitPageBuilder,
      );
      expect(report.issues.single.routeName, _entitlementsRoute.routeName);
    },
  );

  test('billingRouteExecutionReportProvider accepts extension builders', () {
    final container = ProviderContainer(
      overrides: [
        billingRouteContractExtensionRouteDefinitionsProvider.overrideWithValue(
          [_entitlementsRoute],
        ),
        billingRoutePageBuilderRegistryProvider.overrideWithValue(
          BillingRoutePageBuilderRegistry.standard(
            extensionBuildersByRouteIdentityKey: {
              'billingEntitlements': _entitlementsPageBuilder,
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final report = container.read(billingRouteExecutionReportProvider);

    expect(report.isReady, isTrue);
    expect(report.explicitBuilderCount, BillingRoutes.sidebarRoutes.length + 1);
    expect(report.fallbackBuilderCount, 0);
  });

  test('billing route manifests compose definitions and builders', () {
    final container = ProviderContainer(
      overrides: [
        billingRouteExtensionManifestsProvider.overrideWithValue([
          BillingRouteExtensionManifest(
            id: 'billing.entitlements',
            routeDefinitions: const [_entitlementsRoute],
            pageBuildersByRouteIdentityKey: {
              'billingEntitlements': _entitlementsPageBuilder,
            },
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final routeRegistry = container.read(
      billingRouteDefinitionRegistryProvider,
    );
    final builderRegistry = container.read(
      billingRoutePageBuilderRegistryProvider,
    );
    final manifestReport = container.read(
      billingRouteExtensionManifestReportProvider,
    );
    final manifestRemediationPlan = container.read(
      billingRouteExtensionManifestRemediationPlanProvider,
    );
    final executionReport = container.read(billingRouteExecutionReportProvider);

    expect(routeRegistry.routeDefinitions.last, _entitlementsRoute);
    expect(builderRegistry.hasPageBuilderFor(_entitlementsRoute), isTrue);
    expect(manifestReport.isReady, isTrue);
    expect(manifestReport.hasIssues, isFalse);
    expect(manifestRemediationPlan.isEmpty, isTrue);
    expect(executionReport.isReady, isTrue);
    expect(executionReport.fallbackBuilderCount, 0);
  });

  test('billingRouteExtensionManifestReportProvider reports readiness', () {
    final container = ProviderContainer(
      overrides: [
        billingRouteExtensionManifestsProvider.overrideWithValue([
          BillingRouteExtensionManifest(
            id: 'billing.entitlements',
            routeDefinitions: const [_entitlementsRoute],
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final report = container.read(billingRouteExtensionManifestReportProvider);
    final plan = container.read(
      billingRouteExtensionManifestRemediationPlanProvider,
    );

    expect(report.isReady, isFalse);
    expect(
      report.hasIssueKind(
        BillingRouteExtensionManifestIssueKind.missingPageBuilder,
      ),
      isTrue,
    );
    expect(report.blockerIssues.single.manifestId, 'billing.entitlements');
    expect(
      report.summaryLabel,
      'Billing route extension manifests have 1 blocker and 0 warnings.',
    );
    expect(plan.hasBlockers, isTrue);
    expect(
      plan.actions.single.kind,
      BillingRouteExtensionManifestRemediationActionKind.attachPageBuilder,
    );
    expect(
      plan.actions.single.label,
      'Attach billing.entitlements page builder',
    );
  });

  test('billingReleaseGateReportProvider aggregates route readiness', () {
    final container = ProviderContainer(
      overrides: [
        billingRouteExtensionManifestsProvider.overrideWithValue([
          BillingRouteExtensionManifest(
            id: 'billing.entitlements',
            routeDefinitions: const [_entitlementsRoute],
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final report = container.read(billingReleaseGateReportProvider);

    expect(report.status, BillingReleaseGateStatus.blocked);
    expect(report.blockerCount, 2);
    expect(report.blockedLanes.map((lane) => lane.id), [
      billingReleaseGateRouteExecutionLaneId,
      billingReleaseGateRouteExtensionManifestLaneId,
    ]);
    expect(
      report.summaryLabel,
      'Billing release gate is blocked by 2 blockers across 2 lanes.',
    );
  });

  test(
    'billing loose extension page builders keep advanced overrides working',
    () {
      final container = ProviderContainer(
        overrides: [
          billingRouteContractExtensionRouteDefinitionsProvider
              .overrideWithValue([_entitlementsRoute]),
          billingRouteExtensionPageBuildersProvider.overrideWithValue({
            'billingEntitlements': _entitlementsPageBuilder,
          }),
        ],
      );
      addTearDown(container.dispose);

      final executionReport = container.read(
        billingRouteExecutionReportProvider,
      );

      expect(executionReport.isReady, isTrue);
      expect(
        executionReport.explicitBuilderCount,
        BillingRoutes.sidebarRoutes.length + 1,
      );
    },
  );

  test(
    'billingRouteContractReportProvider follows route definition overrides',
    () {
      final container = ProviderContainer(
        overrides: [
          billingRouteContractRouteDefinitionsProvider.overrideWithValue([
            ...BillingRoutes.sidebarRoutes,
            BillingRoutes.sidebarRoutes.first,
          ]),
        ],
      );
      addTearDown(container.dispose);

      final report = container.read(billingRouteContractReportProvider);

      expect(report.isComplete, isFalse);
      expect(
        report.hasIssueKind(BillingRouteContractIssueKind.duplicateRouteName),
        isTrue,
      );
      expect(
        report.hasIssueKind(BillingRouteContractIssueKind.duplicatePath),
        isTrue,
      );
      expect(
        report.hasIssueKind(BillingRouteContractIssueKind.duplicateDestination),
        isTrue,
      );
    },
  );

  test(
    'billingRouteContractRemediationPlanProvider follows route definition overrides',
    () {
      final container = ProviderContainer(
        overrides: [
          billingRouteContractRouteDefinitionsProvider.overrideWithValue([
            ...BillingRoutes.sidebarRoutes,
            BillingRoutes.sidebarRoutes.first,
          ]),
        ],
      );
      addTearDown(container.dispose);

      final plan = container.read(billingRouteContractRemediationPlanProvider);

      expect(plan.blockerActions.length, 3);
      expect(
        plan.actions.first.label,
        'Clean up billingManagement route registry',
      );
      expect(
        plan.summaryLabel,
        '3 route blockers should be cleared before release.',
      );
    },
  );

  test(
    'billingRouteContractRemediationPlanProvider follows report overrides',
    () {
      final registryReport = BillingRouteContractReport.forRouteRegistry();
      final issueReport = BillingRouteContractReport(
        rootRoute: registryReport.rootRoute,
        routeDefinitions: registryReport.routeDefinitions,
        issues: [
          BillingRouteContractIssue(
            kind: BillingRouteContractIssueKind.missingFeaturePageBuilder,
            severity: BillingRouteContractIssueSeverity.blocker,
            routeName: BillingRoutes.checkoutRouteName,
            message: 'Missing checkout page builder',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          billingRouteContractReportProvider.overrideWithValue(issueReport),
        ],
      );
      addTearDown(container.dispose);

      final plan = container.read(billingRouteContractRemediationPlanProvider);

      expect(plan.actionCount, 1);
      expect(
        plan.blockerActions.single.routeName,
        BillingRoutes.checkoutRouteName,
      );
      expect(
        plan.summaryLabel,
        '1 route blocker should be cleared before release.',
      );
    },
  );
}

Page<dynamic> _entitlementsPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  return const MaterialPage(child: SizedBox.shrink());
}

const _entitlementsRoute = BillingManagementRouteDefinition(
  name: 'Billing Entitlements',
  routeName: 'billingEntitlements',
  title: 'Entitlements',
  subtitle: 'Access billing',
  description:
      'Review entitlement billing policies for the selected workspace.',
  icon: 'billing-entitlements',
  path: '${BillingRoutes.managementPath}/entitlements',
  destinationId: BillingNavigationDestinationId.diagnostics,
  routeIdentityKey: 'billingEntitlements',
  surface: BillingManagementRouteSurface.dashboard,
);

const _diagnosticsAliasRoute = BillingManagementRouteDefinition(
  name: 'Billing Diagnostics Alias',
  routeName: 'billingDiagnosticsAlias',
  title: 'Diagnostics Alias',
  subtitle: 'Route identity check',
  description:
      'Simulates an extension route that forgot to declare route identity.',
  icon: 'billing-diagnostics-alias',
  path: '${BillingRoutes.managementPath}/diagnostics-alias',
  destinationId: BillingNavigationDestinationId.diagnostics,
  surface: BillingManagementRouteSurface.dashboard,
);
