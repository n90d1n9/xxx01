import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_statutory_filing.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_statutory_filing_service.dart';

void main() {
  group('FinancialReportStatutoryFilingService', () {
    const service = FinancialReportStatutoryFilingService();

    test('summarizes completed post-release filing follow-ups', () {
      final summary = service.summarize(
        pack: _pack(),
        distributionItems: _completeDistributionItems(),
        archiveSummary: _archiveSummary(isArchived: true),
        asOf: DateTime(2026, 2, 5),
      );

      expect(summary.completeCount, 5);
      expect(summary.overdueCount, 0);
      expect(summary.completionRatio, 1);
      expect(summary.nextAction, 'Post-release statutory tracker is current.');
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.kind ==
                  FinancialReportStatutoryFilingKind.annualCorporateTaxSupport,
            )
            .dueDate,
        DateTime(2026, 5, 31),
      );
    });

    test('flags overdue distribution and statutory archive gaps', () {
      final summary = service.summarize(
        pack: _pack(),
        distributionItems: const [],
        archiveSummary: _archiveSummary(isArchived: false),
        asOf: DateTime(2026, 2, 10),
      );

      expect(summary.completeCount, 0);
      expect(summary.overdueCount, 4);
      expect(summary.dueSoonCount, 0);
      expect(summary.nextAction, contains('Management release copy'));
      expect(
        summary.items.map((item) => item.status),
        contains(FinancialReportStatutoryFilingStatus.pending),
      );
    });
  });
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir Demo',
    frameworkName: 'SAK Indonesia / IFRS aligned',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1, 9),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}

List<FinancialReportReleaseDistributionItem> _completeDistributionItems() {
  return [
    _distributionItem('management-release', DateTime(2026, 2, 2), true),
    _distributionItem('board-owners', DateTime(2026, 2, 3), true),
    _distributionItem('external-auditor', DateTime(2026, 2, 4), true),
    _distributionItem('tax-statutory', DateTime(2026, 2, 6), false),
  ];
}

FinancialReportReleaseDistributionItem _distributionItem(
  String id,
  DateTime dueDate,
  bool requiresAcknowledgement,
) {
  final status =
      requiresAcknowledgement
          ? FinancialReportReleaseDistributionStatus.acknowledged
          : FinancialReportReleaseDistributionStatus.sent;
  return FinancialReportReleaseDistributionItem(
    recipient: FinancialReportReleaseDistributionRecipient(
      id: id,
      name: id,
      role: 'Finance owner',
      organization: 'Kaysir Demo',
      channel: FinancialReportReleaseDistributionChannel.secureLink,
      requiresAcknowledgement: requiresAcknowledgement,
      dueDate: dueDate,
      purpose: 'Release follow-up.',
    ),
    resolution: FinancialReportReleaseDistributionResolution(
      recipientId: id,
      status: status,
      owner: 'Controller',
      updatedAt: DateTime(2026, 2, 2),
      note: 'Complete.',
      evidenceReference: 'EVID-${id.toUpperCase()}',
    ),
  );
}

FinancialReportReleaseArchiveSummary _archiveSummary({
  required bool isArchived,
}) {
  return FinancialReportReleaseArchiveSummary(
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    status:
        isArchived
            ? FinancialReportReleaseArchiveStatus.archived
            : FinancialReportReleaseArchiveStatus.ready,
    record: isArchived ? _archiveRecord : null,
    evidenceReady: true,
    evidenceItemCount: 6,
    readyEvidenceCount: 6,
    nextAction: isArchived ? 'Archived.' : 'Create archive register.',
  );
}

final _archiveRecord = FinancialReportReleaseArchiveRecord(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  archiveId: 'FR-ARCH-2026010120260131-ABCDEF123456',
  archivedAt: DateTime(2026, 2, 1, 14),
  archivedBy: 'Controller',
  custodian: 'Finance archive owner',
  storageLocation: 'Encrypted archive vault',
  retentionPolicy: 'Indonesia statutory/tax archive policy',
  retainUntil: DateTime(2036, 1, 31),
  packageFingerprint: 'abcdef1234567890',
  packageFingerprintAlgorithm: 'SHA-256',
  evidenceItemCount: 6,
  note: 'Archived.',
);
