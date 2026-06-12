import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/payable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_reconciliation_detail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/reconciliation_detail_components.dart';

void main() {
  group('payable reconciliation detail components', () {
    testWidgets('render AP summary and evidence tables', (tester) async {
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
                      title: 'AP Reconciliation Detail',
                      subtitle: 'Vendor bills versus AP ledger activity.',
                      icon: Icons.fact_check_outlined,
                      statusLabel: 'Variance',
                      statusColor: Colors.deepOrange,
                      statusIcon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: 12),
                    PayableReconciliationTotalsPanel(
                      reconciliation: reconciliation,
                      currency: currency,
                    ),
                    const SizedBox(height: 12),
                    PayableSubledgerReconciliationTable(
                      lines: reconciliation.subledgerLines,
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                    const SizedBox(height: 12),
                    PayableLedgerReconciliationTable(
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
      expect(find.text('AP Reconciliation Detail'), findsOneWidget);
      expect(find.text('\$2,400.00'), findsWidgets);
      expect(find.text('Nusantara Supply'), findsOneWidget);
      expect(find.text('BILL-001'), findsOneWidget);
      expect(find.text('AP-001'), findsOneWidget);
    });

    testWidgets('show empty states for missing AP evidence', (tester) async {
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
                    PayableSubledgerReconciliationTable(
                      lines: const [],
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                    const SizedBox(height: 12),
                    PayableLedgerReconciliationTable(
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

      expect(find.byType(ReconciliationEmptyState), findsNWidgets(2));
      expect(find.text('No open payable bills'), findsOneWidget);
      expect(find.text('No AP ledger activity posted'), findsOneWidget);
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
