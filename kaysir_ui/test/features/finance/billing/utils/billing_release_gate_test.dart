import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_definition_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_execution_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';

void main() {
  test('BillingReleaseGateReport accepts ready routing lanes', () {
    final report = BillingReleaseGateReport.forRouting(
      routeContractReport: BillingRouteContractReport.forRouteRegistry(),
      routeExecutionReport: BillingRouteExecutionReport.forRegistry(),
      routeExtensionManifestReport:
          BillingRouteExtensionManifestReport.forManifests(const []),
    );

    expect(report.isReady, isTrue);
    expect(report.status, BillingReleaseGateStatus.ready);
    expect(report.laneCount, 3);
    expect(report.blockerCount, 0);
    expect(report.warningCount, 0);
    expect(
      report.summaryLabel,
      'Billing release gate is ready across 3 lanes.',
    );
    expect(
      report.laneForId(billingReleaseGateRouteContractLaneId)?.title,
      'Route contract',
    );
  });

  test('BillingReleaseGateReport reports hardening lanes', () {
    final contractReport = _routeContractReportWithIssues([
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingRouteMetadata,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: BillingRoutes.diagnosticsRouteName,
        message: 'Metadata missing',
      ),
    ]);

    final report = BillingReleaseGateReport.forRouting(
      routeContractReport: contractReport,
      routeExecutionReport: BillingRouteExecutionReport.forRegistry(),
      routeExtensionManifestReport:
          BillingRouteExtensionManifestReport.forManifests(const []),
    );

    expect(report.isReady, isFalse);
    expect(report.status, BillingReleaseGateStatus.hardening);
    expect(report.hasWarnings, isTrue);
    expect(report.warningCount, 1);
    expect(
      report.hardeningLanes.single.id,
      billingReleaseGateRouteContractLaneId,
    );
    expect(
      report.summaryLabel,
      'Billing release gate is launch-ready with 1 warning across 1 lane.',
    );
  });

  test('BillingReleaseGateReport reports blocked lanes', () {
    final routeRegistry = BillingRouteDefinitionRegistry(
      extensionDefinitions: const [_entitlementsRoute],
    );
    final manifestReport = BillingRouteExtensionManifestReport.forManifests([
      BillingRouteExtensionManifest(
        id: 'billing.entitlements',
        routeDefinitions: const [_entitlementsRoute],
      ),
    ]);

    final report = BillingReleaseGateReport.forRouting(
      routeContractReport: BillingRouteContractReport.forRouteRegistry(),
      routeExecutionReport: BillingRouteExecutionReport.forRegistry(
        routeDefinitionRegistry: routeRegistry,
      ),
      routeExtensionManifestReport: manifestReport,
    );

    expect(report.status, BillingReleaseGateStatus.blocked);
    expect(report.hasBlockers, isTrue);
    expect(report.blockerCount, 2);
    expect(report.blockedLanes.map((lane) => lane.id), [
      billingReleaseGateRouteExecutionLaneId,
      billingReleaseGateRouteExtensionManifestLaneId,
    ]);
    expect(report.actionCount, 2);
    expect(
      report.summaryLabel,
      'Billing release gate is blocked by 2 blockers across 2 lanes.',
    );
  });
}

BillingRouteContractReport _routeContractReportWithIssues(
  Iterable<BillingRouteContractIssue> issues,
) {
  final registryReport = BillingRouteContractReport.forRouteRegistry();

  return BillingRouteContractReport(
    rootRoute: registryReport.rootRoute,
    routeDefinitions: registryReport.routeDefinitions,
    issues: issues,
  );
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
