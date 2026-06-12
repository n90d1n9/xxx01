import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/trial_balance.dart';
import 'package:kaysir/features/finance/accounting/widgets/trial_balance_diagnostics_panel.dart';

void main() {
  group('TrialBalanceDiagnosticsPanel', () {
    testWidgets('opens diagnostic details for affected records', (
      tester,
    ) async {
      TrialBalanceDiagnostic? reviewedDiagnostic;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: TrialBalanceDiagnosticsPanel(
                report: _report(),
                onReviewLedger: (diagnostic) {
                  reviewedDiagnostic = diagnostic;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Review diagnostics'), findsOneWidget);
      expect(find.text('Missing references'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('trial-balance-diagnostic-details-missing-references'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey('trial-balance-diagnostic-details-missing-references'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('trial-balance-diagnostic-details-dialog')),
        findsOneWidget,
      );
      expect(find.text('Affected accounts'), findsOneWidget);
      expect(find.text('Ledger rows'), findsOneWidget);
      expect(find.text('1000 Cash'), findsOneWidget);
      expect(find.text('JE-MISSING-1'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('trial-balance-review-ledger-action')),
      );
      await tester.pumpAndSettle();

      expect(reviewedDiagnostic?.id, 'missing-references');
      expect(
        find.byKey(const ValueKey('trial-balance-diagnostic-details-dialog')),
        findsNothing,
      );
    });
  });
}

TrialBalanceReport _report() {
  return const TrialBalanceReport(
    transactions: [],
    rows: [],
    summary: TrialBalanceSummary(
      accountCount: 1,
      totalDebits: 100,
      totalCredits: 100,
      variance: 0,
      isBalanced: true,
    ),
    closeChecks: [],
    diagnostics: [
      TrialBalanceDiagnostic(
        id: 'missing-references',
        title: 'Missing references',
        message: '1 ledger row(s) need source references.',
        severity: TrialBalanceDiagnosticSeverity.warning,
        count: 1,
        affectedAccounts: ['1000 Cash'],
        affectedTransactionIds: ['JE-MISSING-1'],
      ),
    ],
  );
}
