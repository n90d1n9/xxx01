import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_business_domain_blueprint_panel.dart';

void main() {
  testWidgets('BillingBusinessDomainBlueprintPanel renders product modes', (
    tester,
  ) async {
    final registry = BillingBusinessDomainBlueprintRegistry.forRegistry(
      standardBillingDomainModuleRegistry(),
    );

    await _pumpPanel(
      tester,
      BillingBusinessDomainBlueprintPanel(registry: registry),
    );

    expect(find.text('Product blueprints'), findsOneWidget);
    expect(find.text('Checkout-led commerce'), findsOneWidget);
    expect(find.text('Project billing'), findsOneWidget);
    expect(find.text('Subscription billing'), findsOneWidget);
    expect(find.text('Omni-channel ready'), findsNWidgets(2));
    expect(find.text('Single-channel ready'), findsOneWidget);
    expect(find.text('Default route'), findsNWidgets(3));
    expect(find.text('Line item source'), findsNWidgets(3));
    expect(find.text('Issue policy'), findsNWidgets(3));
    expect(find.text('Warnings'), findsWidgets);
  });

  testWidgets('BillingBusinessDomainBlueprintPanel renders empty registry', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingBusinessDomainBlueprintPanel(
        registry: BillingBusinessDomainBlueprintRegistry(),
      ),
    );

    expect(find.text('Product blueprints'), findsOneWidget);
    expect(
      find.text('No billing product blueprints are registered yet.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 1100, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
