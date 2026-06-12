import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';

void main() {
  test('BillingRouteExtensionManifest exposes routes and builders', () {
    final manifest = BillingRouteExtensionManifest(
      id: 'billing.entitlements',
      routeDefinitions: const [_entitlementsRoute],
      pageBuildersByRouteIdentityKey: {
        ' billingEntitlements ': _entitlementsPageBuilder,
      },
    );

    expect(manifest.isNotEmpty, isTrue);
    expect(manifest.routeIdentityKeys, ['billingEntitlements']);
    expect(manifest.missingPageBuilderDefinitions, isEmpty);
    expect(manifest.hasPageBuilderFor(_entitlementsRoute), isTrue);
    expect(
      manifest.pageBuilderFor(_entitlementsRoute),
      same(_entitlementsPageBuilder),
    );
  });

  test('BillingRouteExtensionManifest reports routes missing builders', () {
    final manifest = BillingRouteExtensionManifest(
      id: 'billing.entitlements',
      routeDefinitions: const [_entitlementsRoute],
    );

    expect(manifest.missingPageBuilderDefinitions, [_entitlementsRoute]);
    expect(manifest.hasPageBuilderFor(_entitlementsRoute), isFalse);
  });

  test('BillingRouteExtensionManifestReport accepts complete manifests', () {
    final manifest = BillingRouteExtensionManifest(
      id: 'billing.entitlements',
      routeDefinitions: const [_entitlementsRoute],
      pageBuildersByRouteIdentityKey: {
        'billingEntitlements': _entitlementsPageBuilder,
      },
    );

    final report = BillingRouteExtensionManifestReport.forManifests([manifest]);

    expect(report.isReady, isTrue);
    expect(report.hasIssues, isFalse);
    expect(report.manifestCount, 1);
    expect(report.routeCount, 1);
    expect(report.pageBuilderCount, 1);
    expect(
      report.summaryLabel,
      'Billing route extension manifests are ready across 1 manifest.',
    );
  });

  test(
    'BillingRouteExtensionManifestReport detects missing and orphan builders',
    () {
      final missingBuilderManifest = BillingRouteExtensionManifest(
        id: 'billing.entitlements.missing-builder',
        routeDefinitions: const [_entitlementsRoute],
      );
      final orphanBuilderManifest = BillingRouteExtensionManifest(
        id: 'billing.entitlements.orphan-builder',
        pageBuildersByRouteIdentityKey: {
          'billingEntitlements': _entitlementsPageBuilder,
        },
      );

      final report = BillingRouteExtensionManifestReport.forManifests([
        missingBuilderManifest,
        orphanBuilderManifest,
      ]);

      expect(report.isReady, isFalse);
      expect(report.hasIssues, isTrue);
      expect(report.routeCount, 1);
      expect(report.pageBuilderCount, 1);
      expect(
        report.hasIssueKind(
          BillingRouteExtensionManifestIssueKind.missingPageBuilder,
        ),
        isTrue,
      );
      expect(
        report.hasIssueKind(
          BillingRouteExtensionManifestIssueKind.orphanPageBuilder,
        ),
        isTrue,
      );
      expect(report.blockerIssues.single.manifestId, missingBuilderManifest.id);
      expect(report.warningIssues.single.manifestId, orphanBuilderManifest.id);
      expect(
        report.summaryLabel,
        'Billing route extension manifests have 1 blocker and 1 warning.',
      );
    },
  );

  test(
    'BillingRouteExtensionManifestReport detects duplicate ids and builders',
    () {
      final first = BillingRouteExtensionManifest(
        id: 'billing.entitlements',
        routeDefinitions: const [_entitlementsRoute],
        pageBuildersByRouteIdentityKey: {
          'billingEntitlements': _entitlementsPageBuilder,
        },
      );
      final second = BillingRouteExtensionManifest(
        id: 'billing.entitlements',
        routeDefinitions: const [_entitlementsRoute],
        pageBuildersByRouteIdentityKey: {
          'billingEntitlements': _entitlementsPageBuilder,
        },
      );

      final report = BillingRouteExtensionManifestReport.forManifests([
        first,
        second,
      ]);

      expect(report.isReady, isFalse);
      expect(
        report.hasIssueKind(
          BillingRouteExtensionManifestIssueKind.duplicateManifestId,
        ),
        isTrue,
      );
      expect(
        report.hasIssueKind(
          BillingRouteExtensionManifestIssueKind.duplicatePageBuilder,
        ),
        isTrue,
      );
      expect(report.blockerIssues.length, 2);
      expect(report.warningIssues, isEmpty);
    },
  );

  test('BillingRouteExtensionManifest rejects blank ids', () {
    expect(
      () => BillingRouteExtensionManifest(id: ' '),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('billingRoutePageBuildersForManifests rejects duplicate builders', () {
    final first = BillingRouteExtensionManifest(
      id: 'billing.entitlements.first',
      pageBuildersByRouteIdentityKey: {
        'billingEntitlements': _entitlementsPageBuilder,
      },
    );
    final second = BillingRouteExtensionManifest(
      id: 'billing.entitlements.second',
      pageBuildersByRouteIdentityKey: {
        'billingEntitlements': _entitlementsPageBuilder,
      },
    );

    expect(
      () => billingRoutePageBuildersForManifests([first, second]),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('manifest helpers flatten routes and builders', () {
    final manifest = BillingRouteExtensionManifest(
      id: 'billing.entitlements',
      routeDefinitions: const [_entitlementsRoute],
      pageBuildersByRouteIdentityKey: {
        'billingEntitlements': _entitlementsPageBuilder,
      },
    );

    expect(billingRouteDefinitionsForManifests([manifest]), [
      _entitlementsRoute,
    ]);
    expect(
      billingRoutePageBuildersForManifests([manifest])['billingEntitlements'],
      same(_entitlementsPageBuilder),
    );
  });
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
