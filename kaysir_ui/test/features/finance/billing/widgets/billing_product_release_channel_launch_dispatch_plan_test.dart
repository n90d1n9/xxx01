import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_release_channel.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_release_edition.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_snapshot.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_status.dart';

void main() {
  test(
    'channel launch dispatch plan reconciles actions with navigation routes',
    () {
      final dispatchPlan =
          BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
            launchPlan: _standardLaunchPlan(),
            dispatchSnapshot: _commerceDispatchSnapshot(hasTenant: true),
          );

      expect(dispatchPlan.entryCount, 14);
      expect(dispatchPlan.actionableCount, 14);
      expect(dispatchPlan.unavailableCount, 0);
      expect(dispatchPlan.routeCount, 2);
      expect(dispatchPlan.localCount, 12);
      expect(dispatchPlan.summary.totalCount, 14);
      expect(dispatchPlan.summary.actionableCount, 14);
      expect(dispatchPlan.summary.blockedCount, 0);
      expect(dispatchPlan.summary.routeCount, dispatchPlan.routeCount);
      expect(dispatchPlan.summary.localCount, dispatchPlan.localCount);
      expect(dispatchPlan.summary.isFullyActionable, isTrue);
      expect(dispatchPlan.summaryLabel, '14 channel routes ready to open.');
      expect(dispatchPlan.payload['blockedCount'], 0);

      final checkoutEntry = dispatchPlan.requireEntryForTarget(
        channelId: 'pos_counter',
        editionId: 'commerce_essentials',
      );

      expect(checkoutEntry.isActionable, isTrue);
      expect(
        checkoutEntry.destinationId,
        BillingNavigationDestinationId.cartCheckout,
      );
      expect(checkoutEntry.destinationLabel, 'Cart & checkout');
      expect(
        checkoutEntry.status,
        BillingProductReleaseChannelLaunchDispatchStatus.route,
      );
      expect(checkoutEntry.statusLabel, 'Route');
      expect(checkoutEntry.payload['status'], 'route');
      expect(checkoutEntry.callToActionLabel, 'Open checkout');
    },
  );

  test(
    'channel launch dispatch plan keeps release blockers non-actionable',
    () {
      final dispatchPlan =
          BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
            launchPlan: _standardLaunchPlan(hasTenant: false),
            dispatchSnapshot: _commerceDispatchSnapshot(hasTenant: false),
          );

      expect(dispatchPlan.entryCount, 14);
      expect(dispatchPlan.actionableCount, 0);
      expect(dispatchPlan.unavailableCount, 14);
      expect(dispatchPlan.summary.totalCount, 14);
      expect(dispatchPlan.summary.actionableCount, 0);
      expect(dispatchPlan.summary.blockedCount, 14);
      expect(dispatchPlan.summary.routeCount, dispatchPlan.routeCount);
      expect(dispatchPlan.summary.localCount, dispatchPlan.localCount);
      expect(dispatchPlan.summary.hasBlockedRoutes, isTrue);
      expect(
        dispatchPlan.summaryLabel,
        '14 channel routes need routing or readiness work.',
      );
      expect(dispatchPlan.payload['blockedCount'], 14);

      final blockedEntry = dispatchPlan.requireEntryForTarget(
        channelId: 'pos_counter',
        editionId: 'commerce_essentials',
      );

      expect(blockedEntry.isBlockedByRelease, isTrue);
      expect(blockedEntry.isActionable, isFalse);
      expect(
        blockedEntry.status,
        BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease,
      );
      expect(
        blockedEntry.destinationId,
        BillingNavigationDestinationId.diagnostics,
      );
      expect(blockedEntry.statusLabel, 'Blocked');
      expect(blockedEntry.payload['status'], 'blockedByRelease');
    },
  );
}

BillingProductReleaseChannelLaunchPlan _standardLaunchPlan({
  bool hasTenant = true,
}) {
  return BillingProductReleaseChannelLaunchPlan.forMatrix(
    BillingProductReleaseChannelMatrix.forEditionCatalog(
      registry: standardBillingProductReleaseChannelRegistry(),
      editionCatalog: _standardEditionCatalog(hasTenant: hasTenant),
    ),
  );
}

BillingProductReleaseEditionCatalog _standardEditionCatalog({
  bool hasTenant = true,
}) {
  final blueprintRegistry = BillingBusinessDomainBlueprintRegistry.forRegistry(
    standardBillingDomainModuleRegistry(),
    hasTenant: hasTenant,
  );
  final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    blueprintRegistry,
  );
  final launchPortfolio =
      BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(matrix);
  final packagePortfolio = BillingProductPackagePortfolio.forLaunchPortfolio(
    registry: standardBillingProductPackageRegistry(),
    launchPortfolio: launchPortfolio,
    columns: matrix.columns,
  );
  final playbook = BillingProductPackageLaunchPlaybook.forPortfolio(
    packagePortfolio,
  );
  final manifestCatalog =
      BillingProductPackageReleaseManifestCatalog.forPortfolio(
        portfolio: packagePortfolio,
        playbook: playbook,
      );

  return BillingProductReleaseEditionCatalog.forManifestCatalog(
    registry: standardBillingProductReleaseEditionRegistry(),
    manifestCatalog: manifestCatalog,
  );
}

BillingNavigationDispatchSnapshot _commerceDispatchSnapshot({
  required bool hasTenant,
}) {
  return BillingNavigationLaunchPlanner(
    hasTenant: hasTenant,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  ).destinationDispatchSnapshot(
    currentSurface: BillingNavigationSurface.dashboard,
  );
}
