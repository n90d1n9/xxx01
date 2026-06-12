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

void main() {
  test('channel launch plan turns channel matrix cells into actions', () {
    final launchPlan = _standardLaunchPlan();

    expect(launchPlan.actionCount, 14);
    expect(launchPlan.channelCount, 5);
    expect(launchPlan.publishNowCount, 2);
    expect(launchPlan.reviewCount, 12);
    expect(launchPlan.blockedCount, 0);
    expect(
      launchPlan.summaryLabel,
      '2 channel launches can publish; 12 need review.',
    );

    final publishAction = launchPlan.requireActionForTarget(
      channelId: 'pos_counter',
      editionId: 'commerce_essentials',
    );
    expect(publishAction.canPublish, isTrue);
    expect(publishAction.label, 'Publish Commerce essentials on POS counter');
    expect(publishAction.laneLabel, 'Launch now');
    expect(publishAction.payload['lane'], 'publishNow');

    final reviewAction = launchPlan.requireActionForTarget(
      channelId: 'pos_counter',
      editionId: 'omni_business',
    );
    expect(reviewAction.needsReview, isTrue);
    expect(reviewAction.label, 'Review Omni business for POS counter');
  });

  test('channel launch plan reports blocked and empty actions', () {
    final blockedPlan = _standardLaunchPlan(hasTenant: false);

    expect(blockedPlan.publishNowCount, 0);
    expect(blockedPlan.blockedCount, 14);
    expect(
      blockedPlan.summaryLabel,
      '14 channel launches need blockers cleared.',
    );
    expect(
      blockedPlan
          .requireActionForTarget(
            channelId: 'pos_counter',
            editionId: 'commerce_essentials',
          )
          .isBlocked,
      isTrue,
    );

    final emptyPlan = BillingProductReleaseChannelLaunchPlan();

    expect(emptyPlan.isEmpty, isTrue);
    expect(
      emptyPlan.summaryLabel,
      'No billing product release channel launch actions are available.',
    );
  });
}

BillingProductReleaseChannelLaunchPlan _standardLaunchPlan({
  bool hasTenant = true,
}) {
  return BillingProductReleaseChannelLaunchPlan.forMatrix(
    _standardMatrix(hasTenant: hasTenant),
  );
}

BillingProductReleaseChannelMatrix _standardMatrix({bool hasTenant = true}) {
  return BillingProductReleaseChannelMatrix.forEditionCatalog(
    registry: standardBillingProductReleaseChannelRegistry(),
    editionCatalog: _standardEditionCatalog(hasTenant: hasTenant),
  );
}

BillingProductReleaseEditionCatalog _standardEditionCatalog({
  bool hasTenant = true,
}) {
  return BillingProductReleaseEditionCatalog.forManifestCatalog(
    registry: standardBillingProductReleaseEditionRegistry(),
    manifestCatalog: _standardManifestCatalog(hasTenant: hasTenant),
  );
}

BillingProductPackageReleaseManifestCatalog _standardManifestCatalog({
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

  return BillingProductPackageReleaseManifestCatalog.forPortfolio(
    portfolio: packagePortfolio,
    playbook: playbook,
  );
}
