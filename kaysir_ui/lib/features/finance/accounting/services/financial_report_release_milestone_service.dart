import '../models/financial_report_pack.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_archive.dart';
import '../models/financial_report_release_archive_retention.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_milestone.dart';
import '../models/financial_report_release_signoff.dart';
import '../models/financial_report_statutory_filing.dart';

class FinancialReportReleaseMilestoneService {
  static const dueSoonWindowDays = 14;

  const FinancialReportReleaseMilestoneService();

  FinancialReportReleaseMilestoneSummary summarize({
    required FinancialReportPack pack,
    required FinancialReportPackageIntegrity packageIntegrity,
    required List<FinancialReportReleaseSignOffItem> signOffItems,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required FinancialReportReleaseArchiveSummary archiveSummary,
    required FinancialReportReleaseArchiveRetentionSummary retentionSummary,
    required FinancialReportStatutoryFilingSummary statutoryFilingSummary,
    required DateTime asOf,
  }) {
    final items = <FinancialReportReleaseMilestoneItem>[
      _packageIntegrityMilestone(pack, packageIntegrity, asOf),
      ..._signOffMilestones(pack, signOffItems, asOf),
      ..._distributionMilestones(distributionItems, asOf),
      _archiveMilestone(pack, archiveSummary, asOf),
      ..._retentionMilestones(retentionSummary, asOf),
      ..._statutoryMilestones(statutoryFilingSummary),
    ]..sort((a, b) => _compareMilestone(a, b));

    final completeCount = _count(
      items,
      FinancialReportReleaseMilestoneStatus.complete,
    );
    final upcomingCount = _count(
      items,
      FinancialReportReleaseMilestoneStatus.upcoming,
    );
    final dueSoonCount = _count(
      items,
      FinancialReportReleaseMilestoneStatus.dueSoon,
    );
    final overdueCount = _count(
      items,
      FinancialReportReleaseMilestoneStatus.overdue,
    );
    final blockedCount = _count(
      items,
      FinancialReportReleaseMilestoneStatus.blocked,
    );

    return FinancialReportReleaseMilestoneSummary(
      items: List.unmodifiable(items),
      completeCount: completeCount,
      upcomingCount: upcomingCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      blockedCount: blockedCount,
      completionRatio: items.isEmpty ? 0 : completeCount / items.length,
      nextAction: _nextAction(items),
    );
  }

  FinancialReportReleaseMilestoneItem _packageIntegrityMilestone(
    FinancialReportPack pack,
    FinancialReportPackageIntegrity packageIntegrity,
    DateTime asOf,
  ) {
    final dueDate = _dateOnly(pack.generatedAt);
    final status =
        packageIntegrity.isVerified
            ? FinancialReportReleaseMilestoneStatus.complete
            : packageIntegrity.status ==
                FinancialReportPackageIntegrityStatus.changed
            ? FinancialReportReleaseMilestoneStatus.blocked
            : _status(complete: false, dueDate: dueDate, asOf: asOf);
    return FinancialReportReleaseMilestoneItem(
      id: 'package-integrity',
      area: FinancialReportReleaseMilestoneArea.packageIntegrity,
      title: 'Closed package certification',
      status: status,
      dueDate: dueDate,
      owner: 'Controller',
      reference: packageIntegrity.status.label,
      detail: packageIntegrity.detail,
    );
  }

  Iterable<FinancialReportReleaseMilestoneItem> _signOffMilestones(
    FinancialReportPack pack,
    List<FinancialReportReleaseSignOffItem> items,
    DateTime asOf,
  ) sync* {
    for (final item in items) {
      final dueDate = _signOffDueDate(pack, item.role);
      yield FinancialReportReleaseMilestoneItem(
        id: 'signoff-${item.id}',
        area: FinancialReportReleaseMilestoneArea.signOff,
        title: item.requirement.title,
        status:
            item.isReturned
                ? FinancialReportReleaseMilestoneStatus.blocked
                : _status(
                  complete: item.isSigned,
                  dueDate: dueDate,
                  asOf: asOf,
                ),
        dueDate: dueDate,
        owner: item.requirement.owner,
        reference: '${item.role.label} / ${item.requirement.reference}',
        detail: item.resolution?.note ?? item.requirement.description,
      );
    }
  }

  Iterable<FinancialReportReleaseMilestoneItem> _distributionMilestones(
    List<FinancialReportReleaseDistributionItem> items,
    DateTime asOf,
  ) sync* {
    for (final item in items) {
      yield FinancialReportReleaseMilestoneItem(
        id: 'distribution-${item.id}',
        area: FinancialReportReleaseMilestoneArea.distribution,
        title: item.recipient.name,
        status:
            item.hasException
                ? FinancialReportReleaseMilestoneStatus.blocked
                : _status(
                  complete: item.isComplete,
                  dueDate: item.recipient.dueDate,
                  asOf: asOf,
                ),
        dueDate: item.recipient.dueDate,
        owner: item.recipient.role,
        reference:
            item.recipient.requiresAcknowledgement
                ? '${item.recipient.channel.label} / acknowledgement required'
                : item.recipient.channel.label,
        detail: item.resolution?.note ?? item.recipient.purpose,
      );
    }
  }

  FinancialReportReleaseMilestoneItem _archiveMilestone(
    FinancialReportPack pack,
    FinancialReportReleaseArchiveSummary archiveSummary,
    DateTime asOf,
  ) {
    final dueDate = _dateOnly(pack.generatedAt.add(const Duration(days: 5)));
    return FinancialReportReleaseMilestoneItem(
      id: 'release-archive',
      area: FinancialReportReleaseMilestoneArea.archive,
      title: 'Release archive register',
      status:
          archiveSummary.status == FinancialReportReleaseArchiveStatus.blocked
              ? FinancialReportReleaseMilestoneStatus.blocked
              : _status(
                complete: archiveSummary.isArchived,
                dueDate: dueDate,
                asOf: asOf,
              ),
      dueDate: archiveSummary.record?.archivedAt ?? dueDate,
      owner: archiveSummary.record?.custodian ?? 'Finance archive owner',
      reference:
          '${archiveSummary.readyEvidenceCount}/${archiveSummary.evidenceItemCount} evidence item(s) ready',
      detail: archiveSummary.nextAction,
    );
  }

  Iterable<FinancialReportReleaseMilestoneItem> _retentionMilestones(
    FinancialReportReleaseArchiveRetentionSummary summary,
    DateTime asOf,
  ) sync* {
    final nextReviewDate = summary.nextReviewDate;
    if (nextReviewDate == null || !summary.hasArchive) {
      return;
    }

    yield FinancialReportReleaseMilestoneItem(
      id: 'retention-review',
      area: FinancialReportReleaseMilestoneArea.retention,
      title: 'Archive retention review',
      status: _retentionStatus(summary, asOf),
      dueDate: nextReviewDate,
      owner: summary.record?.custodian ?? 'Finance archive owner',
      reference: summary.periodLabel,
      detail: summary.nextAction,
    );
  }

  Iterable<FinancialReportReleaseMilestoneItem> _statutoryMilestones(
    FinancialReportStatutoryFilingSummary summary,
  ) sync* {
    for (final item in summary.items) {
      if (item.kind !=
          FinancialReportStatutoryFilingKind.annualCorporateTaxSupport) {
        continue;
      }
      yield FinancialReportReleaseMilestoneItem(
        id: 'statutory-${item.kind.name}',
        area: FinancialReportReleaseMilestoneArea.statutoryFiling,
        title: item.title,
        status: _statutoryStatus(item.status),
        dueDate: item.dueDate,
        owner: item.owner,
        reference: item.reference,
        detail: item.detail,
      );
    }
  }

  FinancialReportReleaseMilestoneStatus _retentionStatus(
    FinancialReportReleaseArchiveRetentionSummary summary,
    DateTime asOf,
  ) {
    switch (summary.status) {
      case FinancialReportReleaseArchiveRetentionStatus.expired:
        return FinancialReportReleaseMilestoneStatus.blocked;
      case FinancialReportReleaseArchiveRetentionStatus.reviewDue:
        return _status(
          complete: false,
          dueDate: summary.nextReviewDate!,
          asOf: asOf,
        );
      case FinancialReportReleaseArchiveRetentionStatus.active:
        return FinancialReportReleaseMilestoneStatus.upcoming;
      case FinancialReportReleaseArchiveRetentionStatus.notArchived:
        return FinancialReportReleaseMilestoneStatus.blocked;
    }
  }

  FinancialReportReleaseMilestoneStatus _statutoryStatus(
    FinancialReportStatutoryFilingStatus status,
  ) {
    switch (status) {
      case FinancialReportStatutoryFilingStatus.complete:
        return FinancialReportReleaseMilestoneStatus.complete;
      case FinancialReportStatutoryFilingStatus.pending:
        return FinancialReportReleaseMilestoneStatus.upcoming;
      case FinancialReportStatutoryFilingStatus.dueSoon:
        return FinancialReportReleaseMilestoneStatus.dueSoon;
      case FinancialReportStatutoryFilingStatus.overdue:
        return FinancialReportReleaseMilestoneStatus.overdue;
      case FinancialReportStatutoryFilingStatus.blocked:
        return FinancialReportReleaseMilestoneStatus.blocked;
    }
  }

  FinancialReportReleaseMilestoneStatus _status({
    required bool complete,
    required DateTime dueDate,
    required DateTime asOf,
  }) {
    if (complete) {
      return FinancialReportReleaseMilestoneStatus.complete;
    }
    final asOfDate = _dateOnly(asOf);
    final due = _dateOnly(dueDate);
    if (asOfDate.isAfter(due)) {
      return FinancialReportReleaseMilestoneStatus.overdue;
    }
    if (due.difference(asOfDate).inDays <= dueSoonWindowDays) {
      return FinancialReportReleaseMilestoneStatus.dueSoon;
    }
    return FinancialReportReleaseMilestoneStatus.upcoming;
  }

  DateTime _signOffDueDate(
    FinancialReportPack pack,
    FinancialReportReleaseSignOffRole role,
  ) {
    final base = _dateOnly(pack.generatedAt);
    switch (role) {
      case FinancialReportReleaseSignOffRole.preparer:
        return base;
      case FinancialReportReleaseSignOffRole.reviewer:
        return base.add(const Duration(days: 1));
      case FinancialReportReleaseSignOffRole.approver:
        return base.add(const Duration(days: 2));
    }
  }

  int _count(
    List<FinancialReportReleaseMilestoneItem> items,
    FinancialReportReleaseMilestoneStatus status,
  ) {
    return items.where((item) => item.status == status).length;
  }

  String _nextAction(List<FinancialReportReleaseMilestoneItem> items) {
    final open = items.where(
      (item) => item.status != FinancialReportReleaseMilestoneStatus.complete,
    );
    final next = open.isEmpty ? null : open.first;
    if (next == null) {
      return 'Release milestone calendar is complete.';
    }
    return '${next.title}: ${next.detail}';
  }

  int _compareMilestone(
    FinancialReportReleaseMilestoneItem a,
    FinancialReportReleaseMilestoneItem b,
  ) {
    final rank = _statusRank(a.status).compareTo(_statusRank(b.status));
    if (rank != 0) {
      return rank;
    }
    final due = a.dueDate.compareTo(b.dueDate);
    if (due != 0) {
      return due;
    }
    return a.title.compareTo(b.title);
  }

  int _statusRank(FinancialReportReleaseMilestoneStatus status) {
    switch (status) {
      case FinancialReportReleaseMilestoneStatus.blocked:
        return 0;
      case FinancialReportReleaseMilestoneStatus.overdue:
        return 1;
      case FinancialReportReleaseMilestoneStatus.dueSoon:
        return 2;
      case FinancialReportReleaseMilestoneStatus.upcoming:
        return 3;
      case FinancialReportReleaseMilestoneStatus.complete:
        return 4;
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
