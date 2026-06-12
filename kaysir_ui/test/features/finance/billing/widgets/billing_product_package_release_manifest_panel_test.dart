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
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_release_manifest_panel.dart';

void main() {
  testWidgets('BillingProductPackageReleaseManifestPanel renders manifests', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductPackageReleaseManifestPanel(catalog: _standardCatalog()),
    );

    expect(find.text('Package release manifests'), findsOneWidget);
    expect(find.text('2 manifests ready; 3 need hardening.'), findsOneWidget);
    expect(find.text('Commerce checkout'), findsOneWidget);
    expect(find.text('Project billing'), findsOneWidget);
    expect(find.text('commerce_checkout:commerce'), findsOneWidget);
    expect(find.text('Release-ready'), findsNWidgets(2));
    expect(find.text('Harden first'), findsNWidgets(3));
    expect(find.text('Ready to publish'), findsNWidgets(2));
    expect(find.text('Stage with review'), findsNWidgets(3));
  });

  testWidgets('BillingProductPackageReleaseManifestPanel renders empty state', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductPackageReleaseManifestPanel(
        catalog: BillingProductPackageReleaseManifestCatalog(),
      ),
    );

    expect(find.text('Package release manifests'), findsOneWidget);
    expect(
      find.text('No package release manifests are available yet.'),
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

BillingProductPackageReleaseManifestCatalog _standardCatalog() {
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

  return BillingProductPackageReleaseManifestCatalog.forPortfolio(
    portfolio: packagePortfolio,
    playbook: playbook,
  );
}
