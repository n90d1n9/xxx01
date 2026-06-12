import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/services/bank_statement_import_service.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_statement_dialog_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_statement_import_dialog.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_statement_line_dialog.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  testWidgets('bank statement line dialog returns signed withdrawals', (
    tester,
  ) async {
    BankStatementLine? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<BankStatementLine>(
                      context: context,
                      builder: (context) => const BankStatementLineDialog(),
                    );
                  },
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Add Bank Statement Line'), findsOneWidget);
    expect(find.byType(BankStatementLineAmountFields), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Date'),
      '2026-01-05',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Vendor payment',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reference'),
      'PAY-001',
    );
    await tester.tap(find.text('Deposit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Withdrawal').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '275');
    await tester.tap(find.text('Add Line'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.reference, 'PAY-001');
    expect(result!.amount, -275);
  });

  testWidgets('bank statement import dialog composes modern import widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(980, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: BankStatementImportDialog(
              service: BankStatementImportService(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Import Bank Statement CSV'), findsOneWidget);
    expect(find.byType(BankStatementImportSummary), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'CSV Data'), '''
date,description,reference,amount
2026-01-05,Customer transfer,BNK-001,1200
''');
    await tester.pumpAndSettle();

    expect(find.text('Import 1'), findsOneWidget);
    expect(find.byType(BankStatementImportPreview), findsOneWidget);
    expect(find.text('BNK-001'), findsOneWidget);
    expect(find.text('Net Movement'), findsOneWidget);
    expect(find.text('Deposits'), findsOneWidget);
    expect(find.text('Withdrawals'), findsOneWidget);
    expect(find.text(r'$1,200.00'), findsWidgets);
  });
}
