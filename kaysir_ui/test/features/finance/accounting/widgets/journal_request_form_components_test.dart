import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/services/journal_request_service.dart';
import 'package:kaysir/features/finance/accounting/widgets/journal_request_form_components.dart';

void main() {
  testWidgets('submits a balanced journal request from the dialog', (
    tester,
  ) async {
    JournalApprovalRequest? submittedRequest;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JournalRequestDialog(
            accounts: _accounts,
            service: JournalRequestService(
              now: () => DateTime(2026, 6, 11, 9),
              nextId: () => 'dialog',
            ),
            onSubmit: (request) => submittedRequest = request,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('journal-request-reference')),
      'JE-DIALOG-001',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-description')),
      'Petty cash correction',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-line-0-amount')),
      '1000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-line-1-amount')),
      '1000000',
    );
    await tester.tap(find.byKey(const ValueKey('journal-request-submit')));
    await tester.pumpAndSettle();

    expect(submittedRequest?.id, 'approval-dialog');
    expect(submittedRequest?.draft.reference, 'JE-DIALOG-001');
    expect(submittedRequest?.status, JournalApprovalStatus.pendingReview);
  });

  testWidgets('shows validation issues for an unbalanced request', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JournalRequestDialog(
            accounts: _accounts,
            service: JournalRequestService(
              now: () => DateTime(2026, 6, 11, 9),
              nextId: () => 'dialog',
            ),
            onSubmit: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('journal-request-reference')),
      'JE-DIALOG-002',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-description')),
      'Broken entry',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-line-0-amount')),
      '1000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-line-1-amount')),
      '500000',
    );
    await tester.tap(find.byKey(const ValueKey('journal-request-submit')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('journal-request-issue-panel')),
      findsOneWidget,
    );
    expect(find.text('Debits and credits must balance.'), findsOneWidget);
  });
}

const _accounts = [
  AccountingAccount(
    id: 'cash',
    code: '1000',
    name: 'Cash',
    type: AccountingAccountType.asset,
  ),
  AccountingAccount(
    id: 'expense',
    code: '5000',
    name: 'Rent Expense',
    type: AccountingAccountType.expense,
  ),
];
