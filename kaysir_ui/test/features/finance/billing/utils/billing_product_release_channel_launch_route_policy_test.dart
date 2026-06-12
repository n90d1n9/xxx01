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
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('standard channel launch route policy maps launch actions', () {
    final policy = standardBillingProductReleaseChannelLaunchRoutePolicy();
    final launchPlan = _standardLaunchPlan();

    final publishTarget = policy.targetFor(
      launchPlan.requireActionForTarget(
        channelId: 'pos_counter',
        editionId: 'commerce_essentials',
      ),
    );

    expect(
      publishTarget.destinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(publishTarget.callToActionLabel, 'Open checkout');
    expect(publishTarget.checklistItems, hasLength(3));

    final reviewTarget = policy.targetFor(
      launchPlan.requireActionForTarget(
        channelId: 'partner_api',
        editionId: 'digital_subscriptions',
      ),
    );

    expect(
      reviewTarget.destinationId,
      BillingNavigationDestinationId.issueOutbox,
    );
    expect(reviewTarget.callToActionLabel, 'Audit outbox');
    expect(reviewTarget.operatorStepLabel, contains('Review'));
  });

  test(
    'standard channel launch route policy routes blocked actions to diagnostics',
    () {
      final policy = standardBillingProductReleaseChannelLaunchRoutePolicy();
      final blockedPlan = _standardLaunchPlan(hasTenant: false);

      final blockedTarget = policy.targetFor(
        blockedPlan.requireActionForTarget(
          channelId: 'pos_counter',
          editionId: 'commerce_essentials',
        ),
      );

      expect(
        blockedTarget.destinationId,
        BillingNavigationDestinationId.diagnostics,
      );
      expect(blockedTarget.callToActionLabel, 'Open diagnostics');
      expect(blockedTarget.operatorStepLabel, contains('Clear blockers'));
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
