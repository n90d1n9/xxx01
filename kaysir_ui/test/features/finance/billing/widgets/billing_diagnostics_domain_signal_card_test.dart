import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_domain_signal_card.dart';

void main() {
  testWidgets('BillingDiagnosticsDomainSignalCard renders signals', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingDiagnosticsDomainSignalCard(
            title: 'Subscription health diagnostics',
            summary: 'Tracks recurring billing readiness.',
            icon: Icons.autorenew_outlined,
            accentColor: Color(0xFF2563EB),
            signals: ['Renewals', 'Entitlements'],
          ),
        ),
      ),
    );

    expect(find.text('Subscription health diagnostics'), findsOneWidget);
    expect(find.text('Tracks recurring billing readiness.'), findsOneWidget);
    expect(find.text('Renewals'), findsOneWidget);
    expect(find.text('Entitlements'), findsOneWidget);
    expect(find.byIcon(Icons.autorenew_outlined), findsOneWidget);
  });
}
