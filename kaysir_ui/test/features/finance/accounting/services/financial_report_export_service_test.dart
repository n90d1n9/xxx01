import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_control_summary.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_export.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_going_concern_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_action_queue.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive_retention.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_evidence_manifest.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_milestone.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_standard_transition.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_statutory_filing.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_subsequent_event_review.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_package_fingerprint_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_package_integrity_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_audit_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_export_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_pack_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_reconciliation_service.dart';

void main() {
  group('FinancialReportExportService', () {
    const packService = FinancialReportPackService();
    const exportService = FinancialReportExportService();

    test('builds a PDF report pack artifact', () async {
      final artifact = await exportService.buildPdf(_pack(packService));

      expect(artifact.format, FinancialReportExportFormat.pdf);
      expect(artifact.mimeType, 'application/pdf');
      expect(artifact.fileName, endsWith('.pdf'));
      expect(artifact.bytes.length, greaterThan(1000));
      expect(ascii.decode(artifact.bytes.take(4).toList()), '%PDF');
    });

    test('builds a CSV report pack artifact with statements and notes', () {
      final artifact = exportService.buildCsv(_pack(packService));
      final csv = utf8.decode(artifact.bytes);

      expect(artifact.format, FinancialReportExportFormat.csv);
      expect(artifact.mimeType, 'text/csv');
      expect(artifact.fileName, endsWith('.csv'));
      expect(csv, contains('Statement of Financial Position'));
      expect(csv, contains('Statement of Cash Flows'));
      expect(csv, contains('Comparative period'));
      expect(csv, contains('Profit (loss) before financing and income tax'));
      expect(csv, contains('PSAK 118 readiness'));
      expect(csv, contains('UKTM / management performance measures'));
      expect(csv, contains('UKTM Reconciliation'));
      expect(csv, contains('UKTM: management operating performance'));
      expect(csv, contains('UKTM reconciliation variance'));
      expect(csv, contains('Ready'));
      expect(csv, contains('Current variance'));
      expect(csv, contains('Comparative variance'));
      expect(csv, contains('Materiality threshold'));
      expect(csv, contains('Materiality basis'));
      expect(csv, contains('Material exception'));
      expect(csv, contains('equity-roll-forward'));
      expect(csv, contains('Tax profile'));
      expect(csv, contains('Standard PPh Badan'));
      expect(csv, contains('22.0%'));
      expect(csv, contains('Supporting Schedule Metrics'));
      expect(csv, contains('Supporting Schedule Evidence Health'));
      expect(csv, contains('Supporting Schedule Evidence By Schedule'));
      expect(csv, contains('Supporting Schedule Close Tasks'));
      expect(csv, contains('No open evidence tasks'));
      expect(csv, contains('Evidence ready'));
      expect(csv, contains('Effective tax rate'));
      expect(csv, contains('Tax source lines'));
      expect(csv, contains('Supporting Schedules'));
      expect(csv, contains('Income Tax Detail'));
      expect(csv, contains('Income Tax Reconciliation'));
      expect(csv, contains('PSAK 212'));
      expect(csv, contains('Total income tax expense'));
      expect(csv, contains('Expected tax expense at 22%'));
      expect(csv, contains('Tax reconciliation difference'));
    });

    test('adds package identity metadata to CSV exports', () {
      final pack = _pack(packService);
      final closeRecord = const FinancialPeriodCloseService().closePeriod(
        checklist: _closeChecklist(),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        closedAt: DateTime(2026, 2, 1, 10),
        closedBy: 'Controller',
        reportPackageHash: 'abcdef1234567890',
        reportPackageHashAlgorithm: 'SHA-256',
      );
      final integrity = const FinancialReportPackageIntegrityService().verify(
        closeRecord: closeRecord,
        currentFingerprint: const FinancialReportPackageFingerprintService()
            .build(pack: pack, checklist: _closeChecklist()),
      );

      final artifact = exportService.buildCsv(
        pack,
        closeRecord: closeRecord,
        packageIntegrity: integrity,
        releaseEvidenceManifest: _releaseEvidenceManifest,
      );
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Report Package Identity'));
      expect(csv, contains('Generated by'));
      expect(csv, contains('Kaysir'));
      expect(csv, contains('Package status'));
      expect(csv, contains(integrity.status.label));
      expect(csv, contains('Period lock hash'));
      expect(csv, contains('ABCDEF123456'));
      expect(csv, contains('Current package hash'));
      expect(csv, contains(integrity.currentShortHash));
      expect(csv, contains('Evidence manifest'));
      expect(csv, contains('100% (2 ready / 0 attention / 0 missing)'));
      expect(csv, contains('Archive ready'));
      expect(csv, contains('Next release action'));
    });

    test('carries bank reconciliation schedules into CSV exports', () {
      final artifact = exportService.buildCsv(
        _pack(
          packService,
          bankReconciliation: _balancedBankReconciliation(),
          bankReconciliationControlSummary: _balancedBankControlSummary(),
        ),
      );
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Bank Reconciliation Evidence'));
      expect(csv, contains('Bank reconciliation evidence'));
      expect(csv, contains('Statement movement'));
      expect(csv, contains('GL cash/bank movement'));
      expect(csv, contains('Bank reconciliation variance'));
      expect(csv, contains('Balanced'));
      expect(csv, contains('Next action'));
      expect(
        csv,
        contains('Bank statement evidence is matched and ready for close.'),
      );
      expect(csv, contains('Suggested journals'));
      expect(csv, contains('Timing aging'));
      expect(csv, contains('Timing exposure'));
      expect(csv, contains('Stale unmatched item'));
      expect(csv, contains('PSAK 201 / PSAK 207'));
    });

    test('exports bank timing deadline evidence to CSV', () {
      final artifact = exportService.buildCsv(
        _pack(
          packService,
          bankReconciliation: _balancedBankReconciliation(),
          bankReconciliationControlSummary: _timingBankControlSummary(),
          bankTimingRegister: _timingBankRegister(),
          bankTimingReviews: _timingBankReviews(),
        ),
      );
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Timing deadline risk'));
      expect(csv, contains('Supporting Schedule Evidence Health'));
      expect(csv, contains('Supporting Schedule Evidence By Schedule'));
      expect(csv, contains('Supporting Schedule Close Tasks'));
      expect(csv, contains('Bank Reconciliation Evidence,Action'));
      expect(csv, contains('evidence-bankReconciliation'));
      expect(csv, contains('Treasury / Cash accountant'));
      expect(csv, contains('Feb 2, 2026'));
      expect(csv, contains('Critical signals'));
      expect(csv, contains('Watch signals'));
      expect(csv, contains('Action'));
      expect(csv, contains('Resolve 1 critical evidence signal(s).'));
      expect(csv, contains('Monitor 2 watch signal(s).'));
      expect(csv, contains('Clear overdue timing deadline(s).'));
      expect(csv, contains('1 overdue / 1 due soon'));
      expect(csv, contains('Timing review coverage'));
      expect(csv, contains('2/3 documented / 2/3 resolved'));
      expect(csv, contains('Timing review action'));
      expect(csv, contains('Document 1 open review(s)'));
      expect(csv, contains('Clear by Jan 29, 2026'));
      expect(csv, contains('Overdue'));
      expect(csv, contains('Due soon (4d left)'));
      expect(csv, contains('Review Cleared'));
      expect(csv, contains('Owner Controller'));
      expect(csv, contains('Cleared on Feb bank statement.'));
    });

    test('exports evidence close task resolution details to CSV', () {
      final artifact = exportService.buildCsv(
        _pack(
          packService,
          bankReconciliation: _balancedBankReconciliation(),
          bankReconciliationControlSummary: _timingBankControlSummary(),
          bankTimingRegister: _timingBankRegister(),
          bankTimingReviews: _timingBankReviews(),
        ),
        evidenceTaskResolutions: [
          FinancialReportEvidenceCloseTaskResolution(
            taskId: 'evidence-bankReconciliation-bank-reconciliation-evidence',
            status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 10),
            note: 'Timing evidence reviewed.',
            evidenceReference: 'WP-BANK-001',
          ),
        ],
        evidenceTaskAuditEvents: [_evidenceTaskAuditEvent()],
      );
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Resolution status'));
      expect(csv, contains('Completed'));
      expect(csv, contains('WP-BANK-001'));
      expect(csv, contains('Timing evidence reviewed.'));
      expect(csv, contains('Supporting Schedule Close Task Audit Trail'));
      expect(csv, contains('Evidence saved'));
      expect(csv, contains('Bank Reconciliation Evidence,Action'));
      expect(csv, contains('1 critical / 2 watch / 1 ready'));
    });

    test('adds report exception register to CSV exports', () {
      const variancePackService = FinancialReportPackService(
        reconciliationService: _VarianceReconciliationService(),
      );

      final artifact = exportService.buildCsv(_pack(variancePackService));
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Report Exceptions'));
      expect(csv, contains('equity-roll-forward-material'));
      expect(csv, contains('Material'));
      expect(csv, contains('Variance exceeds materiality'));
      expect(csv, contains('true'));
    });

    test('adds exception resolution evidence to CSV exports', () {
      const variancePackService = FinancialReportPackService(
        reconciliationService: _VarianceReconciliationService(),
      );

      final artifact = exportService.buildCsv(
        _pack(variancePackService),
        exceptionResolutions: [
          FinancialReportExceptionResolution(
            exceptionId: 'equity-roll-forward-material',
            status: FinancialReportExceptionResolutionStatus.approved,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 11),
            note: 'Approved with supporting schedule.',
            adjustmentReference: 'REV-001',
          ),
        ],
      );
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Resolution status'));
      expect(csv, contains('Approved'));
      expect(csv, contains('Controller'));
      expect(csv, contains('Approved with supporting schedule.'));
      expect(csv, contains('REV-001'));
    });

    test('adds release sign-off certificate to CSV exports', () {
      final artifact = exportService.buildCsv(
        _pack(packService),
        releaseSignOffItems: [_releaseSignOffItem],
        releaseSignOffAuditEvents: [_releaseSignOffAuditEvent],
        managementMeasureAuditEvents: [_managementMeasureAuditEvent],
        releaseDistributionItems: [_releaseDistributionItem],
        releaseDistributionAuditEvents: [_releaseDistributionAuditEvent],
        releaseActionQueueSummary: _releaseActionQueueSummary,
        releaseMilestoneSummary: _releaseMilestoneSummary,
        standardTransitionSummary: _standardTransitionSummary,
        subsequentEventReviewSummary: _subsequentEventReviewSummary,
        goingConcernReviewSummary: _goingConcernReviewSummary,
        releaseEvidenceManifest: _releaseEvidenceManifest,
        releaseArchiveSummary: _releaseArchiveSummary,
        releaseArchiveAuditEvents: [_releaseArchiveAuditEvent],
        releaseArchiveRetentionSummary: _releaseArchiveRetentionSummary,
        statutoryFilingSummary: _statutoryFilingSummary,
      );
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Report Release Evidence Manifest'));
      expect(csv, contains('Report Release Action Queue'));
      expect(csv, contains('Report Release Milestone Calendar'));
      expect(csv, contains('PSAK 118 Transition Readiness'));
      expect(csv, contains('Subsequent Events Review'));
      expect(csv, contains('Going Concern Review'));
      expect(csv, contains('Report Release Archive Register'));
      expect(csv, contains('Report Release Archive Retention Monitor'));
      expect(csv, contains('Report Release Archive Audit Trail'));
      expect(csv, contains('Post-release Statutory Filing Tracker'));
      expect(csv, contains('Archive ready'));
      expect(csv, contains('FR-ARCH-2026010120260131-ABCDEF123456'));
      expect(csv, contains('Finance archive owner'));
      expect(csv, contains('Retention active'));
      expect(csv, contains('Next review'));
      expect(csv, contains('Last review'));
      expect(csv, contains('Last reviewer'));
      expect(csv, contains('SPT Tahunan Badan support pack'));
      expect(csv, contains('Clear overdue distribution: Board / owners'));
      expect(csv, contains('Closed package certification'));
      expect(csv, contains('Required profit or loss subtotals'));
      expect(csv, contains('PSAK 118 / IFRS 18'));
      expect(csv, contains('PSAK 118 transition needs implementation work.'));
      expect(csv, contains('Management subsequent-event inquiry'));
      expect(csv, contains('PSAK 210 / IAS 10'));
      expect(csv, contains('Cash runway and liquidity buffer'));
      expect(csv, contains('PSAK 201 / IAS 1'));
      expect(csv, contains('Going-concern basis appears supportable.'));
      expect(csv, contains('Open actions'));
      expect(csv, contains('DJP: Annual Corporate Tax Return'));
      expect(csv, contains('Retain until'));
      expect(csv, contains('Archive record sealed.'));
      expect(
        csv,
        contains(
          'Release evidence manifest is complete. Archive it with the report pack.',
        ),
      );
      expect(csv, contains('Period close certificate'));
      expect(csv, contains('Package fingerprint'));
      expect(csv, contains('Report Release Sign-offs'));
      expect(csv, contains('Report Release Sign-off Audit Trail'));
      expect(csv, contains('UKTM Audit Trail'));
      expect(csv, contains('Report Release Distribution Register'));
      expect(csv, contains('Report Release Distribution Audit Trail'));
      expect(csv, contains('Approved for release'));
      expect(csv, contains('Approver'));
      expect(csv, contains('Finance Lead'));
      expect(csv, contains('SIGNOFF-APPROVER'));
      expect(csv, contains('adjusted operating performance'));
      expect(csv, contains('UKTM approved for release.'));
      expect(csv, contains('Board / owners'));
      expect(csv, contains('Secure link'));
      expect(csv, contains('DIST-BOARD'));
      expect(csv, contains('Board acknowledged receipt.'));
      expect(csv, contains('Requires acknowledgement'));
      expect(csv, contains('Approved for board distribution.'));
      expect(csv, contains('Jan 2026'));
      expect(csv, contains('Signed'));
      expect(csv, contains('Blocks release'));
      expect(csv, contains('false'));
    });

    test('adds close certificate and audit trail to CSV exports', () {
      final pack = _pack(packService);
      final closeRecord = const FinancialPeriodCloseService().closePeriod(
        checklist: _closeChecklist(),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        closedAt: DateTime(2026, 2, 1, 10),
        closedBy: 'Controller',
        reportPackageHash: 'abcdef1234567890',
        reportPackageHashAlgorithm: 'SHA-256',
        closingEntryPostingId: 'posting-close-jan',
        closingEntryReference: 'CL-2026-01',
        closingEntryPostedAt: DateTime(2026, 2, 1, 8, 45),
      );
      final auditEvent = FinancialPeriodCloseAuditService(
        nextId: () => 'audit-1',
      ).closed(closeRecord);
      final integrity = const FinancialReportPackageIntegrityService().verify(
        closeRecord: closeRecord,
        currentFingerprint: const FinancialReportPackageFingerprintService()
            .build(pack: pack, checklist: _closeChecklist()),
      );

      final artifact = exportService.buildCsv(
        pack,
        closeRecord: closeRecord,
        packageIntegrity: integrity,
        closeAuditTrail: [auditEvent],
      );
      final csv = utf8.decode(artifact.bytes);

      expect(csv, contains('Period Close Certificate'));
      expect(csv, contains('Close Audit Trail'));
      expect(csv, contains('Closed'));
      expect(csv, contains('Controller'));
      expect(csv, contains('Integrity status'));
      expect(csv, contains('Integrity detail'));
      expect(csv, contains('closed hash ABCDEF123456 differs from current'));
      expect(csv, contains('Current fingerprint algorithm'));
      expect(
        csv,
        contains(FinancialReportPackageIntegrityStatus.changed.label),
      );
      expect(csv, contains('100%'));
      expect(csv, contains('abcdef1234567890'));
      expect(csv, contains('SHA-256'));
      expect(csv, contains('Closing entry reference'));
      expect(csv, contains('CL-2026-01'));
      expect(csv, contains('posting-close-jan'));
    });
  });
}

final _releaseActionQueueSummary = FinancialReportReleaseActionQueueSummary(
  items: [
    FinancialReportReleaseActionItem(
      id: 'distribution-board-owners',
      area: FinancialReportReleaseActionArea.distribution,
      priority: FinancialReportReleaseActionPriority.critical,
      title: 'Clear overdue distribution: Board / owners',
      owner: 'Governance recipients',
      dueDate: DateTime(2026, 2, 3),
      detail: 'Board acknowledgement is overdue.',
      reference: 'Secure link / acknowledgement required',
      blocked: true,
    ),
    FinancialReportReleaseActionItem(
      id: 'statutory-tax',
      area: FinancialReportReleaseActionArea.statutoryFiling,
      priority: FinancialReportReleaseActionPriority.high,
      title: 'SPT Tahunan Badan support pack',
      owner: 'Tax / statutory archive',
      dueDate: DateTime(2026, 5, 31),
      detail: 'Prepare released financial statements and tax schedules.',
      reference:
          'DJP: Annual Corporate Tax Return due no later than 4 months after tax year end',
    ),
  ],
  criticalCount: 1,
  highCount: 1,
  overdueCount: 1,
  blockedCount: 1,
  nextAction:
      'Clear overdue distribution: Board / owners: Board acknowledgement is overdue.',
);

final _releaseMilestoneSummary = FinancialReportReleaseMilestoneSummary(
  items: [
    FinancialReportReleaseMilestoneItem(
      id: 'package-integrity',
      area: FinancialReportReleaseMilestoneArea.packageIntegrity,
      title: 'Closed package certification',
      status: FinancialReportReleaseMilestoneStatus.complete,
      dueDate: DateTime(2026, 2, 1),
      owner: 'Controller',
      reference: 'Package verified',
      detail: 'The displayed report package matches the closed package.',
    ),
    FinancialReportReleaseMilestoneItem(
      id: 'statutory-tax',
      area: FinancialReportReleaseMilestoneArea.statutoryFiling,
      title: 'SPT Tahunan Badan support pack',
      status: FinancialReportReleaseMilestoneStatus.dueSoon,
      dueDate: DateTime(2026, 5, 31),
      owner: 'Tax / statutory archive',
      reference:
          'DJP: Annual Corporate Tax Return due no later than 4 months after tax year end',
      detail: 'Prepare released financial statements and tax schedules.',
    ),
  ],
  completeCount: 1,
  upcomingCount: 0,
  dueSoonCount: 1,
  overdueCount: 0,
  blockedCount: 0,
  completionRatio: 0.5,
  nextAction:
      'SPT Tahunan Badan support pack: Prepare released financial statements and tax schedules.',
);

final _subsequentEventReviewSummary =
    FinancialReportSubsequentEventReviewSummary(
      periodEnd: DateTime(2026, 1, 31),
      authorizationTargetDate: DateTime(2026, 2, 3),
      reviewWindowDays: 3,
      standardReference: 'PSAK 210 / IAS 10',
      items: [
        FinancialReportSubsequentEventReviewItem(
          kind: FinancialReportSubsequentEventReviewKind.packageLock,
          title: 'Lock report package through review date',
          status: FinancialReportSubsequentEventReviewStatus.complete,
          dueDate: DateTime(2026, 2, 1),
          owner: 'Controller',
          reference: 'Package verified',
          detail: 'The displayed report package matches the closed package.',
          evidenceReference: 'ABCDEF123456',
        ),
        FinancialReportSubsequentEventReviewItem(
          kind: FinancialReportSubsequentEventReviewKind.managementInquiry,
          title: 'Management subsequent-event inquiry',
          status: FinancialReportSubsequentEventReviewStatus.dueSoon,
          dueDate: DateTime(2026, 2, 2),
          owner: 'Controller',
          reference: 'PSAK 210 / IAS 10',
          detail: 'Management inquiry completed.',
          evidenceReference: 'SE-REVIEW-001',
        ),
      ],
      completeCount: 1,
      openCount: 0,
      dueSoonCount: 1,
      overdueCount: 0,
      blockedCount: 0,
      completionRatio: 0.5,
      nextAction:
          'Management subsequent-event inquiry: Management inquiry completed.',
    );

final _standardTransitionSummary = FinancialReportStandardTransitionSummary(
  currentStandardReference: 'PSAK 201 / IAS 1',
  nextStandardReference: 'PSAK 118 / IFRS 18',
  effectiveDate: DateTime(2027, 1, 1),
  daysUntilEffective: 214,
  items: const [
    FinancialReportStandardTransitionItem(
      kind: FinancialReportStandardTransitionKind.effectiveStandard,
      title: 'PSAK 118 effective-date watch',
      status: FinancialReportStandardTransitionStatus.monitor,
      metric: '214 day(s) remaining',
      owner: 'Reporting lead',
      reference: 'PSAK 118 / IFRS 18 effective 2027-01-01',
      detail: 'Track implementation work before PSAK 118 replaces PSAK 201.',
      evidenceReference: 'SAK Indonesia',
    ),
    FinancialReportStandardTransitionItem(
      kind: FinancialReportStandardTransitionKind.profitLossSubtotals,
      title: 'Required profit or loss subtotals',
      status: FinancialReportStandardTransitionStatus.actionRequired,
      metric: 'Operating mapped',
      owner: 'Reporting accountant',
      reference: 'PSAK 118 / IFRS 18',
      detail:
          'Add the PSAK 118 subtotal for profit before financing and income tax.',
      evidenceReference: 'Operating profit present',
    ),
  ],
  readyCount: 0,
  monitorCount: 1,
  actionRequiredCount: 1,
  overdueCount: 0,
  notApplicableCount: 0,
  readinessRatio: 0,
  headline: 'PSAK 118 transition needs implementation work.',
  nextAction:
      'Required profit or loss subtotals: Add the PSAK 118 subtotal for profit before financing and income tax.',
);

const _goingConcernReviewSummary = FinancialReportGoingConcernReviewSummary(
  standardReference: 'PSAK 201 / IAS 1',
  items: [
    FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.liquidityBuffer,
      title: 'Cash runway and liquidity buffer',
      status: FinancialReportGoingConcernReviewStatus.satisfactory,
      metric: 'Positive cash cover',
      owner: 'Treasury / Cash accountant',
      reference: 'PSAK 201 / IAS 1 / PSAK 207',
      detail:
          'Cash balance is not being consumed by negative operating cash flow.',
      evidenceReference: '4.5K',
    ),
    FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.managementAssessment,
      title: 'Management going-concern conclusion',
      status: FinancialReportGoingConcernReviewStatus.satisfactory,
      metric: 'Conclusion captured',
      owner: 'Finance director',
      reference: 'PSAK 201 / IAS 1',
      detail:
          'Management assertion and release approval support the going-concern basis.',
      evidenceReference: 'SIGNOFF-APPROVER',
    ),
  ],
  satisfactoryCount: 2,
  watchCount: 0,
  attentionCount: 0,
  materialUncertaintyCount: 0,
  incompleteCount: 0,
  readinessRatio: 1,
  conclusion: 'Going-concern basis appears supportable.',
  nextAction: 'Going-concern review is ready for report release.',
);

final _releaseSignOffItem = FinancialReportReleaseSignOffItem(
  requirement: const FinancialReportReleaseSignOffRequirement(
    id: 'approved-for-release',
    role: FinancialReportReleaseSignOffRole.approver,
    title: 'Approved for release',
    description: 'Approve report pack release.',
    owner: 'Finance director',
    reference: 'Indonesia release approval',
  ),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Finance Lead',
    signedAt: DateTime(2026, 2, 1, 12),
    note: 'Approved for board distribution.',
    evidenceReference: 'SIGNOFF-APPROVER',
  ),
);

final _releaseSignOffAuditEvent = FinancialReportReleaseSignOffAuditEvent(
  id: 'release-audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  requirementId: 'approved-for-release',
  requirementTitle: 'Approved for release',
  role: FinancialReportReleaseSignOffRole.approver,
  action: FinancialReportReleaseSignOffAuditAction.signed,
  occurredAt: DateTime(2026, 2, 1, 12),
  actor: 'Finance Lead',
  status: FinancialReportReleaseSignOffStatus.signed,
  note: 'Approved for board distribution.',
  evidenceReference: 'SIGNOFF-APPROVER',
);

final _managementMeasureAuditEvent = FinancialReportManagementMeasureAuditEvent(
  id: 'uktm-audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  measureId: 'uktm-adjusted-operating-performance',
  measureLabel: 'adjusted operating performance',
  action: FinancialReportManagementMeasureAuditAction.approved,
  occurredAt: DateTime(2026, 2, 1, 11),
  actor: 'Finance Lead',
  status: FinancialReportManagementMeasureApprovalStatus.approved,
  note: 'UKTM approved for release.',
);

final _releaseDistributionItem = FinancialReportReleaseDistributionItem(
  recipient: FinancialReportReleaseDistributionRecipient(
    id: 'board-owners',
    name: 'Board / owners',
    role: 'Governance recipients',
    organization: 'Kaysir Advisory',
    channel: FinancialReportReleaseDistributionChannel.secureLink,
    requiresAcknowledgement: true,
    dueDate: DateTime(2026, 2, 3),
    purpose: 'Governance review and formal distribution record.',
  ),
  resolution: FinancialReportReleaseDistributionResolution(
    recipientId: 'board-owners',
    status: FinancialReportReleaseDistributionStatus.acknowledged,
    owner: 'Finance Lead',
    updatedAt: DateTime(2026, 2, 1, 13),
    note: 'Board acknowledged receipt.',
    evidenceReference: 'DIST-BOARD',
  ),
);

final _releaseDistributionAuditEvent =
    FinancialReportReleaseDistributionAuditEvent(
      id: 'distribution-audit-1',
      periodKey: '20260101-20260131',
      periodLabel: 'Jan 2026',
      recipientId: 'board-owners',
      recipientName: 'Board / owners',
      channel: FinancialReportReleaseDistributionChannel.secureLink,
      action: FinancialReportReleaseDistributionAuditAction.acknowledged,
      occurredAt: DateTime(2026, 2, 1, 13),
      actor: 'Finance Lead',
      status: FinancialReportReleaseDistributionStatus.acknowledged,
      note: 'Board acknowledged receipt.',
      evidenceReference: 'DIST-BOARD',
    );

const _releaseEvidenceManifest = FinancialReportReleaseEvidenceManifestSummary(
  items: [
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.closeCertificate,
      title: 'Period close certificate',
      status: FinancialReportReleaseEvidenceStatus.ready,
      detail: 'Closed by Controller with 0 blocker(s).',
      reference: 'Close certificate',
    ),
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.packageFingerprint,
      title: 'Package fingerprint',
      status: FinancialReportReleaseEvidenceStatus.ready,
      detail: 'The displayed report package matches the closed package.',
      reference: 'ABCDEF123456',
    ),
  ],
  readyCount: 2,
  attentionCount: 0,
  missingCount: 0,
  archiveReady: true,
  completionRatio: 1,
  nextAction:
      'Release evidence manifest is complete. Archive it with the report pack.',
);

final _releaseArchiveSummary = FinancialReportReleaseArchiveSummary(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  status: FinancialReportReleaseArchiveStatus.archived,
  record: FinancialReportReleaseArchiveRecord(
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
    evidenceItemCount: 2,
    note: 'Release file archived.',
  ),
  evidenceReady: true,
  evidenceItemCount: 2,
  readyEvidenceCount: 2,
  nextAction:
      'Archive record sealed under FR-ARCH-2026010120260131-ABCDEF123456; retain through 2036-01-31.',
);

final _releaseArchiveAuditEvent = FinancialReportReleaseArchiveAuditEvent(
  id: 'archive-audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  archiveId: 'FR-ARCH-2026010120260131-ABCDEF123456',
  action: FinancialReportReleaseArchiveAuditAction.archived,
  occurredAt: DateTime(2026, 2, 1, 14),
  actor: 'Controller',
  custodian: 'Finance archive owner',
  storageLocation: 'Encrypted archive vault',
  retentionPolicy: 'Indonesia statutory/tax archive policy',
  retainUntil: DateTime(2036, 1, 31),
  nextReviewDate: DateTime(2027, 2, 1),
  packageFingerprint: 'abcdef1234567890',
  note: 'Archive record sealed.',
);

final _releaseArchiveRetentionSummary =
    FinancialReportReleaseArchiveRetentionSummary(
      periodKey: '20260101-20260131',
      periodLabel: 'Jan 2026',
      status: FinancialReportReleaseArchiveRetentionStatus.active,
      record: _releaseArchiveSummary.record,
      asOf: DateTime(2026, 5, 1),
      retainUntil: DateTime(2036, 1, 31),
      nextReviewDate: DateTime(2027, 2, 1),
      lastReviewAt: DateTime(2026, 5, 1),
      lastReviewActor: 'Controller',
      daysRemaining: 3562,
      daysUntilReview: 276,
      reviewWindowDays: 90,
      nextAction:
          'Archive custody is current; next retention review is due in 276 day(s).',
      checkpoints: const [
        FinancialReportReleaseArchiveRetentionCheckpoint(
          title: 'Custodian',
          value: 'Finance archive owner',
          detail: 'Encrypted archive vault',
          status: FinancialReportReleaseArchiveRetentionStatus.active,
        ),
        FinancialReportReleaseArchiveRetentionCheckpoint(
          title: 'Next review',
          value: '2027-02-01',
          detail: '276 day(s) remaining',
          status: FinancialReportReleaseArchiveRetentionStatus.active,
        ),
      ],
    );

final _statutoryFilingSummary = FinancialReportStatutoryFilingSummary(
  items: [
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.managementRelease,
      title: 'Management release copy',
      status: FinancialReportStatutoryFilingStatus.complete,
      dueDate: DateTime(2026, 2, 2),
      owner: 'Management release owner',
      reference: 'Internal management release',
      detail: 'Management release evidence is complete.',
      evidenceReference: 'DIST-MANAGEMENT',
    ),
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.annualCorporateTaxSupport,
      title: 'SPT Tahunan Badan support pack',
      status: FinancialReportStatutoryFilingStatus.dueSoon,
      dueDate: DateTime(2026, 5, 31),
      owner: 'Tax / statutory archive',
      reference:
          'DJP: Annual Corporate Tax Return due no later than 4 months after tax year end',
      detail: 'Prepare released financial statements and tax schedules.',
      evidenceReference: 'DIST-TAX',
    ),
  ],
  completeCount: 1,
  dueSoonCount: 1,
  overdueCount: 0,
  blockedCount: 0,
  completionRatio: 0.5,
  nextAction:
      'SPT Tahunan Badan support pack: Prepare released financial statements and tax schedules.',
);

FinancialCloseChecklist _closeChecklist() {
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
      FinancialCloseChecklistItem(
        id: 'report-pack',
        title: 'Report pack',
        description: 'Statements generated',
        status: FinancialCloseItemStatus.ready,
        reference: 'PSAK 201',
      ),
    ],
  );
}

class _VarianceReconciliationService
    extends FinancialReportReconciliationService {
  const _VarianceReconciliationService();

  @override
  List<FinancialReportReconciliationCheck> buildChecks({
    required FinancialReportStatement position,
    required FinancialReportStatement profitOrLoss,
    required FinancialReportStatement changesInEquity,
    required FinancialReportStatement cashFlows,
  }) {
    return const [
      FinancialReportReconciliationCheck(
        id: 'equity-roll-forward',
        title: 'Equity roll-forward reconciles',
        description:
            'Opening equity plus current-period equity movements equals ending equity.',
        standardReference: 'PSAK 201',
        variance: 125,
        comparativeVariance: -10,
      ),
    ];
  }
}

FinancialReportPack _pack(
  FinancialReportPackService service, {
  BankReconciliation? bankReconciliation,
  BankReconciliationControlSummary? bankReconciliationControlSummary,
  List<BankReconciliationTimingRegisterItem> bankTimingRegister = const [],
  Map<String, BankReconciliationTimingReview> bankTimingReviews = const {},
}) {
  return service.build(
    entries: [
      FinancialEntry(
        name: 'Cash',
        amount: 1000,
        date: DateTime(2025, 12, 31),
        category: '1000 - Cash',
        type: 'asset',
        sourceCategory: 'Opening balance',
      ),
      FinancialEntry(
        name: 'Sales Revenue',
        amount: 5000,
        date: DateTime(2026, 1, 15),
        category: '4000 - Sales Revenue',
        type: 'income',
      ),
      FinancialEntry(
        name: 'Rent Expense',
        amount: 1200,
        date: DateTime(2026, 1, 16),
        category: '5000 - Rent Expense',
        type: 'expense',
      ),
      FinancialEntry(
        name: 'Income Tax Expense',
        amount: 300,
        date: DateTime(2026, 1, 20),
        category: '5200 - Income Tax Expense',
        type: 'expense',
        sourceCategory: 'Pajak penghasilan',
      ),
      FinancialEntry(
        name: 'Cash',
        amount: 3500,
        date: DateTime(2026, 1, 31),
        category: '1000 - Cash',
        type: 'asset',
        sourceCategory: 'Operating collection',
      ),
    ],
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    generatedAt: DateTime(2026, 2, 1, 9),
    bankReconciliation: bankReconciliation,
    bankReconciliationControlSummary: bankReconciliationControlSummary,
    bankTimingRegister: bankTimingRegister,
    bankTimingReviews: bankTimingReviews,
  );
}

BankReconciliationControlSummary _balancedBankControlSummary() {
  return const BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.ready,
    nextAction: 'Bank statement evidence is matched and ready for close.',
    statementLineCount: 1,
    matchedCount: 1,
    unmatchedStatementCount: 0,
    unmatchedLedgerCount: 0,
    suggestedJournalCount: 0,
    timingDifferenceCount: 0,
    staleThresholdDays: 30,
  );
}

BankReconciliationControlSummary _timingBankControlSummary() {
  return BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.timingReview,
    nextAction: 'Confirm timing differences clear on a later statement.',
    statementLineCount: 1,
    matchedCount: 1,
    unmatchedStatementCount: 0,
    unmatchedLedgerCount: 0,
    suggestedJournalCount: 0,
    timingDifferenceCount: 3,
    staleThresholdDays: 30,
    timingAging: const BankReconciliationTimingAgingSummary(
      currentCount: 1,
      watchCount: 1,
      staleCount: 1,
      currentAmount: 100,
      watchAmount: 200,
      staleAmount: 300,
    ),
    oldestUnmatchedAgeDays: 32,
    oldestUnmatchedDate: DateTime(2025, 12, 30),
    oldestUnmatchedReference: 'PAY-002',
  );
}

List<BankReconciliationTimingRegisterItem> _timingBankRegister() {
  return [
    BankReconciliationTimingRegisterItem(
      reference: 'PAY-002',
      date: DateTime(2025, 12, 30),
      description: 'Stale outstanding payment',
      amount: -300,
      ageDays: 32,
      clearByDate: DateTime(2026, 1, 29),
      bucket: BankReconciliationTimingBucket.stale,
      type: BankReconciliationResolutionType.outstandingPayment,
      clearanceStatus: BankReconciliationTimingClearanceStatus.escalate,
      suggestedAction: 'Investigate stale payment.',
    ),
    BankReconciliationTimingRegisterItem(
      reference: 'PAY-001',
      date: DateTime(2026, 1, 5),
      description: 'Outstanding payment',
      amount: -200,
      ageDays: 26,
      clearByDate: DateTime(2026, 2, 4),
      bucket: BankReconciliationTimingBucket.watch,
      type: BankReconciliationResolutionType.outstandingPayment,
      clearanceStatus: BankReconciliationTimingClearanceStatus.monitor,
      suggestedAction: 'Confirm later statement clearing.',
    ),
    BankReconciliationTimingRegisterItem(
      reference: 'DEP-001',
      date: DateTime(2026, 1, 29),
      description: 'Deposit in transit',
      amount: 100,
      ageDays: 2,
      clearByDate: DateTime(2026, 2, 28),
      bucket: BankReconciliationTimingBucket.current,
      type: BankReconciliationResolutionType.depositInTransit,
      clearanceStatus: BankReconciliationTimingClearanceStatus.open,
      suggestedAction: 'Confirm later statement clearing.',
    ),
  ];
}

Map<String, BankReconciliationTimingReview> _timingBankReviews() {
  return {
    'PAY-002': BankReconciliationTimingReview(
      reference: 'PAY-002',
      status: BankReconciliationTimingReviewStatus.cleared,
      owner: 'Controller',
      note: 'Cleared on Feb bank statement.',
      reviewedAt: DateTime(2026, 1, 31, 16),
    ),
    'PAY-001': BankReconciliationTimingReview(
      reference: 'PAY-001',
      status: BankReconciliationTimingReviewStatus.adjusted,
      owner: 'Accounting Lead',
      note: 'Posted bank fee adjustment.',
      reviewedAt: DateTime(2026, 2, 1, 9),
    ),
  };
}

FinancialReportEvidenceTaskAuditEvent _evidenceTaskAuditEvent() {
  return FinancialReportEvidenceTaskAuditEvent(
    id: 'audit-1',
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    taskId: 'evidence-bankReconciliation-bank-reconciliation-evidence',
    taskTitle: 'Bank Reconciliation Evidence evidence follow-up',
    scheduleTitle: 'Bank Reconciliation Evidence',
    action: FinancialReportEvidenceTaskAuditAction.evidenceSaved,
    occurredAt: DateTime(2026, 2, 1, 10),
    actor: 'Controller',
    status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
    note: 'Timing evidence reviewed.',
    evidenceReference: 'WP-BANK-001',
  );
}

BankReconciliation _balancedBankReconciliation() {
  final statementLine = BankStatementLine(
    id: 'stmt-1',
    date: DateTime(2026, 1, 15),
    description: 'Customer transfer INV-001',
    amount: 1200,
    reference: 'INV-001',
  );
  final ledgerLine = BankLedgerReconciliationLine(
    transactionId: 'trx-1',
    date: DateTime(2026, 1, 15),
    account: '1001 - Bank BCA',
    description: 'Customer transfer INV-001',
    reference: 'INV-001',
    type: TransactionType.debit,
    amount: 1200,
  );

  return BankReconciliation(
    statementLines: [statementLine],
    ledgerLines: [ledgerLine],
    matches: [
      BankReconciliationMatch(
        statementLine: statementLine,
        ledgerLine: ledgerLine,
        matchType: BankReconciliationMatchType.reference,
        dateDifferenceDays: 0,
        amountVariance: 0,
      ),
    ],
    unmatchedStatementLines: const [],
    unmatchedLedgerLines: const [],
  );
}
