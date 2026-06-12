import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bank_statement_repository.dart';
import 'local_bank_statement_repository.dart';

export 'bank_statement_repository.dart';

final bankStatementRepositoryProvider = Provider<BankStatementRepository>((
  ref,
) {
  return LocalBankStatementRepository(
    store: LocalDbBankStatementSnapshotStore(),
  );
});
