import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/chart_of_accounts_validator.dart';
import 'package:kaysir/features/finance/accounting/widgets/chart_of_accounts_components.dart';

void main() {
  testWidgets('renders CoA summary and validation issue panel', (tester) async {
    final validation = ChartOfAccountsValidationResult(
      issues: const [
        ChartOfAccountsValidationIssue(
          message: 'Required posting account 1100 is missing.',
          severity: ChartOfAccountsValidationSeverity.error,
          code: '1100',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ChartOfAccountsSummaryStrip(
                accounts: const [
                  AccountingAccount(
                    id: 'cash',
                    code: '1000',
                    name: 'Cash',
                    type: AccountingAccountType.asset,
                  ),
                ],
                validation: validation,
              ),
              ChartOfAccountsValidationPanel(validation: validation),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('1 error(s), 0 warning(s)'), findsOneWidget);
    expect(
      find.text('Required posting account 1100 is missing.'),
      findsOneWidget,
    );
  });

  testWidgets('submits a new account from the account dialog', (tester) async {
    AccountingAccount? submittedAccount;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartOfAccountsAccountDialog(
            existingAccounts: const [],
            onSubmit: (account) => submittedAccount = account,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('chart-of-accounts-code-field')),
      '6100',
    );
    await tester.enterText(
      find.byKey(const ValueKey('chart-of-accounts-name-field')),
      'Cloud subscription expense',
    );
    await tester.tap(
      find.byKey(const ValueKey('chart-of-accounts-save-account')),
    );
    await tester.pumpAndSettle();

    expect(submittedAccount?.code, '6100');
    expect(submittedAccount?.name, 'Cloud subscription expense');
    expect(submittedAccount?.currencyCode, 'IDR');
  });
}
