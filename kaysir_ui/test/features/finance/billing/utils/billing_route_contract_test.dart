import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/finance/billing/billing_features.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';

void main() {
  test('billing route contract accepts generated sidebar routes', () {
    final report = BillingRouteContractReport.forFeatureRoute(
      rootRoute: BillingFeatures().registerScreens().single,
    );

    expect(report.isComplete, isTrue, reason: report.summaryLabel);
    expect(report.expectedSidebarPaths, [
      BillingRoutes.workspacesPath,
      BillingRoutes.workCenterPath,
      BillingRoutes.invoicesPath,
      BillingRoutes.createInvoicePath,
      BillingRoutes.insightsPath,
      BillingRoutes.issueOutboxPath,
      BillingRoutes.policyPath,
      BillingRoutes.productsPath,
      BillingRoutes.checkoutPath,
      BillingRoutes.diagnosticsPath,
    ]);
    expect(report.actualSidebarPaths, report.expectedSidebarPaths);
    expect(
      report.summaryLabel,
      'Billing route contract is complete across '
      '${BillingRoutes.sidebarRoutes.length} routes.',
    );
  });

  test('billing route contract can audit the route registry directly', () {
    final report = BillingRouteContractReport.forRouteRegistry();

    expect(report.isComplete, isTrue, reason: report.summaryLabel);
    expect(
      report.hasIssueKind(
        BillingRouteContractIssueKind.missingFeaturePageBuilder,
      ),
      isFalse,
    );
    expect(report.actualSidebarPaths, report.expectedSidebarPaths);
  });

  test('billing route contract detects missing feature routes', () {
    final root = BillingFeatures().registerScreens().single;
    final report = BillingRouteContractReport.forFeatureRoute(
      rootRoute: _copyRoot(
        root,
        items: root.items.where(
          (route) => route.routeName != BillingRoutes.diagnosticsRouteName,
        ),
      ),
    );

    expect(report.isReady, isFalse);
    expect(
      report.hasIssueKind(BillingRouteContractIssueKind.missingFeatureRoute),
      isTrue,
    );
    expect(
      report
          .issueForKind(BillingRouteContractIssueKind.missingFeatureRoute)
          ?.routeName,
      BillingRoutes.diagnosticsRouteName,
    );
  });

  test('billing route contract detects duplicate registry definitions', () {
    final report = BillingRouteContractReport.forFeatureRoute(
      rootRoute: BillingFeatures().registerScreens().single,
      routeDefinitions: [
        ...BillingRoutes.sidebarRoutes,
        BillingRoutes.sidebarRoutes.first,
      ],
    );

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
  });

  test('billing route contract detects feature metadata drift', () {
    final root = BillingFeatures().registerScreens().single;
    final report = BillingRouteContractReport.forFeatureRoute(
      rootRoute: _copyRoot(
        root,
        items: root.items.map((route) {
          if (route.routeName != BillingRoutes.diagnosticsRouteName) {
            return route;
          }

          return FeatureRoutes(
            name: route.name,
            title: 'Diagnostics',
            subtitle: 'Wrong metadata',
            description: 'Wrong description',
            icon: 'wrong-icon',
            path: '${BillingRoutes.managementPath}/diag',
          );
        }),
      ),
    );

    expect(
      report.hasIssueKind(
        BillingRouteContractIssueKind.featureRoutePathMismatch,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingRouteContractIssueKind.featureRouteTitleMismatch,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingRouteContractIssueKind.featureRouteSubtitleMismatch,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingRouteContractIssueKind.featureRouteDescriptionMismatch,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingRouteContractIssueKind.featureRouteIconMismatch,
      ),
      isTrue,
    );
    expect(
      report.hasIssueKind(
        BillingRouteContractIssueKind.missingFeaturePageBuilder,
      ),
      isTrue,
    );
  });
}

FeatureRoutes _copyRoot(FeatureRoutes root, {Iterable<FeatureRoutes>? items}) {
  return FeatureRoutes(
    name: root.name,
    title: root.title,
    subtitle: root.subtitle,
    description: root.description,
    icon: root.icon,
    path: root.path,
    pageBuilder: root.pageBuilder,
    position: root.position,
    items: items?.toList(growable: false) ?? root.items,
  );
}
