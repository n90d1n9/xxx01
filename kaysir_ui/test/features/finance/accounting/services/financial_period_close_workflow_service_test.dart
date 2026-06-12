import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close_workflow.dart';
import 'package:kaysir/features/finance/accounting/models/period_closing_entry.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_workflow_service.dart';

void main() {
  group('FinancialPeriodCloseWorkflowService', () {
    const service = FinancialPeriodCloseWorkflowService();

    test('blocks close until a bounded period is selected', () {
      final snapshot = service.build(
        periodLabel: 'All periods',
        periodStart: null,
        periodEnd: null,
        checklist: _checklist(),
        closingEntryPreview: _closingEntryPreview(hasNominalActivity: false),
        closingEntryPosted: false,
        closeRecord: null,
        auditTrail: const [],
      );

      expect(snapshot.hasBoundedPeriod, isFalse);
      expect(snapshot.statusLabel, 'Select period');
      expect(snapshot.canClosePeriod, isFalse);
      expect(
        snapshot.steps.first.status,
        FinancialPeriodCloseWorkflowStepStatus.blocked,
      );
      expect(
        snapshot.attentionItems,
        contains(
          'Select a bounded period before posting or locking the close.',
        ),
      );
    });

    test('surfaces a ready closing entry before allowing period close', () {
      final snapshot = service.build(
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        checklist: _checklist(),
        closingEntryPreview: _closingEntryPreview(hasNominalActivity: true),
        closingEntryPosted: false,
        closeRecord: null,
        auditTrail: const [],
      );

      expect(snapshot.closingEntryRequired, isTrue);
      expect(snapshot.canPostClosingEntry, isTrue);
      expect(snapshot.canClosePeriod, isFalse);
      expect(
        snapshot.steps.firstWhere((step) => step.id == 'closing-entry').status,
        FinancialPeriodCloseWorkflowStepStatus.active,
      );
    });

    test(
      'allows final close after blockers clear and closing entry is posted',
      () {
        final snapshot = service.build(
          periodLabel: 'Jan 2026',
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
          checklist: _checklist(),
          closingEntryPreview: _closingEntryPreview(hasNominalActivity: true),
          closingEntryPosted: true,
          closeRecord: null,
          auditTrail: const [],
        );

        expect(snapshot.canPostClosingEntry, isFalse);
        expect(snapshot.canClosePeriod, isTrue);
        expect(snapshot.statusLabel, 'Ready to close');
        expect(
          snapshot.steps.firstWhere((step) => step.id == 'close').status,
          FinancialPeriodCloseWorkflowStepStatus.active,
        );
      },
    );

    test('marks a closed period as locked with reopen available', () {
      final record = const FinancialPeriodCloseService().closePeriod(
        checklist: _checklist(),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final snapshot = service.build(
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        checklist: _checklist(),
        closingEntryPreview: _closingEntryPreview(hasNominalActivity: true),
        closingEntryPosted: true,
        closeRecord: record,
        auditTrail: const [],
      );

      expect(snapshot.isClosed, isTrue);
      expect(snapshot.statusLabel, 'Locked');
      expect(snapshot.canClosePeriod, isFalse);
      expect(snapshot.canReopenPeriod, isTrue);
      expect(
        snapshot.steps.firstWhere((step) => step.id == 'archive').status,
        FinancialPeriodCloseWorkflowStepStatus.complete,
      );
    });
  });
}

FinancialCloseChecklist _checklist({bool blocked = false}) {
  return FinancialCloseChecklist(
    periodLabel: 'Jan 2026',
    generatedAt: DateTime(2026, 2, 1),
    totalDebit: 100,
    totalCredit: blocked ? 90 : 100,
    trialBalanceVariance: blocked ? 10 : 0,
    items: [
      FinancialCloseChecklistItem(
        id: 'trial-balance',
        title: 'Trial balance',
        description: 'Debits equal credits',
        status:
            blocked
                ? FinancialCloseItemStatus.blocked
                : FinancialCloseItemStatus.ready,
        reference: 'GL',
      ),
      const FinancialCloseChecklistItem(
        id: 'report-pack',
        title: 'Report pack',
        description: 'Statements generated',
        status: FinancialCloseItemStatus.ready,
        reference: 'PSAK 201',
      ),
    ],
  );
}

PeriodClosingEntryPreview _closingEntryPreview({
  required bool hasNominalActivity,
}) {
  final revenue = _account(
    id: 'revenue',
    code: '4000',
    name: 'Revenue',
    type: AccountingAccountType.revenue,
  );
  final expense = _account(
    id: 'expense',
    code: '5000',
    name: 'Expense',
    type: AccountingAccountType.expense,
  );
  final retainedEarnings = _account(
    id: 'equity',
    code: '3200',
    name: 'Retained earnings',
    type: AccountingAccountType.equity,
  );

  return PeriodClosingEntryPreview(
    periodLabel: 'Jan 2026',
    closingDate: DateTime(2026, 1, 31),
    retainedEarningsAccount: retainedEarnings,
    revenueBalances:
        hasNominalActivity
            ? [PeriodClosingAccountBalance(account: revenue, balance: 100)]
            : const [],
    expenseBalances:
        hasNominalActivity
            ? [PeriodClosingAccountBalance(account: expense, balance: 40)]
            : const [],
    draft:
        hasNominalActivity
            ? JournalDraft(
              id: 'closing-draft',
              date: DateTime(2026, 1, 31),
              reference: 'CL-2026-01',
              description: 'Close nominal accounts',
              source: JournalSource.periodClose,
              lines: const [
                JournalLineDraft(
                  accountId: 'revenue',
                  accountName: 'Revenue',
                  side: JournalSide.debit,
                  amount: 100,
                ),
                JournalLineDraft(
                  accountId: 'expense',
                  accountName: 'Expense',
                  side: JournalSide.credit,
                  amount: 40,
                ),
                JournalLineDraft(
                  accountId: 'equity',
                  accountName: 'Retained earnings',
                  side: JournalSide.credit,
                  amount: 60,
                ),
              ],
            )
            : null,
  );
}

AccountingAccount _account({
  required String id,
  required String code,
  required String name,
  required AccountingAccountType type,
}) {
  return AccountingAccount(id: id, code: code, name: name, type: type);
}
