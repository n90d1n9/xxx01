import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/payable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/states/payable_reconciliation_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_reconciliation_card.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_reconciliation_detail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/reconciliation_detail_components.dart';

void main() {
  group('PayableReconciliationCard', () {
    testWidgets('shows AP reconciliation status and opens detail evidence', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            payableReconciliationProvider.overrideWithValue(_reconciliation()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: PayableReconciliationCard()),
            ),
          ),
        ),
      );

      expect(find.text('AP Reconciliation'), findsOneWidget);
      expect(find.text('Variance'), findsWidgets);
      expect(find.text('Subledger'), findsOneWidget);
      expect(find.text('GL AP'), findsOneWidget);

      await tester.tap(find.byTooltip('View reconciliation detail'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(ReconciliationDetailHeader), findsOneWidget);
      expect(find.byType(PayableReconciliationTotalsPanel), findsOneWidget);
      expect(find.text('AP Reconciliation Detail'), findsOneWidget);
      expect(find.text('Open Payable Subledger'), findsOneWidget);
      expect(find.text('Accounts Payable GL Activity'), findsOneWidget);
      expect(find.text('Nusantara Supply'), findsOneWidget);
      expect(find.text('BILL-001'), findsOneWidget);
      expect(find.text('AP-001'), findsOneWidget);
    });
  });
}

PayableReconciliation _reconciliation() {
  return PayableReconciliation(
    subledgerBalance: 2400,
    ledgerBalance: 2200,
    subledgerLines: [
      PayableSubledgerReconciliationLine(
        billId: 'bill-1',
        reference: 'BILL-001',
        vendorName: 'Nusantara Supply',
        dueDate: DateTime(2026, 1, 25),
        remainingAmount: 1400,
      ),
      PayableSubledgerReconciliationLine(
        billId: 'bill-2',
        reference: 'BILL-002',
        vendorName: 'Metro Logistics',
        dueDate: DateTime(2026, 2, 10),
        remainingAmount: 1000,
      ),
    ],
    ledgerLines: [
      PayableLedgerReconciliationLine(
        postingId: 'posting-1',
        reference: 'AP-001',
        description: 'Vendor bill posted',
        date: DateTime(2026, 1, 2),
        source: 'Payable',
        creditAmount: 2200,
      ),
    ],
  );
}
