import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_release_milestone.dart';
import '../../services/financial_report_release_milestone_service.dart';
import 'financial_report_package_integrity_provider.dart';
import 'financial_report_pack_provider.dart';
import 'financial_report_release_archive_provider.dart';
import 'financial_report_release_distribution_provider.dart';
import 'financial_report_release_signoff_provider.dart';

final financialReportReleaseMilestoneServiceProvider =
    Provider<FinancialReportReleaseMilestoneService>((ref) {
      return const FinancialReportReleaseMilestoneService();
    });

final currentFinancialReportReleaseMilestoneProvider =
    Provider<FinancialReportReleaseMilestoneSummary>((ref) {
      return ref
          .watch(financialReportReleaseMilestoneServiceProvider)
          .summarize(
            pack: ref.watch(financialReportPackProvider),
            packageIntegrity: ref.watch(
              currentFinancialReportPackageIntegrityProvider,
            ),
            signOffItems: ref.watch(
              currentFinancialReportReleaseSignOffItemsProvider,
            ),
            distributionItems: ref.watch(
              currentFinancialReportReleaseDistributionItemsProvider,
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
