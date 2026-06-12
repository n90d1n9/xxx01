import '../accounting_core/models/ledger_posting.dart';

abstract class PostedLedgerRepository {
  List<LedgerPosting> loadPostings();

  void appendPosting(LedgerPosting posting);

  void clear();
}

abstract class HydratablePostedLedgerRepository
    implements PostedLedgerRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryPostedLedgerRepository implements PostedLedgerRepository {
  final List<LedgerPosting> _postings;

  InMemoryPostedLedgerRepository({Iterable<LedgerPosting>? postings})
    : _postings = [...?postings];

  @override
  List<LedgerPosting> loadPostings() {
    return List.unmodifiable(_postings);
  }

  @override
  void appendPosting(LedgerPosting posting) {
    _postings.add(posting);
  }

  void replaceAll(Iterable<LedgerPosting> postings) {
    _postings
      ..clear()
      ..addAll(postings);
  }

  @override
  void clear() {
    _postings.clear();
  }
}
