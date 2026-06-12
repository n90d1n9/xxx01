import '../models/journal_approval.dart';

/// Repository contract for persisted journal approval queue state.
abstract class JournalApprovalRepository {
  List<JournalApprovalRequest> loadRequests();

  void replaceAll(Iterable<JournalApprovalRequest> requests);
}

/// Hydratable repository for journal approvals stored outside memory.
abstract class HydratableJournalApprovalRepository
    implements JournalApprovalRepository {
  Future<void> hydrate();

  Future<void> persist();
}

/// In-memory journal approval repository for tests and previews.
class InMemoryJournalApprovalRepository implements JournalApprovalRepository {
  InMemoryJournalApprovalRepository({
    Iterable<JournalApprovalRequest>? requests,
  }) : _requests = [...?requests];

  final List<JournalApprovalRequest> _requests;

  @override
  List<JournalApprovalRequest> loadRequests() {
    return List.unmodifiable(_requests);
  }

  @override
  void replaceAll(Iterable<JournalApprovalRequest> requests) {
    _requests
      ..clear()
      ..addAll(requests);
  }
}
