import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_control_summary.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_disclosure_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/models/payable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/receivable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/services/financial_close_checklist_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_pack_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_reconciliation_service.dart';

void main() {
  group('FinancialCloseChecklistService', () {
    const packService = FinancialReportPackService();
    const closeService = FinancialCloseChecklistService();

    test('marks the close ready when ledger and report checks pass', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        generatedAt: DateTime(2026, 2, 1),
      );

      expect(checklist.trialBalanceVariance, 0);
      expect(
        _item(checklist, 'trial-balance').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'financial-position-reconciliation').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'cash-flow').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'cash-roll-forward').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'bank-reconciliation').status,
        FinancialCloseItemStatus.review,
      );
      expect(
        _item(checklist, 'receivable-reconciliation').status,
        FinancialCloseItemStatus.review,
      );
      expect(
        _item(checklist, 'payable-reconciliation').status,
        FinancialCloseItemStatus.review,
      );
      expect(
        _item(checklist, 'equity-roll-forward').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'profit-oci-tie-out').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'mapping').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'comparatives').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'report-exceptions').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'supporting-evidence').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'supporting-evidence').amountLabel,
        'No open evidence tasks',
      );
      expect(
        _item(checklist, 'report-exceptions').amountLabel,
        'No exceptions',
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.ready,
      );
      expect(checklist.hasBlockers, isFalse);
    });

    test(
      'surfaces disclosure note review without blocking export readiness',
      () {
        final checklist = closeService.build(
          pack: _pack(packService),
          ledgerTransactions: _balancedLedger(),
          closingEntryPosted: true,
          disclosureReviewItems: const [
            FinancialReportDisclosureReviewItem(
              requirement: FinancialReportDisclosureRequirement(
                id: 'note-1-basis-of-preparation',
                noteNumber: '1',
                title: 'Basis of Preparation',
                description: 'Prepared using accrual basis.',
                standardReferences: ['PSAK 201'],
                owner: 'Controller',
                priority: FinancialReportDisclosureRequirementPriority.required,
              ),
            ),
          ],
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        final disclosureItem = _item(checklist, 'disclosure-notes');
        expect(disclosureItem.status, FinancialCloseItemStatus.review);
        expect(
          disclosureItem.amountLabel,
          '0/1 resolved / 1 required / 0 approved / 0 deferred',
        );
        expect(
          _item(checklist, 'export-ready').status,
          FinancialCloseItemStatus.ready,
        );
        expect(checklist.hasBlockers, isFalse);
      },
    );

    test('blocks close export when trial balance is out of balance', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: [
          ..._balancedLedger(),
          LedgerTransaction(
            id: 'missing-credit',
            date: DateTime(2026, 1, 31),
            account: '1000 - Cash',
            description: 'Unbalanced adjustment',
            type: TransactionType.debit,
            amount: 50,
            reference: 'ADJ-999',
            category: 'Adjustment',
          ),
        ],
        closingEntryPosted: true,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(checklist.trialBalanceVariance, 50);
      expect(
        _item(checklist, 'trial-balance').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test('uses opening balances from the shared trial balance engine', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: [
          LedgerTransaction(
            id: 'opening-cash',
            date: DateTime(2025, 12, 31),
            account: '1000 - Cash',
            description: 'Opening cash',
            type: TransactionType.debit,
            amount: 100,
            reference: 'OPEN-001',
            category: 'Opening',
          ),
          ..._balancedLedger(),
        ],
        closingEntryPosted: true,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(checklist.trialBalanceVariance, 100);
      expect(checklist.totalDebit, 5100);
      expect(checklist.totalCredit, 5000);
      expect(
        _item(checklist, 'ledger-activity').amountLabel,
        '6 rows / 4 account(s)',
      );
      expect(
        _item(checklist, 'trial-balance').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
    });

    test('blocks close export and shows report reconciliation variance', () {
      const packService = FinancialReportPackService(
        reconciliationService: _VarianceReconciliationService(),
      );
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final equityItem = _item(checklist, 'equity-roll-forward');
      final exceptionItem = _item(checklist, 'report-exceptions');

      expect(equityItem.status, FinancialCloseItemStatus.blocked);
      expect(equityItem.amountLabel, 'Var 125 / Comp -10 / Material');
      expect(exceptionItem.status, FinancialCloseItemStatus.blocked);
      expect(
        exceptionItem.amountLabel,
        '1 blocker(s) / 1 exception(s) / 0 resolved',
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test(
      'blocks close export when tax reconciliation variance is material',
      () {
        final checklist = closeService.build(
          pack: _pack(packService, taxAmount: 300),
          ledgerTransactions: _balancedLedger(taxAmount: 300),
          closingEntryPosted: true,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );
        final taxItem = _item(checklist, 'tax-reconciliation');
        final exceptionItem = _item(checklist, 'report-exceptions');

        expect(taxItem.status, FinancialCloseItemStatus.blocked);
        expect(taxItem.amountLabel, 'Var -536 / Comp 0 / Material');
        expect(exceptionItem.status, FinancialCloseItemStatus.blocked);
        expect(
          exceptionItem.amountLabel,
          '1 blocker(s) / 1 exception(s) / 0 resolved',
        );
        expect(
          _item(checklist, 'export-ready').status,
          FinancialCloseItemStatus.blocked,
        );
        expect(checklist.hasBlockers, isTrue);
      },
    );

    test(
      'allows close export when material tax reconciliation is approved',
      () {
        final checklist = closeService.build(
          pack: _pack(packService, taxAmount: 300),
          ledgerTransactions: _balancedLedger(taxAmount: 300),
          closingEntryPosted: true,
          exceptionResolutions: [
            FinancialReportExceptionResolution(
              exceptionId: 'tax-reconciliation-material',
              status: FinancialReportExceptionResolutionStatus.approved,
              reviewer: 'Controller',
              resolvedAt: DateTime(2026, 2, 1, 11),
              note: 'Approved with tax reconciliation working paper.',
            ),
          ],
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(
          _item(checklist, 'tax-reconciliation').status,
          FinancialCloseItemStatus.review,
        );
        expect(
          _item(checklist, 'report-exceptions').status,
          FinancialCloseItemStatus.ready,
        );
        expect(
          _item(checklist, 'export-ready').status,
          FinancialCloseItemStatus.ready,
        );
        expect(checklist.hasBlockers, isFalse);
      },
    );

    test('blocks close export when tax settlement variance is material', () {
      final checklist = closeService.build(
        pack: _taxSettlementPack(payableAmount: 500),
        ledgerTransactions: _balancedLedger(taxAmount: 814),
        closingEntryPosted: true,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final taxItem = _item(checklist, 'tax-settlement');
      final exceptionItem = _item(checklist, 'report-exceptions');

      expect(taxItem.status, FinancialCloseItemStatus.blocked);
      expect(taxItem.amountLabel, 'Var -114 / Comp 0 / Material');
      expect(exceptionItem.status, FinancialCloseItemStatus.blocked);
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test('blocks close export when VAT settlement variance is material', () {
      final checklist = closeService.build(
        pack: _vatSettlementPack(vatPayableAmount: 100),
        ledgerTransactions: _balancedLedger(taxAmount: 836),
        closingEntryPosted: true,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final vatItem = _item(checklist, 'vat-settlement');
      final exceptionItem = _item(checklist, 'report-exceptions');

      expect(vatItem.status, FinancialCloseItemStatus.blocked);
      expect(vatItem.amountLabel, 'Var -120 / Comp 0 / Material');
      expect(exceptionItem.status, FinancialCloseItemStatus.blocked);
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test(
      'blocks close export when bank statement does not match cash ledger',
      () {
        final checklist = closeService.build(
          pack: _pack(packService),
          ledgerTransactions: _balancedLedger(),
          closingEntryPosted: true,
          bankReconciliation: BankReconciliation(
            statementLines: [
              BankStatementLine(
                id: 'stmt-1',
                date: DateTime(2026, 1, 31),
                description: 'Customer receipt',
                amount: 900,
                reference: 'BNK-001',
              ),
            ],
            ledgerLines: [
              BankLedgerReconciliationLine(
                transactionId: 'cash-1',
                date: DateTime(2026, 1, 31),
                account: '1000 - Cash',
                description: 'Customer receipt',
                reference: 'BNK-001',
                type: TransactionType.debit,
                amount: 1000,
              ),
            ],
            matches: const [],
            unmatchedStatementLines: [
              BankStatementLine(
                id: 'stmt-1',
                date: DateTime(2026, 1, 31),
                description: 'Customer receipt',
                amount: 900,
                reference: 'BNK-001',
              ),
            ],
            unmatchedLedgerLines: [
              BankLedgerReconciliationLine(
                transactionId: 'cash-1',
                date: DateTime(2026, 1, 31),
                account: '1000 - Cash',
                description: 'Customer receipt',
                reference: 'BNK-001',
                type: TransactionType.debit,
                amount: 1000,
              ),
            ],
          ),
          bankReconciliationControlSummary: BankReconciliationControlSummary(
            severity: BankReconciliationControlSeverity.postAdjustments,
            nextAction:
                'Post or review 1 suggested bank adjustment journal(s).',
            statementLineCount: 1,
            matchedCount: 0,
            unmatchedStatementCount: 1,
            unmatchedLedgerCount: 1,
            suggestedJournalCount: 1,
            timingDifferenceCount: 1,
            staleThresholdDays: 30,
            oldestUnmatchedAgeDays: 0,
            oldestUnmatchedDate: DateTime(2026, 1, 31),
            oldestUnmatchedReference: 'BNK-001',
          ),
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );
        final bankItem = _item(checklist, 'bank-reconciliation');

        expect(bankItem.status, FinancialCloseItemStatus.blocked);
        expect(
          bankItem.amountLabel,
          'Stmt 900 / GL 1K / Var -100 / Unmatched 2 / Action Post adjustments / Journals 1 / Timing 1 / Oldest 0 days',
        );
        expect(bankItem.description, contains('Post or review 1 suggested'));
        expect(
          _item(checklist, 'export-ready').status,
          FinancialCloseItemStatus.blocked,
        );
        expect(checklist.hasBlockers, isTrue);
      },
    );

    test('allows close export for current bank timing differences', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        bankReconciliation: _timingOnlyBankReconciliation(),
        bankReconciliationControlSummary: _timingOnlyBankControlSummary(
          oldestAgeDays: 5,
        ),
        bankTimingRegister: [
          _timingRegisterItem(ageDays: 5, clearByDate: DateTime(2026, 2, 4)),
        ],
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final bankItem = _item(checklist, 'bank-reconciliation');

      expect(bankItem.status, FinancialCloseItemStatus.review);
      expect(
        bankItem.amountLabel,
        'Stmt 1K / GL 750 / Var 250 / Unmatched 1 / Action Review timing / Timing 1 / Aging Current 1 / Watch 0 / Stale 0 / Exposure Current 250 / Watch 0 / Stale 0 / Deadline 0 overdue / 1 due soon / Review 0/1 / Resolved 0/1 / Oldest 5 days',
      );
      expect(
        bankItem.description,
        contains('Confirm 1 timing difference(s) clear'),
      );
      expect(bankItem.description, contains('Monitor 1 timing item(s)'));
      expect(
        bankItem.description,
        contains('Document 1 timing review item(s)'),
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.ready,
      );
      expect(checklist.hasBlockers, isFalse);
    });

    test('blocks close export for overdue bank timing deadlines', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        bankReconciliation: _timingOnlyBankReconciliation(),
        bankReconciliationControlSummary: _timingOnlyBankControlSummary(
          oldestAgeDays: 5,
        ),
        bankTimingRegister: [
          _timingRegisterItem(ageDays: 5, clearByDate: DateTime(2026, 1, 30)),
        ],
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final bankItem = _item(checklist, 'bank-reconciliation');

      expect(bankItem.status, FinancialCloseItemStatus.blocked);
      expect(bankItem.amountLabel, contains('Deadline 1 overdue / 0 due soon'));
      expect(
        bankItem.description,
        contains('Resolve 1 overdue timing review(s) before close'),
      );
      expect(bankItem.amountLabel, contains('Review 0/1'));
      expect(bankItem.amountLabel, contains('Review overdue 1'));
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test('allows close export when overdue bank timing review is resolved', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        bankReconciliation: _timingOnlyBankReconciliation(),
        bankReconciliationControlSummary: _timingOnlyBankControlSummary(
          oldestAgeDays: 5,
        ),
        bankTimingRegister: [
          _timingRegisterItem(ageDays: 5, clearByDate: DateTime(2026, 1, 30)),
        ],
        bankTimingReviews: {
          'PAY-001': _timingReview(
            status: BankReconciliationTimingReviewStatus.cleared,
            note: 'Cleared in the next bank statement.',
          ),
        },
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final bankItem = _item(checklist, 'bank-reconciliation');

      expect(bankItem.status, FinancialCloseItemStatus.review);
      expect(bankItem.amountLabel, contains('Deadline 1 overdue / 0 due soon'));
      expect(bankItem.amountLabel, contains('Review 1/1'));
      expect(bankItem.amountLabel, contains('Resolved 1/1'));
      expect(bankItem.amountLabel, isNot(contains('Review overdue')));
      expect(
        bankItem.description,
        contains('Overdue timing item(s) have documented review evidence'),
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.ready,
      );
      expect(checklist.hasBlockers, isFalse);
    });

    test('blocks close export for stale bank timing differences', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        bankReconciliation: _timingOnlyBankReconciliation(),
        bankReconciliationControlSummary: _timingOnlyBankControlSummary(
          oldestAgeDays: 45,
        ),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final bankItem = _item(checklist, 'bank-reconciliation');

      expect(bankItem.status, FinancialCloseItemStatus.blocked);
      expect(bankItem.amountLabel, contains('Action Review timing'));
      expect(bankItem.amountLabel, contains('Timing 1'));
      expect(
        bankItem.amountLabel,
        contains('Aging Current 0 / Watch 0 / Stale 1'),
      );
      expect(
        bankItem.amountLabel,
        contains('Exposure Current 0 / Watch 0 / Stale 250'),
      );
      expect(bankItem.amountLabel, contains('Oldest 45 days'));
      expect(bankItem.amountLabel, contains('Stale'));
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test('blocks close export when supporting evidence tasks need action', () {
      final checklist = closeService.build(
        pack: _packWithSupportingSchedules(_pack(packService), [
          _criticalEvidenceSchedule(),
        ]),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        generatedAt: DateTime(2026, 2, 1),
      );
      final evidenceItem = _item(checklist, 'supporting-evidence');

      expect(evidenceItem.status, FinancialCloseItemStatus.blocked);
      expect(evidenceItem.amountLabel, '1 blocker(s) / 1 task(s) / 0 resolved');
      expect(
        evidenceItem.description,
        contains('Bank Reconciliation Evidence'),
      );
      expect(
        evidenceItem.description,
        contains('Resolve 1 critical evidence signal'),
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test(
      'clears supporting evidence blockers when task evidence is completed',
      () {
        final checklist = closeService.build(
          pack: _packWithSupportingSchedules(_pack(packService), [
            _criticalEvidenceSchedule(),
          ]),
          ledgerTransactions: _balancedLedger(),
          closingEntryPosted: true,
          evidenceTaskResolutions: [
            FinancialReportEvidenceCloseTaskResolution(
              taskId: _criticalEvidenceTaskId,
              status:
                  FinancialReportEvidenceCloseTaskResolutionStatus.completed,
              reviewer: 'Controller',
              resolvedAt: DateTime(2026, 2, 1, 10),
              note: 'Timing evidence reviewed and attached.',
              evidenceReference: 'WP-BANK-001',
            ),
          ],
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
          generatedAt: DateTime(2026, 2, 1),
        );
        final evidenceItem = _item(checklist, 'supporting-evidence');

        expect(evidenceItem.status, FinancialCloseItemStatus.ready);
        expect(
          evidenceItem.amountLabel,
          '0 blocker(s) / 1 task(s) / 1 resolved',
        );
        expect(
          evidenceItem.description,
          'Supporting schedule evidence tasks are resolved for close.',
        );
        expect(
          _item(checklist, 'export-ready').status,
          FinancialCloseItemStatus.ready,
        );
        expect(checklist.hasBlockers, isFalse);
      },
    );

    test('blocks close export when AR subledger does not match ledger', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        receivableReconciliation: const ReceivableReconciliation(
          subledgerBalance: 100,
          ledgerBalance: 80,
        ),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final receivableItem = _item(checklist, 'receivable-reconciliation');

      expect(receivableItem.status, FinancialCloseItemStatus.blocked);
      expect(receivableItem.amountLabel, 'Sub 100 / GL 80 / Var 20');
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test('blocks close export when AP subledger does not match ledger', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        payableReconciliation: const PayableReconciliation(
          subledgerBalance: 80,
          ledgerBalance: 100,
        ),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final payableItem = _item(checklist, 'payable-reconciliation');

      expect(payableItem.status, FinancialCloseItemStatus.blocked);
      expect(payableItem.amountLabel, 'Sub 80 / GL 100 / Var -20');
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test('allows close export when material report exception is approved', () {
      const packService = FinancialReportPackService(
        reconciliationService: _VarianceReconciliationService(),
      );
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        exceptionResolutions: [
          FinancialReportExceptionResolution(
            exceptionId: 'equity-roll-forward-material',
            status: FinancialReportExceptionResolutionStatus.approved,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 11),
            note: 'Approved with supporting equity roll-forward schedule.',
          ),
        ],
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(
        _item(checklist, 'equity-roll-forward').status,
        FinancialCloseItemStatus.review,
      );
      expect(
        _item(checklist, 'report-exceptions').status,
        FinancialCloseItemStatus.ready,
      );
      expect(
        _item(checklist, 'report-exceptions').amountLabel,
        '0 blocker(s) / 1 exception(s) / 1 resolved',
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.ready,
      );
      expect(checklist.hasBlockers, isFalse);
    });

    test(
      'allows close export when material exception links to posted adjustment',
      () {
        const packService = FinancialReportPackService(
          reconciliationService: _VarianceReconciliationService(),
        );
        final checklist = closeService.build(
          pack: _pack(packService),
          ledgerTransactions: _balancedLedger(),
          closingEntryPosted: true,
          exceptionResolutions: [
            FinancialReportExceptionResolution(
              exceptionId: 'equity-roll-forward-material',
              status: FinancialReportExceptionResolutionStatus.adjusted,
              reviewer: 'Controller',
              resolvedAt: DateTime(2026, 2, 1, 11),
              note: 'Posted adjustment to correct equity presentation.',
              adjustmentReference: 'ADJ-001',
              adjustmentPostingId: 'posting-1',
            ),
          ],
          postedAdjustmentJournals: [_posting],
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(
          _item(checklist, 'equity-roll-forward').status,
          FinancialCloseItemStatus.review,
        );
        expect(
          _item(checklist, 'report-exceptions').status,
          FinancialCloseItemStatus.ready,
        );
        expect(
          _item(checklist, 'export-ready').status,
          FinancialCloseItemStatus.ready,
        );
        expect(checklist.hasBlockers, isFalse);
      },
    );

    test('keeps close blocked when adjusted exception has no posted journal', () {
      const packService = FinancialReportPackService(
        reconciliationService: _VarianceReconciliationService(),
      );
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
        exceptionResolutions: [
          FinancialReportExceptionResolution(
            exceptionId: 'equity-roll-forward-material',
            status: FinancialReportExceptionResolutionStatus.adjusted,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 11),
            note:
                'Adjustment reference has not been linked to a posted journal.',
            adjustmentReference: 'ADJ-001',
            adjustmentPostingId: 'missing-posting',
          ),
        ],
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(
        _item(checklist, 'report-exceptions').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });

    test('flags unbounded reports for comparative review', () {
      final pack = packService.build(
        entries: _entries(),
        periodLabel: 'All periods',
        asOfLabel: 'latest available period',
      );
      final checklist = closeService.build(
        pack: pack,
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: true,
      );

      expect(
        _item(checklist, 'comparatives').status,
        FinancialCloseItemStatus.review,
      );
    });

    test('blocks final close until the closing entry is posted', () {
      final checklist = closeService.build(
        pack: _pack(packService),
        ledgerTransactions: _balancedLedger(),
        closingEntryPosted: false,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(
        _item(checklist, 'closing-entry').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(
        _item(checklist, 'export-ready').status,
        FinancialCloseItemStatus.blocked,
      );
      expect(checklist.hasBlockers, isTrue);
    });
  });
}

FinancialCloseChecklistItem _item(
  FinancialCloseChecklist checklist,
  String id,
) {
  return checklist.items.singleWhere((item) => item.id == id);
}

BankReconciliation _timingOnlyBankReconciliation() {
  final statementLine = BankStatementLine(
    id: 'stmt-1',
    date: DateTime(2026, 1, 31),
    description: 'Customer receipt',
    amount: 1000,
    reference: 'BNK-001',
  );
  final receiptLedgerLine = BankLedgerReconciliationLine(
    transactionId: 'cash-1',
    date: DateTime(2026, 1, 31),
    account: '1000 - Cash',
    description: 'Customer receipt',
    reference: 'BNK-001',
    type: TransactionType.debit,
    amount: 1000,
  );
  final outstandingPayment = BankLedgerReconciliationLine(
    transactionId: 'pay-1',
    date: DateTime(2026, 1, 26),
    account: '1000 - Cash',
    description: 'Outstanding vendor payment',
    reference: 'PAY-001',
    type: TransactionType.credit,
    amount: 250,
  );

  return BankReconciliation(
    statementLines: [statementLine],
    ledgerLines: [receiptLedgerLine, outstandingPayment],
    matches: [
      BankReconciliationMatch(
        statementLine: statementLine,
        ledgerLine: receiptLedgerLine,
        matchType: BankReconciliationMatchType.reference,
        dateDifferenceDays: 0,
        amountVariance: 0,
      ),
    ],
    unmatchedStatementLines: const [],
    unmatchedLedgerLines: [outstandingPayment],
  );
}

BankReconciliationControlSummary _timingOnlyBankControlSummary({
  required int oldestAgeDays,
}) {
  return BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.timingReview,
    nextAction: 'Confirm 1 timing difference(s) clear on a later statement.',
    statementLineCount: 1,
    matchedCount: 1,
    unmatchedStatementCount: 0,
    unmatchedLedgerCount: 1,
    suggestedJournalCount: 0,
    timingDifferenceCount: 1,
    staleThresholdDays: 30,
    timingAging: BankReconciliationTimingAgingSummary(
      currentCount: oldestAgeDays >= 30 ? 0 : 1,
      watchCount: 0,
      staleCount: oldestAgeDays >= 30 ? 1 : 0,
      currentAmount: oldestAgeDays >= 30 ? 0 : 250,
      watchAmount: 0,
      staleAmount: oldestAgeDays >= 30 ? 250 : 0,
    ),
    oldestUnmatchedAgeDays: oldestAgeDays,
    oldestUnmatchedDate: DateTime(2026, 1, 26),
    oldestUnmatchedReference: 'PAY-001',
  );
}

BankReconciliationTimingRegisterItem _timingRegisterItem({
  required int ageDays,
  required DateTime clearByDate,
}) {
  return BankReconciliationTimingRegisterItem(
    reference: 'PAY-001',
    date: DateTime(2026, 1, 26),
    description: 'Outstanding vendor payment',
    amount: -250,
    ageDays: ageDays,
    clearByDate: clearByDate,
    bucket: BankReconciliationTimingBucket.current,
    type: BankReconciliationResolutionType.outstandingPayment,
    clearanceStatus: BankReconciliationTimingClearanceStatus.open,
    suggestedAction:
        'Confirm the payment clears on a later bank statement before close.',
  );
}

BankReconciliationTimingReview _timingReview({
  BankReconciliationTimingReviewStatus status =
      BankReconciliationTimingReviewStatus.inReview,
  String owner = 'Controller',
  String note = 'Waiting for clearing evidence.',
}) {
  return BankReconciliationTimingReview(
    reference: 'PAY-001',
    status: status,
    owner: owner,
    note: note,
    reviewedAt: DateTime(2026, 2, 1, 9),
  );
}

FinancialReportPack _pack(
  FinancialReportPackService service, {
  double taxAmount = 836,
}) {
  return service.build(
    entries: _entries(taxAmount: taxAmount),
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    generatedAt: DateTime(2026, 2, 1),
  );
}

FinancialReportPack _packWithSupportingSchedules(
  FinancialReportPack pack,
  List<FinancialReportSupportingSchedule> supportingSchedules,
) {
  return FinancialReportPack(
    entityName: pack.entityName,
    frameworkName: pack.frameworkName,
    jurisdiction: pack.jurisdiction,
    presentationCurrency: pack.presentationCurrency,
    periodLabel: pack.periodLabel,
    asOfLabel: pack.asOfLabel,
    comparativePeriodLabel: pack.comparativePeriodLabel,
    comparativeAsOfLabel: pack.comparativeAsOfLabel,
    periodStart: pack.periodStart,
    periodEnd: pack.periodEnd,
    generatedAt: pack.generatedAt,
    statements: pack.statements,
    notes: pack.notes,
    supportingSchedules: supportingSchedules,
    complianceItems: pack.complianceItems,
    metrics: pack.metrics,
    taxProfile: pack.taxProfile,
  );
}

const _criticalEvidenceTaskId =
    'evidence-bankReconciliation-bank-reconciliation-evidence';

FinancialReportSupportingSchedule _criticalEvidenceSchedule() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.bankReconciliation,
    title: 'Bank Reconciliation Evidence',
    subtitle: 'Bank statement and GL cash/bank tie-out.',
    totalLabel: 'Bank reconciliation variance',
    lines: [],
    metrics: [
      FinancialReportScheduleMetric(
        label: 'Timing deadline risk',
        value: '1 overdue / 0 due soon',
        helperText: 'Clear-by deadline risk.',
      ),
    ],
  );
}

FinancialReportPack _taxSettlementPack({double payableAmount = 614}) {
  return const FinancialReportPackService().build(
    entries: [
      FinancialEntry(
        name: 'Sales Revenue',
        amount: 5000,
        date: DateTime(2026, 1, 15),
        category: '4000 - Sales Revenue',
        type: 'income',
      ),
      FinancialEntry(
        name: 'Rent Expense',
        amount: 1200,
        date: DateTime(2026, 1, 16),
        category: '5000 - Rent Expense',
        type: 'expense',
      ),
      FinancialEntry(
        name: 'Interest Expense',
        amount: 100,
        date: DateTime(2026, 1, 18),
        category: '5100 - Interest Expense',
        type: 'expense',
      ),
      FinancialEntry(
        name: 'Income Tax Expense',
        amount: 814,
        date: DateTime(2026, 1, 20),
        category: '5900 - Income Tax Expense',
        type: 'expense',
        sourceCategory: 'Pajak penghasilan',
      ),
      FinancialEntry(
        name: 'PPh 23 Withholding Credit',
        amount: 200,
        date: DateTime(2026, 1, 31),
        category: '1350 - Kredit Pajak',
        type: 'asset',
        sourceCategory: 'Bukti potong PPh 23',
      ),
      FinancialEntry(
        name: 'Income Tax Payable',
        amount: payableAmount,
        date: DateTime(2026, 1, 31),
        category: '2400 - Income Tax Payable',
        type: 'liability',
        sourceCategory: 'PPh 29 payable',
      ),
    ],
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
  );
}

FinancialReportPack _vatSettlementPack({double vatPayableAmount = 220}) {
  return const FinancialReportPackService().build(
    entries: [
      FinancialEntry(
        name: 'Sales Revenue',
        amount: 5000,
        date: DateTime(2026, 1, 15),
        category: '4000 - Sales Revenue',
        type: 'income',
      ),
      FinancialEntry(
        name: 'Rent Expense',
        amount: 1200,
        date: DateTime(2026, 1, 16),
        category: '5000 - Rent Expense',
        type: 'expense',
      ),
      FinancialEntry(
        name: 'Income Tax Expense',
        amount: 836,
        date: DateTime(2026, 1, 20),
        category: '5900 - Income Tax Expense',
        type: 'expense',
        sourceCategory: 'Pajak penghasilan',
      ),
      FinancialEntry(
        name: 'Input VAT',
        amount: 110,
        date: DateTime(2026, 1, 31),
        category: '1300 - PPN Masukan',
        type: 'asset',
        sourceCategory: 'PPN masukan',
      ),
      FinancialEntry(
        name: 'Output VAT',
        amount: 330,
        date: DateTime(2026, 1, 31),
        category: '2400 - PPN Keluaran',
        type: 'liability',
        sourceCategory: 'PPN keluaran',
      ),
      FinancialEntry(
        name: 'VAT Payable',
        amount: vatPayableAmount,
        date: DateTime(2026, 1, 31),
        category: '2410 - VAT Payable',
        type: 'liability',
        sourceCategory: 'VAT settlement',
      ),
    ],
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
  );
}

List<FinancialEntry> _entries({double taxAmount = 836}) {
  return [
    FinancialEntry(
      name: 'Cash',
      amount: 1000,
      date: DateTime(2025, 12, 31),
      category: '1000 - Cash',
      type: 'asset',
      sourceCategory: 'Opening balance',
    ),
    FinancialEntry(
      name: 'Owner Capital',
      amount: 500,
      date: DateTime(2026, 1, 1),
      category: '3000 - Owner Capital',
      type: 'equity',
      sourceCategory: 'Modal disetor',
    ),
    FinancialEntry(
      name: 'Sales Revenue',
      amount: 5000,
      date: DateTime(2026, 1, 15),
      category: '4000 - Sales Revenue',
      type: 'income',
    ),
    FinancialEntry(
      name: 'Rent Expense',
      amount: 1200,
      date: DateTime(2026, 1, 16),
      category: '5000 - Rent Expense',
      type: 'expense',
    ),
    FinancialEntry(
      name: 'Income Tax Expense',
      amount: taxAmount,
      date: DateTime(2026, 1, 20),
      category: '5900 - Income Tax Expense',
      type: 'expense',
      sourceCategory: 'Pajak penghasilan',
    ),
    FinancialEntry(
      name: 'Cash',
      amount: 3500,
      date: DateTime(2026, 1, 31),
      category: '1000 - Cash',
      type: 'asset',
      sourceCategory: 'Operating collection',
    ),
  ];
}

List<LedgerTransaction> _balancedLedger({double taxAmount = 836}) {
  return [
    _ledger(
      id: 'cash-sale',
      account: '1000 - Cash',
      type: TransactionType.debit,
      amount: 5000,
    ),
    _ledger(
      id: 'revenue',
      account: '4000 - Sales Revenue',
      type: TransactionType.credit,
      amount: 5000,
    ),
    _ledger(
      id: 'rent',
      account: '5000 - Rent Expense',
      type: TransactionType.debit,
      amount: 1200,
    ),
    _ledger(
      id: 'cash-rent',
      account: '1000 - Cash',
      type: TransactionType.credit,
      amount: 1200,
    ),
    _ledger(
      id: 'tax',
      account: '5900 - Income Tax Expense',
      type: TransactionType.debit,
      amount: taxAmount,
    ),
    _ledger(
      id: 'cash-tax',
      account: '1000 - Cash',
      type: TransactionType.credit,
      amount: taxAmount,
    ),
  ];
}

LedgerTransaction _ledger({
  required String id,
  required String account,
  required TransactionType type,
  required double amount,
}) {
  return LedgerTransaction(
    id: id,
    date: DateTime(2026, 1, 31),
    account: account,
    description: 'Close test',
    type: type,
    amount: amount,
    reference: 'CL-001',
    category: 'Close',
  );
}

final _posting = LedgerPosting(
  id: 'posting-1',
  journalId: 'journal-1',
  entryDate: DateTime(2026, 1, 31),
  postedAt: DateTime(2026, 2, 1, 10),
  reference: 'ADJ-001',
  description: 'Correct equity presentation',
  source: JournalSource.manualAdjustment,
  lines: const [
    LedgerPostingLine(
      id: 'posting-1-1',
      accountId: 'equity',
      accountName: 'Equity',
      side: JournalSide.debit,
      amount: 125,
    ),
    LedgerPostingLine(
      id: 'posting-1-2',
      accountId: 'retained-earnings',
      accountName: 'Retained Earnings',
      side: JournalSide.credit,
      amount: 125,
    ),
  ],
);

class _VarianceReconciliationService
    extends FinancialReportReconciliationService {
  const _VarianceReconciliationService();

  @override
  List<FinancialReportReconciliationCheck> buildChecks({
    required FinancialReportStatement position,
    required FinancialReportStatement profitOrLoss,
    required FinancialReportStatement changesInEquity,
    required FinancialReportStatement cashFlows,
  }) {
    return const [
      FinancialReportReconciliationCheck(
        id: 'position-equation',
        title: 'Financial position reconciles',
        description: 'Total assets equal total liabilities plus equity.',
        standardReference: 'PSAK 201',
        variance: 0,
        comparativeVariance: 0,
      ),
      FinancialReportReconciliationCheck(
        id: 'cash-reconciliation',
        title: 'Cash flow reconciles to ending cash',
        description:
            'Beginning cash plus net cash flow equals ending cash and cash equivalents.',
        standardReference: 'PSAK 207',
        variance: 0,
        comparativeVariance: 0,
      ),
      FinancialReportReconciliationCheck(
        id: 'equity-roll-forward',
        title: 'Equity roll-forward reconciles',
        description:
            'Opening equity plus current-period equity movements equals ending equity.',
        standardReference: 'PSAK 201',
        variance: 125,
        comparativeVariance: -10,
      ),
      FinancialReportReconciliationCheck(
        id: 'comprehensive-income-tie-out',
        title: 'Profit and OCI tie to equity',
        description:
            'Profit or loss and OCI in the equity statement agree to the profit or loss and OCI statement.',
        standardReference: 'PSAK 201',
        variance: 0,
        comparativeVariance: 0,
      ),
    ];
  }
}
