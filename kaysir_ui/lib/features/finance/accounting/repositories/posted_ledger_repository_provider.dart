import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_posted_ledger_repository.dart';
import 'posted_ledger_repository.dart';

export 'posted_ledger_repository.dart';

final postedLedgerRepositoryProvider = Provider<PostedLedgerRepository>((ref) {
  return LocalPostedLedgerRepository(store: LocalDbPostedLedgerSnapshotStore());
});
