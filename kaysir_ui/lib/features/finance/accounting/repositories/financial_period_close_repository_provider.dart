import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_period_close_repository.dart';
import 'local_financial_period_close_repository.dart';

export 'financial_period_close_repository.dart';

final financialPeriodCloseRepositoryProvider =
    Provider<FinancialPeriodCloseRepository>((ref) {
      return LocalFinancialPeriodCloseRepository(
        store: LocalDbFinancialPeriodCloseSnapshotStore(),
      );
    });
