import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/receivable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/states/receivable_reconciliation_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/receivable_reconciliation_detail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/receivable_reconciliation_card.dart';
import 'package:kaysir/features/finance/accounting/widgets/reconciliation_detail_components.dart';

void main() {
  group('ReceivableReconciliationCard', () {
    testWidgets('shows AR reconciliation status and opens detail evidence', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receivableReconciliationProvider.overrideWithValue(
              _reconciliation(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReceivableReconciliationCard(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('AR Reconciliation'), findsOneWidget);
      expect(find.text('Variance'), findsWidgets);
      expect(find.text('Subledger'), findsOneWidget);
      expect(find.text('GL AR'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);

      await tester.tap(find.byTooltip('View reconciliation detail'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(ReconciliationDetailHeader), findsOneWidget);
      expect(find.byType(ReceivableReconciliationTotalsPanel), findsOneWidget);
      expect(find.text('AR Reconciliation Detail'), findsOneWidget);
      expect(find.text('Aging Buckets'), findsOneWidget);
      expect(find.text('Open Receivable Subledger'), findsOneWidget);
      expect(find.text('Accounts Receivable GL Activity'), findsOneWidget);
      expect(find.text('Acme Stores'), findsOneWidget);
      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('31-60'), findsOneWidget);
      expect(find.text('AR-001'), findsOneWidget);
    });
  });
}

ReceivableReconciliation _reconciliation() {
  return ReceivableReconciliation(
    subledgerBalance: 1300,
    ledgerBalance: 1200,
    subledgerLines: [
      ReceivableSubledgerReconciliationLine(
        invoiceId: 'invoice-1',
        reference: 'INV-001',
        customerName: 'Acme Stores',
        dueDate: DateTime(2026, 1, 15),
        remainingAmount: 800,
        daysPastDue: 45,
      ),
      ReceivableSubledgerReconciliationLine(
        invoiceId: 'invoice-2',
        reference: 'INV-002',
        customerName: 'Bumi Retail',
        dueDate: DateTime(2026, 2, 5),
        remainingAmount: 500,
        daysPastDue: 8,
      ),
    ],
    ledgerLines: [
      ReceivableLedgerReconciliationLine(
        postingId: 'posting-1',
        reference: 'AR-001',
        description: 'Customer invoice issued',
        date: DateTime(2026, 1, 1),
        source: 'Receivable',
        debitAmount: 1200,
      ),
    ],
    agingBuckets: const [
      ReceivableAgingBucket(
        id: ReceivableAgingBucketIds.current,
        label: 'Current',
        amount: 0,
        invoiceCount: 0,
      ),
      ReceivableAgingBucket(
        id: ReceivableAgingBucketIds.overdue1To30,
        label: '1-30',
        amount: 500,
        invoiceCount: 1,
      ),
      ReceivableAgingBucket(
        id: ReceivableAgingBucketIds.overdue31To60,
        label: '31-60',
        amount: 800,
        invoiceCount: 1,
      ),
    ],
  );
}
