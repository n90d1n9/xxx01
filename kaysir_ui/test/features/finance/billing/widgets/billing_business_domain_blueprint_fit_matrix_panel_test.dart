import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_business_domain_blueprint_fit_matrix_panel.dart';

void main() {
  testWidgets(
    'BillingBusinessDomainBlueprintFitMatrixPanel renders standard fit matrix',
    (tester) async {
      final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
        BillingBusinessDomainBlueprintRegistry.forRegistry(
          standardBillingDomainModuleRegistry(),
        ),
      );

      await _pumpPanel(
        tester,
        BillingBusinessDomainBlueprintFitMatrixPanel(matrix: matrix),
      );

      expect(find.text('Blueprint fit matrix'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Subscriptions'), findsOneWidget);
      expect(find.text('Service'), findsOneWidget);
      expect(find.text('Omni-channel'), findsOneWidget);
      expect(find.text('Commerce'), findsOneWidget);
      expect(find.text('Construction'), findsOneWidget);
      expect(find.text('Digital subscriptions'), findsOneWidget);
      expect(find.text('Fit'), findsNWidgets(7));
      expect(find.text('No fit'), findsNWidgets(8));
    },
  );

  testWidgets(
    'BillingBusinessDomainBlueprintFitMatrixPanel renders empty state',
    (tester) async {
      await _pumpPanel(
        tester,
        BillingBusinessDomainBlueprintFitMatrixPanel(
          matrix: BillingBusinessDomainBlueprintFitMatrix(),
        ),
      );

      expect(find.text('Blueprint fit matrix'), findsOneWidget);
      expect(
        find.text('No billing blueprint fit signals are available yet.'),
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
