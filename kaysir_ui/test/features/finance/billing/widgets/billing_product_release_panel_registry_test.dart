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
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_panel_registry.dart';

void main() {
  test('standard product release panel registry keeps release order', () {
    final registry = standardBillingProductReleasePanelRegistry();

    expect(registry.descriptorIds, [
      billingProductReleaseEditionPanelId,
      billingProductReleaseChannelMatrixPanelId,
    ]);
  });

  test(
    'standard product release panel registry resolves source-specific panels',
    () {
      final registry = standardBillingProductReleasePanelRegistry();

      expect(
        registry
            .descriptorsForSource(_standardEditionCatalog())
            .map((descriptor) => descriptor.id),
        [billingProductReleaseEditionPanelId],
      );
      expect(
        registry
            .descriptorsForSource(_standardMatrix())
            .map((descriptor) => descriptor.id),
        [billingProductReleaseChannelMatrixPanelId],
      );
    },
  );

  testWidgets('product release panel registry builds channel matrix panel', (
    tester,
  ) async {
    final registry = standardBillingProductReleasePanelRegistry();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            child: SingleChildScrollView(
              child: registry.build(
                billingProductReleaseChannelMatrixPanelId,
                _standardMatrix(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Edition channel matrix'), findsOneWidget);
    expect(
      find.text('2 channel releases can publish; 12 need review.'),
      findsOneWidget,
    );
    expect(find.text('POS counter'), findsOneWidget);
    expect(find.text('Admin back office'), findsOneWidget);
  });

  testWidgets('product release panel registry builds empty edition panel', (
    tester,
  ) async {
    final registry = standardBillingProductReleasePanelRegistry();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: registry.build(
              billingProductReleaseEditionPanelId,
              BillingProductReleaseEditionCatalog(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product release editions'), findsOneWidget);
    expect(
      find.text('No product release editions are available yet.'),
      findsOneWidget,
    );
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
