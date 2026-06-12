import 'package:flutter/material.dart';

import '../accounting_core/models/ledger_posting.dart';
import '../models/financial_close_checklist.dart';
import '../models/financial_period_close.dart';
import '../models/financial_period_close_audit.dart';
import '../models/financial_report_evidence_close_task.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_package_integrity.dart';
import '../models/financial_report_review_exception.dart';
import '../models/financial_report_standard_transition.dart';
import '../models/period_closing_entry.dart';
import 'financial_close_checklist_panel.dart';
import 'financial_report_compliance_panel.dart';
import 'financial_report_exception_register_panel.dart';
import 'financial_report_notes_panel.dart';
import 'financial_report_pack_layout_components.dart';
import 'financial_report_pack_summary_components.dart';
import 'financial_report_standard_transition_panel.dart';
import 'financial_report_supporting_schedules_panel.dart';
import 'period_closing_entry_preview_panel.dart';

class FinancialReportPackView extends StatelessWidget {
  final FinancialReportPack pack;
  final FinancialCloseChecklist? closeChecklist;
  final FinancialPeriodCloseRecord? closeRecord;
  final FinancialReportPackageIntegrity? packageIntegrity;
  final FinancialReportStandardTransitionSummary? standardTransitionSummary;
  final List<FinancialReportExceptionResolution> exceptionResolutions;
  final List<FinancialReportEvidenceCloseTaskResolution>
  evidenceTaskResolutions;
  final List<FinancialReportEvidenceTaskAuditEvent> evidenceTaskAuditEvents;
  final List<LedgerPosting> postedAdjustmentJournals;
  final void Function(
    FinancialReportReviewException exception,
    FinancialReportExceptionResolutionStatus status,
  )?
  onResolveException;
  final void Function(
    FinancialReportEvidenceCloseTask task,
    FinancialReportEvidenceCloseTaskResolutionStatus status,
  )?
  onResolveEvidenceTask;
  final String? exceptionResolutionLockedReason;
  final String? evidenceTaskResolutionLockedReason;
  final PeriodClosingEntryPreview? closingEntryPreview;
  final bool closingEntryPosted;
  final List<FinancialPeriodCloseAuditEvent> closeAuditTrail;
  final VoidCallback? onClosePeriod;
  final VoidCallback? onReopenPeriod;
  final VoidCallback? onPostClosingEntry;
  final bool isDarkMode;
  final bool scrollable;

  const FinancialReportPackView({
    super.key,
    required this.pack,
    this.closeChecklist,
    this.closeRecord,
    this.packageIntegrity,
    this.standardTransitionSummary,
    this.exceptionResolutions = const [],
    this.evidenceTaskResolutions = const [],
    this.evidenceTaskAuditEvents = const [],
    this.postedAdjustmentJournals = const [],
    this.onResolveException,
    this.onResolveEvidenceTask,
    this.exceptionResolutionLockedReason,
    this.evidenceTaskResolutionLockedReason,
    this.closingEntryPreview,
    this.closingEntryPosted = false,
    this.closeAuditTrail = const [],
    this.onClosePeriod,
    this.onReopenPeriod,
    this.onPostClosingEntry,
    required this.isDarkMode,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = FinancialReportPackSectionStack(
      sections: [
        FinancialReportPackSummaryHeader(pack: pack, isDarkMode: isDarkMode),
        FinancialReportPackMetricGrid(
          metrics: pack.metrics,
          isDarkMode: isDarkMode,
        ),
        FinancialReportCompliancePanel(pack: pack, isDarkMode: isDarkMode),
        if (standardTransitionSummary != null)
          FinancialReportStandardTransitionPanel(
            summary: standardTransitionSummary!,
          ),
        if (pack.supportingSchedules.isNotEmpty)
          FinancialReportSupportingSchedulesPanel(
            pack: pack,
            evidenceTaskResolutions: evidenceTaskResolutions,
            evidenceTaskAuditEvents: evidenceTaskAuditEvents,
            onResolveEvidenceTask: onResolveEvidenceTask,
            evidenceTaskResolutionLockedReason:
                evidenceTaskResolutionLockedReason,
            isDarkMode: isDarkMode,
          ),
        FinancialReportExceptionRegisterPanel(
          pack: pack,
          exceptionResolutions: exceptionResolutions,
          postedAdjustmentJournals: postedAdjustmentJournals,
          onResolveException: onResolveException,
          resolutionActionLockedReason: exceptionResolutionLockedReason,
          isDarkMode: isDarkMode,
        ),
        if (closingEntryPreview != null)
          PeriodClosingEntryPreviewPanel(
            preview: closingEntryPreview!,
            isPosted: closingEntryPosted,
            onPostClosingEntry: onPostClosingEntry,
            isDarkMode: isDarkMode,
          ),
        if (closeChecklist != null)
          FinancialCloseChecklistPanel(
            checklist: closeChecklist!,
            closeRecord: closeRecord,
            packageIntegrity: packageIntegrity,
            closeAuditTrail: closeAuditTrail,
            onClosePeriod: onClosePeriod,
            onReopenPeriod: onReopenPeriod,
            isDarkMode: isDarkMode,
          ),
        if (pack.statements.isNotEmpty)
          FinancialReportStatementSection(pack: pack, isDarkMode: isDarkMode),
        FinancialReportNotesPanel(pack: pack, isDarkMode: isDarkMode),
      ],
    );

    if (!scrollable) {
      return content;
    }

    return SingleChildScrollView(child: content);
  }
}
