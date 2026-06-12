import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_close_record_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial close record components', () {
    testWidgets('renders close record evidence pills', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialCloseRecordSummary(
              closeRecord: _closedRecord(),
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Closed Jun 30, 2026 15:30'), findsOneWidget);
      expect(find.text('By Finance Lead'), findsOneWidget);
      expect(find.text('Package ABCDEF123456'), findsOneWidget);
      expect(find.text('Closing CE-2026-06'), findsOneWidget);
    });

    testWidgets('renders package integrity warning details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportPackageIntegrityBanner(
              integrity: FinancialReportPackageIntegrity(
                status: FinancialReportPackageIntegrityStatus.changed,
                closeRecord: _closedRecord(),
                currentFingerprint: const FinancialReportPackageFingerprint(
                  algorithm: 'sha256',
                  hash: 'ffffffffffff999999999999',
                ),
              ),
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Package changed'), findsOneWidget);
      expect(
        find.textContaining('displayed report package changed'),
        findsOneWidget,
      );
      expect(
        find.text('Closed ABCDEF123456 | Current FFFFFFFFFFFF'),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
    });

    testWidgets('emits close and reopen actions when allowed', (tester) async {
      var closeCount = 0;
      var reopenCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialClosePeriodActions(
              checklist: _readyChecklist(),
              closeRecord: null,
              onClosePeriod: () => closeCount++,
              onReopenPeriod: () => reopenCount++,
              isDarkMode: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Close Period'));
      await tester.pump();

      expect(closeCount, 1);
      expect(reopenCount, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialClosePeriodActions(
              checklist: _readyChecklist(),
              closeRecord: _closedRecord(),
              onClosePeriod: () => closeCount++,
              onReopenPeriod: () => reopenCount++,
              isDarkMode: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reopen'));
      await tester.pump();

      expect(closeCount, 1);
      expect(reopenCount, 1);
    });
  });
}

FinancialPeriodCloseRecord _closedRecord() {
  return FinancialPeriodCloseRecord(
    periodKey: '2026-06',
    periodLabel: 'June 2026',
    periodStart: DateTime(2026, 6),
    periodEnd: DateTime(2026, 6, 30),
    status: FinancialPeriodCloseStatus.closed,
    closedAt: DateTime(2026, 6, 30, 15, 30),
    closedBy: 'Finance Lead',
    reopenedAt: null,
    reopenedBy: null,
    reopenReason: null,
    checklistReadinessRatio: 1,
    blockerCount: 0,
    reportGeneratedAt: DateTime(2026, 6, 30, 15),
    reportPackageHash: 'abcdef1234567890',
    reportPackageHashAlgorithm: 'sha256',
    closingEntryReference: 'CE-2026-06',
  );
}

FinancialCloseChecklist _readyChecklist() {
  return FinancialCloseChecklist(
    periodLabel: 'June 2026',
    generatedAt: DateTime(2026, 6, 30, 15),
    totalDebit: 100,
    totalCredit: 100,
    trialBalanceVariance: 0,
    items: const [
      FinancialCloseChecklistItem(
        id: 'ready',
        title: 'Ready',
        description: 'Ready to close.',
        status: FinancialCloseItemStatus.ready,
        reference: 'GL',
      ),
    ],
  );
}
