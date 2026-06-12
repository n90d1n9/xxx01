import '../models/financial_report_management_measure.dart';
import '../models/financial_report_management_measure_release_readiness.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_action_queue.dart';
import '../models/financial_report_release_archive.dart';
import '../models/financial_report_release_archive_retention.dart';
import '../models/financial_report_release_control.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_evidence_manifest.dart';
import '../models/financial_report_release_signoff.dart';
import '../models/financial_report_statutory_filing.dart';
import 'financial_report_management_measure_service.dart';

class FinancialReportReleaseActionQueueService {
  final FinancialReportManagementMeasureService managementMeasureService;

  const FinancialReportReleaseActionQueueService({
    this.managementMeasureService =
        const FinancialReportManagementMeasureService(),
  });

  FinancialReportReleaseActionQueueSummary summarize({
    required FinancialReportReleaseControlSummary controlSummary,
    required FinancialReportPackageIntegrity packageIntegrity,
    List<FinancialReportManagementMeasureReconciliation>
        managementMeasureReconciliations =
        const [],
    FinancialReportManagementMeasureReleaseReadinessSummary?
    managementMeasureReleaseReadiness,
    required List<FinancialReportReleaseSignOffItem> signOffItems,
    required List<FinancialReportReleaseDistributionItem> distributionItems,
    required FinancialReportReleaseEvidenceManifestSummary evidenceManifest,
    required FinancialReportReleaseArchiveSummary archiveSummary,
    required FinancialReportReleaseArchiveRetentionSummary retentionSummary,
    required FinancialReportStatutoryFilingSummary statutoryFilingSummary,
    required DateTime asOf,
  }) {
    final items = <FinancialReportReleaseActionItem>[
      ..._packageIntegrityActions(packageIntegrity),
      if (managementMeasureReleaseReadiness == null)
        ..._managementMeasureActions(managementMeasureReconciliations)
      else
        ..._managementMeasureReleaseReadinessActions(
          managementMeasureReleaseReadiness,
        ),
      ..._signOffActions(signOffItems),
      ..._evidenceManifestActions(evidenceManifest),
      ..._distributionActions(distributionItems, asOf),
      ..._archiveActions(archiveSummary),
      ..._retentionActions(retentionSummary),
      ..._statutoryFilingActions(statutoryFilingSummary),
    ]..sort((a, b) => _compareAction(a, b));

    return FinancialReportReleaseActionQueueSummary(
      items: List.unmodifiable(items),
      criticalCount:
          items
              .where(
                (item) =>
                    item.priority ==
                    FinancialReportReleaseActionPriority.critical,
              )
              .length,
      highCount:
          items
              .where(
                (item) =>
                    item.priority == FinancialReportReleaseActionPriority.high,
              )
              .length,
      overdueCount:
          items
              .where(
                (item) =>
                    item.dueDate != null &&
                    DateTime(
                      asOf.year,
                      asOf.month,
                      asOf.day,
                    ).isAfter(_dateOnly(item.dueDate!)),
              )
              .length,
      blockedCount: items.where((item) => item.blocked).length,
      nextAction: _nextAction(items, controlSummary),
    );
  }

  Iterable<FinancialReportReleaseActionItem> _packageIntegrityActions(
    FinancialReportPackageIntegrity packageIntegrity,
  ) sync* {
    if (packageIntegrity.isVerified) {
      return;
    }
    yield FinancialReportReleaseActionItem(
      id: 'package-integrity',
      area: FinancialReportReleaseActionArea.packageIntegrity,
      priority:
          packageIntegrity.status ==
                  FinancialReportPackageIntegrityStatus.changed
              ? FinancialReportReleaseActionPriority.critical
              : FinancialReportReleaseActionPriority.high,
      title: 'Certify report package',
      owner: 'Controller',
      dueDate: packageIntegrity.closeRecord?.periodEnd,
      detail: packageIntegrity.detail,
      reference: packageIntegrity.status.label,
      blocked: true,
      destination: FinancialReportReleaseActionDestination.reportPack,
    );
  }

  Iterable<FinancialReportReleaseActionItem> _signOffActions(
    List<FinancialReportReleaseSignOffItem> items,
  ) sync* {
    for (final item in items) {
      if (item.isSigned) {
        continue;
      }
      final returned = item.isReturned;
      yield FinancialReportReleaseActionItem(
        id: 'signoff-${item.id}',
        area: FinancialReportReleaseActionArea.signOff,
        priority:
            returned
                ? FinancialReportReleaseActionPriority.high
                : FinancialReportReleaseActionPriority.normal,
        title:
            returned
                ? 'Resolve returned sign-off: ${item.requirement.title}'
                : 'Complete sign-off: ${item.requirement.title}',
        owner: item.requirement.owner,
        dueDate: null,
        detail: item.resolution?.note ?? item.requirement.description,
        reference: '${item.role.label} / ${item.requirement.reference}',
        blocked: item.blocksRelease,
        destination: FinancialReportReleaseActionDestination.signOff,
      );
    }
  }

  Iterable<FinancialReportReleaseActionItem> _managementMeasureActions(
    List<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) sync* {
    for (final reconciliation in reconciliations) {
      if (reconciliation.hasOpenVariance) {
        yield FinancialReportReleaseActionItem(
          id: 'management-measure-variance-${reconciliation.measure.id}',
          area: FinancialReportReleaseActionArea.managementMeasures,
          priority: FinancialReportReleaseActionPriority.critical,
          title: 'Resolve UKTM variance: ${reconciliation.measure.label}',
          owner: reconciliation.measure.owner,
          dueDate: null,
          detail:
              'Variance ${_amount(reconciliation.variance)} against ${reconciliation.measure.closestSubtotalShortLabel}.',
          reference:
              'PSAK 118 / ${reconciliation.measure.approvalStatus.label}',
          blocked: true,
          destination:
              FinancialReportReleaseActionDestination
                  .managementMeasureReconciliationCheck,
        );
        continue;
      }

      if (!reconciliation.isApproved) {
        yield FinancialReportReleaseActionItem(
          id: 'management-measure-approval-${reconciliation.measure.id}',
          area: FinancialReportReleaseActionArea.managementMeasures,
          priority:
              reconciliation.measure.approvalStatus ==
                      FinancialReportManagementMeasureApprovalStatus.returned
                  ? FinancialReportReleaseActionPriority.high
                  : FinancialReportReleaseActionPriority.normal,
          title: 'Approve UKTM measure: ${reconciliation.measure.label}',
          owner: reconciliation.measure.owner,
          dueDate: null,
          detail:
              managementMeasureService.releaseLockedReason([reconciliation]) ??
              'Management measure is ready for release.',
          reference:
              '${reconciliation.measure.closestSubtotalShortLabel} / ${reconciliation.measure.approvalStatus.label}',
          blocked: true,
          destination:
              FinancialReportReleaseActionDestination
                  .managementMeasureApprovalCheck,
        );
      }
    }
  }

  Iterable<FinancialReportReleaseActionItem>
  _managementMeasureReleaseReadinessActions(
    FinancialReportManagementMeasureReleaseReadinessSummary summary,
  ) sync* {
    for (final item in summary.items) {
      if (item.isReady) {
        continue;
      }
      yield FinancialReportReleaseActionItem(
        id: 'management-measure-release-${item.kind.name}',
        area: FinancialReportReleaseActionArea.managementMeasures,
        priority: _managementMeasureReleaseCheckPriority(item.kind),
        title: _managementMeasureReleaseCheckTitle(item.kind),
        owner: 'Finance controller',
        dueDate: null,
        detail: item.detail,
        reference: 'UKTM release evidence / ${item.metric}',
        blocked: true,
        destination: _managementMeasureReleaseCheckDestination(item.kind),
      );
    }
  }

  Iterable<FinancialReportReleaseActionItem> _evidenceManifestActions(
    FinancialReportReleaseEvidenceManifestSummary summary,
  ) sync* {
    for (final item in summary.items) {
      if (!item.requiredForArchive ||
          item.status == FinancialReportReleaseEvidenceStatus.ready) {
        continue;
      }
      yield FinancialReportReleaseActionItem(
        id: 'evidence-${item.kind.name}',
        area: FinancialReportReleaseActionArea.evidenceManifest,
        priority:
            item.status == FinancialReportReleaseEvidenceStatus.missing
                ? FinancialReportReleaseActionPriority.high
                : FinancialReportReleaseActionPriority.normal,
        title: 'Prepare ${item.title}',
        owner: 'Finance controller',
        dueDate: null,
        detail: item.detail,
        reference: item.reference,
        blocked: item.status == FinancialReportReleaseEvidenceStatus.missing,
        destination: FinancialReportReleaseActionDestination.evidenceManifest,
      );
    }
  }

  Iterable<FinancialReportReleaseActionItem> _distributionActions(
    List<FinancialReportReleaseDistributionItem> items,
    DateTime asOf,
  ) sync* {
    for (final item in items) {
      if (item.isComplete) {
        continue;
      }
      final overdue = item.isOverdue(asOf);
      yield FinancialReportReleaseActionItem(
        id: 'distribution-${item.id}',
        area: FinancialReportReleaseActionArea.distribution,
        priority:
            overdue || item.hasException
                ? FinancialReportReleaseActionPriority.critical
                : FinancialReportReleaseActionPriority.high,
        title: _distributionTitle(item, overdue),
        owner: _owner(item.resolution?.owner, item.recipient.role),
        dueDate: item.recipient.dueDate,
        detail: item.resolution?.note ?? item.recipient.purpose,
        reference:
            item.recipient.requiresAcknowledgement
                ? '${item.recipient.channel.label} / acknowledgement required'
                : item.recipient.channel.label,
        blocked: item.hasException,
        destination: FinancialReportReleaseActionDestination.distribution,
      );
    }
  }

  Iterable<FinancialReportReleaseActionItem> _archiveActions(
    FinancialReportReleaseArchiveSummary summary,
  ) sync* {
    if (summary.isArchived) {
      return;
    }
    yield FinancialReportReleaseActionItem(
      id: 'archive-register',
      area: FinancialReportReleaseActionArea.archive,
      priority:
          summary.status == FinancialReportReleaseArchiveStatus.blocked
              ? FinancialReportReleaseActionPriority.high
              : FinancialReportReleaseActionPriority.normal,
      title:
          summary.status == FinancialReportReleaseArchiveStatus.blocked
              ? 'Complete archive evidence'
              : 'Create release archive register',
      owner: 'Finance archive owner',
      dueDate: null,
      detail: summary.nextAction,
      reference:
          '${summary.readyEvidenceCount}/${summary.evidenceItemCount} evidence item(s) ready',
      blocked: summary.status == FinancialReportReleaseArchiveStatus.blocked,
      destination: FinancialReportReleaseActionDestination.archive,
    );
  }

  Iterable<FinancialReportReleaseActionItem> _retentionActions(
    FinancialReportReleaseArchiveRetentionSummary summary,
  ) sync* {
    switch (summary.status) {
      case FinancialReportReleaseArchiveRetentionStatus.expired:
        yield FinancialReportReleaseActionItem(
          id: 'retention-expired',
          area: FinancialReportReleaseActionArea.retention,
          priority: FinancialReportReleaseActionPriority.critical,
          title: 'Escalate expired archive retention',
          owner: summary.record?.custodian ?? 'Finance archive owner',
          dueDate: summary.retainUntil,
          detail: summary.nextAction,
          reference: summary.periodLabel,
          blocked: true,
          destination: FinancialReportReleaseActionDestination.retention,
        );
        break;
      case FinancialReportReleaseArchiveRetentionStatus.reviewDue:
        yield FinancialReportReleaseActionItem(
          id: 'retention-review',
          area: FinancialReportReleaseActionArea.retention,
          priority: FinancialReportReleaseActionPriority.high,
          title: 'Complete archive retention review',
          owner: summary.record?.custodian ?? 'Finance archive owner',
          dueDate: summary.nextReviewDate,
          detail: summary.nextAction,
          reference: summary.periodLabel,
          destination: FinancialReportReleaseActionDestination.retention,
        );
        break;
      case FinancialReportReleaseArchiveRetentionStatus.notArchived:
      case FinancialReportReleaseArchiveRetentionStatus.active:
        break;
    }
  }

  Iterable<FinancialReportReleaseActionItem> _statutoryFilingActions(
    FinancialReportStatutoryFilingSummary summary,
  ) sync* {
    for (final item in summary.items) {
      if (item.kind !=
              FinancialReportStatutoryFilingKind.annualCorporateTaxSupport ||
          item.status == FinancialReportStatutoryFilingStatus.complete ||
          item.status == FinancialReportStatutoryFilingStatus.pending) {
        continue;
      }
      yield FinancialReportReleaseActionItem(
        id: 'statutory-${item.kind.name}',
        area: FinancialReportReleaseActionArea.statutoryFiling,
        priority: _statutoryPriority(item.status),
        title: item.title,
        owner: item.owner,
        dueDate: item.dueDate,
        detail: item.detail,
        reference: item.reference,
        blocked: item.status == FinancialReportStatutoryFilingStatus.blocked,
        destination: FinancialReportReleaseActionDestination.statutoryFiling,
      );
    }
  }

  String _distributionTitle(
    FinancialReportReleaseDistributionItem item,
    bool overdue,
  ) {
    if (item.hasException) {
      return 'Resolve distribution exception: ${item.recipient.name}';
    }
    if (overdue) {
      return 'Clear overdue distribution: ${item.recipient.name}';
    }
    if (item.isSent && item.recipient.requiresAcknowledgement) {
      return 'Capture acknowledgement: ${item.recipient.name}';
    }
    return 'Send report pack: ${item.recipient.name}';
  }

  FinancialReportReleaseActionPriority _statutoryPriority(
    FinancialReportStatutoryFilingStatus status,
  ) {
    switch (status) {
      case FinancialReportStatutoryFilingStatus.overdue:
      case FinancialReportStatutoryFilingStatus.blocked:
        return FinancialReportReleaseActionPriority.critical;
      case FinancialReportStatutoryFilingStatus.dueSoon:
        return FinancialReportReleaseActionPriority.high;
      case FinancialReportStatutoryFilingStatus.pending:
      case FinancialReportStatutoryFilingStatus.complete:
        return FinancialReportReleaseActionPriority.normal;
    }
  }

  FinancialReportReleaseActionPriority _managementMeasureReleaseCheckPriority(
    FinancialReportManagementMeasureReleaseCheckKind kind,
  ) {
    switch (kind) {
      case FinancialReportManagementMeasureReleaseCheckKind.auditTrail:
      case FinancialReportManagementMeasureReleaseCheckKind.reconciliation:
        return FinancialReportReleaseActionPriority.critical;
      case FinancialReportManagementMeasureReleaseCheckKind.approval:
      case FinancialReportManagementMeasureReleaseCheckKind.exportEvidence:
        return FinancialReportReleaseActionPriority.high;
    }
  }

  String _managementMeasureReleaseCheckTitle(
    FinancialReportManagementMeasureReleaseCheckKind kind,
  ) {
    switch (kind) {
      case FinancialReportManagementMeasureReleaseCheckKind.auditTrail:
        return 'Complete UKTM audit trail';
      case FinancialReportManagementMeasureReleaseCheckKind.approval:
        return 'Complete UKTM approval';
      case FinancialReportManagementMeasureReleaseCheckKind.reconciliation:
        return 'Resolve UKTM reconciliation';
      case FinancialReportManagementMeasureReleaseCheckKind.exportEvidence:
        return 'Prepare UKTM export evidence';
    }
  }

  FinancialReportReleaseActionDestination
  _managementMeasureReleaseCheckDestination(
    FinancialReportManagementMeasureReleaseCheckKind kind,
  ) {
    switch (kind) {
      case FinancialReportManagementMeasureReleaseCheckKind.auditTrail:
        return FinancialReportReleaseActionDestination
            .managementMeasureAuditTrail;
      case FinancialReportManagementMeasureReleaseCheckKind.approval:
        return FinancialReportReleaseActionDestination
            .managementMeasureApprovalCheck;
      case FinancialReportManagementMeasureReleaseCheckKind.reconciliation:
        return FinancialReportReleaseActionDestination
            .managementMeasureReconciliationCheck;
      case FinancialReportManagementMeasureReleaseCheckKind.exportEvidence:
        return FinancialReportReleaseActionDestination
            .managementMeasureExportEvidenceCheck;
    }
  }

  String _nextAction(
    List<FinancialReportReleaseActionItem> items,
    FinancialReportReleaseControlSummary controlSummary,
  ) {
    if (items.isEmpty) {
      return controlSummary.releaseComplete
          ? 'Release action queue is clear.'
          : controlSummary.nextAction;
    }
    final next = items.first;
    return '${next.title}: ${next.detail}';
  }

  int _compareAction(
    FinancialReportReleaseActionItem a,
    FinancialReportReleaseActionItem b,
  ) {
    final priority = _priorityRank(
      a.priority,
    ).compareTo(_priorityRank(b.priority));
    if (priority != 0) {
      return priority;
    }
    final due = _compareDueDates(a.dueDate, b.dueDate);
    if (due != 0) {
      return due;
    }
    final area = a.area.label.compareTo(b.area.label);
    if (area != 0) {
      return area;
    }
    return a.title.compareTo(b.title);
  }

  int _compareDueDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return a.compareTo(b);
  }

  int _priorityRank(FinancialReportReleaseActionPriority priority) {
    switch (priority) {
      case FinancialReportReleaseActionPriority.critical:
        return 0;
      case FinancialReportReleaseActionPriority.high:
        return 1;
      case FinancialReportReleaseActionPriority.normal:
        return 2;
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _owner(String? primary, String fallback) {
    final value = primary?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return fallback;
  }

  String _amount(double value) {
    final rounded = value.round();
    if ((value - rounded).abs() < 0.01) {
      return rounded.toString();
    }
    return value.toStringAsFixed(2);
  }
}
