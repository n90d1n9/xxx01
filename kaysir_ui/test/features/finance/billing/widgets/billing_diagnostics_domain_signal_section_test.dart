import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_domain_signal_section.dart';

void main() {
  test('BillingDiagnosticsDomainSignalSection creates descriptor metadata', () {
    final section = BillingDiagnosticsDomainSignalSection(
      id: 'subscription-signal',
      priority: 180,
      title: 'Subscription health diagnostics',
      summary: 'Tracks recurring billing readiness.',
      icon: Icons.autorenew_outlined,
      accentColor: const Color(0xFF2563EB),
      signals: const [' Renewals ', '', 'Entitlements'],
    );

    final descriptor = section.toDescriptor();

    expect(descriptor.id, 'subscription-signal');
    expect(descriptor.priority, 180);
    expect(section.signals, ['Renewals', 'Entitlements']);
  });

  testWidgets('BillingDiagnosticsDomainSignalSection builds signal card', (
    tester,
  ) async {
    final section = BillingDiagnosticsDomainSignalSection(
      id: 'construction-signal',
      title: 'Construction milestone diagnostics',
      summary: 'Tracks milestone billing readiness.',
      icon: Icons.engineering_outlined,
      accentColor: const Color(0xFF0F766E),
      signals: const ['Milestones', 'Deposits'],
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: section.buildCard())),
    );

    expect(find.text('Construction milestone diagnostics'), findsOneWidget);
    expect(find.text('Tracks milestone billing readiness.'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
    expect(find.text('Deposits'), findsOneWidget);
    expect(find.byIcon(Icons.engineering_outlined), findsOneWidget);
  });

  test('BillingDiagnosticsDomainSignalSection validates required text', () {
    expect(
      () => BillingDiagnosticsDomainSignalSection(
        id: '',
        title: 'Subscription health diagnostics',
        summary: 'Tracks recurring billing readiness.',
        icon: Icons.autorenew_outlined,
        accentColor: const Color(0xFF2563EB),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => BillingDiagnosticsDomainSignalSection(
        id: 'subscription-signal',
        title: ' Subscription health diagnostics ',
        summary: 'Tracks recurring billing readiness.',
        icon: Icons.autorenew_outlined,
        accentColor: const Color(0xFF2563EB),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
