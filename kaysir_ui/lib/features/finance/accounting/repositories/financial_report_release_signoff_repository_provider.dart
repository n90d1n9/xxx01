import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_report_release_signoff_repository.dart';
import 'local_financial_report_release_signoff_repository.dart';

export 'financial_report_release_signoff_repository.dart';

final financialReportReleaseSignOffRepositoryProvider =
    Provider<FinancialReportReleaseSignOffRepository>((ref) {
      return LocalFinancialReportReleaseSignOffRepository(
        store: LocalDbFinancialReportReleaseSignOffSnapshotStore(),
      );
    });
