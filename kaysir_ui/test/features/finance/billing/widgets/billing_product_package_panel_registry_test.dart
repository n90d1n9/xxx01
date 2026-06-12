import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_bundle.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_manifest.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_panel_registry.dart';

void main() {
  test('standard product package panel registry keeps workflow order', () {
    final registry = standardBillingProductPackagePanelRegistry();

    expect(registry.descriptorIds, [
      billingProductPackagePortfolioPanelId,
      billingProductPackageReleaseManifestPanelId,
      billingProductPackageReleaseBundlePanelId,
      billingProductPackageLaunchPlaybookPanelId,
    ]);
  });

  test(
    'standard product package panel registry resolves source-specific panels',
    () {
      final registry = standardBillingProductPackagePanelRegistry();

      expect(
        registry
            .descriptorsForSource(_standardPortfolio())
            .map((descriptor) => descriptor.id),
        [billingProductPackagePortfolioPanelId],
      );
      expect(
        registry
            .descriptorsForSource(_standardManifestCatalog())
            .map((descriptor) => descriptor.id),
        [billingProductPackageReleaseManifestPanelId],
      );
      expect(
        registry
            .descriptorsForSource(_standardBundleCatalog())
            .map((descriptor) => descriptor.id),
        [billingProductPackageReleaseBundlePanelId],
      );
      expect(
        registry
            .descriptorsForSource(_standardPlaybook())
            .map((descriptor) => descriptor.id),
        [billingProductPackageLaunchPlaybookPanelId],
      );
    },
  );

  testWidgets('product package panel registry builds portfolio panel', (
    tester,
  ) async {
    final registry = standardBillingProductPackagePanelRegistry();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            child: SingleChildScrollView(
              child: registry.build(
                billingProductPackagePortfolioPanelId,
                _standardPortfolio(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product packages'), findsOneWidget);
    expect(
      find.text(
        '5 billing product packages are mapped with 3 hardening actions.',
      ),
      findsOneWidget,
    );
    expect(find.text('Packages'), findsOneWidget);
    expect(find.text('Commerce checkout'), findsOneWidget);
  });

  testWidgets('product package panel registry builds empty playbook panel', (
    tester,
  ) async {
    final registry = standardBillingProductPackagePanelRegistry();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: registry.build(
              billingProductPackageLaunchPlaybookPanelId,
              BillingProductPackageLaunchPlaybook(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Package launch playbook'), findsOneWidget);
    expect(
      find.text('No package launch actions are available yet.'),
      findsOneWidget,
    );
  });
}

BillingProductPackagePortfolio _standardPortfolio() {
  final blueprintRegistry = BillingBusinessDomainBlueprintRegistry.forRegistry(
    standardBillingDomainModuleRegistry(),
  );
  final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    blueprintRegistry,
  );
  final launchPortfolio =
      BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(matrix);

  return BillingProductPackagePortfolio.forLaunchPortfolio(
    registry: standardBillingProductPackageRegistry(),
    launchPortfolio: launchPortfolio,
    columns: matrix.columns,
  );
}

BillingProductPackageLaunchPlaybook _standardPlaybook() {
  return BillingProductPackageLaunchPlaybook.forPortfolio(_standardPortfolio());
}

BillingProductPackageReleaseManifestCatalog _standardManifestCatalog() {
  return BillingProductPackageReleaseManifestCatalog.forPortfolio(
    portfolio: _standardPortfolio(),
    playbook: _standardPlaybook(),
  );
}

BillingProductPackageReleaseBundleCatalog _standardBundleCatalog() {
  return BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
    _standardManifestCatalog(),
  );
}
