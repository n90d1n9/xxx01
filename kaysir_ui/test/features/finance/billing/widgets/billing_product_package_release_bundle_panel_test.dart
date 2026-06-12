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
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_release_bundle_panel.dart';

void main() {
  testWidgets('BillingProductPackageReleaseBundlePanel renders bundles', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductPackageReleaseBundlePanel(catalog: _standardCatalog()),
    );

    expect(find.text('Package release bundles'), findsOneWidget);
    expect(
      find.text('2 manifests can publish; 3 need review.'),
      findsOneWidget,
    );
    expect(find.text('Publish now'), findsWidgets);
    expect(find.text('Review before release'), findsOneWidget);
    expect(find.textContaining('publish_now'), findsOneWidget);
    expect(find.textContaining('review_before_release'), findsOneWidget);
    expect(find.text('Publish bundle'), findsOneWidget);
    expect(find.text('Review hardening'), findsOneWidget);
    expect(find.text('commerce_checkout:commerce'), findsOneWidget);
  });

  testWidgets('BillingProductPackageReleaseBundlePanel renders empty state', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductPackageReleaseBundlePanel(
        catalog: BillingProductPackageReleaseBundleCatalog(),
      ),
    );

    expect(find.text('Package release bundles'), findsOneWidget);
    expect(
      find.text('No package release bundles are available yet.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 1100, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

BillingProductPackageReleaseBundleCatalog _standardCatalog() {
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

  return BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
    manifestCatalog,
  );
}
