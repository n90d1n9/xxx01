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
import 'package:kaysir/features/finance/billing/utils/billing_product_release_edition.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_edition_panel.dart';

void main() {
  testWidgets('BillingProductReleaseEditionPanel renders editions', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductReleaseEditionPanel(catalog: _standardCatalog()),
    );

    expect(find.text('Product release editions'), findsOneWidget);
    expect(find.text('1 edition can publish; 4 need review.'), findsOneWidget);
    expect(find.text('Commerce essentials'), findsOneWidget);
    expect(find.text('Digital subscriptions'), findsOneWidget);
    expect(find.text('Publish edition'), findsOneWidget);
    expect(find.text('Review hardening'), findsWidgets);
    expect(find.text('Core packages'), findsWidgets);
    expect(find.text('Add-ons'), findsWidgets);
    expect(find.text('commerce_checkout:commerce'), findsWidgets);
    expect(find.text('omni_channel_billing:commerce'), findsWidgets);
  });

  testWidgets('BillingProductReleaseEditionPanel renders empty state', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductReleaseEditionPanel(
        catalog: BillingProductReleaseEditionCatalog(),
      ),
    );

    expect(find.text('Product release editions'), findsOneWidget);
    expect(
      find.text('No product release editions are available yet.'),
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

BillingProductReleaseEditionCatalog _standardCatalog() {
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
