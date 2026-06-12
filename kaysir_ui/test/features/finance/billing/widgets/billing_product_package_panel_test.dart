import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_panel.dart';

void main() {
  testWidgets('BillingProductPackagePanel renders package lanes', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductPackagePanel(portfolio: _standardPortfolio()),
    );

    expect(find.text('Product packages'), findsOneWidget);
    expect(
      find.text(
        '5 billing product packages are mapped with 3 hardening actions.',
      ),
      findsOneWidget,
    );
    expect(find.text('Commerce checkout'), findsOneWidget);
    expect(find.text('Project billing'), findsOneWidget);
    expect(find.text('Digital subscriptions'), findsOneWidget);
    expect(find.text('Service operations'), findsOneWidget);
    expect(find.text('Omni-channel billing'), findsOneWidget);
    expect(find.text('Package now'), findsNWidgets(2));
    expect(find.text('Harden first'), findsNWidgets(3));
    expect(find.text('Checkout'), findsWidgets);
    expect(find.text('Omni-channel'), findsWidgets);
  });

  testWidgets('BillingProductPackagePanel renders empty state', (tester) async {
    await _pumpPanel(
      tester,
      BillingProductPackagePanel(portfolio: BillingProductPackagePortfolio()),
    );

    expect(find.text('Product packages'), findsOneWidget);
    expect(
      find.text('No billing product packages are registered yet.'),
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
