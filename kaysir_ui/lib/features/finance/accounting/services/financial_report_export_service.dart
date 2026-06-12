import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../accounting_core/models/ledger_posting.dart';
import '../models/financial_period_close.dart';
import '../models/financial_period_close_audit.dart';
import '../models/financial_report_evidence_close_task.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_export.dart';
import '../models/financial_report_export_identity.dart';
import '../models/financial_report_going_concern_review.dart';
import '../models/financial_report_management_measure.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_release_action_queue.dart';
import '../models/financial_report_release_archive.dart';
import '../models/financial_report_release_archive_retention.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_evidence_manifest.dart';
import '../models/financial_report_release_milestone.dart';
import '../models/financial_report_release_signoff.dart';
import '../models/financial_report_review_exception.dart';
import '../models/financial_report_standard_transition.dart';
import '../models/financial_report_statutory_filing.dart';
import '../models/financial_report_subsequent_event_review.dart';
import 'financial_report_evidence_close_task_service.dart';
import 'financial_report_exception_resolution_service.dart';
import 'financial_report_export_identity_service.dart';
import 'financial_report_schedule_evidence_health_service.dart';

class FinancialReportExportService {
  final FinancialReportExceptionResolutionService exceptionResolutionService;
  final FinancialReportScheduleEvidenceHealthService
  scheduleEvidenceHealthService;
  final FinancialReportEvidenceCloseTaskService evidenceCloseTaskService;
  final FinancialReportExportIdentityService exportIdentityService;

  const FinancialReportExportService({
    this.exceptionResolutionService =
        const FinancialReportExceptionResolutionService(),
    this.scheduleEvidenceHealthService =
        const FinancialReportScheduleEvidenceHealthService(),
    this.evidenceCloseTaskService =
        const FinancialReportEvidenceCloseTaskService(),
    this.exportIdentityService = const FinancialReportExportIdentityService(),
  });

  Future<FinancialReportExportArtifact> buildPdf(
    FinancialReportPack pack, {
    FinancialPeriodCloseRecord? closeRecord,
    FinancialReportPackageIntegrity? packageIntegrity,
    List<FinancialReportExceptionResolution> exceptionResolutions = const [],
    List<FinancialReportEvidenceCloseTaskResolution> evidenceTaskResolutions =
        const [],
    List<FinancialReportEvidenceTaskAuditEvent> evidenceTaskAuditEvents =
        const [],
    List<FinancialReportManagementMeasureAuditEvent>
        managementMeasureAuditEvents =
        const [],
    List<FinancialReportReleaseSignOffItem> releaseSignOffItems = const [],
    List<FinancialReportReleaseSignOffAuditEvent> releaseSignOffAuditEvents =
        const [],
    List<FinancialReportReleaseDistributionItem> releaseDistributionItems =
        const [],
    List<FinancialReportReleaseDistributionAuditEvent>
        releaseDistributionAuditEvents =
        const [],
    FinancialReportReleaseActionQueueSummary? releaseActionQueueSummary,
    FinancialReportReleaseMilestoneSummary? releaseMilestoneSummary,
    FinancialReportStandardTransitionSummary? standardTransitionSummary,
    FinancialReportSubsequentEventReviewSummary? subsequentEventReviewSummary,
    FinancialReportGoingConcernReviewSummary? goingConcernReviewSummary,
    FinancialReportReleaseEvidenceManifestSummary? releaseEvidenceManifest,
    FinancialReportReleaseArchiveSummary? releaseArchiveSummary,
    List<FinancialReportReleaseArchiveAuditEvent> releaseArchiveAuditEvents =
        const [],
    FinancialReportReleaseArchiveRetentionSummary?
    releaseArchiveRetentionSummary,
    FinancialReportStatutoryFilingSummary? statutoryFilingSummary,
    List<LedgerPosting> postedAdjustmentJournals = const [],
    List<FinancialPeriodCloseAuditEvent> closeAuditTrail = const [],
  }) async {
    final reportExceptions = exceptionResolutionService.buildReviewItems(
      pack: pack,
      resolutions: exceptionResolutions,
      postedAdjustmentJournals: postedAdjustmentJournals,
    );
    final scheduleEvidenceHealth = scheduleEvidenceHealthService.summarize(
      pack.supportingSchedules,
    );
    final scheduleEvidenceHealthItems = scheduleEvidenceHealthService
        .summarizeBySchedule(pack.supportingSchedules);
    final evidenceCloseTaskItems = evidenceCloseTaskService.buildReviewItems(
      schedules: pack.supportingSchedules,
      resolutions: evidenceTaskResolutions,
      generatedAt: pack.generatedAt,
    );
    final exportIdentity = exportIdentityService.build(
      pack: pack,
      closeRecord: closeRecord,
      packageIntegrity: packageIntegrity,
      releaseEvidenceManifest: releaseEvidenceManifest,
    );
    final pdf = pw.Document(
      title: '${pack.entityName} Financial Report Pack',
      author: 'Kaysir',
      subject: pack.periodLabel,
    );
    final generatedAt = DateFormat(
      'MMM d, yyyy HH:mm',
    ).format(pack.generatedAt);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (context) => _footer(context, generatedAt),
        build:
            (context) => [
              _cover(pack),
              pw.SizedBox(height: 18),
              _packageIdentityTable(exportIdentity),
              pw.SizedBox(height: 18),
              _metricTable(pack),
              pw.SizedBox(height: 18),
              _complianceTable(pack),
              if (pack.supportingSchedules.isNotEmpty) ...[
                pw.SizedBox(height: 18),
                _scheduleEvidenceHealthTable(scheduleEvidenceHealth),
                pw.SizedBox(height: 8),
                _scheduleEvidenceHealthByScheduleTable(
                  scheduleEvidenceHealthItems,
                ),
                pw.SizedBox(height: 8),
                _evidenceCloseTasksTable(evidenceCloseTaskItems),
                if (evidenceTaskAuditEvents.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  _evidenceTaskAuditTable(evidenceTaskAuditEvents),
                ],
                pw.SizedBox(height: 12),
                ...pack.supportingSchedules.expand(
                  (schedule) => [
                    _supportingScheduleTable(pack, schedule),
                    pw.SizedBox(height: 12),
                  ],
                ),
              ],
              pw.SizedBox(height: 18),
              _reviewExceptionTable(pack, reportExceptions),
              if (_hasCloseCertificate(
                closeRecord,
                packageIntegrity,
                closeAuditTrail,
              )) ...[
                pw.SizedBox(height: 18),
                _closeCertificate(
                  closeRecord,
                  packageIntegrity,
                  closeAuditTrail,
                ),
              ],
              if (releaseSignOffItems.isNotEmpty ||
                  releaseSignOffAuditEvents.isNotEmpty ||
                  releaseDistributionItems.isNotEmpty ||
                  releaseDistributionAuditEvents.isNotEmpty ||
                  releaseActionQueueSummary != null ||
                  releaseMilestoneSummary != null ||
                  standardTransitionSummary != null ||
                  subsequentEventReviewSummary != null ||
                  goingConcernReviewSummary != null ||
                  releaseEvidenceManifest != null ||
                  releaseArchiveSummary != null ||
                  releaseArchiveAuditEvents.isNotEmpty ||
                  managementMeasureAuditEvents.isNotEmpty ||
                  releaseArchiveRetentionSummary != null ||
                  statutoryFilingSummary != null) ...[
                pw.SizedBox(height: 18),
                if (releaseActionQueueSummary != null) ...[
                  _releaseActionQueueTable(releaseActionQueueSummary),
                ],
                if (releaseMilestoneSummary != null) ...[
                  if (releaseActionQueueSummary != null) pw.SizedBox(height: 8),
                  _releaseMilestoneTable(releaseMilestoneSummary),
                ],
                if (standardTransitionSummary != null) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null)
                    pw.SizedBox(height: 8),
                  _standardTransitionTable(standardTransitionSummary),
                ],
                if (subsequentEventReviewSummary != null) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null)
                    pw.SizedBox(height: 8),
                  _subsequentEventReviewTable(subsequentEventReviewSummary),
                ],
                if (goingConcernReviewSummary != null) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null)
                    pw.SizedBox(height: 8),
                  _goingConcernReviewTable(goingConcernReviewSummary),
                ],
                if (releaseEvidenceManifest != null) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null)
                    pw.SizedBox(height: 8),
                  _releaseEvidenceManifestTable(releaseEvidenceManifest),
                ],
                if (releaseArchiveSummary != null) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null)
                    pw.SizedBox(height: 8),
                  _releaseArchiveTable(releaseArchiveSummary),
                ],
                if (releaseArchiveRetentionSummary != null) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null)
                    pw.SizedBox(height: 8),
                  _releaseArchiveRetentionTable(releaseArchiveRetentionSummary),
                ],
                if (statutoryFilingSummary != null) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null ||
                      releaseArchiveRetentionSummary != null)
                    pw.SizedBox(height: 8),
                  _statutoryFilingTable(statutoryFilingSummary),
                ],
                if (releaseArchiveAuditEvents.isNotEmpty) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null ||
                      releaseArchiveRetentionSummary != null ||
                      statutoryFilingSummary != null)
                    pw.SizedBox(height: 8),
                  _releaseArchiveAuditTable(releaseArchiveAuditEvents),
                ],
                if (releaseSignOffItems.isNotEmpty) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null ||
                      releaseArchiveRetentionSummary != null ||
                      statutoryFilingSummary != null ||
                      releaseArchiveAuditEvents.isNotEmpty)
                    pw.SizedBox(height: 8),
                  _releaseSignOffTable(releaseSignOffItems),
                ],
                if (managementMeasureAuditEvents.isNotEmpty) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null ||
                      releaseArchiveRetentionSummary != null ||
                      statutoryFilingSummary != null ||
                      releaseArchiveAuditEvents.isNotEmpty ||
                      releaseSignOffItems.isNotEmpty)
                    pw.SizedBox(height: 8),
                  _managementMeasureAuditTable(managementMeasureAuditEvents),
                ],
                if (releaseSignOffAuditEvents.isNotEmpty) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null ||
                      releaseArchiveRetentionSummary != null ||
                      statutoryFilingSummary != null ||
                      releaseArchiveAuditEvents.isNotEmpty ||
                      managementMeasureAuditEvents.isNotEmpty ||
                      releaseSignOffItems.isNotEmpty)
                    pw.SizedBox(height: 8),
                  _releaseSignOffAuditTable(releaseSignOffAuditEvents),
                ],
                if (releaseDistributionItems.isNotEmpty) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null ||
                      releaseArchiveRetentionSummary != null ||
                      statutoryFilingSummary != null ||
                      releaseArchiveAuditEvents.isNotEmpty ||
                      managementMeasureAuditEvents.isNotEmpty ||
                      releaseSignOffItems.isNotEmpty ||
                      releaseSignOffAuditEvents.isNotEmpty)
                    pw.SizedBox(height: 8),
                  _releaseDistributionTable(releaseDistributionItems),
                ],
                if (releaseDistributionAuditEvents.isNotEmpty) ...[
                  if (releaseActionQueueSummary != null ||
                      releaseMilestoneSummary != null ||
                      standardTransitionSummary != null ||
                      subsequentEventReviewSummary != null ||
                      goingConcernReviewSummary != null ||
                      releaseEvidenceManifest != null ||
                      releaseArchiveSummary != null ||
                      releaseArchiveRetentionSummary != null ||
                      statutoryFilingSummary != null ||
                      releaseArchiveAuditEvents.isNotEmpty ||
                      managementMeasureAuditEvents.isNotEmpty ||
                      releaseSignOffItems.isNotEmpty ||
                      releaseSignOffAuditEvents.isNotEmpty ||
                      releaseDistributionItems.isNotEmpty)
                    pw.SizedBox(height: 8),
                  _releaseDistributionAuditTable(
                    releaseDistributionAuditEvents,
                  ),
                ],
              ],
              pw.SizedBox(height: 18),
              ...pack.statements.expand(
                (statement) => [
                  _statementSection(pack, statement),
                  pw.SizedBox(height: 16),
                ],
              ),
              _notesSection(pack),
            ],
      ),
    );

    return FinancialReportExportArtifact(
      fileName: _fileName(pack, FinancialReportExportFormat.pdf),
      mimeType: FinancialReportExportFormat.pdf.mimeType,
      format: FinancialReportExportFormat.pdf,
      bytes: await pdf.save(),
    );
  }

  FinancialReportExportArtifact buildCsv(
    FinancialReportPack pack, {
    FinancialPeriodCloseRecord? closeRecord,
    FinancialReportPackageIntegrity? packageIntegrity,
    List<FinancialReportExceptionResolution> exceptionResolutions = const [],
    List<FinancialReportEvidenceCloseTaskResolution> evidenceTaskResolutions =
        const [],
    List<FinancialReportEvidenceTaskAuditEvent> evidenceTaskAuditEvents =
        const [],
    List<FinancialReportManagementMeasureAuditEvent>
        managementMeasureAuditEvents =
        const [],
    List<FinancialReportReleaseSignOffItem> releaseSignOffItems = const [],
    List<FinancialReportReleaseSignOffAuditEvent> releaseSignOffAuditEvents =
        const [],
    List<FinancialReportReleaseDistributionItem> releaseDistributionItems =
        const [],
    List<FinancialReportReleaseDistributionAuditEvent>
        releaseDistributionAuditEvents =
        const [],
    FinancialReportReleaseActionQueueSummary? releaseActionQueueSummary,
    FinancialReportReleaseMilestoneSummary? releaseMilestoneSummary,
    FinancialReportStandardTransitionSummary? standardTransitionSummary,
    FinancialReportSubsequentEventReviewSummary? subsequentEventReviewSummary,
    FinancialReportGoingConcernReviewSummary? goingConcernReviewSummary,
    FinancialReportReleaseEvidenceManifestSummary? releaseEvidenceManifest,
    FinancialReportReleaseArchiveSummary? releaseArchiveSummary,
    List<FinancialReportReleaseArchiveAuditEvent> releaseArchiveAuditEvents =
        const [],
    FinancialReportReleaseArchiveRetentionSummary?
    releaseArchiveRetentionSummary,
    FinancialReportStatutoryFilingSummary? statutoryFilingSummary,
    List<LedgerPosting> postedAdjustmentJournals = const [],
    List<FinancialPeriodCloseAuditEvent> closeAuditTrail = const [],
  }) {
    final reportExceptions = exceptionResolutionService.buildReviewItems(
      pack: pack,
      resolutions: exceptionResolutions,
      postedAdjustmentJournals: postedAdjustmentJournals,
    );
    final scheduleEvidenceHealth = scheduleEvidenceHealthService.summarize(
      pack.supportingSchedules,
    );
    final scheduleEvidenceHealthItems = scheduleEvidenceHealthService
        .summarizeBySchedule(pack.supportingSchedules);
    final evidenceCloseTaskItems = evidenceCloseTaskService.buildReviewItems(
      schedules: pack.supportingSchedules,
      resolutions: evidenceTaskResolutions,
      generatedAt: pack.generatedAt,
    );
    final exportIdentity = exportIdentityService.build(
      pack: pack,
      closeRecord: closeRecord,
      packageIntegrity: packageIntegrity,
      releaseEvidenceManifest: releaseEvidenceManifest,
    );
    final rows = <List<Object?>>[
      [
        'Entity',
        pack.entityName,
        'Framework',
        pack.frameworkName,
        'Jurisdiction',
        pack.jurisdiction,
      ],
      [
        'Period',
        pack.periodLabel,
        'As of',
        pack.asOfLabel,
        'Currency',
        pack.presentationCurrency,
      ],
      [
        'Tax profile',
        pack.taxProfile.label,
        'Benchmark',
        pack.taxProfile.rateLabel,
        'Reference',
        pack.taxProfile.standardReference,
      ],
      if (pack.hasComparativePeriod)
        [
          'Comparative period',
          pack.comparativePeriodLabel,
          'Comparative as of',
          pack.comparativeAsOfLabel,
          '',
          '',
        ],
      const [],
      ['Report Package Identity'],
      ['Field', 'Value'],
      ..._packageIdentityRows(exportIdentity),
      const [],
      ['Metrics'],
      ['Label', 'Current', 'Comparative', 'Variance', 'Helper'],
      ...pack.metrics.map(
        (metric) => [
          metric.label,
          metric.amount,
          metric.comparativeAmount,
          metric.variance,
          metric.helperText,
        ],
      ),
      const [],
      ['Compliance'],
      [
        'ID',
        'Title',
        'Reference',
        'Status',
        'Description',
        'Current variance',
        'Comparative variance',
        'Materiality threshold',
        'Materiality basis',
        'Material exception',
      ],
      ...pack.complianceItems.map(
        (item) => [
          item.id,
          item.title,
          item.standardReference,
          item.isSatisfied ? 'Ready' : 'Needs review',
          item.description,
          item.variance,
          item.comparativeVariance,
          item.materialityThreshold,
          item.materialityBasis ?? '',
          item.isMaterialVariance,
        ],
      ),
      const [],
      if (pack.supportingSchedules.isNotEmpty) ...[
        ['Supporting Schedule Evidence Health'],
        [
          'Status',
          'Critical signals',
          'Watch signals',
          'Ready signals',
          'Action',
        ],
        [
          scheduleEvidenceHealth.level.label,
          scheduleEvidenceHealth.criticalSignalCount,
          scheduleEvidenceHealth.watchSignalCount,
          scheduleEvidenceHealth.readySignalCount,
          scheduleEvidenceHealth.actionLabel,
        ],
        const [],
        ['Supporting Schedule Evidence By Schedule'],
        [
          'Schedule',
          'Status',
          'Critical signals',
          'Watch signals',
          'Ready signals',
          'Action',
        ],
        ...scheduleEvidenceHealthItems.map(
          (item) => [
            item.scheduleTitle,
            item.level.label,
            item.summary.criticalSignalCount,
            item.summary.watchSignalCount,
            item.summary.readySignalCount,
            item.actionLabel,
          ],
        ),
        const [],
        ['Supporting Schedule Close Tasks'],
        [
          'Task ID',
          'Schedule',
          'Priority',
          'Owner',
          'Due date',
          'Reviewer',
          'Blocks close',
          'Signals',
          'Reference',
          'Action',
          'Expected evidence',
          'Resolution status',
          'Resolved by',
          'Resolved at',
          'Resolution note',
          'Evidence reference',
        ],
        if (evidenceCloseTaskItems.isEmpty)
          [
            'none',
            '',
            'Ready',
            '',
            '',
            '',
            false,
            '',
            '',
            'No open evidence tasks',
            'Evidence ready',
            '',
            '',
            '',
            '',
            '',
          ]
        else
          ...evidenceCloseTaskItems.map(
            (item) => [
              item.id,
              item.task.scheduleTitle,
              item.priority.label,
              item.task.owner,
              _date(item.task.dueDate),
              item.task.reviewer,
              item.blocksClose,
              item.task.signalLabel,
              item.task.reference,
              item.task.actionLabel,
              item.task.evidenceLabel,
              item.resolution?.status.label ?? 'Open',
              item.resolution?.reviewer ?? '',
              _dateTime(item.resolution?.resolvedAt),
              item.resolution?.note ?? '',
              item.resolution?.evidenceReference ?? '',
            ],
          ),
        const [],
        if (evidenceTaskAuditEvents.isNotEmpty) ...[
          ['Supporting Schedule Close Task Audit Trail'],
          [
            'Action',
            'Occurred at',
            'Actor',
            'Task ID',
            'Task',
            'Schedule',
            'Resolution status',
            'Evidence reference',
            'Note',
          ],
          ...evidenceTaskAuditEvents.map(
            (event) => [
              event.action.label,
              _dateTime(event.occurredAt),
              event.actor,
              event.taskId,
              event.taskTitle,
              event.scheduleTitle,
              event.status.label,
              event.evidenceReference ?? '',
              event.note,
            ],
          ),
          const [],
        ],
        ['Supporting Schedule Metrics'],
        ['Schedule', 'Metric', 'Value', 'Helper'],
        ...pack.supportingSchedules.expand(
          (schedule) => schedule.metrics.map(
            (metric) => [
              schedule.title,
              metric.label,
              metric.value,
              metric.helperText,
            ],
          ),
        ),
        const [],
        ['Supporting Schedules'],
        [
          'Schedule',
          'Reference',
          'Line item',
          'Current',
          'Comparative',
          'Variance',
          'Source category',
          'Note',
        ],
        ...pack.supportingSchedules.expand(
          (schedule) => [
            ...schedule.lines.map(
              (line) => [
                schedule.title,
                schedule.standardReferences.join('; '),
                line.label,
                line.amount,
                line.comparativeAmount,
                line.variance,
                line.sourceCategory ?? '',
                line.noteReference == null ? '' : 'Note ${line.noteReference}',
              ],
            ),
            [
              schedule.title,
              '',
              schedule.totalLabel,
              schedule.totalAmount,
              schedule.comparativeTotalAmount,
              schedule.variance,
              '',
              '',
            ],
          ],
        ),
        const [],
      ],
      ['Report Exceptions'],
      [
        'ID',
        'Severity',
        'Source check',
        'Reference',
        'Description',
        'Current variance',
        'Comparative variance',
        'Materiality threshold',
        'Materiality basis',
        'Blocks close',
        'Resolution status',
        'Resolved by',
        'Resolved at',
        'Resolution note',
        'Adjustment reference',
        'Adjustment posting ID',
      ],
      if (reportExceptions.isEmpty)
        ['none', 'None', '', '', 'No unresolved report exceptions.']
      else
        ...reportExceptions.map(
          (item) => [
            item.id,
            item.severity.label,
            item.sourceComplianceId,
            item.exception.standardReference,
            item.exception.description,
            item.exception.variance,
            item.exception.comparativeVariance,
            item.exception.materialityThreshold,
            item.exception.materialityBasis ?? '',
            item.blocksClose,
            item.resolution?.status.label ?? 'Open',
            item.resolution?.reviewer ?? '',
            _dateTime(item.resolution?.resolvedAt),
            item.resolution?.note ?? '',
            item.resolution?.adjustmentReference ?? '',
            item.resolution?.adjustmentPostingId ?? '',
          ],
        ),
      const [],
      if (_hasCloseCertificate(
        closeRecord,
        packageIntegrity,
        closeAuditTrail,
      )) ...[
        ['Period Close Certificate'],
        ['Status', closeRecord?.status.label ?? 'Not closed'],
        ['Integrity status', packageIntegrity?.status.label ?? ''],
        ['Integrity detail', packageIntegrity?.detail ?? ''],
        ['Current fingerprint', packageIntegrity?.currentHash ?? ''],
        [
          'Current fingerprint algorithm',
          packageIntegrity?.currentAlgorithm ?? '',
        ],
        ['Closed at', _dateTime(closeRecord?.closedAt)],
        ['Closed by', closeRecord?.closedBy ?? ''],
        ['Reopened at', _dateTime(closeRecord?.reopenedAt)],
        ['Reopened by', closeRecord?.reopenedBy ?? ''],
        ['Reopen reason', closeRecord?.reopenReason ?? ''],
        ['Package fingerprint', closeRecord?.reportPackageHash ?? ''],
        [
          'Fingerprint algorithm',
          closeRecord?.reportPackageHashAlgorithm ?? '',
        ],
        ['Closing entry reference', closeRecord?.closingEntryReference ?? ''],
        ['Closing entry posting ID', closeRecord?.closingEntryPostingId ?? ''],
        [
          'Closing entry posted at',
          _dateTime(closeRecord?.closingEntryPostedAt),
        ],
        [
          'Readiness',
          closeRecord == null
              ? ''
              : '${(closeRecord.checklistReadinessRatio * 100).round()}%',
        ],
        ['Blockers', closeRecord?.blockerCount ?? ''],
        const [],
        if (closeAuditTrail.isNotEmpty) ...[
          ['Close Audit Trail'],
          [
            'Action',
            'Occurred at',
            'Actor',
            'Reason',
            'Readiness',
            'Blockers',
            'Package fingerprint',
            'Closing entry reference',
            'Closing entry posting ID',
            'Closing entry posted at',
          ],
          ...closeAuditTrail.map(
            (event) => [
              event.action.label,
              _dateTime(event.occurredAt),
              event.actor,
              event.reason ?? '',
              '${(event.checklistReadinessRatio * 100).round()}%',
              event.blockerCount,
              event.reportPackageHash ?? '',
              event.closingEntryReference ?? '',
              event.closingEntryPostingId ?? '',
              _dateTime(event.closingEntryPostedAt),
            ],
          ),
          const [],
        ],
      ],
      if (releaseActionQueueSummary != null) ...[
        ['Report Release Action Queue'],
        ['Open actions', releaseActionQueueSummary.totalCount],
        ['Critical', releaseActionQueueSummary.criticalCount],
        ['High', releaseActionQueueSummary.highCount],
        ['Overdue', releaseActionQueueSummary.overdueCount],
        ['Blocked', releaseActionQueueSummary.blockedCount],
        ['Next action', releaseActionQueueSummary.nextAction],
        [
          'Action',
          'Priority',
          'Area',
          'Owner',
          'Due date',
          'Blocked',
          'Reference',
          'Detail',
        ],
        ...releaseActionQueueSummary.items.map(
          (item) => [
            item.title,
            item.priority.label,
            item.area.label,
            item.owner,
            item.dueDate == null ? '' : _date(item.dueDate!),
            item.blocked,
            item.reference,
            item.detail,
          ],
        ),
        const [],
      ],
      if (releaseMilestoneSummary != null) ...[
        ['Report Release Milestone Calendar'],
        ['Complete', releaseMilestoneSummary.completeCount],
        ['Upcoming', releaseMilestoneSummary.upcomingCount],
        ['Due soon', releaseMilestoneSummary.dueSoonCount],
        ['Overdue', releaseMilestoneSummary.overdueCount],
        ['Blocked', releaseMilestoneSummary.blockedCount],
        ['Next action', releaseMilestoneSummary.nextAction],
        [
          'Milestone',
          'Status',
          'Area',
          'Due date',
          'Owner',
          'Reference',
          'Detail',
        ],
        ...releaseMilestoneSummary.items.map(
          (item) => [
            item.title,
            item.status.label,
            item.area.label,
            _date(item.dueDate),
            item.owner,
            item.reference,
            item.detail,
          ],
        ),
        const [],
      ],
      if (standardTransitionSummary != null) ...[
        ['PSAK 118 Transition Readiness'],
        [
          'Current standard',
          standardTransitionSummary.currentStandardReference,
        ],
        ['Next standard', standardTransitionSummary.nextStandardReference],
        ['Effective date', _date(standardTransitionSummary.effectiveDate)],
        ['Days until effective', standardTransitionSummary.daysUntilEffective],
        ['Ready', standardTransitionSummary.readyCount],
        ['Monitor', standardTransitionSummary.monitorCount],
        ['Action required', standardTransitionSummary.actionRequiredCount],
        ['Overdue', standardTransitionSummary.overdueCount],
        ['Headline', standardTransitionSummary.headline],
        ['Next action', standardTransitionSummary.nextAction],
        [
          'Review',
          'Status',
          'Metric',
          'Owner',
          'Reference',
          'Evidence',
          'Detail',
        ],
        ...standardTransitionSummary.items.map(
          (item) => [
            item.title,
            item.status.label,
            item.metric,
            item.owner,
            item.reference,
            item.evidenceReference,
            item.detail,
          ],
        ),
        const [],
      ],
      if (subsequentEventReviewSummary != null) ...[
        ['Subsequent Events Review'],
        ['Standard reference', subsequentEventReviewSummary.standardReference],
        ['Period end', _date(subsequentEventReviewSummary.periodEnd)],
        [
          'Authorization target',
          _date(subsequentEventReviewSummary.authorizationTargetDate),
        ],
        ['Review window days', subsequentEventReviewSummary.reviewWindowDays],
        ['Complete', subsequentEventReviewSummary.completeCount],
        ['Open', subsequentEventReviewSummary.openCount],
        ['Due soon', subsequentEventReviewSummary.dueSoonCount],
        ['Overdue', subsequentEventReviewSummary.overdueCount],
        ['Blocked', subsequentEventReviewSummary.blockedCount],
        ['Next action', subsequentEventReviewSummary.nextAction],
        [
          'Check',
          'Status',
          'Due date',
          'Owner',
          'Reference',
          'Evidence',
          'Detail',
        ],
        ...subsequentEventReviewSummary.items.map(
          (item) => [
            item.title,
            item.status.label,
            _date(item.dueDate),
            item.owner,
            item.reference,
            item.evidenceReference,
            item.detail,
          ],
        ),
        const [],
      ],
      if (goingConcernReviewSummary != null) ...[
        ['Going Concern Review'],
        ['Standard reference', goingConcernReviewSummary.standardReference],
        ['Satisfactory', goingConcernReviewSummary.satisfactoryCount],
        ['Watch', goingConcernReviewSummary.watchCount],
        ['Attention', goingConcernReviewSummary.attentionCount],
        [
          'Material uncertainty',
          goingConcernReviewSummary.materialUncertaintyCount,
        ],
        ['Incomplete', goingConcernReviewSummary.incompleteCount],
        ['Conclusion', goingConcernReviewSummary.conclusion],
        ['Next action', goingConcernReviewSummary.nextAction],
        [
          'Review',
          'Status',
          'Metric',
          'Owner',
          'Reference',
          'Evidence',
          'Detail',
        ],
        ...goingConcernReviewSummary.items.map(
          (item) => [
            item.title,
            item.status.label,
            item.metric,
            item.owner,
            item.reference,
            item.evidenceReference,
            item.detail,
          ],
        ),
        const [],
      ],
      if (releaseEvidenceManifest != null) ...[
        ['Report Release Evidence Manifest'],
        ['Archive ready', releaseEvidenceManifest.archiveReady],
        ['Next action', releaseEvidenceManifest.nextAction],
        ['Artifact', 'Status', 'Required', 'Reference', 'Detail'],
        ...releaseEvidenceManifest.items.map(
          (item) => [
            item.title,
            item.status.label,
            item.requiredForArchive,
            item.reference,
            item.detail,
          ],
        ),
        const [],
      ],
      if (releaseArchiveSummary != null) ...[
        ['Report Release Archive Register'],
        ['Status', releaseArchiveSummary.status.label],
        ['Evidence ready', releaseArchiveSummary.evidenceReady],
        ['Evidence items', releaseArchiveSummary.evidenceItemCount],
        ['Next action', releaseArchiveSummary.nextAction],
        if (releaseArchiveSummary.record != null) ...[
          ['Archive ID', releaseArchiveSummary.record!.archiveId],
          ['Archived at', _dateTime(releaseArchiveSummary.record!.archivedAt)],
          ['Archived by', releaseArchiveSummary.record!.archivedBy],
          ['Custodian', releaseArchiveSummary.record!.custodian],
          ['Storage location', releaseArchiveSummary.record!.storageLocation],
          ['Retention policy', releaseArchiveSummary.record!.retentionPolicy],
          ['Retain until', _date(releaseArchiveSummary.record!.retainUntil)],
          [
            'Package fingerprint',
            releaseArchiveSummary.record!.packageFingerprint,
          ],
          [
            'Package fingerprint algorithm',
            releaseArchiveSummary.record!.packageFingerprintAlgorithm,
          ],
          ['Note', releaseArchiveSummary.record!.note],
        ],
        const [],
      ],
      if (releaseArchiveRetentionSummary != null) ...[
        ['Report Release Archive Retention Monitor'],
        ['Status', releaseArchiveRetentionSummary.status.label],
        ['As of', _date(releaseArchiveRetentionSummary.asOf)],
        [
          'Retain until',
          releaseArchiveRetentionSummary.retainUntil == null
              ? ''
              : _date(releaseArchiveRetentionSummary.retainUntil!),
        ],
        [
          'Next review',
          releaseArchiveRetentionSummary.nextReviewDate == null
              ? ''
              : _date(releaseArchiveRetentionSummary.nextReviewDate!),
        ],
        [
          'Last review',
          releaseArchiveRetentionSummary.lastReviewAt == null
              ? ''
              : _date(releaseArchiveRetentionSummary.lastReviewAt!),
        ],
        ['Last reviewer', releaseArchiveRetentionSummary.lastReviewActor ?? ''],
        ['Days remaining', releaseArchiveRetentionSummary.daysRemaining ?? ''],
        [
          'Days until review',
          releaseArchiveRetentionSummary.daysUntilReview ?? '',
        ],
        ['Next action', releaseArchiveRetentionSummary.nextAction],
        ['Checkpoint', 'Value', 'Status', 'Detail'],
        ...releaseArchiveRetentionSummary.checkpoints.map(
          (checkpoint) => [
            checkpoint.title,
            checkpoint.value,
            checkpoint.status.label,
            checkpoint.detail,
          ],
        ),
        const [],
      ],
      if (statutoryFilingSummary != null) ...[
        ['Post-release Statutory Filing Tracker'],
        ['Complete', statutoryFilingSummary.completeCount],
        ['Due soon', statutoryFilingSummary.dueSoonCount],
        ['Overdue', statutoryFilingSummary.overdueCount],
        ['Blocked', statutoryFilingSummary.blockedCount],
        ['Next action', statutoryFilingSummary.nextAction],
        [
          'Filing',
          'Status',
          'Due date',
          'Owner',
          'Reference',
          'Evidence',
          'Detail',
        ],
        ...statutoryFilingSummary.items.map(
          (item) => [
            item.title,
            item.status.label,
            _date(item.dueDate),
            item.owner,
            item.reference,
            item.evidenceReference,
            item.detail,
          ],
        ),
        const [],
      ],
      if (releaseArchiveAuditEvents.isNotEmpty) ...[
        ['Report Release Archive Audit Trail'],
        [
          'Action',
          'Occurred at',
          'Actor',
          'Archive ID',
          'Period',
          'Custodian',
          'Storage location',
          'Retention policy',
          'Retain until',
          'Next review',
          'Package fingerprint',
          'Note',
        ],
        ...releaseArchiveAuditEvents.map(
          (event) => [
            event.action.label,
            _dateTime(event.occurredAt),
            event.actor,
            event.archiveId ?? '',
            event.periodLabel,
            event.custodian ?? '',
            event.storageLocation ?? '',
            event.retentionPolicy ?? '',
            event.retainUntil == null ? '' : _date(event.retainUntil!),
            event.nextReviewDate == null ? '' : _date(event.nextReviewDate!),
            event.packageFingerprint ?? '',
            event.note,
          ],
        ),
        const [],
      ],
      if (releaseSignOffItems.isNotEmpty) ...[
        ['Report Release Sign-offs'],
        [
          'Requirement',
          'Role',
          'Owner',
          'Reference',
          'Status',
          'Signer',
          'Signed at',
          'Note',
          'Evidence',
          'Blocks release',
        ],
        ...releaseSignOffItems.map(
          (item) => [
            item.requirement.title,
            item.role.label,
            item.requirement.owner,
            item.requirement.reference,
            item.statusLabel,
            item.resolution?.signer ?? '',
            _dateTime(item.resolution?.signedAt),
            item.resolution?.note ?? '',
            item.resolution?.evidenceReference ?? '',
            item.blocksRelease,
          ],
        ),
        const [],
      ],
      if (releaseSignOffAuditEvents.isNotEmpty) ...[
        ['Report Release Sign-off Audit Trail'],
        [
          'Action',
          'Occurred at',
          'Actor',
          'Requirement',
          'Role',
          'Status',
          'Period',
          'Note',
          'Evidence',
        ],
        ...releaseSignOffAuditEvents.map(
          (event) => [
            event.action.label,
            _dateTime(event.occurredAt),
            event.actor,
            event.requirementTitle,
            event.role.label,
            event.status?.label ?? '',
            event.periodLabel,
            event.note,
            event.evidenceReference ?? '',
          ],
        ),
        const [],
      ],
      if (managementMeasureAuditEvents.isNotEmpty) ...[
        ['UKTM Audit Trail'],
        [
          'Action',
          'Occurred at',
          'Actor',
          'Measure',
          'Status',
          'Period',
          'Note',
        ],
        ...managementMeasureAuditEvents.map(
          (event) => [
            event.action.label,
            _dateTime(event.occurredAt),
            event.actor,
            event.measureLabel,
            event.status?.label ?? '',
            event.periodLabel,
            event.note,
          ],
        ),
        const [],
      ],
      if (releaseDistributionItems.isNotEmpty) ...[
        ['Report Release Distribution Register'],
        [
          'Recipient',
          'Role',
          'Organization',
          'Channel',
          'Requires acknowledgement',
          'Due date',
          'Status',
          'Owner',
          'Updated at',
          'Note',
          'Evidence',
          'Complete',
        ],
        ...releaseDistributionItems.map(
          (item) => [
            item.recipient.name,
            item.recipient.role,
            item.recipient.organization,
            item.recipient.channel.label,
            item.recipient.requiresAcknowledgement,
            _date(item.recipient.dueDate),
            item.statusLabel,
            item.resolution?.owner ?? '',
            _dateTime(item.resolution?.updatedAt),
            item.resolution?.note ?? '',
            item.resolution?.evidenceReference ?? '',
            item.isComplete,
          ],
        ),
        const [],
      ],
      if (releaseDistributionAuditEvents.isNotEmpty) ...[
        ['Report Release Distribution Audit Trail'],
        [
          'Action',
          'Occurred at',
          'Actor',
          'Recipient',
          'Channel',
          'Status',
          'Period',
          'Note',
          'Evidence',
        ],
        ...releaseDistributionAuditEvents.map(
          (event) => [
            event.action.label,
            _dateTime(event.occurredAt),
            event.actor,
            event.recipientName,
            event.channel.label,
            event.status?.label ?? '',
            event.periodLabel,
            event.note,
            event.evidenceReference ?? '',
          ],
        ),
        const [],
      ],
    ];

    for (final statement in pack.statements) {
      rows.addAll([
        [statement.title],
        [statement.subtitle],
        ['Line item', 'Current', 'Comparative', 'Variance', 'Note'],
        ...statement.lines.map(
          (line) => [
            line.label,
            line.amount,
            line.comparativeAmount,
            line.variance,
            line.noteReference,
          ],
        ),
        const [],
      ]);
    }

    rows.addAll([
      ['Notes'],
      ['Number', 'Title', 'Body', 'References'],
      ...pack.notes.map(
        (note) => [
          note.number,
          note.title,
          note.body,
          note.standardReferences.join('; '),
        ],
      ),
    ]);

    return FinancialReportExportArtifact(
      fileName: _fileName(pack, FinancialReportExportFormat.csv),
      mimeType: FinancialReportExportFormat.csv.mimeType,
      format: FinancialReportExportFormat.csv,
      bytes: Uint8List.fromList(
        utf8.encode(const ListToCsvConverter().convert(rows)),
      ),
    );
  }

  pw.Widget _closeCertificate(
    FinancialPeriodCloseRecord? closeRecord,
    FinancialReportPackageIntegrity? packageIntegrity,
    List<FinancialPeriodCloseAuditEvent> closeAuditTrail,
  ) {
    final rows = <List<String>>[
      ['Status', closeRecord?.status.label ?? 'Not closed'],
      ['Integrity status', packageIntegrity?.status.label ?? ''],
      ['Integrity detail', packageIntegrity?.detail ?? ''],
      ['Current fingerprint', packageIntegrity?.currentHash ?? ''],
      [
        'Current fingerprint algorithm',
        packageIntegrity?.currentAlgorithm ?? '',
      ],
      ['Closed at', _dateTime(closeRecord?.closedAt)],
      ['Closed by', closeRecord?.closedBy ?? ''],
      ['Reopened at', _dateTime(closeRecord?.reopenedAt)],
      ['Reopened by', closeRecord?.reopenedBy ?? ''],
      ['Reopen reason', closeRecord?.reopenReason ?? ''],
      ['Package fingerprint', closeRecord?.reportPackageHash ?? ''],
      ['Fingerprint algorithm', closeRecord?.reportPackageHashAlgorithm ?? ''],
      ['Closing entry', closeRecord?.closingEntryEvidenceLabel ?? ''],
      ['Closing entry posting ID', closeRecord?.closingEntryPostingId ?? ''],
      ['Closing entry posted at', _dateTime(closeRecord?.closingEntryPostedAt)],
      [
        'Readiness',
        closeRecord == null
            ? ''
            : '${(closeRecord.checklistReadinessRatio * 100).round()}%',
      ],
      ['Blockers', closeRecord?.blockerCount.toString() ?? ''],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _textTable(
          title: 'Period Close Certificate',
          headers: const ['Field', 'Value'],
          rows: rows,
        ),
        if (closeAuditTrail.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          _textTable(
            title: 'Close Audit Trail',
            headers: const [
              'Action',
              'Occurred at',
              'Actor',
              'Reason',
              'Readiness',
              'Blockers',
              'Package fingerprint',
              'Closing entry',
            ],
            rows:
                closeAuditTrail
                    .map(
                      (event) => [
                        event.action.label,
                        _dateTime(event.occurredAt),
                        event.actor,
                        event.reason ?? '',
                        '${(event.checklistReadinessRatio * 100).round()}%',
                        event.blockerCount.toString(),
                        event.reportPackageHash ?? '',
                        event.closingEntryEvidenceLabel ?? '',
                      ],
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }

  pw.Widget _releaseSignOffTable(
    List<FinancialReportReleaseSignOffItem> items,
  ) {
    return _textTable(
      title: 'Report Release Sign-offs',
      headers: const [
        'Requirement',
        'Role',
        'Status',
        'Signer',
        'Signed at',
        'Evidence',
      ],
      rows:
          items
              .map(
                (item) => [
                  item.requirement.title,
                  item.role.label,
                  item.statusLabel,
                  item.resolution?.signer ?? '',
                  _dateTime(item.resolution?.signedAt),
                  item.resolution?.evidenceReference ?? '',
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseEvidenceManifestTable(
    FinancialReportReleaseEvidenceManifestSummary summary,
  ) {
    return _textTable(
      title: 'Report Release Evidence Manifest',
      subtitle: summary.nextAction,
      headers: const ['Artifact', 'Status', 'Required', 'Reference'],
      rows:
          summary.items
              .map(
                (item) => [
                  item.title,
                  item.status.label,
                  item.requiredForArchive ? 'Yes' : 'No',
                  item.reference,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseActionQueueTable(
    FinancialReportReleaseActionQueueSummary summary,
  ) {
    return _textTable(
      title: 'Report Release Action Queue',
      subtitle: summary.nextAction,
      headers: const ['Action', 'Priority', 'Area', 'Due'],
      rows:
          summary.items
              .map(
                (item) => [
                  item.title,
                  item.priority.label,
                  item.area.label,
                  item.dueDate == null ? '' : _date(item.dueDate!),
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseMilestoneTable(
    FinancialReportReleaseMilestoneSummary summary,
  ) {
    return _textTable(
      title: 'Report Release Milestone Calendar',
      subtitle: summary.nextAction,
      headers: const ['Milestone', 'Status', 'Due', 'Owner'],
      rows:
          summary.items
              .map(
                (item) => [
                  item.title,
                  item.status.label,
                  _date(item.dueDate),
                  item.owner,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _subsequentEventReviewTable(
    FinancialReportSubsequentEventReviewSummary summary,
  ) {
    return _textTable(
      title: 'Subsequent Events Review',
      subtitle: summary.nextAction,
      headers: const ['Check', 'Status', 'Due', 'Evidence'],
      rows:
          summary.items
              .map(
                (item) => [
                  item.title,
                  item.status.label,
                  _date(item.dueDate),
                  item.evidenceReference,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _standardTransitionTable(
    FinancialReportStandardTransitionSummary summary,
  ) {
    return _textTable(
      title: 'PSAK 118 Transition Readiness',
      subtitle: summary.nextAction,
      headers: const ['Review', 'Status', 'Metric', 'Evidence'],
      rows:
          summary.items
              .map(
                (item) => [
                  item.title,
                  item.status.label,
                  item.metric,
                  item.evidenceReference,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _goingConcernReviewTable(
    FinancialReportGoingConcernReviewSummary summary,
  ) {
    return _textTable(
      title: 'Going Concern Review',
      subtitle: summary.nextAction,
      headers: const ['Review', 'Status', 'Metric', 'Evidence'],
      rows:
          summary.items
              .map(
                (item) => [
                  item.title,
                  item.status.label,
                  item.metric,
                  item.evidenceReference,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseArchiveTable(FinancialReportReleaseArchiveSummary summary) {
    final record = summary.record;
    return _textTable(
      title: 'Report Release Archive Register',
      subtitle: summary.nextAction,
      headers: const ['Field', 'Value'],
      rows: [
        ['Status', summary.status.label],
        [
          'Evidence',
          '${summary.readyEvidenceCount}/${summary.evidenceItemCount} ready',
        ],
        if (record != null) ...[
          ['Archive ID', record.archiveId],
          ['Archived at', _dateTime(record.archivedAt)],
          ['Archived by', record.archivedBy],
          ['Custodian', record.custodian],
          ['Storage location', record.storageLocation],
          ['Retention policy', record.retentionPolicy],
          ['Retain until', _date(record.retainUntil)],
          [
            'Package fingerprint',
            '${record.packageFingerprintAlgorithm} ${record.shortFingerprint}',
          ],
          ['Note', record.note],
        ],
      ],
    );
  }

  pw.Widget _releaseArchiveRetentionTable(
    FinancialReportReleaseArchiveRetentionSummary summary,
  ) {
    return _textTable(
      title: 'Report Release Archive Retention Monitor',
      subtitle: summary.nextAction,
      headers: const ['Field', 'Value'],
      rows: [
        ['Status', summary.status.label],
        ['As of', _date(summary.asOf)],
        [
          'Retain until',
          summary.retainUntil == null ? '' : _date(summary.retainUntil!),
        ],
        [
          'Next review',
          summary.nextReviewDate == null ? '' : _date(summary.nextReviewDate!),
        ],
        [
          'Last review',
          summary.lastReviewAt == null ? '' : _date(summary.lastReviewAt!),
        ],
        ['Last reviewer', summary.lastReviewActor ?? ''],
        ['Days remaining', summary.daysRemaining?.toString() ?? ''],
        ['Days until review', summary.daysUntilReview?.toString() ?? ''],
        ...summary.checkpoints.map(
          (checkpoint) => [
            checkpoint.title,
            '${checkpoint.value} / ${checkpoint.status.label}',
          ],
        ),
      ],
    );
  }

  pw.Widget _statutoryFilingTable(
    FinancialReportStatutoryFilingSummary summary,
  ) {
    return _textTable(
      title: 'Post-release Statutory Filing Tracker',
      subtitle: summary.nextAction,
      headers: const ['Filing', 'Status', 'Due', 'Evidence'],
      rows:
          summary.items
              .map(
                (item) => [
                  item.title,
                  item.status.label,
                  _date(item.dueDate),
                  item.evidenceReference,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseArchiveAuditTable(
    List<FinancialReportReleaseArchiveAuditEvent> events,
  ) {
    return _textTable(
      title: 'Report Release Archive Audit Trail',
      headers: const [
        'Action',
        'Occurred',
        'Actor',
        'Archive',
        'Retain until',
        'Next review',
        'Note',
      ],
      rows:
          events
              .map(
                (event) => [
                  event.action.label,
                  _dateTime(event.occurredAt),
                  event.actor,
                  event.archiveId ?? '',
                  event.retainUntil == null ? '' : _date(event.retainUntil!),
                  event.nextReviewDate == null
                      ? ''
                      : _date(event.nextReviewDate!),
                  event.note,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseSignOffAuditTable(
    List<FinancialReportReleaseSignOffAuditEvent> events,
  ) {
    return _textTable(
      title: 'Report Release Sign-off Audit Trail',
      headers: const [
        'Action',
        'Occurred',
        'Actor',
        'Requirement',
        'Status',
        'Evidence',
      ],
      rows:
          events
              .map(
                (event) => [
                  event.action.label,
                  _dateTime(event.occurredAt),
                  event.actor,
                  event.requirementTitle,
                  event.status?.label ?? '',
                  event.evidenceReference ?? '',
                ],
              )
              .toList(),
    );
  }

  pw.Widget _managementMeasureAuditTable(
    List<FinancialReportManagementMeasureAuditEvent> events,
  ) {
    return _textTable(
      title: 'UKTM Audit Trail',
      headers: const [
        'Action',
        'Occurred',
        'Actor',
        'Measure',
        'Status',
        'Note',
      ],
      rows:
          events
              .map(
                (event) => [
                  event.action.label,
                  _dateTime(event.occurredAt),
                  event.actor,
                  event.measureLabel,
                  event.status?.label ?? '',
                  event.note,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseDistributionTable(
    List<FinancialReportReleaseDistributionItem> items,
  ) {
    return _textTable(
      title: 'Report Release Distribution Register',
      headers: const [
        'Recipient',
        'Channel',
        'Due',
        'Status',
        'Owner',
        'Evidence',
      ],
      rows:
          items
              .map(
                (item) => [
                  item.recipient.name,
                  item.recipient.channel.label,
                  _date(item.recipient.dueDate),
                  item.statusLabel,
                  item.resolution?.owner ?? '',
                  item.resolution?.evidenceReference ?? '',
                ],
              )
              .toList(),
    );
  }

  pw.Widget _releaseDistributionAuditTable(
    List<FinancialReportReleaseDistributionAuditEvent> events,
  ) {
    return _textTable(
      title: 'Report Release Distribution Audit Trail',
      headers: const [
        'Action',
        'Occurred',
        'Actor',
        'Recipient',
        'Status',
        'Evidence',
      ],
      rows:
          events
              .map(
                (event) => [
                  event.action.label,
                  _dateTime(event.occurredAt),
                  event.actor,
                  event.recipientName,
                  event.status?.label ?? '',
                  event.evidenceReference ?? '',
                ],
              )
              .toList(),
    );
  }

  pw.Widget _cover(FinancialReportPack pack) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blueGrey100),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${pack.entityName} Financial Report Pack',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('${pack.frameworkName} - ${pack.jurisdiction}'),
          pw.SizedBox(height: 4),
          pw.Text('Period: ${pack.periodLabel}'),
          pw.Text('As of: ${pack.asOfLabel}'),
          if (pack.hasComparativePeriod)
            pw.Text('Comparative: ${pack.comparativePeriodLabel}'),
          pw.Text('Presentation currency: ${pack.presentationCurrency}'),
          pw.Text(
            'Tax benchmark: ${pack.taxProfile.label} (${pack.taxProfile.rateLabel})',
          ),
        ],
      ),
    );
  }

  pw.Widget _packageIdentityTable(FinancialReportExportIdentity identity) {
    return _textTable(
      title: 'Report Package Identity',
      subtitle: identity.packageStatus,
      headers: const ['Field', 'Value'],
      rows: _packageIdentityRows(identity),
    );
  }

  List<List<String>> _packageIdentityRows(
    FinancialReportExportIdentity identity,
  ) {
    return [
      ['Generated by', identity.generatedBy],
      ['Generated at', _dateTime(identity.generatedAt)],
      ['Entity', identity.entityName],
      ['Period', identity.periodLabel],
      ['Framework', identity.frameworkName],
      ['Jurisdiction', identity.jurisdiction],
      ['Currency', identity.currency],
      ['Package status', identity.packageStatus],
      ['Integrity detail', identity.packageDetail],
      ['Period lock hash', identity.periodLockHashLabel],
      ['Closed package algorithm', identity.closedPackageAlgorithmLabel],
      ['Current package hash', identity.currentPackageHashLabel],
      ['Current package algorithm', identity.currentPackageAlgorithmLabel],
      ['Evidence manifest', identity.evidenceManifestLabel],
      ['Archive ready', identity.archiveReadyLabel],
      ['Next release action', identity.releaseNextActionLabel],
    ];
  }

  pw.Widget _metricTable(FinancialReportPack pack) {
    final rows =
        pack.metrics
            .map(
              (metric) => [
                metric.label,
                _money(pack, metric.amount),
                _optionalMoney(pack, metric.comparativeAmount),
                _optionalMoney(pack, metric.variance),
              ],
            )
            .toList();

    return _textTable(
      title: 'Key Metrics',
      headers: const ['Metric', 'Current', 'Comparative', 'Variance'],
      rows: rows,
    );
  }

  pw.Widget _complianceTable(FinancialReportPack pack) {
    final rows =
        pack.complianceItems
            .map(
              (item) => [
                item.title,
                item.standardReference,
                item.isSatisfied ? 'Ready' : 'Needs review',
                item.hasVarianceEvidence
                    ? _complianceVarianceLabel(pack, item)
                    : '',
                item.hasMaterialityEvidence
                    ? _complianceMaterialityLabel(pack, item)
                    : '',
              ],
            )
            .toList();

    return _textTable(
      title: 'SAK / IFRS Readiness',
      headers: const [
        'Check',
        'Reference',
        'Status',
        'Variance',
        'Materiality',
      ],
      rows: rows,
    );
  }

  pw.Widget _scheduleEvidenceHealthTable(
    FinancialReportScheduleEvidenceHealthSummary summary,
  ) {
    return _textTable(
      title: 'Supporting Schedule Evidence Health',
      headers: const ['Status', 'Critical', 'Watch', 'Ready', 'Action'],
      rows: [
        [
          summary.level.label,
          summary.criticalSignalCount.toString(),
          summary.watchSignalCount.toString(),
          summary.readySignalCount.toString(),
          summary.actionLabel,
        ],
      ],
    );
  }

  pw.Widget _scheduleEvidenceHealthByScheduleTable(
    List<FinancialReportScheduleEvidenceHealthItem> items,
  ) {
    return _textTable(
      title: 'Supporting Schedule Evidence By Schedule',
      headers: const [
        'Schedule',
        'Status',
        'Critical',
        'Watch',
        'Ready',
        'Action',
      ],
      rows:
          items
              .map(
                (item) => [
                  item.scheduleTitle,
                  item.level.label,
                  item.summary.criticalSignalCount.toString(),
                  item.summary.watchSignalCount.toString(),
                  item.summary.readySignalCount.toString(),
                  item.actionLabel,
                ],
              )
              .toList(),
    );
  }

  pw.Widget _evidenceCloseTasksTable(
    List<FinancialReportEvidenceCloseTaskReviewItem> items,
  ) {
    return _textTable(
      title: 'Supporting Schedule Close Tasks',
      headers: const [
        'Task',
        'Priority',
        'Owner',
        'Due',
        'Reviewer',
        'Status',
        'Action',
      ],
      rows:
          items.isEmpty
              ? const [
                [
                  'No open evidence tasks',
                  'Ready',
                  '',
                  '',
                  '',
                  '',
                  'Evidence ready',
                ],
              ]
              : items
                  .map(
                    (item) => [
                      item.task.scheduleTitle,
                      item.priority.label,
                      item.task.owner,
                      _date(item.task.dueDate),
                      item.task.reviewer,
                      item.resolution?.status.label ?? 'Open',
                      item.task.actionLabel,
                    ],
                  )
                  .toList(),
    );
  }

  pw.Widget _evidenceTaskAuditTable(
    List<FinancialReportEvidenceTaskAuditEvent> events,
  ) {
    return _textTable(
      title: 'Supporting Schedule Close Task Audit Trail',
      headers: const [
        'Action',
        'Occurred',
        'Actor',
        'Schedule',
        'Status',
        'Reference',
      ],
      rows:
          events
              .map(
                (event) => [
                  event.action.label,
                  _dateTime(event.occurredAt),
                  event.actor,
                  event.scheduleTitle,
                  event.status.label,
                  event.evidenceReference ?? '',
                ],
              )
              .toList(),
    );
  }

  pw.Widget _supportingScheduleTable(
    FinancialReportPack pack,
    FinancialReportSupportingSchedule schedule,
  ) {
    final rows = [
      ...schedule.lines.map(
        (line) => [
          line.label,
          _money(pack, line.amount),
          _optionalMoney(pack, line.comparativeAmount),
          _optionalMoney(pack, line.variance),
          line.sourceCategory ?? '',
        ],
      ),
      [
        schedule.totalLabel,
        _money(pack, schedule.totalAmount),
        _optionalMoney(pack, schedule.comparativeTotalAmount),
        _optionalMoney(pack, schedule.variance),
        '',
      ],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (schedule.metrics.isNotEmpty) ...[
          _textTable(
            title: '${schedule.title} Metrics',
            subtitle:
                '${schedule.subtitle} - ${schedule.standardReferences.join(', ')}',
            headers: const ['Metric', 'Value', 'Evidence'],
            rows:
                schedule.metrics
                    .map(
                      (metric) => [
                        metric.label,
                        metric.value,
                        metric.helperText,
                      ],
                    )
                    .toList(),
          ),
          pw.SizedBox(height: 8),
        ],
        _textTable(
          title: schedule.title,
          subtitle:
              '${schedule.subtitle} - ${schedule.standardReferences.join(', ')}',
          headers: const [
            'Line item',
            'Current',
            'Comparative',
            'Variance',
            'Source',
          ],
          rows: rows,
        ),
      ],
    );
  }

  pw.Widget _reviewExceptionTable(
    FinancialReportPack pack,
    List<FinancialReportExceptionReviewItem> exceptions,
  ) {
    final rows = <List<String>>[
      if (exceptions.isEmpty)
        const ['None', '', 'No unresolved report exceptions.', '', '']
      else
        ...exceptions.map(
          (item) => [
            item.severity.label,
            item.sourceComplianceId,
            item.exception.standardReference,
            _exceptionVarianceLabel(pack, item),
            _exceptionResolutionLabel(pack, item),
          ],
        ),
    ];

    return _textTable(
      title: 'Report Exception Register',
      headers: const [
        'Severity',
        'Source',
        'Reference',
        'Variance',
        'Resolution',
      ],
      rows: rows,
    );
  }

  pw.Widget _statementSection(
    FinancialReportPack pack,
    FinancialReportStatement statement,
  ) {
    final rows =
        statement.lines
            .map(
              (line) => [
                '${'  ' * line.indentLevel}${line.label}',
                _optionalMoney(pack, line.amount),
                _optionalMoney(pack, line.comparativeAmount),
                _optionalMoney(pack, line.variance),
                line.noteReference == null ? '' : 'Note ${line.noteReference}',
              ],
            )
            .toList();

    return _textTable(
      title: statement.title,
      subtitle: statement.subtitle,
      headers: const [
        'Line item',
        'Current',
        'Comparative',
        'Variance',
        'Note',
      ],
      rows: rows,
    );
  }

  pw.Widget _notesSection(FinancialReportPack pack) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Notes'),
        ...pack.notes.map(
          (note) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${note.number}. ${note.title}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(note.body, style: const pw.TextStyle(fontSize: 9)),
                pw.Text(
                  note.standardReferences.join(', '),
                  style: const pw.TextStyle(
                    color: PdfColors.blueGrey600,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _hasCloseCertificate(
    FinancialPeriodCloseRecord? closeRecord,
    FinancialReportPackageIntegrity? packageIntegrity,
    List<FinancialPeriodCloseAuditEvent> closeAuditTrail,
  ) {
    final hasIntegrity =
        packageIntegrity != null &&
        packageIntegrity.status !=
            FinancialReportPackageIntegrityStatus.notClosed;
    return closeRecord != null || hasIntegrity || closeAuditTrail.isNotEmpty;
  }

  pw.Widget _textTable({
    required String title,
    String? subtitle,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        if (subtitle != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(
              subtitle,
              style: const pw.TextStyle(color: PdfColors.blueGrey600),
            ),
          ),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
          border: pw.TableBorder.all(color: PdfColors.blueGrey100),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 4,
          ),
        ),
      ],
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _footer(pw.Context context, String generatedAt) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated $generatedAt',
          style: const pw.TextStyle(color: PdfColors.blueGrey500, fontSize: 8),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(color: PdfColors.blueGrey500, fontSize: 8),
        ),
      ],
    );
  }

  String _money(FinancialReportPack pack, double value) {
    return NumberFormat.currency(
      symbol: '${pack.presentationCurrency} ',
      decimalDigits: 0,
    ).format(value);
  }

  String _optionalMoney(FinancialReportPack pack, double? value) {
    if (value == null) {
      return '';
    }
    return _money(pack, value);
  }

  String _complianceVarianceLabel(
    FinancialReportPack pack,
    FinancialReportComplianceItem item,
  ) {
    final values = <String>[];
    final variance = item.variance;
    if (variance != null) {
      values.add('Current ${_money(pack, variance)}');
    }
    final comparativeVariance = item.comparativeVariance;
    if (comparativeVariance != null) {
      values.add('Comparative ${_money(pack, comparativeVariance)}');
    }
    return values.join(' | ');
  }

  String _complianceMaterialityLabel(
    FinancialReportPack pack,
    FinancialReportComplianceItem item,
  ) {
    final threshold = item.materialityThreshold;
    if (threshold == null) {
      return '';
    }
    final status =
        item.isMaterialVariance ? 'Material exception' : 'Below threshold';
    final basis = item.materialityBasis;
    if (basis == null || basis.isEmpty) {
      return '$status at ${_money(pack, threshold)}';
    }
    return '$status at ${_money(pack, threshold)} ($basis)';
  }

  String _exceptionVarianceLabel(
    FinancialReportPack pack,
    FinancialReportExceptionReviewItem item,
  ) {
    final exception = item.exception;
    if (!exception.hasVarianceEvidence) {
      return '';
    }
    final values = <String>[];
    final variance = exception.variance;
    if (variance != null) {
      values.add('Current ${_money(pack, variance)}');
    }
    final comparativeVariance = exception.comparativeVariance;
    if (comparativeVariance != null) {
      values.add('Comparative ${_money(pack, comparativeVariance)}');
    }
    return values.join(' | ');
  }

  String _exceptionResolutionLabel(
    FinancialReportPack pack,
    FinancialReportExceptionReviewItem item,
  ) {
    final exception = item.exception;
    final threshold = exception.materialityThreshold;
    final materiality =
        threshold == null ? '' : 'Threshold ${_money(pack, threshold)}';
    final resolution = item.resolution;
    if (resolution == null) {
      return materiality.isEmpty ? 'Open' : 'Open - $materiality';
    }
    final reference = resolution.adjustmentReference;
    final status =
        reference == null || reference.isEmpty
            ? resolution.status.label
            : '${resolution.status.label} ($reference)';
    final postingId = resolution.adjustmentPostingId;
    final statusWithPosting =
        postingId == null || postingId.isEmpty
            ? status
            : '$status / posting $postingId';
    if (materiality.isEmpty) {
      return statusWithPosting;
    }
    return '$statusWithPosting - $materiality';
  }

  String _dateTime(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateFormat('MMM d, yyyy HH:mm').format(value);
  }

  String _date(DateTime value) {
    return DateFormat('MMM d, yyyy').format(value);
  }

  String _fileName(
    FinancialReportPack pack,
    FinancialReportExportFormat format,
  ) {
    final entity = _slug(pack.entityName);
    final period = _slug(pack.periodLabel);
    return '${entity}_financial_report_pack_$period.${format.extension}';
  }

  String _slug(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.isEmpty ? 'report' : normalized;
  }
}
