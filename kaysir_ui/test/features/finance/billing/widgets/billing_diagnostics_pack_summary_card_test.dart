import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_pack_summary_card.dart';

void main() {
  testWidgets('BillingDiagnosticsPackSummaryCard renders blocked state', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsPackSummaryCard(
        summaryLabel: '2 of 3 billing packs need attention.',
        packCount: 3,
        blockerCount: 2,
        warningCount: 4,
      ),
    );

    expect(find.text('2 of 3 billing packs need attention.'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Packs'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Blockers'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsPackSummaryCard renders warning state', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsPackSummaryCard(
        summaryLabel: '3 billing packs are release-ready with 3 warnings.',
        packCount: 3,
        blockerCount: 0,
        warningCount: 3,
      ),
    );

    expect(
      find.text('3 billing packs are release-ready with 3 warnings.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);
  });

  testWidgets('BillingDiagnosticsPackSummaryCard renders ready state', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      const BillingDiagnosticsPackSummaryCard(
        summaryLabel: '3 billing packs are release-ready.',
        packCount: 3,
        blockerCount: 0,
        warningCount: 0,
      ),
    );

    expect(find.text('3 billing packs are release-ready.'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });
}

Future<void> _pumpCard(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SizedBox(width: 420, child: child))),
  );
}
