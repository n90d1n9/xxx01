import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_report_release_archive_repository.dart';
import 'local_financial_report_release_archive_repository.dart';

export 'financial_report_release_archive_repository.dart';

final financialReportReleaseArchiveRepositoryProvider =
    Provider<FinancialReportReleaseArchiveRepository>((ref) {
      return LocalFinancialReportReleaseArchiveRepository(
        store: LocalDbFinancialReportReleaseArchiveSnapshotStore(),
      );
    });
