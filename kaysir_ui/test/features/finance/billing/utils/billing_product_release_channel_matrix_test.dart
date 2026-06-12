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
  test('release channel matrix maps editions to channel readiness', () {
    final matrix = _standardMatrix();

    expect(matrix.channelCount, 5);
    expect(matrix.targetedCellCount, 14);
    expect(matrix.publishNowCellCount, 2);
    expect(matrix.reviewCellCount, 12);
    expect(matrix.blockedCellCount, 0);
    expect(
      matrix.summaryLabel,
      '2 channel releases can publish; 12 need review.',
    );

    final pos = matrix.requireRowForChannel('pos_counter');
    expect(pos.targetedCount, 2);
    expect(pos.publishNowCount, 1);
    expect(pos.reviewCount, 1);
    expect(pos.payload['channelKey'], 'pos_counter');

    final admin = matrix.requireRowForChannel('admin_back_office');
    expect(admin.targetedCount, 5);
    expect(admin.publishNowCount, 1);
    expect(admin.reviewCount, 4);
  });

  test('release channel matrix reports blocked and empty channel states', () {
    final blockedMatrix = _standardMatrix(hasTenant: false);

    expect(blockedMatrix.targetedCellCount, 14);
    expect(blockedMatrix.publishNowCellCount, 0);
    expect(blockedMatrix.blockedCellCount, 14);
    expect(
      blockedMatrix.summaryLabel,
      '14 channel releases need blockers cleared.',
    );

    final emptyMatrix = BillingProductReleaseChannelMatrix.forEditionCatalog(
      registry: BillingProductReleaseChannelRegistry(),
      editionCatalog: _standardEditionCatalog(),
    );

    expect(emptyMatrix.isEmpty, isTrue);
    expect(
      emptyMatrix.summaryLabel,
      'No billing product release channels are available.',
    );
  });
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
