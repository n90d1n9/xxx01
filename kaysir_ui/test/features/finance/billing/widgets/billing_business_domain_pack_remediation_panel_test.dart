import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_business_domain_pack_remediation_panel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  testWidgets('BillingBusinessDomainPackRemediationPanel renders warnings', (
    tester,
  ) async {
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      ),
    );

    await _pumpPanel(
      tester,
      BillingBusinessDomainPackRemediationPanel(plan: plan),
    );

    expect(find.text('Pack remediation plan'), findsOneWidget);
    expect(find.text('Hardening recommended'), findsOneWidget);
    expect(find.text(plan.summaryLabel), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Domains'), findsOneWidget);
    expect(find.text('Add Construction line item adapter'), findsOneWidget);
    expect(find.text('Register Commerce diagnostics profile'), findsOneWidget);
    expect(find.text('Warning'), findsWidgets);
  });

  testWidgets(
    'BillingBusinessDomainPackRemediationPanel dispatches action destinations',
    (tester) async {
      final plan =
          BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
            BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
              standardBillingDomainPackRegistry(),
            ),
          );
      BillingNavigationDestinationId? selectedDestination;

      await _pumpPanel(
        tester,
        BillingBusinessDomainPackRemediationPanel(
          plan: plan,
          onDestinationSelected: (destination) {
            selectedDestination = destination;
          },
        ),
      );

      await tester.tap(find.text('Open products').first);
      await tester.pump();

      expect(
        selectedDestination,
        BillingNavigationDestinationId.productWorkspace,
      );
    },
  );

  testWidgets('BillingBusinessDomainPackRemediationPanel renders blockers', (
    tester,
  ) async {
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
        hasTenant: false,
      ),
    );

    await _pumpPanel(
      tester,
      BillingBusinessDomainPackRemediationPanel(plan: plan),
    );

    expect(find.text('Clear blockers first'), findsOneWidget);
    expect(find.text(plan.summaryLabel), findsOneWidget);
    expect(find.text('Restore Commerce navigation coverage'), findsOneWidget);
    expect(find.text('Blocker'), findsWidgets);
    expect(find.byIcon(Icons.report_outlined), findsOneWidget);
  });

  testWidgets('BillingBusinessDomainPackRemediationPanel renders empty plan', (
    tester,
  ) async {
    final plan = BillingBusinessDomainPackRegistryRemediationPlan(
      packPlans: const [],
    );

    await _pumpPanel(
      tester,
      BillingBusinessDomainPackRemediationPanel(plan: plan),
    );

    expect(find.text('No actions required'), findsOneWidget);
    expect(
      find.text('No pack remediation actions are required.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
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
