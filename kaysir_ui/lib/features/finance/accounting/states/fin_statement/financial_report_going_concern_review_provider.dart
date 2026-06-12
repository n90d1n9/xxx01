import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_going_concern_review.dart';
import '../../services/financial_report_going_concern_review_service.dart';
import 'financial_report_disclosure_review_provider.dart';
import 'financial_report_pack_provider.dart';
import 'financial_report_release_signoff_provider.dart';

final financialReportGoingConcernReviewServiceProvider =
    Provider<FinancialReportGoingConcernReviewService>((ref) {
      return const FinancialReportGoingConcernReviewService();
    });

final currentFinancialReportGoingConcernReviewProvider =
    Provider<FinancialReportGoingConcernReviewSummary>((ref) {
      return ref
          .watch(financialReportGoingConcernReviewServiceProvider)
          .summarize(
            pack: ref.watch(financialReportPackProvider),
            disclosureReviewItems: ref.watch(
              currentFinancialReportDisclosureReviewItemsProvider,
            ),
            signOffItems: ref.watch(
              currentFinancialReportReleaseSignOffItemsProvider,
            ),
          );
    });
