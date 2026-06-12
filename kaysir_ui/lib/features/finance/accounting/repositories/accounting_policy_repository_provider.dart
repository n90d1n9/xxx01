import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'accounting_policy_repository.dart';
import 'local_accounting_policy_repository.dart';

export 'accounting_policy_repository.dart';

final accountingPolicyRepositoryProvider = Provider<AccountingPolicyRepository>(
  (ref) {
    return LocalAccountingPolicyRepository(
      store: LocalDbAccountingPolicySnapshotStore(),
    );
  },
);
