import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_business_domain_blueprint_launch_plan_panel.dart';

void main() {
  testWidgets(
    'BillingBusinessDomainBlueprintLaunchPlanPanel renders launch lanes',
    (tester) async {
      final registry = BillingBusinessDomainBlueprintRegistry.forRegistry(
        standardBillingDomainModuleRegistry(),
      );
      final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
        registry,
      );
      final portfolio =
          BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(matrix);

      await _pumpPanel(
        tester,
        BillingBusinessDomainBlueprintLaunchPlanPanel(portfolio: portfolio),
      );

      expect(find.text('Product launch plan'), findsOneWidget);
      expect(
        find.text(
          '2 of 3 billing product domains need hardening before packaging.',
        ),
        findsOneWidget,
      );
      expect(find.text('Package now'), findsOneWidget);
      expect(find.text('Harden first'), findsNWidgets(2));
      expect(find.text('Commerce'), findsOneWidget);
      expect(find.text('Construction'), findsOneWidget);
      expect(find.text('Digital subscriptions'), findsOneWidget);
      expect(find.text('Package checkout-led commerce'), findsOneWidget);
      expect(find.text('Harden warning'), findsNWidgets(2));
      expect(find.text('Checkout'), findsWidgets);
      expect(find.text('Omni-channel'), findsWidgets);
    },
  );

  testWidgets(
    'BillingBusinessDomainBlueprintLaunchPlanPanel renders empty state',
    (tester) async {
      await _pumpPanel(
        tester,
        BillingBusinessDomainBlueprintLaunchPlanPanel(
          portfolio: BillingBusinessDomainBlueprintLaunchPortfolio(),
        ),
      );

      expect(find.text('Product launch plan'), findsOneWidget);
      expect(
        find.text('No billing product launch plans are available yet.'),
        findsOneWidget,
      );
    },
  );
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
