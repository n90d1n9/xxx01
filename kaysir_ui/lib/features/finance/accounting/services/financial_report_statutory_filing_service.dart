import '../models/financial_report_pack.dart';
import '../models/financial_report_release_archive.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_statutory_filing.dart';

class FinancialReportStatutoryFilingService {
  static const dueSoonWindowDays = 14;
  static const annualCorporateTaxReturnReference =
      'DJP: Annual Corporate Tax Return due no later than 4 months after tax year end';

  const FinancialReportStatutoryFilingService();

  FinancialReportStatutoryFilingSummary summarize({
    required FinancialReportPack pack,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required FinancialReportReleaseArchiveSummary archiveSummary,
    required DateTime asOf,
  }) {
    final items = [
      _distributionItem(
        kind: FinancialReportStatutoryFilingKind.managementRelease,
        title: 'Management release copy',
        recipientId: 'management-release',
        distributionItems: distributionItems,
        asOf: asOf,
        fallbackDueDate: pack.generatedAt.add(const Duration(days: 1)),
        reference: 'Internal management release',
      ),
      _distributionItem(
        kind: FinancialReportStatutoryFilingKind.boardDistribution,
        title: 'Board / owner report package',
        recipientId: 'board-owners',
        distributionItems: distributionItems,
        asOf: asOf,
        fallbackDueDate: pack.generatedAt.add(const Duration(days: 2)),
        reference: 'Governance distribution evidence',
      ),
      _distributionItem(
        kind: FinancialReportStatutoryFilingKind.auditorHandoff,
        title: 'External audit handoff',
        recipientId: 'external-auditor',
        distributionItems: distributionItems,
        asOf: asOf,
        fallbackDueDate: pack.generatedAt.add(const Duration(days: 3)),
        reference: 'Audit file handoff',
      ),
      _annualTaxSupportItem(
        pack: pack,
        distributionItems: distributionItems,
        archiveSummary: archiveSummary,
        asOf: asOf,
      ),
      _statutoryArchiveItem(
        pack: pack,
        archiveSummary: archiveSummary,
        asOf: asOf,
      ),
    ];

    final completeCount = _count(
      items,
      FinancialReportStatutoryFilingStatus.complete,
    );
    final dueSoonCount = _count(
      items,
      FinancialReportStatutoryFilingStatus.dueSoon,
    );
    final overdueCount = _count(
      items,
      FinancialReportStatutoryFilingStatus.overdue,
    );
    final blockedCount = _count(
      items,
      FinancialReportStatutoryFilingStatus.blocked,
    );

    return FinancialReportStatutoryFilingSummary(
      items: List.unmodifiable(items),
      completeCount: completeCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      blockedCount: blockedCount,
      completionRatio: items.isEmpty ? 0 : completeCount / items.length,
      nextAction: _nextAction(items),
    );
  }

  FinancialReportStatutoryFilingItem _distributionItem({
    required FinancialReportStatutoryFilingKind kind,
    required String title,
    required String recipientId,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required DateTime asOf,
    required DateTime fallbackDueDate,
    required String reference,
  }) {
    final item = _findDistributionItem(distributionItems, recipientId);
    final dueDate = item?.recipient.dueDate ?? fallbackDueDate;
    final status = _status(
      complete: item?.isComplete ?? false,
      dueDate: dueDate,
      asOf: asOf,
    );
    return FinancialReportStatutoryFilingItem(
      kind: kind,
      title: title,
      status: status,
      dueDate: dueDate,
      owner: item?.recipient.role ?? 'Finance controller',
      reference: reference,
      detail:
          item == null
              ? 'Configure the related distribution recipient.'
              : item.isComplete
              ? '${item.recipient.name} evidence is complete.'
              : '${item.recipient.name} is ${item.statusLabel.toLowerCase()}.',
      evidenceReference: item?.resolution?.evidenceReference ?? '',
    );
  }

  FinancialReportStatutoryFilingItem _annualTaxSupportItem({
    required FinancialReportPack pack,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required FinancialReportReleaseArchiveSummary archiveSummary,
    required DateTime asOf,
  }) {
    final taxDistribution = _findDistributionItem(
      distributionItems,
      'tax-statutory',
    );
    final dueDate = _annualCorporateTaxDueDate(
      pack.periodEnd ?? pack.generatedAt,
    );
    final complete =
        archiveSummary.isArchived && (taxDistribution?.isComplete ?? false);
    return FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.annualCorporateTaxSupport,
      title: 'SPT Tahunan Badan support pack',
      status: _status(complete: complete, dueDate: dueDate, asOf: asOf),
      dueDate: dueDate,
      owner: 'Tax / statutory archive',
      reference: annualCorporateTaxReturnReference,
      detail:
          complete
              ? 'Tax support archive is ready for annual corporate return filing.'
              : 'Prepare released financial statements and tax schedules for SPT support.',
      evidenceReference: taxDistribution?.resolution?.evidenceReference ?? '',
    );
  }

  FinancialReportStatutoryFilingItem _statutoryArchiveItem({
    required FinancialReportPack pack,
    required FinancialReportReleaseArchiveSummary archiveSummary,
    required DateTime asOf,
  }) {
    final dueDate = pack.generatedAt.add(const Duration(days: 5));
    return FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.statutoryArchive,
      title: 'Indonesia statutory evidence archive',
      status: _status(
        complete: archiveSummary.isArchived,
        dueDate: dueDate,
        asOf: asOf,
      ),
      dueDate: dueDate,
      owner: 'Finance controller',
      reference: 'Release archive and retention evidence',
      detail:
          archiveSummary.isArchived
              ? 'Archive register is sealed with retention evidence.'
              : 'Create the release archive register and retention monitor.',
      evidenceReference: archiveSummary.record?.archiveId ?? '',
    );
  }

  FinancialReportReleaseDistributionItem? _findDistributionItem(
    List<FinancialReportReleaseDistributionItem> items,
    String id,
  ) {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  FinancialReportStatutoryFilingStatus _status({
    required bool complete,
    required DateTime dueDate,
    required DateTime asOf,
  }) {
    if (complete) {
      return FinancialReportStatutoryFilingStatus.complete;
    }
    if (asOf.isAfter(dueDate)) {
      return FinancialReportStatutoryFilingStatus.overdue;
    }
    final daysUntilDue = dueDate.difference(asOf).inDays;
    if (daysUntilDue <= dueSoonWindowDays) {
      return FinancialReportStatutoryFilingStatus.dueSoon;
    }
    return FinancialReportStatutoryFilingStatus.pending;
  }

  DateTime _annualCorporateTaxDueDate(DateTime periodEnd) {
    return _addMonths(
      DateTime(periodEnd.year, periodEnd.month, periodEnd.day),
      4,
    );
  }

  DateTime _addMonths(DateTime date, int months) {
    final target = DateTime(date.year, date.month + months, date.day);
    if (target.day != date.day) {
      return DateTime(date.year, date.month + months + 1, 0);
    }
    return target;
  }

  int _count(
    List<FinancialReportStatutoryFilingItem> items,
    FinancialReportStatutoryFilingStatus status,
  ) {
    return items.where((item) => item.status == status).length;
  }

  String _nextAction(List<FinancialReportStatutoryFilingItem> items) {
    final blockers =
        items
            .where(
              (item) =>
                  item.status == FinancialReportStatutoryFilingStatus.overdue ||
                  item.status == FinancialReportStatutoryFilingStatus.blocked ||
                  item.status == FinancialReportStatutoryFilingStatus.dueSoon,
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (blockers.isEmpty) {
      return 'Post-release statutory tracker is current.';
    }
    final next = blockers.first;
    return '${next.title}: ${next.detail}';
  }
}
