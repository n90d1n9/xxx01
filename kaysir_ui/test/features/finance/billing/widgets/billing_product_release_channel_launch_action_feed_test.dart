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
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_action_feed.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_status.dart';

void main() {
  test('launch action feed pairs actions with dispatch entries', () {
    final launchPlan = _standardLaunchPlan();
    final feed = BillingProductReleaseChannelLaunchActionFeed.fromPlan(
      launchPlan: launchPlan,
      dispatchPlan: _dispatchPlan(launchPlan),
    );

    expect(feed.itemCount, 14);
    expect(feed.actionableCount, 14);
    expect(feed.missingDispatchCount, 0);
    expect(
      feed.itemsForLane(BillingProductReleaseChannelLaunchLane.publishNow),
      hasLength(2),
    );
    expect(
      feed.itemsForDispatchStatus(
        BillingProductReleaseChannelLaunchDispatchStatus.route,
      ),
      hasLength(2),
    );

    final checkoutItems = feed.itemsForDestination(
      BillingNavigationDestinationId.cartCheckout,
    );

    expect(checkoutItems, hasLength(1));
    expect(
      checkoutItems.single.dispatchEntry?.callToActionLabel,
      'Open checkout',
    );
    expect(feed.search('checkout'), hasLength(2));
    expect(feed.search('checkout'), contains(checkoutItems.single));
  });

  test('launch action feed supports actions before dispatch is attached', () {
    final launchPlan = _standardLaunchPlan();
    final feed = BillingProductReleaseChannelLaunchActionFeed.fromPlan(
      launchPlan: launchPlan,
    );

    expect(feed.itemCount, 14);
    expect(feed.actionableCount, 0);
    expect(feed.missingDispatchCount, 14);
    expect(
      feed.itemsForDispatchStatus(
        BillingProductReleaseChannelLaunchDispatchStatus.route,
      ),
      isEmpty,
    );
    expect(feed.itemsForChannel('pos_counter'), hasLength(2));
    expect(feed.itemsForEdition('commerce_essentials'), hasLength(2));
    expect(feed.search('omni business'), isNotEmpty);
  });
}

BillingProductReleaseChannelLaunchPlan _standardLaunchPlan() {
  return BillingProductReleaseChannelLaunchPlan.forMatrix(
    BillingProductReleaseChannelMatrix.forEditionCatalog(
      registry: standardBillingProductReleaseChannelRegistry(),
      editionCatalog: _standardEditionCatalog(),
    ),
  );
}

BillingProductReleaseChannelLaunchDispatchPlan _dispatchPlan(
  BillingProductReleaseChannelLaunchPlan launchPlan,
) {
  final dispatchSnapshot = BillingNavigationLaunchPlanner(
    hasTenant: true,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  ).destinationDispatchSnapshot(
    currentSurface: BillingNavigationSurface.dashboard,
  );

  return BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan(
    launchPlan: launchPlan,
    dispatchSnapshot: dispatchSnapshot,
  );
}

BillingProductReleaseEditionCatalog _standardEditionCatalog() {
  final blueprintRegistry = BillingBusinessDomainBlueprintRegistry.forRegistry(
    standardBillingDomainModuleRegistry(),
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
