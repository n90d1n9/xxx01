import '../models/bank_reconciliation_timing_review.dart';

abstract class BankReconciliationTimingReviewRepository {
  Map<String, BankReconciliationTimingReview> loadReviews(String periodKey);

  Map<String, Map<String, BankReconciliationTimingReview>>
  loadReviewsByPeriod();

  void saveReview({
    required String periodKey,
    required BankReconciliationTimingReview review,
  });

  void removeReview({required String periodKey, required String reference});

  void clear();
}

abstract class HydratableBankReconciliationTimingReviewRepository
    implements BankReconciliationTimingReviewRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryBankReconciliationTimingReviewRepository
    implements BankReconciliationTimingReviewRepository {
  final Map<String, Map<String, BankReconciliationTimingReview>>
  _reviewsByPeriod;

  InMemoryBankReconciliationTimingReviewRepository({
    Map<String, Map<String, BankReconciliationTimingReview>>? reviewsByPeriod,
  }) : _reviewsByPeriod = _copyReviewsByPeriod(reviewsByPeriod ?? const {});

  @override
  Map<String, BankReconciliationTimingReview> loadReviews(String periodKey) {
    return Map.unmodifiable(
      _copyReviewMap(_reviewsByPeriod[periodKey] ?? const {}),
    );
  }

  @override
  Map<String, Map<String, BankReconciliationTimingReview>>
  loadReviewsByPeriod() {
    final reviewsByPeriod =
        <String, Map<String, BankReconciliationTimingReview>>{};
    for (final entry in _reviewsByPeriod.entries) {
      reviewsByPeriod[entry.key] = Map.unmodifiable(
        _copyReviewMap(entry.value),
      );
    }
    return Map.unmodifiable(reviewsByPeriod);
  }

  @override
  void saveReview({
    required String periodKey,
    required BankReconciliationTimingReview review,
  }) {
    final reviews = _copyReviewMap(_reviewsByPeriod[periodKey] ?? const {});
    reviews[review.reference] = review;
    _reviewsByPeriod[periodKey] = _copyReviewMap(reviews);
  }

  @override
  void removeReview({required String periodKey, required String reference}) {
    final reviews = _reviewsByPeriod[periodKey];
    if (reviews == null) {
      return;
    }

    final next = _copyReviewMap(reviews)..remove(reference);
    if (next.isEmpty) {
      _reviewsByPeriod.remove(periodKey);
    } else {
      _reviewsByPeriod[periodKey] = next;
    }
  }

  void replaceAll(
    Map<String, Map<String, BankReconciliationTimingReview>> reviewsByPeriod,
  ) {
    _reviewsByPeriod
      ..clear()
      ..addAll(_copyReviewsByPeriod(reviewsByPeriod));
  }

  @override
  void clear() {
    _reviewsByPeriod.clear();
  }
}

Map<String, Map<String, BankReconciliationTimingReview>> _copyReviewsByPeriod(
  Map<String, Map<String, BankReconciliationTimingReview>> source,
) {
  return source.map(
    (periodKey, reviews) => MapEntry(periodKey, _copyReviewMap(reviews)),
  );
}

Map<String, BankReconciliationTimingReview> _copyReviewMap(
  Map<String, BankReconciliationTimingReview> source,
) {
  final sorted = source.values.toList()..sort(_compareReviews);
  return {for (final review in sorted) review.reference: review};
}

int _compareReviews(
  BankReconciliationTimingReview left,
  BankReconciliationTimingReview right,
) {
  final reference = left.reference.compareTo(right.reference);
  if (reference != 0) {
    return reference;
  }
  return left.reviewedAt.compareTo(right.reviewedAt);
}
