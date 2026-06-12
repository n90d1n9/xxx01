import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_remediation_summary_card.dart';

void main() {
  testWidgets('BillingDiagnosticsRemediationSummaryCard renders blockers', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsRemediationSummaryCard(
        summaryLabel:
            '3 blocker actions should be cleared before pack release.',
        actionCount: 6,
        blockerActionCount: 3,
        warningActionCount: 3,
      ),
    );

    expect(
      find.text('3 blocker actions should be cleared before pack release.'),
      findsOneWidget,
    );
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Blockers'), findsOneWidget);
    expect(find.text('Hardening'), findsOneWidget);
    expect(find.byIcon(Icons.report_outlined), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsRemediationSummaryCard renders hardening', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsRemediationSummaryCard(
        summaryLabel:
            '3 hardening actions can improve billing pack release quality.',
        actionCount: 3,
        blockerActionCount: 0,
        warningActionCount: 3,
      ),
    );

    expect(
      find.text(
        '3 hardening actions can improve billing pack release quality.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsRemediationSummaryCard renders ready state', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsRemediationSummaryCard(
        summaryLabel: 'All billing packs have no remediation actions.',
        actionCount: 0,
        blockerActionCount: 0,
        warningActionCount: 0,
      ),
    );

    expect(
      find.text('All billing packs have no remediation actions.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });
}

Future<void> _pumpCard(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SizedBox(width: 440, child: child))),
  );
}
