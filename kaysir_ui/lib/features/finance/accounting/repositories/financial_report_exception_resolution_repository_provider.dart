import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_report_exception_resolution_repository.dart';
import 'local_financial_report_exception_resolution_repository.dart';

export 'financial_report_exception_resolution_repository.dart';

final financialReportExceptionResolutionRepositoryProvider =
    Provider<FinancialReportExceptionResolutionRepository>((ref) {
      return LocalFinancialReportExceptionResolutionRepository(
        store: LocalDbFinancialReportExceptionResolutionSnapshotStore(),
      );
    });
