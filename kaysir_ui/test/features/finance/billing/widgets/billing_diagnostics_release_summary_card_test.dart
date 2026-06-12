import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_release_summary_card.dart';

void main() {
  testWidgets('BillingDiagnosticsReleaseSummaryCard renders blocked state', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsReleaseSummaryCard(
        summaryLabel: '3 launch tasks need attention',
        hasBlockers: true,
      ),
    );

    expect(find.text('3 launch tasks need attention'), findsOneWidget);
    expect(find.byIcon(Icons.pending_actions_outlined), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsReleaseSummaryCard renders ready state', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsReleaseSummaryCard(
        summaryLabel: 'All launch tasks are ready',
        hasBlockers: false,
      ),
    );

    expect(find.text('All launch tasks are ready'), findsOneWidget);
    expect(find.byIcon(Icons.task_alt_outlined), findsOneWidget);
  });
}

Future<void> _pumpCard(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SizedBox(width: 360, child: child))),
  );
}
