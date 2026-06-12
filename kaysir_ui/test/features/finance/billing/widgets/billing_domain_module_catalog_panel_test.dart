import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_module_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_catalog_panel.dart';

void main() {
  testWidgets('BillingDomainModuleCatalogPanel renders domain capabilities', (
    tester,
  ) async {
    final report = BillingDomainModuleRegistryReadinessReport.forRegistry(
      standardBillingDomainModuleRegistry(),
    );

    await _pumpPanel(tester, BillingDomainModuleCatalogPanel(report: report));

    expect(find.text('Domain catalog'), findsOneWidget);
    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('Construction'), findsOneWidget);
    expect(find.text('Digital subscriptions'), findsOneWidget);
    expect(find.text('Omni-channel'), findsNWidgets(2));
    expect(find.text('Progress billing'), findsOneWidget);
    expect(find.text('Recurring subscriptions'), findsOneWidget);
    expect(find.text('Line items'), findsNWidgets(3));
    expect(find.text('Screens'), findsNWidgets(3));
  });

  testWidgets('BillingDomainModuleCatalogPanel renders empty registry', (
    tester,
  ) async {
    final report = BillingDomainModuleRegistryReadinessReport.forRegistry(
      BillingBusinessDomainModuleRegistry(),
    );

    await _pumpPanel(tester, BillingDomainModuleCatalogPanel(report: report));

    expect(find.text('Domain catalog'), findsOneWidget);
    expect(
      find.text('No reusable billing domain modules are registered yet.'),
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
