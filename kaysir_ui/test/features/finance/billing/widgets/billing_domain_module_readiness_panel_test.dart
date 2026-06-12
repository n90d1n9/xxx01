import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_module_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_badge.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_panel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_registry_readiness_panel.dart';

void main() {
  testWidgets('BillingDomainModuleReadinessBadge renders ready state', (
    tester,
  ) async {
    final report = BillingDomainModuleReadinessReport.forModule(
      commerceBillingDomainModule(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BillingDomainModuleReadinessBadge(report: report)),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.byTooltip(report.summaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });

  testWidgets('BillingDomainModuleReadinessBadge renders warning state', (
    tester,
  ) async {
    final report = BillingDomainModuleReadinessReport.forModule(
      constructionBillingDomainModule(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BillingDomainModuleReadinessBadge(report: report)),
      ),
    );

    expect(find.text('Warnings'), findsOneWidget);
    expect(find.byTooltip(report.summaryLabel), findsOneWidget);
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);
  });

  testWidgets('BillingDomainModuleReadinessPanel renders launch-ready module', (
    tester,
  ) async {
    final report = BillingDomainModuleReadinessReport.forModule(
      commerceBillingDomainModule(),
    );

    await _pumpPanel(tester, BillingDomainModuleReadinessPanel(report: report));

    expect(find.text('Domain readiness'), findsOneWidget);
    expect(find.text('Launch-ready'), findsOneWidget);
    expect(find.text(report.summaryLabel), findsOneWidget);
    expect(find.text('Blockers'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(find.text('Reachable'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('BillingDomainModuleReadinessPanel shows blocker details', (
    tester,
  ) async {
    final report = BillingDomainModuleReadinessReport.forModule(
      commerceBillingDomainModule(),
      hasTenant: false,
    );

    await _pumpPanel(tester, BillingDomainModuleReadinessPanel(report: report));

    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Navigation coverage'), findsOneWidget);
    expect(find.textContaining('Work center'), findsOneWidget);
  });

  testWidgets('BillingDomainModuleRegistryReadinessPanel renders modules', (
    tester,
  ) async {
    final report = BillingDomainModuleRegistryReadinessReport.forRegistry(
      standardBillingDomainModuleRegistry(),
    );

    await _pumpPanel(
      tester,
      BillingDomainModuleRegistryReadinessPanel(report: report),
    );

    expect(find.text('Billing modules'), findsOneWidget);
    expect(find.text('Ready with warnings'), findsOneWidget);
    expect(find.text(report.summaryLabel), findsOneWidget);
    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('Construction'), findsOneWidget);
    expect(find.text('Digital subscriptions'), findsOneWidget);
  });
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SizedBox(width: 900, child: child))),
  );
}
