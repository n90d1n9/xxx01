import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/journal_approval_seed_data.dart';
import 'journal_approval_repository.dart';
import 'local_journal_approval_repository.dart';

export 'journal_approval_repository.dart';

/// Repository provider for persisted journal approval queue state.
final journalApprovalRepositoryProvider = Provider<JournalApprovalRepository>((
  ref,
) {
  return LocalJournalApprovalRepository(
    store: LocalDbJournalApprovalSnapshotStore(),
    requests: seedJournalApprovals(),
  );
});
