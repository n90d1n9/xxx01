import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/vendor.dart';
import 'package:kaysir/features/finance/accounting/models/vendor_statement.dart';
import 'package:kaysir/features/finance/accounting/widgets/vendor_statement_components.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('vendor statement summary and lines use reusable UI widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final currency = NumberFormat.simpleCurrency(decimalDigits: 2);
    final statement = _sampleStatement();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 640,
            child: Column(
              children: [
                VendorStatementSummaryGrid(
                  statement: statement,
                  currency: currency,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: VendorStatementLineList(
                    statement: statement,
                    currency: currency,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
    expect(find.text(r'$750.00'), findsNWidgets(2));
    expect(find.text('Open Bills'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsNWidgets(2));
    expect(find.text('Bill'), findsOneWidget);
    expect(find.text('Payment'), findsWidgets);
    expect(find.text('BILL-001'), findsOneWidget);
    expect(find.text('PAY-001'), findsOneWidget);
    expect(find.textContaining(r'Balance $750.00'), findsOneWidget);
  });

  testWidgets('vendor statement line list renders an empty state', (
    tester,
  ) async {
    final statement = VendorStatement(vendor: _vendor(), lines: const []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 320,
            child: VendorStatementLineList(
              statement: statement,
              currency: NumberFormat.simpleCurrency(decimalDigits: 2),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No payable activity'), findsOneWidget);
  });
}

VendorStatement _sampleStatement() {
  return VendorStatement(
    vendor: _vendor(),
    totalBilled: 1000,
    totalPaid: 250,
    overdueAmount: 750,
    openBillCount: 1,
    lines: [
      VendorStatementLine(
        type: VendorStatementLineType.bill,
        date: DateTime(2026, 5, 1),
        reference: 'BILL-001',
        description: 'Office supplies',
        chargeAmount: 1000,
        balance: 1000,
      ),
      VendorStatementLine(
        type: VendorStatementLineType.payment,
        date: DateTime(2026, 5, 15),
        reference: 'PAY-001',
        description: 'Payment for BILL-001',
        paymentAmount: 250,
        balance: 750,
      ),
    ],
  );
}

Vendor _vendor() {
  return Vendor(id: 'vendor-1', name: 'Acme Supplies', email: 'ap@acme.test');
}
