import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_exception_resolution_service.dart';

void main() {
  group('FinancialReportExceptionResolutionService', () {
    const service = FinancialReportExceptionResolutionService();

    test('keeps material exceptions blocking until resolved', () {
      final items = service.buildReviewItems(
        pack: _pack(_materialExceptionCompliance()),
      );

      expect(items.single.blocksClose, isTrue);
      expect(items.single.isResolved, isFalse);
    });

    test('clears close blocker when exception is approved', () {
      final items = service.buildReviewItems(
        pack: _pack(_materialExceptionCompliance()),
        resolutions: [
          FinancialReportExceptionResolution(
            exceptionId: 'equity-roll-forward-material',
            status: FinancialReportExceptionResolutionStatus.approved,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 11),
            note: 'Approved as immaterial after supporting schedule review.',
          ),
        ],
      );

      expect(items.single.blocksClose, isFalse);
      expect(items.single.isResolved, isTrue);
      expect(items.single.resolution?.status.label, 'Approved');
    });

    test('does not clear close blocker for deferred exceptions', () {
      final items = service.buildReviewItems(
        pack: _pack(_materialExceptionCompliance()),
        resolutions: [
          FinancialReportExceptionResolution(
            exceptionId: 'equity-roll-forward-material',
            status: FinancialReportExceptionResolutionStatus.deferred,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 11),
            note: 'Review deferred.',
          ),
        ],
      );

      expect(items.single.blocksClose, isTrue);
      expect(items.single.isResolved, isFalse);
    });

    test(
      'requires adjusted exceptions to link to a posted adjustment journal',
      () {
        final items = service.buildReviewItems(
          pack: _pack(_materialExceptionCompliance()),
          resolutions: [
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
        );

        expect(items.single.blocksClose, isFalse);
        expect(items.single.isResolved, isTrue);
      },
    );

    test('keeps adjusted exceptions blocking when the posting is missing', () {
      final items = service.buildReviewItems(
        pack: _pack(_materialExceptionCompliance()),
        resolutions: [
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
      );

      expect(items.single.blocksClose, isTrue);
      expect(items.single.isResolved, isFalse);
    });
  });
}

FinancialReportComplianceItem _materialExceptionCompliance() {
  return const FinancialReportComplianceItem(
    id: 'equity-roll-forward',
    title: 'Equity roll-forward reconciles',
    description: 'Opening equity ties to ending equity.',
    standardReference: 'PSAK 201',
    isSatisfied: false,
    variance: 125,
    materialityThreshold: 44,
    materialityBasis: '1% of total assets',
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

FinancialReportPack _pack(FinancialReportComplianceItem item) {
  return FinancialReportPack(
    entityName: 'Kaysir',
    frameworkName: 'SAK Indonesia (IFRS-converged)',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1),
    statements: const [],
    notes: const [],
    complianceItems: [item],
    metrics: const [],
  );
}
