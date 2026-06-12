import '../models/financial_report_pack.dart';
import '../models/financial_report_release_distribution.dart';

class FinancialReportReleaseDistributionService {
  const FinancialReportReleaseDistributionService();

  List<FinancialReportReleaseDistributionRecipient> buildRecipients({
    required FinancialReportPack pack,
  }) {
    final baseDate = pack.generatedAt;
    return [
      FinancialReportReleaseDistributionRecipient(
        id: 'management-release',
        name: 'Finance Director',
        role: 'Management release owner',
        organization: pack.entityName,
        channel: FinancialReportReleaseDistributionChannel.secureLink,
        requiresAcknowledgement: true,
        dueDate: baseDate.add(const Duration(days: 1)),
        purpose: 'Management copy of the approved financial report pack.',
      ),
      FinancialReportReleaseDistributionRecipient(
        id: 'board-owners',
        name: 'Board / owners',
        role: 'Governance recipients',
        organization: pack.entityName,
        channel: FinancialReportReleaseDistributionChannel.email,
        requiresAcknowledgement: true,
        dueDate: baseDate.add(const Duration(days: 2)),
        purpose: 'Governance review and formal distribution record.',
      ),
      FinancialReportReleaseDistributionRecipient(
        id: 'external-auditor',
        name: 'External auditor',
        role: 'Audit file recipient',
        organization: 'Independent auditor',
        channel: FinancialReportReleaseDistributionChannel.portal,
        requiresAcknowledgement: true,
        dueDate: baseDate.add(const Duration(days: 3)),
        purpose: 'Audit evidence handoff with report pack cross-reference.',
      ),
      FinancialReportReleaseDistributionRecipient(
        id: 'tax-statutory',
        name: 'Tax / statutory archive',
        role: 'Indonesia tax support',
        organization: pack.jurisdiction,
        channel: FinancialReportReleaseDistributionChannel.secureLink,
        requiresAcknowledgement: false,
        dueDate: baseDate.add(const Duration(days: 5)),
        purpose: 'SPT and local statutory working paper support archive.',
      ),
    ];
  }

  List<FinancialReportReleaseDistributionItem> buildItems({
    required Iterable<FinancialReportReleaseDistributionRecipient> recipients,
    Iterable<FinancialReportReleaseDistributionResolution> resolutions =
        const [],
  }) {
    final resolutionsByRecipient = {
      for (final resolution in resolutions) resolution.recipientId: resolution,
    };
    return recipients
        .map(
          (recipient) => FinancialReportReleaseDistributionItem(
            recipient: recipient,
            resolution: resolutionsByRecipient[recipient.id],
          ),
        )
        .toList();
  }

  int completedCount(Iterable<FinancialReportReleaseDistributionItem> items) {
    return items.where((item) => item.isComplete).length;
  }

  int acknowledgedCount(
    Iterable<FinancialReportReleaseDistributionItem> items,
  ) {
    return items.where((item) => item.isAcknowledged).length;
  }

  int exceptionCount(Iterable<FinancialReportReleaseDistributionItem> items) {
    return items.where((item) => item.hasException).length;
  }

  int overdueCount(
    Iterable<FinancialReportReleaseDistributionItem> items,
    DateTime asOf,
  ) {
    return items.where((item) => item.isOverdue(asOf)).length;
  }

  bool distributionComplete(
    Iterable<FinancialReportReleaseDistributionItem> items,
  ) {
    final itemList = items.toList();
    return itemList.isNotEmpty && itemList.every((item) => item.isComplete);
  }
}
