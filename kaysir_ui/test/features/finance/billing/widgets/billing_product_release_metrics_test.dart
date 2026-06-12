import 'package:flutter/material.dart';
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
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_matrix_metrics.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_edition_metrics.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_metric_provider_registry.dart';

void main() {
  test('release edition metrics summarize edition catalog readiness', () {
    final metrics = BillingProductReleaseEditionMetrics.fromCatalog(
      _standardEditionCatalog(),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Editions')?.value, '5');
    expect(metrics.metricForLabel('Publish')?.value, '1');
    expect(metrics.metricForLabel('Review')?.value, '4');
    expect(metrics.metricForLabel('Blocked')?.value, '0');
    expect(
      metrics.metricForLabel('Editions')?.icon,
      Icons.view_carousel_outlined,
    );
  });

  test('release channel matrix metrics summarize channel readiness', () {
    final metrics = BillingProductReleaseChannelMatrixMetrics.fromMatrix(
      _standardMatrix(),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Channels')?.value, '5');
    expect(metrics.metricForLabel('Publish')?.value, '2');
    expect(metrics.metricForLabel('Review')?.value, '12');
    expect(metrics.metricForLabel('Blocked')?.value, '0');
    expect(metrics.metricForLabel('Channels')?.icon, Icons.hub_outlined);
  });

  test('release metric provider registry resolves release sources', () {
    final registry = standardBillingProductReleaseMetricProviderRegistry();

    expect(registry.providerIds, [
      billingProductReleaseEditionMetricProviderId,
      billingProductReleaseChannelMatrixMetricProviderId,
    ]);
    expect(
      registry
          .resolve(
            billingProductReleaseEditionMetricProviderId,
            _standardEditionCatalog(),
          )
          .metricForLabel('Publish')
          ?.value,
      '1',
    );
    expect(
      registry
          .resolve(
            billingProductReleaseChannelMatrixMetricProviderId,
            _standardMatrix(),
          )
          .metricForLabel('Review')
          ?.value,
      '12',
    );
  });

  test('release metrics keep empty sources measurable', () {
    final editionMetrics = BillingProductReleaseEditionMetrics.fromCatalog(
      BillingProductReleaseEditionCatalog(),
    );
    final matrixMetrics = BillingProductReleaseChannelMatrixMetrics.fromMatrix(
      BillingProductReleaseChannelMatrix(),
    );

    expect(editionMetrics.metricForLabel('Editions')?.value, '0');
    expect(editionMetrics.metricForLabel('Publish')?.value, '0');
    expect(matrixMetrics.metricForLabel('Channels')?.value, '0');
    expect(matrixMetrics.metricForLabel('Blocked')?.value, '0');
  });
}

BillingProductReleaseChannelMatrix _standardMatrix() {
  return BillingProductReleaseChannelMatrix.forEditionCatalog(
    registry: standardBillingProductReleaseChannelRegistry(),
    editionCatalog: _standardEditionCatalog(),
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
