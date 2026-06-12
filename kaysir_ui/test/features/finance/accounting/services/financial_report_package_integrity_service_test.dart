import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_package_integrity_service.dart';

void main() {
  group('FinancialReportPackageIntegrityService', () {
    const service = FinancialReportPackageIntegrityService();
    const current = FinancialReportPackageFingerprint(
      algorithm: 'SHA-256',
      hash: 'abcdef1234567890',
    );

    test('marks a matching closed package as verified', () {
      final integrity = service.verify(
        closeRecord: _closedRecord(hash: current.hash),
        currentFingerprint: current,
      );

      expect(integrity.status, FinancialReportPackageIntegrityStatus.verified);
      expect(integrity.isVerified, isTrue);
      expect(integrity.hasWarning, isFalse);
      expect(integrity.hashMatches, isTrue);
      expect(integrity.algorithmMatches, isTrue);
    });

    test('marks a different current package as changed', () {
      final integrity = service.verify(
        closeRecord: _closedRecord(hash: 'closed-hash'),
        currentFingerprint: current,
      );

      expect(integrity.status, FinancialReportPackageIntegrityStatus.changed);
      expect(integrity.isVerified, isFalse);
      expect(integrity.hasWarning, isTrue);
      expect(integrity.hashMatches, isFalse);
      expect(integrity.algorithmMatches, isTrue);
      expect(
        integrity.detail,
        contains('closed hash CLOSED-HASH differs from current ABCDEF123456'),
      );
    });

    test('explains hash algorithm mismatches separately', () {
      final integrity = service.verify(
        closeRecord: _closedRecord(hash: current.hash, algorithm: 'SHA-512'),
        currentFingerprint: current,
      );

      expect(integrity.status, FinancialReportPackageIntegrityStatus.changed);
      expect(integrity.hashMatches, isTrue);
      expect(integrity.algorithmMatches, isFalse);
      expect(
        integrity.detail,
        contains('closed algorithm SHA-512 differs from current SHA-256'),
      );
    });

    test(
      'marks old close records without a fingerprint as missing evidence',
      () {
        final integrity = service.verify(
          closeRecord: _closedRecord(hash: null),
          currentFingerprint: current,
        );

        expect(
          integrity.status,
          FinancialReportPackageIntegrityStatus.missingFingerprint,
        );
        expect(integrity.hasWarning, isTrue);
      },
    );

    test('does not verify a reopened period', () {
      final closeService = const FinancialPeriodCloseService();
      final closed = _closedRecord(hash: current.hash);
      final reopened = closeService.reopenPeriod(
        record: closed,
        reason: 'Late vendor bill',
      );

      final integrity = service.verify(
        closeRecord: reopened,
        currentFingerprint: current,
      );

      expect(integrity.status, FinancialReportPackageIntegrityStatus.notClosed);
    });
  });
}

FinancialPeriodCloseRecord _closedRecord({
  required String? hash,
  String? algorithm,
}) {
  return const FinancialPeriodCloseService().closePeriod(
    checklist: _checklist(),
    periodLabel: 'Jan 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    closedAt: DateTime(2026, 2, 1, 10),
    closedBy: 'Controller',
    reportPackageHash: hash,
    reportPackageHashAlgorithm: algorithm ?? (hash == null ? null : 'SHA-256'),
  );
}

FinancialCloseChecklist _checklist() {
  return FinancialCloseChecklist(
    periodLabel: 'Jan 2026',
    generatedAt: DateTime(2026, 2, 1, 9),
    totalDebit: 100,
    totalCredit: 100,
    trialBalanceVariance: 0,
    items: const [
      FinancialCloseChecklistItem(
        id: 'trial-balance',
        title: 'Trial balance',
        description: 'Debits equal credits',
        status: FinancialCloseItemStatus.ready,
        reference: 'GL',
      ),
    ],
  );
}
