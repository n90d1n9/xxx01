import '../models/financial_report_disclosure_review.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_signoff.dart';
import '../models/financial_report_subsequent_event_review.dart';

class FinancialReportSubsequentEventReviewService {
  static const dueSoonWindowDays = 14;
  static const standardReference = 'PSAK 210 / IAS 10';

  const FinancialReportSubsequentEventReviewService();

  FinancialReportSubsequentEventReviewSummary summarize({
    required FinancialReportPack pack,
    required FinancialReportPackageIntegrity packageIntegrity,
    required List<FinancialReportReleaseSignOffItem> signOffItems,
    required List<FinancialReportDisclosureReviewItem> disclosureReviewItems,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required DateTime asOf,
  }) {
    final periodEnd = _dateOnly(pack.periodEnd ?? pack.generatedAt);
    final authorizationDate = _authorizationTargetDate(pack, signOffItems);
    final reviewerSignOff = _signOffFor(
      signOffItems,
      FinancialReportReleaseSignOffRole.reviewer,
    );
    final approverSignOff = _signOffFor(
      signOffItems,
      FinancialReportReleaseSignOffRole.approver,
    );
    final requiredDisclosureItems = disclosureReviewItems
        .where(
          (item) =>
              item.priority ==
              FinancialReportDisclosureRequirementPriority.required,
        )
        .toList(growable: false);
    final hasDisclosureReview = requiredDisclosureItems.isNotEmpty;
    final disclosureResolved =
        hasDisclosureReview &&
        requiredDisclosureItems.every((item) => item.isResolved);
    final disclosureApproved =
        hasDisclosureReview &&
        requiredDisclosureItems.every(
          (item) =>
              item.resolution?.status ==
              FinancialReportDisclosureResolutionStatus.approved,
        );
    final hasDeferredDisclosure = requiredDisclosureItems.any(
      (item) => item.isDeferred,
    );
    final distributionExceptionCount =
        distributionItems.where((item) => item.hasException).length;
    final authorizationComplete =
        packageIntegrity.isVerified && (approverSignOff?.isSigned ?? false);

    final items = [
      _packageLockItem(pack, packageIntegrity, asOf),
      _managementInquiryItem(pack, reviewerSignOff, asOf),
      _adjustingEventAssessmentItem(
        pack: pack,
        disclosureItems: requiredDisclosureItems,
        complete: disclosureResolved,
        blocked: hasDeferredDisclosure,
        asOf: asOf,
      ),
      _disclosureUpdateItem(
        pack: pack,
        disclosureItems: requiredDisclosureItems,
        complete: disclosureApproved,
        blocked: hasDeferredDisclosure,
        asOf: asOf,
      ),
      _authorizationForIssueItem(
        pack: pack,
        packageIntegrity: packageIntegrity,
        approverSignOff: approverSignOff,
        authorizationDate: authorizationDate,
        asOf: asOf,
      ),
      _releaseChangeFreezeItem(
        pack: pack,
        authorizationComplete: authorizationComplete,
        distributionExceptionCount: distributionExceptionCount,
        asOf: asOf,
      ),
    ];

    final completeCount = _count(
      items,
      FinancialReportSubsequentEventReviewStatus.complete,
    );
    final openCount = _count(
      items,
      FinancialReportSubsequentEventReviewStatus.open,
    );
    final dueSoonCount = _count(
      items,
      FinancialReportSubsequentEventReviewStatus.dueSoon,
    );
    final overdueCount = _count(
      items,
      FinancialReportSubsequentEventReviewStatus.overdue,
    );
    final blockedCount = _count(
      items,
      FinancialReportSubsequentEventReviewStatus.blocked,
    );
    final reviewWindowDays = authorizationDate.difference(periodEnd).inDays;

    return FinancialReportSubsequentEventReviewSummary(
      periodEnd: periodEnd,
      authorizationTargetDate: authorizationDate,
      reviewWindowDays: reviewWindowDays < 0 ? 0 : reviewWindowDays,
      standardReference: standardReference,
      items: List.unmodifiable(items),
      completeCount: completeCount,
      openCount: openCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      blockedCount: blockedCount,
      completionRatio: items.isEmpty ? 0 : completeCount / items.length,
      nextAction: _nextAction(items),
    );
  }

  FinancialReportSubsequentEventReviewItem _packageLockItem(
    FinancialReportPack pack,
    FinancialReportPackageIntegrity packageIntegrity,
    DateTime asOf,
  ) {
    final dueDate = _dateOnly(pack.generatedAt);
    return FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.packageLock,
      title: 'Lock report package through review date',
      status:
          packageIntegrity.status ==
                  FinancialReportPackageIntegrityStatus.changed
              ? FinancialReportSubsequentEventReviewStatus.blocked
              : _status(
                complete: packageIntegrity.isVerified,
                dueDate: dueDate,
                asOf: asOf,
              ),
      dueDate: dueDate,
      owner: 'Controller',
      reference: packageIntegrity.status.label,
      detail: packageIntegrity.detail,
      evidenceReference: packageIntegrity.currentShortHash,
    );
  }

  FinancialReportSubsequentEventReviewItem _managementInquiryItem(
    FinancialReportPack pack,
    FinancialReportReleaseSignOffItem? reviewerSignOff,
    DateTime asOf,
  ) {
    final dueDate = _dateOnly(pack.generatedAt.add(const Duration(days: 1)));
    return FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.managementInquiry,
      title: 'Management subsequent-event inquiry',
      status:
          reviewerSignOff?.isReturned ?? false
              ? FinancialReportSubsequentEventReviewStatus.blocked
              : _status(
                complete: reviewerSignOff?.isSigned ?? false,
                dueDate: dueDate,
                asOf: asOf,
              ),
      dueDate: dueDate,
      owner: reviewerSignOff?.requirement.owner ?? 'Controller',
      reference: standardReference,
      detail:
          reviewerSignOff?.resolution?.note ??
          'Confirm management has reviewed events between period end and authorization for issue.',
      evidenceReference: reviewerSignOff?.resolution?.evidenceReference ?? '',
    );
  }

  FinancialReportSubsequentEventReviewItem _adjustingEventAssessmentItem({
    required FinancialReportPack pack,
    required List<FinancialReportDisclosureReviewItem> disclosureItems,
    required bool complete,
    required bool blocked,
    required DateTime asOf,
  }) {
    final dueDate = _dateOnly(pack.generatedAt.add(const Duration(days: 1)));
    return FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.adjustingEventAssessment,
      title: 'Adjusting event assessment',
      status:
          blocked
              ? FinancialReportSubsequentEventReviewStatus.blocked
              : _status(complete: complete, dueDate: dueDate, asOf: asOf),
      dueDate: dueDate,
      owner: 'Reporting accountant',
      reference: standardReference,
      detail: _disclosureDetail(disclosureItems, 'resolved'),
      evidenceReference: _evidenceReference(disclosureItems),
    );
  }

  FinancialReportSubsequentEventReviewItem _disclosureUpdateItem({
    required FinancialReportPack pack,
    required List<FinancialReportDisclosureReviewItem> disclosureItems,
    required bool complete,
    required bool blocked,
    required DateTime asOf,
  }) {
    final dueDate = _dateOnly(pack.generatedAt.add(const Duration(days: 2)));
    return FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.disclosureUpdate,
      title: 'Non-adjusting event disclosure update',
      status:
          blocked
              ? FinancialReportSubsequentEventReviewStatus.blocked
              : _status(complete: complete, dueDate: dueDate, asOf: asOf),
      dueDate: dueDate,
      owner: 'Controller',
      reference: standardReference,
      detail: _disclosureDetail(disclosureItems, 'approved'),
      evidenceReference: _evidenceReference(disclosureItems),
    );
  }

  FinancialReportSubsequentEventReviewItem _authorizationForIssueItem({
    required FinancialReportPack pack,
    required FinancialReportPackageIntegrity packageIntegrity,
    required FinancialReportReleaseSignOffItem? approverSignOff,
    required DateTime authorizationDate,
    required DateTime asOf,
  }) {
    final blocked =
        packageIntegrity.status ==
            FinancialReportPackageIntegrityStatus.changed ||
        (approverSignOff?.isReturned ?? false);
    return FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.authorizationForIssue,
      title: 'Authorization for issue captured',
      status:
          blocked
              ? FinancialReportSubsequentEventReviewStatus.blocked
              : _status(
                complete:
                    packageIntegrity.isVerified &&
                    (approverSignOff?.isSigned ?? false),
                dueDate: authorizationDate,
                asOf: asOf,
              ),
      dueDate: authorizationDate,
      owner: approverSignOff?.requirement.owner ?? 'Finance director',
      reference: standardReference,
      detail:
          approverSignOff?.resolution?.note ??
          'Capture the date the financial statements are authorized for issue.',
      evidenceReference: approverSignOff?.resolution?.evidenceReference ?? '',
    );
  }

  FinancialReportSubsequentEventReviewItem _releaseChangeFreezeItem({
    required FinancialReportPack pack,
    required bool authorizationComplete,
    required int distributionExceptionCount,
    required DateTime asOf,
  }) {
    final dueDate = _dateOnly(pack.generatedAt.add(const Duration(days: 3)));
    return FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.releaseChangeFreeze,
      title: 'Post-authorization change freeze',
      status:
          distributionExceptionCount > 0
              ? FinancialReportSubsequentEventReviewStatus.blocked
              : _status(
                complete: authorizationComplete,
                dueDate: dueDate,
                asOf: asOf,
              ),
      dueDate: dueDate,
      owner: 'Finance controller',
      reference: 'Release control / $standardReference',
      detail:
          distributionExceptionCount > 0
              ? 'Resolve $distributionExceptionCount distribution exception(s) before release evidence is frozen.'
              : 'Keep the report pack unchanged after authorization unless subsequent-event review is reopened.',
      evidenceReference: '',
    );
  }

  FinancialReportReleaseSignOffItem? _signOffFor(
    List<FinancialReportReleaseSignOffItem> items,
    FinancialReportReleaseSignOffRole role,
  ) {
    for (final item in items) {
      if (item.role == role) {
        return item;
      }
    }
    return null;
  }

  DateTime _authorizationTargetDate(
    FinancialReportPack pack,
    List<FinancialReportReleaseSignOffItem> signOffItems,
  ) {
    final approver = _signOffFor(
      signOffItems,
      FinancialReportReleaseSignOffRole.approver,
    );
    if (approver?.isSigned ?? false) {
      return _dateOnly(approver!.resolution!.signedAt);
    }
    return _dateOnly(pack.generatedAt.add(const Duration(days: 2)));
  }

  FinancialReportSubsequentEventReviewStatus _status({
    required bool complete,
    required DateTime dueDate,
    required DateTime asOf,
  }) {
    if (complete) {
      return FinancialReportSubsequentEventReviewStatus.complete;
    }
    final due = _dateOnly(dueDate);
    final asOfDate = _dateOnly(asOf);
    if (asOfDate.isAfter(due)) {
      return FinancialReportSubsequentEventReviewStatus.overdue;
    }
    if (due.difference(asOfDate).inDays <= dueSoonWindowDays) {
      return FinancialReportSubsequentEventReviewStatus.dueSoon;
    }
    return FinancialReportSubsequentEventReviewStatus.open;
  }

  String _disclosureDetail(
    List<FinancialReportDisclosureReviewItem> items,
    String targetStatus,
  ) {
    if (items.isEmpty) {
      return 'Configure disclosure review items for subsequent-event assessment.';
    }
    final resolved = items.where((item) => item.isResolved).length;
    final deferred = items.where((item) => item.isDeferred).length;
    final suffix = deferred == 0 ? '' : ' / $deferred deferred';
    return '$resolved/${items.length} required disclosure review item(s) $targetStatus$suffix.';
  }

  String _evidenceReference(List<FinancialReportDisclosureReviewItem> items) {
    final references = items
        .map((item) => item.resolution?.evidenceReference ?? '')
        .where((reference) => reference.trim().isNotEmpty)
        .toList(growable: false);
    return references.isEmpty ? '' : references.join(', ');
  }

  int _count(
    List<FinancialReportSubsequentEventReviewItem> items,
    FinancialReportSubsequentEventReviewStatus status,
  ) {
    return items.where((item) => item.status == status).length;
  }

  String _nextAction(List<FinancialReportSubsequentEventReviewItem> items) {
    final open =
        items
            .where(
              (item) =>
                  item.status !=
                  FinancialReportSubsequentEventReviewStatus.complete,
            )
            .toList()
          ..sort((a, b) {
            final rank = _statusRank(a.status).compareTo(_statusRank(b.status));
            if (rank != 0) {
              return rank;
            }
            return a.dueDate.compareTo(b.dueDate);
          });
    if (open.isEmpty) {
      return 'Subsequent events review is complete through authorization for issue.';
    }
    final next = open.first;
    return '${next.title}: ${next.detail}';
  }

  int _statusRank(FinancialReportSubsequentEventReviewStatus status) {
    switch (status) {
      case FinancialReportSubsequentEventReviewStatus.blocked:
        return 0;
      case FinancialReportSubsequentEventReviewStatus.overdue:
        return 1;
      case FinancialReportSubsequentEventReviewStatus.dueSoon:
        return 2;
      case FinancialReportSubsequentEventReviewStatus.open:
        return 3;
      case FinancialReportSubsequentEventReviewStatus.complete:
        return 4;
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
