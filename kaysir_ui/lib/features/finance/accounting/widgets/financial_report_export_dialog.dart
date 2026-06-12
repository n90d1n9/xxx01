import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/financial_report_export.dart';
import '../states/accounting_core_provider.dart';
import '../states/fin_statement/financial_period_close_audit_provider.dart';
import '../states/fin_statement/financial_period_close_provider.dart';
import '../states/fin_statement/financial_report_package_integrity_provider.dart';
import '../states/fin_statement/financial_report_evidence_task_resolution_provider.dart';
import '../states/fin_statement/financial_report_export_provider.dart';
import '../states/fin_statement/financial_report_exception_resolution_provider.dart';
import '../states/fin_statement/financial_report_going_concern_review_provider.dart';
import '../states/fin_statement/financial_report_management_measure_provider.dart';
import '../states/fin_statement/financial_report_pack_provider.dart';
import '../states/fin_statement/financial_report_release_action_queue_provider.dart';
import '../states/fin_statement/financial_report_release_archive_provider.dart';
import '../states/fin_statement/financial_report_release_distribution_provider.dart';
import '../states/fin_statement/financial_report_release_evidence_manifest_provider.dart';
import '../states/fin_statement/financial_report_release_milestone_provider.dart';
import '../states/fin_statement/financial_report_release_signoff_provider.dart';
import '../states/fin_statement/financial_report_standard_transition_provider.dart';
import '../states/fin_statement/financial_report_subsequent_event_review_provider.dart';
import 'financial_report_export_components.dart';

class FinancialReportExportDialog extends ConsumerStatefulWidget {
  const FinancialReportExportDialog({super.key});

  @override
  ConsumerState<FinancialReportExportDialog> createState() =>
      _FinancialReportExportDialogState();
}

class _FinancialReportExportDialogState
    extends ConsumerState<FinancialReportExportDialog> {
  FinancialReportExportFormat? _exportingFormat;

  @override
  Widget build(BuildContext context) {
    final pack = ref.watch(financialReportPackProvider);
    final signOffItems = ref.watch(
      currentFinancialReportReleaseSignOffItemsProvider,
    );
    final distributionItems = ref.watch(
      currentFinancialReportReleaseDistributionItemsProvider,
    );
    final isBusy = _exportingFormat != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FinancialReportExportHeader(),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FinancialReportExportContextPanel(pack: pack),
                      const SizedBox(height: 14),
                      FinancialReportExportReadinessPanel(
                        pack: pack,
                        signOffItems: signOffItems,
                        distributionItems: distributionItems,
                      ),
                      const SizedBox(height: 14),
                      FinancialReportExportOptionList(
                        exportingFormat: _exportingFormat,
                        isBusy: isBusy,
                        onExport: _export,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: AppActionButton(
                  label: 'Cancel',
                  icon: Icons.close_rounded,
                  variant: AppActionButtonVariant.text,
                  onPressed: isBusy ? null : () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export(FinancialReportExportFormat format) async {
    setState(() => _exportingFormat = format);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final pack = ref.read(financialReportPackProvider);
    final closeRecord = ref.read(currentFinancialPeriodCloseRecordProvider);
    final closeAuditTrail = ref.read(currentFinancialPeriodCloseAuditProvider);
    final exceptionResolutions = ref.read(
      currentFinancialReportExceptionResolutionsProvider,
    );
    final evidenceTaskResolutions = ref.read(
      currentFinancialReportEvidenceTaskResolutionsProvider,
    );
    final evidenceTaskAuditEvents = ref.read(
      currentFinancialReportEvidenceTaskAuditProvider,
    );
    final managementMeasureAuditEvents = ref.read(
      currentFinancialReportManagementMeasureAuditProvider,
    );
    final releaseSignOffItems = ref.read(
      currentFinancialReportReleaseSignOffItemsProvider,
    );
    final releaseSignOffAuditEvents = ref.read(
      currentFinancialReportReleaseSignOffAuditProvider,
    );
    final releaseDistributionItems = ref.read(
      currentFinancialReportReleaseDistributionItemsProvider,
    );
    final releaseDistributionAuditEvents = ref.read(
      currentFinancialReportReleaseDistributionAuditProvider,
    );
    final releaseActionQueueSummary = ref.read(
      currentFinancialReportReleaseActionQueueProvider,
    );
    final releaseMilestoneSummary = ref.read(
      currentFinancialReportReleaseMilestoneProvider,
    );
    final standardTransitionSummary = ref.read(
      currentFinancialReportStandardTransitionProvider,
    );
    final subsequentEventReviewSummary = ref.read(
      currentFinancialReportSubsequentEventReviewProvider,
    );
    final goingConcernReviewSummary = ref.read(
      currentFinancialReportGoingConcernReviewProvider,
    );
    final releaseEvidenceManifest = ref.read(
      currentFinancialReportReleaseEvidenceManifestProvider,
    );
    final releaseArchiveSummary = ref.read(
      currentFinancialReportReleaseArchiveSummaryProvider,
    );
    final releaseArchiveAuditEvents = ref.read(
      currentFinancialReportReleaseArchiveAuditProvider,
    );
    final releaseArchiveRetentionSummary = ref.read(
      currentFinancialReportReleaseArchiveRetentionProvider,
    );
    final statutoryFilingSummary = ref.read(
      currentFinancialReportStatutoryFilingProvider,
    );
    final postedAdjustmentJournals = ref.read(postedLedgerProvider);
    final packageIntegrity = ref.read(
      currentFinancialReportPackageIntegrityProvider,
    );
    final service = ref.read(financialReportExportServiceProvider);

    try {
      final artifact = switch (format) {
        FinancialReportExportFormat.pdf => await service.buildPdf(
          pack,
          closeRecord: closeRecord,
          packageIntegrity: packageIntegrity,
          exceptionResolutions: exceptionResolutions,
          evidenceTaskResolutions: evidenceTaskResolutions,
          evidenceTaskAuditEvents: evidenceTaskAuditEvents,
          managementMeasureAuditEvents: managementMeasureAuditEvents,
          releaseSignOffItems: releaseSignOffItems,
          releaseSignOffAuditEvents: releaseSignOffAuditEvents,
          releaseDistributionItems: releaseDistributionItems,
          releaseDistributionAuditEvents: releaseDistributionAuditEvents,
          releaseActionQueueSummary: releaseActionQueueSummary,
          releaseMilestoneSummary: releaseMilestoneSummary,
          standardTransitionSummary: standardTransitionSummary,
          subsequentEventReviewSummary: subsequentEventReviewSummary,
          goingConcernReviewSummary: goingConcernReviewSummary,
          releaseEvidenceManifest: releaseEvidenceManifest,
          releaseArchiveSummary: releaseArchiveSummary,
          releaseArchiveAuditEvents: releaseArchiveAuditEvents,
          releaseArchiveRetentionSummary: releaseArchiveRetentionSummary,
          statutoryFilingSummary: statutoryFilingSummary,
          postedAdjustmentJournals: postedAdjustmentJournals,
          closeAuditTrail: closeAuditTrail,
        ),
        FinancialReportExportFormat.csv => service.buildCsv(
          pack,
          closeRecord: closeRecord,
          packageIntegrity: packageIntegrity,
          exceptionResolutions: exceptionResolutions,
          evidenceTaskResolutions: evidenceTaskResolutions,
          evidenceTaskAuditEvents: evidenceTaskAuditEvents,
          managementMeasureAuditEvents: managementMeasureAuditEvents,
          releaseSignOffItems: releaseSignOffItems,
          releaseSignOffAuditEvents: releaseSignOffAuditEvents,
          releaseDistributionItems: releaseDistributionItems,
          releaseDistributionAuditEvents: releaseDistributionAuditEvents,
          releaseActionQueueSummary: releaseActionQueueSummary,
          releaseMilestoneSummary: releaseMilestoneSummary,
          standardTransitionSummary: standardTransitionSummary,
          subsequentEventReviewSummary: subsequentEventReviewSummary,
          goingConcernReviewSummary: goingConcernReviewSummary,
          releaseEvidenceManifest: releaseEvidenceManifest,
          releaseArchiveSummary: releaseArchiveSummary,
          releaseArchiveAuditEvents: releaseArchiveAuditEvents,
          releaseArchiveRetentionSummary: releaseArchiveRetentionSummary,
          statutoryFilingSummary: statutoryFilingSummary,
          postedAdjustmentJournals: postedAdjustmentJournals,
          closeAuditTrail: closeAuditTrail,
        ),
      };

      if (!mounted) {
        return;
      }

      switch (artifact.format) {
        case FinancialReportExportFormat.pdf:
          await Printing.sharePdf(
            bytes: artifact.bytes,
            filename: artifact.fileName,
          );
          break;
        case FinancialReportExportFormat.csv:
          await SharePlus.instance.share(
            ShareParams(
              files: [
                XFile.fromData(
                  artifact.bytes,
                  name: artifact.fileName,
                  mimeType: artifact.mimeType,
                ),
              ],
              fileNameOverrides: [artifact.fileName],
              subject: artifact.fileName,
            ),
          );
          break;
      }

      if (!mounted) {
        return;
      }
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${artifact.format.label} report pack is ready.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _exportingFormat = null);
      }
    }
  }
}
