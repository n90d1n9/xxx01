import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation_navigation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/domain_pack_contract_action_strip.dart';

void main() {
  testWidgets('DomainPackContractActionStrip forwards remediation navigation', (
    tester,
  ) async {
    final plan = _standardPlan();
    final action = plan.actions.first;
    BillingNavigationDestinationId? selectedDestination;

    await _pumpStrip(
      tester,
      DomainPackContractActionStrip(
        actions: plan.actions,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    await tester.tap(
      find.byKey(ValueKey('domain-pack-contract-open-${action.id}')),
    );
    await tester.pump();

    expect(
      selectedDestination,
      billingBusinessDomainPackRemediationNavigationTargetFor(
        action,
      ).destinationId,
    );
    expect(find.text('Open products (2)'), findsOneWidget);
    expect(find.text('Open diagnostics (2)'), findsOneWidget);
  });

  testWidgets('DomainPackContractActionStrip hides overflow actions', (
    tester,
  ) async {
    final plan = _standardPlan();

    await _pumpStrip(
      tester,
      DomainPackContractActionStrip(
        actions: plan.actions,
        maxVisibleActions: 1,
        onDestinationSelected: (_) {},
      ),
    );

    expect(
      find.byKey(
        ValueKey('domain-pack-contract-open-${plan.actions.first.id}'),
      ),
      findsOneWidget,
    );
    expect(find.text('+2 more actions'), findsOneWidget);
    expect(find.text('Open diagnostics (2)'), findsNothing);
  });

  testWidgets('DomainPackContractActionStrip hides without callback', (
    tester,
  ) async {
    await _pumpStrip(
      tester,
      DomainPackContractActionStrip(actions: _standardPlan().actions),
    );

    expect(find.byType(TextButton), findsNothing);
  });
}

BillingBusinessDomainPackRegistryRemediationPlan _standardPlan() {
  final readiness =
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      );

  return BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
    readiness,
  );
}

Future<void> _pumpStrip(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 640, child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
