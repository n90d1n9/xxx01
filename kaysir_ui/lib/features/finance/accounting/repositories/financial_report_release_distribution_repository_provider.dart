import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_report_release_distribution_repository.dart';
import 'local_financial_report_release_distribution_repository.dart';

export 'financial_report_release_distribution_repository.dart';

final financialReportReleaseDistributionRepositoryProvider =
    Provider<FinancialReportReleaseDistributionRepository>((ref) {
      return LocalFinancialReportReleaseDistributionRepository(
        store: LocalDbFinancialReportReleaseDistributionSnapshotStore(),
      );
    });
