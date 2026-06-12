import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_domain_context_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation_navigation.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_domain_section.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  testWidgets(
    'BillingDiagnosticsDomainSection renders domain readiness chain',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final context = container.read(
        billingDiagnosticsDomainContextProvider(true),
      );

      await _pumpSection(
        tester,
        BillingDiagnosticsDomainSection(context: context),
      );

      expect(find.text('Billing modules'), findsOneWidget);
      expect(find.text('Business domain packs'), findsOneWidget);
      expect(find.text('Domain-pack contracts'), findsOneWidget);
      expect(find.text('Pack remediation plan'), findsOneWidget);
      expect(find.text('Domain catalog'), findsOneWidget);
      expect(find.text('Product blueprints'), findsOneWidget);
      expect(find.text('Blueprint fit matrix'), findsOneWidget);
      expect(find.text('Product launch plan'), findsOneWidget);
      expect(find.text('Commerce'), findsWidgets);
      expect(find.text('Construction'), findsWidgets);
      expect(find.text('Digital subscriptions'), findsWidgets);
    },
  );

  testWidgets('BillingDiagnosticsDomainSection forwards remediation actions', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = container.read(
      billingDiagnosticsDomainContextProvider(true),
    );
    BillingNavigationDestinationId? selectedDestination;

    await _pumpSection(
      tester,
      BillingDiagnosticsDomainSection(
        context: context,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    final openProducts = find.byKey(
      const ValueKey(
        'billing-pack-remediation-open-construction:module:missingLineItemAdapter:0',
      ),
    );
    await tester.ensureVisible(openProducts);
    await tester.pump();
    await tester.tap(openProducts);
    await tester.pump();

    expect(
      selectedDestination,
      BillingNavigationDestinationId.productWorkspace,
    );
  });

  testWidgets(
    'BillingDiagnosticsDomainSection forwards contract coverage actions',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final context = container.read(
        billingDiagnosticsDomainContextProvider(true),
      );
      final action = context.packRemediationPlan.actions.first;
      BillingNavigationDestinationId? selectedDestination;

      await _pumpSection(
        tester,
        BillingDiagnosticsDomainSection(
          context: context,
          onDestinationSelected: (destination) {
            selectedDestination = destination;
          },
        ),
      );

      final openContractAction = find.byKey(
        ValueKey('domain-pack-contract-open-${action.id}'),
      );
      await tester.ensureVisible(openContractAction);
      await tester.pump();
      await tester.tap(openContractAction);
      await tester.pump();

      expect(
        selectedDestination,
        billingBusinessDomainPackRemediationNavigationTargetFor(
          action,
        ).destinationId,
      );
    },
  );
}

Future<void> _pumpSection(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 1100, child: child)),
      ),
    ),
  );
}
