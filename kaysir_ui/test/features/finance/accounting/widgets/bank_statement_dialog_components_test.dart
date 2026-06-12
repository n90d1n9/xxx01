import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/services/bank_statement_import_service.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_statement_dialog_components.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('statement direction field reports selection changes', (
    tester,
  ) async {
    var direction = BankStatementLineDirection.deposit;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BankStatementLineDirectionField(
            direction: direction,
            enabled: true,
            onChanged: (value) => direction = value,
          ),
        ),
      ),
    );

    expect(
      find.byType(AppSelectField<BankStatementLineDirection>),
      findsOneWidget,
    );
    expect(find.text('Deposit'), findsOneWidget);

    await tester.tap(find.text('Deposit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Withdrawal').last);
    await tester.pumpAndSettle();

    expect(direction, BankStatementLineDirection.withdrawal);
  });

  testWidgets(
    'statement import summary preview and issues render review state',
    (tester) async {
      final line = BankStatementLine(
        id: 'stmt-1',
        date: DateTime(2026, 1, 5),
        description: 'Customer transfer',
        amount: 1200,
        reference: 'BNK-001',
      );
      const issue = BankStatementImportIssue(
        rowNumber: 3,
        message: 'Invalid amount',
      );
      final result = BankStatementImportResult(
        lines: [
          line,
          BankStatementLine(
            id: 'stmt-2',
            date: DateTime(2026, 1, 6),
            description: 'Vendor payment',
            amount: -275,
            reference: 'PAY-001',
          ),
        ],
        issues: const [issue],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  BankStatementImportSummary(result: result),
                  BankStatementImportPreview(lines: result.lines),
                  BankStatementImportIssues(issues: result.issues),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Importable'), findsOneWidget);
      expect(find.text('Net Movement'), findsOneWidget);
      expect(find.text('Deposits'), findsOneWidget);
      expect(find.text('Withdrawals'), findsOneWidget);
      expect(find.text('Review'), findsNWidgets(2));
      expect(find.text('BNK-001'), findsOneWidget);
      expect(find.text('PAY-001'), findsOneWidget);
      expect(find.text('Customer transfer'), findsOneWidget);
      expect(find.text(r'$1,200.00'), findsOneWidget);
      expect(find.text(r'$925.00'), findsOneWidget);
      expect(find.text('Row 3: Invalid amount'), findsOneWidget);
      expect(find.byType(AppInfoRow), findsNWidgets(5));
    },
  );
}
