import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_report_disclosure_review_repository.dart';
import 'local_financial_report_disclosure_review_repository.dart';

export 'financial_report_disclosure_review_repository.dart';

final financialReportDisclosureReviewRepositoryProvider =
    Provider<FinancialReportDisclosureReviewRepository>((ref) {
      return LocalFinancialReportDisclosureReviewRepository(
        store: LocalDbFinancialReportDisclosureReviewSnapshotStore(),
      );
    });
