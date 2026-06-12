import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../billing_routes.dart';
import '../utils/billing_route_definition_registry.dart';
import '../utils/billing_route_contract.dart';
import '../utils/billing_route_contract_remediation.dart';
import '../utils/billing_route_execution_contract.dart';
import '../utils/billing_route_extension_manifest.dart';
import '../utils/billing_route_extension_manifest_remediation.dart';
import '../utils/billing_route_page_builder_registry.dart';
import '../utils/billing_release_gate.dart';

/// Provides the standard route definitions audited by billing diagnostics.
final billingRouteContractBaseRouteDefinitionsProvider =
    Provider<List<BillingManagementRouteDefinition>>((ref) {
      return BillingRoutes.sidebarRoutes;
    });

/// Provides product or domain-specific route definitions added to billing.
final billingRouteContractExtensionRouteDefinitionsProvider =
    Provider<List<BillingManagementRouteDefinition>>((ref) {
      return const <BillingManagementRouteDefinition>[];
    });

/// Provides executable billing route manifests contributed by products/domains.
final billingRouteExtensionManifestsProvider =
    Provider<List<BillingRouteExtensionManifest>>((ref) {
      return const <BillingRouteExtensionManifest>[];
    });

/// Provides manifest readiness for executable route extension packs.
final billingRouteExtensionManifestReportProvider = Provider<
  BillingRouteExtensionManifestReport
>((ref) {
  final extensionManifests = ref.watch(billingRouteExtensionManifestsProvider);

  return BillingRouteExtensionManifestReport.forManifests(extensionManifests);
});

/// Provides prioritized remediation for billing route extension manifests.
final billingRouteExtensionManifestRemediationPlanProvider =
    Provider<BillingRouteExtensionManifestRemediationPlan>((ref) {
      final report = ref.watch(billingRouteExtensionManifestReportProvider);
      return BillingRouteExtensionManifestRemediationPlan.forReport(report);
    });

/// Provides loose extension page builders for advanced integration points.
final billingRouteExtensionPageBuildersProvider =
    Provider<Map<String, BillingRoutePageBuilder>>((ref) {
      return const <String, BillingRoutePageBuilder>{};
    });

/// Provides the composed billing route registry audited by diagnostics.
final billingRouteDefinitionRegistryProvider =
    Provider<BillingRouteDefinitionRegistry>((ref) {
      final baseDefinitions = ref.watch(
        billingRouteContractBaseRouteDefinitionsProvider,
      );
      final extensionDefinitions = ref.watch(
        billingRouteContractExtensionRouteDefinitionsProvider,
      );
      final extensionManifests = ref.watch(
        billingRouteExtensionManifestsProvider,
      );

      return BillingRouteDefinitionRegistry(
        baseDefinitions: baseDefinitions,
        extensionDefinitions: [
          ...extensionDefinitions,
          ...billingRouteDefinitionsForManifests(extensionManifests),
        ],
      );
    });

/// Provides the composed route definitions audited by billing diagnostics.
final billingRouteContractRouteDefinitionsProvider =
    Provider<List<BillingManagementRouteDefinition>>((ref) {
      return ref.watch(billingRouteDefinitionRegistryProvider).routeDefinitions;
    });

/// Provides executable page builders for billing route definitions.
final billingRoutePageBuilderRegistryProvider =
    Provider<BillingRoutePageBuilderRegistry>((ref) {
      final extensionManifests = ref.watch(
        billingRouteExtensionManifestsProvider,
      );
      final extensionPageBuilders = ref.watch(
        billingRouteExtensionPageBuildersProvider,
      );

      return BillingRoutePageBuilderRegistry.standard(
        extensionBuildersByRouteIdentityKey: {
          ...billingRoutePageBuildersForManifests(extensionManifests),
          ...extensionPageBuilders,
        },
      );
    });

/// Provides the current billing route/sidebar contract report.
final billingRouteContractReportProvider = Provider<BillingRouteContractReport>(
  (ref) {
    final routeDefinitions = ref.watch(
      billingRouteContractRouteDefinitionsProvider,
    );
    return BillingRouteContractReport.forRouteRegistry(
      routeDefinitions: routeDefinitions,
    );
  },
);

/// Provides prioritized remediation for the current route contract report.
final billingRouteContractRemediationPlanProvider =
    Provider<BillingRouteContractRemediationPlan>((ref) {
      final report = ref.watch(billingRouteContractReportProvider);
      return BillingRouteContractRemediationPlan.forReport(report);
    });

/// Provides the current billing route execution readiness report.
final billingRouteExecutionReportProvider =
    Provider<BillingRouteExecutionReport>((ref) {
      final routeDefinitionRegistry = ref.watch(
        billingRouteDefinitionRegistryProvider,
      );
      final pageBuilderRegistry = ref.watch(
        billingRoutePageBuilderRegistryProvider,
      );

      return BillingRouteExecutionReport.forRegistry(
        routeDefinitionRegistry: routeDefinitionRegistry,
        pageBuilderRegistry: pageBuilderRegistry,
      );
    });

/// Provides the aggregate billing release gate for route launch readiness.
final billingReleaseGateReportProvider = Provider<BillingReleaseGateReport>((
  ref,
) {
  final routeContractReport = ref.watch(billingRouteContractReportProvider);
  final routeContractRemediationPlan = ref.watch(
    billingRouteContractRemediationPlanProvider,
  );
  final routeExecutionReport = ref.watch(billingRouteExecutionReportProvider);
  final routeExtensionManifestReport = ref.watch(
    billingRouteExtensionManifestReportProvider,
  );
  final routeExtensionManifestRemediationPlan = ref.watch(
    billingRouteExtensionManifestRemediationPlanProvider,
  );

  return BillingReleaseGateReport.forRouting(
    routeContractReport: routeContractReport,
    routeContractRemediationPlan: routeContractRemediationPlan,
    routeExecutionReport: routeExecutionReport,
    routeExtensionManifestReport: routeExtensionManifestReport,
    routeExtensionManifestRemediationPlan:
        routeExtensionManifestRemediationPlan,
  );
});
