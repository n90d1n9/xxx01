import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/receivable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/widgets/receivable_reconciliation_detail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/reconciliation_detail_components.dart';

void main() {
  group('receivable reconciliation detail components', () {
    testWidgets('render summary, aging, and evidence tables', (tester) async {
      final reconciliation = _reconciliation();
      final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
      final dateFormat = DateFormat('MM/dd/yyyy');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ReconciliationDetailHeader(
                      title: 'AR Reconciliation Detail',
                      subtitle: 'Customer invoices versus AR ledger activity.',
                      icon: Icons.fact_check_outlined,
                      statusLabel: 'Variance',
                      statusColor: Colors.deepOrange,
                      statusIcon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: 12),
                    ReceivableReconciliationTotalsPanel(
                      reconciliation: reconciliation,
                      currency: currency,
                    ),
                    const SizedBox(height: 12),
                    ReconciliationSectionHeader(
                      title: 'Aging Buckets',
                      amount: reconciliation.overdueBalance,
                      amountLabel: 'Overdue',
                      currency: currency,
                    ),
                    const SizedBox(height: 8),
                    ReceivableAgingBucketStrip(
                      buckets: reconciliation.agingBuckets,
                      currency: currency,
                    ),
                    const SizedBox(height: 12),
                    ReceivableSubledgerReconciliationTable(
                      lines: reconciliation.subledgerLines,
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                    const SizedBox(height: 12),
                    ReceivableLedgerReconciliationTable(
                      lines: reconciliation.ledgerLines,
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ReconciliationDetailHeader), findsOneWidget);
      expect(find.byType(ReconciliationMetricStrip), findsOneWidget);
      expect(find.byType(ReconciliationTableShell), findsNWidgets(2));
      expect(find.byType(DataTable), findsNWidgets(2));
      expect(find.text('AR Reconciliation Detail'), findsOneWidget);
      expect(find.text('\$1,300.00'), findsWidgets);
      expect(find.text('31-60'), findsOneWidget);
      expect(find.text('Acme Stores'), findsOneWidget);
      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('AR-001'), findsOneWidget);
    });

    testWidgets('show compact empty states for missing evidence', (
      tester,
    ) async {
      final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
      final dateFormat = DateFormat('MM/dd/yyyy');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReceivableAgingBucketStrip(
                      buckets: const [],
                      currency: currency,
                    ),
                    const SizedBox(height: 12),
                    ReceivableSubledgerReconciliationTable(
                      lines: const [],
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                    const SizedBox(height: 12),
                    ReceivableLedgerReconciliationTable(
                      lines: const [],
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ReconciliationEmptyState), findsNWidgets(3));
      expect(find.text('No receivable aging buckets'), findsOneWidget);
      expect(find.text('No open customer invoices'), findsOneWidget);
      expect(find.text('No AR ledger activity posted'), findsOneWidget);
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
