import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bank_reconciliation_timing_review_repository.dart';
import 'local_bank_reconciliation_timing_review_repository.dart';

export 'bank_reconciliation_timing_review_repository.dart';

final bankReconciliationTimingReviewRepositoryProvider =
    Provider<BankReconciliationTimingReviewRepository>((ref) {
      return LocalBankReconciliationTimingReviewRepository(
        store: LocalDbBankReconciliationTimingReviewSnapshotStore(),
      );
    });
