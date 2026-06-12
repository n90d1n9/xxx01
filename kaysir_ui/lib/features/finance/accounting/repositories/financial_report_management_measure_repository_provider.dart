import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_report_management_measure_repository.dart';
import 'local_financial_report_management_measure_repository.dart';

export 'financial_report_management_measure_repository.dart';

final financialReportManagementMeasureRepositoryProvider =
    Provider<FinancialReportManagementMeasureRepository>((ref) {
      return LocalFinancialReportManagementMeasureRepository(
        store: LocalDbFinancialReportManagementMeasureSnapshotStore(),
      );
    });
