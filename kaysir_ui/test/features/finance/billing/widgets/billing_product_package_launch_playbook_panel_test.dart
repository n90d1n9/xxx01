import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_launch_playbook_panel.dart';

void main() {
  testWidgets('BillingProductPackageLaunchPlaybookPanel renders actions', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductPackageLaunchPlaybookPanel(playbook: _standardPlaybook()),
    );

    expect(find.text('Package launch playbook'), findsOneWidget);
    expect(
      find.text('2 packages can launch now; 3 need hardening.'),
      findsOneWidget,
    );
    expect(find.text('Package Commerce checkout'), findsOneWidget);
    expect(find.text('Package Omni-channel billing'), findsOneWidget);
    expect(find.text('Harden Construction'), findsWidgets);
    expect(find.text('Launch now'), findsNWidgets(2));
    expect(find.text('Harden'), findsWidgets);
  });

  testWidgets('BillingProductPackageLaunchPlaybookPanel renders empty state', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingProductPackageLaunchPlaybookPanel(
        playbook: BillingProductPackageLaunchPlaybook(),
      ),
    );

    expect(find.text('Package launch playbook'), findsOneWidget);
    expect(
      find.text('No package launch actions are available yet.'),
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

BillingProductPackageLaunchPlaybook _standardPlaybook() {
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

  return BillingProductPackageLaunchPlaybook.forPortfolio(packagePortfolio);
}
