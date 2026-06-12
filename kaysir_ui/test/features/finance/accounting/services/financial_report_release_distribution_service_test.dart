import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_distribution_service.dart';

void main() {
  group('FinancialReportReleaseDistributionService', () {
    const service = FinancialReportReleaseDistributionService();

    test('builds default distribution recipients from report pack context', () {
      final recipients = service.buildRecipients(pack: _pack());

      expect(recipients, hasLength(4));
      expect(recipients.first.name, 'Finance Director');
      expect(
        recipients.first.channel,
        FinancialReportReleaseDistributionChannel.secureLink,
      );
      expect(recipients[2].organization, 'Independent auditor');
      expect(recipients.last.organization, 'Indonesia');
      expect(recipients.last.requiresAcknowledgement, isFalse);
    });

    test(
      'tracks completed, acknowledged, exception, and overdue recipients',
      () {
        final recipients = service.buildRecipients(pack: _pack());
        final items = service.buildItems(
          recipients: recipients,
          resolutions: [
            _resolution(
              recipientId: 'management-release',
              status: FinancialReportReleaseDistributionStatus.acknowledged,
            ),
            _resolution(
              recipientId: 'board-owners',
              status: FinancialReportReleaseDistributionStatus.sent,
            ),
            _resolution(
              recipientId: 'external-auditor',
              status: FinancialReportReleaseDistributionStatus.exception,
            ),
            _resolution(
              recipientId: 'tax-statutory',
              status: FinancialReportReleaseDistributionStatus.sent,
            ),
          ],
        );

        expect(service.completedCount(items), 2);
        expect(service.acknowledgedCount(items), 1);
        expect(service.exceptionCount(items), 1);
        expect(service.overdueCount(items, DateTime(2026, 2, 10)), 2);
        expect(service.distributionComplete(items), isFalse);
      },
    );
  });
}

FinancialReportReleaseDistributionResolution _resolution({
  required String recipientId,
  required FinancialReportReleaseDistributionStatus status,
}) {
  return FinancialReportReleaseDistributionResolution(
    recipientId: recipientId,
    status: status,
    owner: 'Controller',
    updatedAt: DateTime(2026, 2, 1, 10),
    note: 'Distribution updated.',
    evidenceReference: 'DIST-$recipientId',
  );
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}
