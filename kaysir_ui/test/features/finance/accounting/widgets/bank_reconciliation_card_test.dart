import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/repositories/bank_statement_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/repositories/posted_ledger_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/states/accounting_core_provider.dart';
import 'package:kaysir/features/finance/accounting/states/bank_reconciliation_provider.dart';
import 'package:kaysir/features/finance/accounting/states/gl/ledger_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_reconciliation_card.dart';

void main() {
  group('BankReconciliationCard', () {
    testWidgets('adds a statement line and shows matched detail evidence', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bankStatementRepositoryProvider.overrideWithValue(
            InMemoryBankStatementRepository(),
          ),
          combinedLedgerProvider.overrideWithValue(_cashLedger()),
        ],
      );
      addTearDown(container.dispose);
      await tester.binding.setSurfaceSize(const Size(1100, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: BankReconciliationCard()),
            ),
          ),
        ),
      );

      expect(find.text('Bank Reconciliation'), findsOneWidget);
      expect(find.text('Needs statement'), findsOneWidget);

      await tester.tap(find.text('Add Statement'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Date'),
        '2026-01-05',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Customer transfer',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Reference'),
        'BNK-001',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'),
        '1200',
      );
      await tester.tap(find.text('Add Line'));
      await tester.pumpAndSettle();

      expect(container.read(bankStatementLinesProvider), hasLength(1));
      expect(container.read(bankReconciliationProvider).isBalanced, isTrue);
      expect(find.text('Balanced'), findsOneWidget);

      await tester.tap(find.text('Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Bank Reconciliation Detail'), findsOneWidget);
      expect(find.text('Matched Activity'), findsOneWidget);
      expect(find.text('Statement Lines'), findsOneWidget);
      expect(find.text('Unmatched Statement Lines'), findsOneWidget);
      expect(find.text('Unmatched Cash Ledger'), findsOneWidget);
      expect(find.text('Reference'), findsWidgets);
      expect(find.text('BNK-001'), findsWidgets);
      expect(find.text('No unmatched statement lines'), findsOneWidget);
      expect(find.text('No unmatched cash ledger rows'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove statement line').first);
      await tester.pumpAndSettle();

      expect(container.read(bankStatementLinesProvider), isEmpty);
      expect(
        container.read(bankReconciliationProvider).hasStatementEvidence,
        isFalse,
      );
      expect(find.text('Statement Lines'), findsNothing);
    });

    testWidgets('imports CSV statement lines into reconciliation state', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bankStatementRepositoryProvider.overrideWithValue(
            InMemoryBankStatementRepository(),
          ),
          combinedLedgerProvider.overrideWithValue(_cashLedger()),
        ],
      );
      addTearDown(container.dispose);
      await tester.binding.setSurfaceSize(const Size(1100, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: BankReconciliationCard()),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Import CSV'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'CSV Data'), '''
date,description,reference,amount
2026-01-05,Customer transfer,BNK-001,1200
''');
      await tester.pumpAndSettle();

      expect(find.text('Importable'), findsOneWidget);
      expect(find.text('Import 1'), findsOneWidget);

      await tester.tap(find.text('Import 1'));
      await tester.pumpAndSettle();

      expect(container.read(bankStatementLinesProvider), hasLength(1));
      expect(container.read(bankReconciliationProvider).isBalanced, isTrue);
      expect(find.text('Balanced'), findsOneWidget);
      expect(find.text('Imported 1 statement line(s)'), findsOneWidget);
    });

    testWidgets('reviews duplicate CSV imports before they are added', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bankStatementRepositoryProvider.overrideWithValue(
            InMemoryBankStatementRepository(),
          ),
          combinedLedgerProvider.overrideWithValue(_cashLedger()),
        ],
      );
      addTearDown(container.dispose);
      await tester.binding.setSurfaceSize(const Size(1100, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: BankReconciliationCard()),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Import CSV'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'CSV Data'), '''
date,description,reference,amount
2026-01-05,Customer transfer,BNK-001,1200
''');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import CSV'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'CSV Data'), '''
date,description,reference,amount
2026-01-05,Customer transfer,BNK-001,1200
''');
      await tester.pumpAndSettle();

      expect(find.text('Row 2: Duplicate statement line'), findsOneWidget);
      expect(find.text('Import 1'), findsNothing);
      expect(container.read(bankStatementLinesProvider), hasLength(1));
    });

    testWidgets('shows resolution suggestions for unmatched statement rows', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bankStatementRepositoryProvider.overrideWithValue(
            InMemoryBankStatementRepository(),
          ),
          postedLedgerRepositoryProvider.overrideWithValue(
            InMemoryPostedLedgerRepository(),
          ),
          combinedLedgerProvider.overrideWithValue(const <LedgerTransaction>[]),
        ],
      );
      addTearDown(container.dispose);
      await tester.binding.setSurfaceSize(const Size(1100, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: BankReconciliationCard()),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Import CSV'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'CSV Data'), '''
date,description,reference,amount
2026-01-05,Biaya admin bank,ADM-001,-15000
''');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Resolution Workbench'), findsOneWidget);
      expect(find.text('Bank fee'), findsOneWidget);
      expect(find.text('Post bank fee expense'), findsOneWidget);
      expect(find.text('1 journal, 0 timing'), findsOneWidget);
      expect(find.text('Suggested Journal Drafts'), findsOneWidget);
      expect(find.text('Bank Charges Expense'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      final postAction = find.widgetWithText(TextButton, 'Post');
      await tester.ensureVisible(postAction);
      await tester.pumpAndSettle();
      await tester.tap(postAction);
      await tester.pumpAndSettle();

      expect(container.read(postedLedgerProvider), hasLength(1));
      expect(container.read(postedLedgerProvider).single.reference, 'ADM-001');
      expect(find.text('Posted'), findsOneWidget);
    });

    testWidgets('filters timing difference register rows in detail view', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          bankStatementRepositoryProvider.overrideWithValue(
            InMemoryBankStatementRepository(),
          ),
          combinedLedgerProvider.overrideWithValue(_timingLedger()),
        ],
      );
      addTearDown(container.dispose);
      await tester.binding.setSurfaceSize(const Size(1100, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: BankReconciliationCard()),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Import CSV'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'CSV Data'), '''
date,description,reference,amount
2026-01-05,Customer transfer,BNK-001,1200
''');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import 1'));
      await tester.pumpAndSettle();

      expect(find.text('Deadline Risk'), findsOneWidget);
      expect(find.text('2 overdue / 0 due soon'), findsOneWidget);
      expect(find.text('Timing Review'), findsOneWidget);
      expect(find.text('0/2'), findsOneWidget);
      expect(find.text('Overdue timing'), findsOneWidget);
      expect(find.text('Overdue review'), findsOneWidget);

      await tester.tap(find.text('Deadline Risk'));
      await tester.pumpAndSettle();

      final healthStrip = find.byKey(
        const Key('bank-reconciliation-control-health-strip'),
      );
      expect(healthStrip, findsOneWidget);
      expect(
        find.descendant(of: healthStrip, matching: find.text('Deadline Risk')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: healthStrip,
          matching: find.text('2 overdue / 0 due soon'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: healthStrip, matching: find.text('Next Clear By')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: healthStrip,
          matching: find.text('DEP-001 by 02/27/2026'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: healthStrip, matching: find.text('Overdue timing')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: healthStrip, matching: find.text('Timing Review')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: healthStrip, matching: find.text('0/2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: healthStrip, matching: find.text('Overdue review')),
        findsOneWidget,
      );

      final registerSection = find.byKey(
        const Key('bank-timing-register-section'),
      );
      expect(registerSection, findsOneWidget);
      final atRiskFilter = find.descendant(
        of: registerSection,
        matching: find.widgetWithText(ChoiceChip, 'At Risk'),
      );
      expect(tester.widget<ChoiceChip>(atRiskFilter).selected, isTrue);
      expect(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('Visible Net'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('\$75.00')),
        findsWidgets,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('Outstanding Payments'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('Deadline Risk'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('Review Coverage'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('0/2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('Review')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('Open')),
        findsWidgets,
      );

      await tester.enterText(
        find.descendant(of: registerSection, matching: find.byType(TextField)),
        'vendor',
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
        findsNothing,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('1 / 2 item(s)'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Clear timing search'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('02/27/2026')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('Overdue')),
        findsWidgets,
      );

      final overdueFilter = find.descendant(
        of: registerSection,
        matching: find.widgetWithText(ChoiceChip, 'Overdue'),
      );
      await tester.ensureVisible(overdueFilter);
      await tester.pumpAndSettle();
      await tester.tap(overdueFilter);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('2 / 2 item(s)'),
        ),
        findsOneWidget,
      );

      final dueSoonFilter = find.descendant(
        of: registerSection,
        matching: find.widgetWithText(ChoiceChip, 'Due Soon'),
      );
      await tester.ensureVisible(dueSoonFilter);
      await tester.pumpAndSettle();
      await tester.tap(dueSoonFilter);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
        findsNothing,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('0 / 2 item(s)'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('No timing differences in this view'),
        ),
        findsOneWidget,
      );

      final allFilter = find.descendant(
        of: registerSection,
        matching: find.widgetWithText(ChoiceChip, 'All'),
      );
      await tester.ensureVisible(allFilter);
      await tester.pumpAndSettle();
      await tester.tap(allFilter);
      await tester.pumpAndSettle();

      final referenceHeader = find.descendant(
        of: registerSection,
        matching: find.text('Reference'),
      );
      await tester.ensureVisible(referenceHeader);
      await tester.pumpAndSettle();
      await tester.tap(referenceHeader);
      await tester.pumpAndSettle();
      await tester.tap(referenceHeader);
      await tester.pumpAndSettle();

      final depositRowTop = tester.getTopLeft(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
      );
      final paymentRowTop = tester.getTopLeft(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
      );
      expect(paymentRowTop.dy, lessThan(depositRowTop.dy));

      final paymentsFilter = find.descendant(
        of: registerSection,
        matching: find.text('Payments'),
      );
      await tester.ensureVisible(paymentsFilter);
      await tester.pumpAndSettle();
      await tester.tap(paymentsFilter);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
        findsNothing,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('1 / 2 item(s)'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('\$275.00')),
        findsWidgets,
      );

      final watchFilter = find.descendant(
        of: registerSection,
        matching: find.text('Watch'),
      );
      await tester.ensureVisible(watchFilter);
      await tester.pumpAndSettle();
      await tester.tap(watchFilter);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: registerSection, matching: find.text('DEP-001')),
        findsNothing,
      );
      expect(
        find.descendant(of: registerSection, matching: find.text('PAY-001')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('0 / 2 item(s)'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: registerSection,
          matching: find.text('No timing differences in this view'),
        ),
        findsOneWidget,
      );
    });
  });
}

List<LedgerTransaction> _cashLedger() {
  return [
    LedgerTransaction(
      id: 'cash-in',
      date: DateTime(2026, 1, 5),
      account: '1000 - Bank Mandiri',
      description: 'Customer transfer',
      type: TransactionType.debit,
      amount: 1200,
      reference: 'BNK-001',
      category: 'Receipt',
    ),
  ];
}

List<LedgerTransaction> _timingLedger() {
  return [
    ..._cashLedger(),
    LedgerTransaction(
      id: 'deposit-in-transit',
      date: DateTime(2026, 1, 28),
      account: '1000 - Bank Mandiri',
      description: 'Deposit in transit',
      type: TransactionType.debit,
      amount: 350,
      reference: 'DEP-001',
      category: 'Receipt',
    ),
    LedgerTransaction(
      id: 'outstanding-payment',
      date: DateTime(2026, 1, 29),
      account: '1000 - Bank Mandiri',
      description: 'Outstanding vendor payment',
      type: TransactionType.credit,
      amount: 275,
      reference: 'PAY-001',
      category: 'Payment',
    ),
  ];
}
