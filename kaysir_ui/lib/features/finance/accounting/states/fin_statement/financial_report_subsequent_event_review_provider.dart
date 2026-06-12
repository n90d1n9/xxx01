import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_subsequent_event_review.dart';
import '../../services/financial_report_subsequent_event_review_service.dart';
import 'financial_report_disclosure_review_provider.dart';
import 'financial_report_package_integrity_provider.dart';
import 'financial_report_pack_provider.dart';
import 'financial_report_release_distribution_provider.dart';
import 'financial_report_release_signoff_provider.dart';

final financialReportSubsequentEventReviewServiceProvider =
    Provider<FinancialReportSubsequentEventReviewService>((ref) {
      return const FinancialReportSubsequentEventReviewService();
    });

final currentFinancialReportSubsequentEventReviewProvider =
    Provider<FinancialReportSubsequentEventReviewSummary>((ref) {
      return ref
          .watch(financialReportSubsequentEventReviewServiceProvider)
          .summarize(
            pack: ref.watch(financialReportPackProvider),
            packageIntegrity: ref.watch(
              currentFinancialReportPackageIntegrityProvider,
            ),
            signOffItems: ref.watch(
              currentFinancialReportReleaseSignOffItemsProvider,
            ),
            disclosureReviewItems: ref.watch(
              currentFinancialReportDisclosureReviewItemsProvider,
            ),
            distributionItems: ref.watch(
              currentFinancialReportReleaseDistributionItemsProvider,
            ),
            asOf: DateTime.now(),
          );
    });
