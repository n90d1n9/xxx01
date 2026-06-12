import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_release_action_queue.dart';
import '../../services/financial_report_release_action_queue_service.dart';
import 'financial_report_management_measure_release_readiness_provider.dart';
import 'financial_report_package_integrity_provider.dart';
import 'financial_report_release_archive_provider.dart';
import 'financial_report_release_distribution_provider.dart';
import 'financial_report_release_evidence_manifest_provider.dart';
import 'financial_report_release_signoff_provider.dart';

final financialReportReleaseActionQueueServiceProvider =
    Provider<FinancialReportReleaseActionQueueService>((ref) {
      return const FinancialReportReleaseActionQueueService();
    });

final currentFinancialReportReleaseActionQueueProvider =
    Provider<FinancialReportReleaseActionQueueSummary>((ref) {
      return ref
          .watch(financialReportReleaseActionQueueServiceProvider)
          .summarize(
            controlSummary: ref.watch(
              currentFinancialReportReleaseControlSummaryProvider,
            ),
            packageIntegrity: ref.watch(
              currentFinancialReportPackageIntegrityProvider,
            ),
            managementMeasureReleaseReadiness: ref.watch(
              currentFinancialReportManagementMeasureReleaseReadinessProvider,
            ),
            signOffItems: ref.watch(
              currentFinancialReportReleaseSignOffItemsProvider,
            ),
            distributionItems: ref.watch(
              currentFinancialReportReleaseDistributionItemsProvider,
            ),
            evidenceManifest: ref.watch(
              currentFinancialReportReleaseEvidenceManifestProvider,
            ),
            archiveSummary: ref.watch(
              currentFinancialReportReleaseArchiveSummaryProvider,
            ),
            retentionSummary: ref.watch(
              currentFinancialReportReleaseArchiveRetentionProvider,
            ),
            statutoryFilingSummary: ref.watch(
              currentFinancialReportStatutoryFilingProvider,
            ),
            asOf: DateTime.now(),
          );
    });
