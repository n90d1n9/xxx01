import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_review_exception.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_review_exception_service.dart';

void main() {
  group('FinancialReportReviewExceptionService', () {
    const service = FinancialReportReviewExceptionService();

    test('classifies material variances as close blockers', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'equity-roll-forward',
            title: 'Equity roll-forward reconciles',
            description: 'Opening equity ties to ending equity.',
            standardReference: 'PSAK 201',
            isSatisfied: false,
            variance: 125,
            comparativeVariance: -10,
            materialityThreshold: 44,
            materialityBasis: '1% of total assets',
          ),
        ]),
      );

      expect(exceptions, hasLength(1));
      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.material,
      );
      expect(exceptions.single.blocksClose, isTrue);
      expect(exceptions.single.materialityThreshold, 44);
    });

    test('keeps non-material disclosure gaps as review exceptions', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'tax-oci-detail',
            title: 'Tax and OCI source detail',
            description: 'Tax and OCI schedules are separately flagged.',
            standardReference: 'PSAK 201',
            isSatisfied: false,
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.review,
      );
      expect(exceptions.single.blocksClose, isFalse);
    });

    test('classifies non-material reconciliation gaps as blocking', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'cash-reconciliation',
            title: 'Cash flow reconciles to ending cash',
            description:
                'Beginning cash plus net cash flow equals ending cash.',
            standardReference: 'PSAK 207',
            isSatisfied: false,
            variance: 5,
            materialityThreshold: 100,
            materialityBasis: '1% of total assets',
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.blocking,
      );
      expect(exceptions.single.blocksClose, isTrue);
    });

    test('classifies chart mapping gaps as blocking', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'chart-mapping',
            title: 'Chart-to-report mapping',
            description: 'Ledger accounts are classified into report lines.',
            standardReference: 'PSAK 201',
            isSatisfied: false,
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.blocking,
      );
      expect(exceptions.single.blocksClose, isTrue);
    });

    test('classifies unreconciled bank evidence as blocking', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'bank-reconciliation',
            title: 'Bank reconciliation evidence',
            description:
                'Bank statement movement ties to GL cash/bank movement with no unmatched items.',
            standardReference: 'PSAK 201 / PSAK 207',
            isSatisfied: false,
            variance: 0,
            materialityThreshold: 100,
            materialityBasis: '1% of total assets',
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.blocking,
      );
      expect(exceptions.single.blocksClose, isTrue);
      expect(exceptions.single.sourceComplianceId, 'bank-reconciliation');
    });

    test('classifies material cash roll-forward gaps as close blockers', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'cash-roll-forward',
            title: 'Cash roll-forward ties to statement cash',
            description: 'Opening cash plus cash movements should tie out.',
            standardReference: 'PSAK 207',
            isSatisfied: false,
            variance: -500,
            materialityThreshold: 50,
            materialityBasis: '1% of total assets',
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.material,
      );
      expect(exceptions.single.blocksClose, isTrue);
      expect(exceptions.single.sourceComplianceId, 'cash-roll-forward');
    });

    test('classifies material tax reconciliation gaps as close blockers', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'tax-reconciliation',
            title: 'Income tax reconciliation within materiality',
            description:
                'Recorded tax should reconcile to statutory benchmark.',
            standardReference: 'PSAK 212',
            isSatisfied: false,
            variance: -434,
            materialityThreshold: 44,
            materialityBasis: '1% of total assets',
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.material,
      );
      expect(exceptions.single.blocksClose, isTrue);
      expect(exceptions.single.standardReference, 'PSAK 212');
    });

    test('classifies material tax settlement gaps as close blockers', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'tax-settlement',
            title: 'Income tax settlement ties to payable',
            description:
                'Tax credits and income tax payable should tie to current tax.',
            standardReference: 'PSAK 212',
            isSatisfied: false,
            variance: -114,
            materialityThreshold: 50,
            materialityBasis: '1% of total revenue',
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.material,
      );
      expect(exceptions.single.blocksClose, isTrue);
      expect(exceptions.single.sourceComplianceId, 'tax-settlement');
    });

    test('classifies material VAT settlement gaps as close blockers', () {
      final exceptions = service.build(
        _pack([
          const FinancialReportComplianceItem(
            id: 'vat-settlement',
            title: 'VAT / PPN settlement ties out',
            description:
                'Input VAT, output VAT, and net VAT payable should tie out.',
            standardReference: 'Indonesia VAT / PPN',
            isSatisfied: false,
            variance: -120,
            materialityThreshold: 50,
            materialityBasis: '1% of total revenue',
          ),
        ]),
      );

      expect(
        exceptions.single.severity,
        FinancialReportReviewExceptionSeverity.material,
      );
      expect(exceptions.single.blocksClose, isTrue);
      expect(exceptions.single.sourceComplianceId, 'vat-settlement');
    });
  });
}

FinancialReportPack _pack(List<FinancialReportComplianceItem> complianceItems) {
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
    complianceItems: complianceItems,
    metrics: const [],
  );
}
