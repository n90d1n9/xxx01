import 'bank_reconciliation_timing_register.dart';

enum BankReconciliationTimingReviewStatus {
  open,
  inReview,
  cleared,
  adjusted,
  deferred,
}

extension BankReconciliationTimingReviewStatusLabel
    on BankReconciliationTimingReviewStatus {
  String get label {
    switch (this) {
      case BankReconciliationTimingReviewStatus.open:
        return 'Open';
      case BankReconciliationTimingReviewStatus.inReview:
        return 'In Review';
      case BankReconciliationTimingReviewStatus.cleared:
        return 'Cleared';
      case BankReconciliationTimingReviewStatus.adjusted:
        return 'Adjusted';
      case BankReconciliationTimingReviewStatus.deferred:
        return 'Deferred';
    }
  }

  bool get isResolved {
    switch (this) {
      case BankReconciliationTimingReviewStatus.cleared:
      case BankReconciliationTimingReviewStatus.adjusted:
        return true;
      case BankReconciliationTimingReviewStatus.open:
      case BankReconciliationTimingReviewStatus.inReview:
      case BankReconciliationTimingReviewStatus.deferred:
        return false;
    }
  }
}

class BankReconciliationTimingReview {
  final String reference;
  final BankReconciliationTimingReviewStatus status;
  final String owner;
  final String note;
  final DateTime reviewedAt;

  const BankReconciliationTimingReview({
    required this.reference,
    required this.status,
    required this.owner,
    required this.note,
    required this.reviewedAt,
  });

  factory BankReconciliationTimingReview.fromJson(Map<String, dynamic> json) {
    return BankReconciliationTimingReview(
      reference: json['reference'] as String,
      status: _reviewStatusFromJson(json['status']),
      owner: json['owner'] as String? ?? 'Unassigned',
      note: json['note'] as String? ?? '',
      reviewedAt: _reviewedAtFromJson(json['reviewedAt']),
    );
  }

  factory BankReconciliationTimingReview.open(String reference) {
    return BankReconciliationTimingReview(
      reference: reference,
      status: BankReconciliationTimingReviewStatus.open,
      owner: 'Unassigned',
      note: '',
      reviewedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool get hasEvidence =>
      status != BankReconciliationTimingReviewStatus.open ||
      owner.trim() != 'Unassigned' ||
      note.trim().isNotEmpty;

  bool get isResolved => status.isResolved;

  String get ownerLabel => owner.trim().isEmpty ? 'Unassigned' : owner.trim();

  String get noteLabel => note.trim().isEmpty ? 'No note' : note.trim();

  bool get needsOwner =>
      status != BankReconciliationTimingReviewStatus.open &&
      ownerLabel == 'Unassigned';

  bool matchesSearch(String query) {
    final normalizedQuery = _normalizeReviewSearchValue(query);
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return [
      reference,
      status.label,
      ownerLabel,
      noteLabel,
      reviewedAt.toIso8601String(),
    ].any(
      (value) => _normalizeReviewSearchValue(value).contains(normalizedQuery),
    );
  }

  BankReconciliationTimingReview copyWith({
    BankReconciliationTimingReviewStatus? status,
    String? owner,
    String? note,
    DateTime? reviewedAt,
  }) {
    return BankReconciliationTimingReview(
      reference: reference,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      note: note ?? this.note,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'status': status.name,
      'owner': owner,
      'note': note,
      'reviewedAt': reviewedAt.toIso8601String(),
    };
  }
}

class BankReconciliationTimingReviewSummary {
  final int itemCount;
  final int documentedCount;
  final int openCount;
  final int inReviewCount;
  final int clearedCount;
  final int adjustedCount;
  final int deferredCount;
  final int unresolvedOverdueCount;
  final int needsOwnerCount;

  const BankReconciliationTimingReviewSummary({
    required this.itemCount,
    required this.documentedCount,
    required this.openCount,
    required this.inReviewCount,
    required this.clearedCount,
    required this.adjustedCount,
    required this.deferredCount,
    required this.unresolvedOverdueCount,
    required this.needsOwnerCount,
  });

  factory BankReconciliationTimingReviewSummary.fromItems({
    required Iterable<BankReconciliationTimingRegisterItem> items,
    required Map<String, BankReconciliationTimingReview> reviews,
  }) {
    var itemCount = 0;
    var documentedCount = 0;
    var openCount = 0;
    var inReviewCount = 0;
    var clearedCount = 0;
    var adjustedCount = 0;
    var deferredCount = 0;
    var unresolvedOverdueCount = 0;
    var needsOwnerCount = 0;

    for (final item in items) {
      final review =
          reviews[item.reference] ??
          BankReconciliationTimingReview.open(item.reference);
      itemCount += 1;
      if (review.hasEvidence) {
        documentedCount += 1;
      }
      if (review.needsOwner) {
        needsOwnerCount += 1;
      }
      if (!review.isResolved &&
          item.deadlineStatus ==
              BankReconciliationTimingDeadlineStatus.overdue) {
        unresolvedOverdueCount += 1;
      }
      switch (review.status) {
        case BankReconciliationTimingReviewStatus.open:
          openCount += 1;
        case BankReconciliationTimingReviewStatus.inReview:
          inReviewCount += 1;
        case BankReconciliationTimingReviewStatus.cleared:
          clearedCount += 1;
        case BankReconciliationTimingReviewStatus.adjusted:
          adjustedCount += 1;
        case BankReconciliationTimingReviewStatus.deferred:
          deferredCount += 1;
      }
    }

    return BankReconciliationTimingReviewSummary(
      itemCount: itemCount,
      documentedCount: documentedCount,
      openCount: openCount,
      inReviewCount: inReviewCount,
      clearedCount: clearedCount,
      adjustedCount: adjustedCount,
      deferredCount: deferredCount,
      unresolvedOverdueCount: unresolvedOverdueCount,
      needsOwnerCount: needsOwnerCount,
    );
  }

  bool get hasItems => itemCount > 0;

  int get resolvedCount => clearedCount + adjustedCount;

  int get unresolvedCount => itemCount - resolvedCount;

  int get unreviewedCount => itemCount - documentedCount;

  double get coverageRatio => itemCount == 0 ? 1 : documentedCount / itemCount;

  bool get hasReviewGaps =>
      unreviewedCount > 0 || needsOwnerCount > 0 || unresolvedOverdueCount > 0;

  String get coverageLabel => hasItems ? '$documentedCount/$itemCount' : '-';

  String get resolvedLabel => hasItems ? '$resolvedCount/$itemCount' : '-';

  String get nextActionLabel {
    if (!hasItems) {
      return 'No timing review required';
    }
    if (unresolvedOverdueCount > 0) {
      return 'Resolve $unresolvedOverdueCount overdue review(s)';
    }
    if (needsOwnerCount > 0) {
      return 'Assign $needsOwnerCount review owner(s)';
    }
    if (unreviewedCount > 0) {
      return 'Document $unreviewedCount open review(s)';
    }
    if (inReviewCount > 0) {
      return 'Follow up $inReviewCount active review(s)';
    }
    if (deferredCount > 0) {
      return 'Revisit $deferredCount deferred item(s)';
    }
    return 'Timing review evidence complete';
  }
}

String _normalizeReviewSearchValue(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

BankReconciliationTimingReviewStatus _reviewStatusFromJson(Object? value) {
  final normalized = value?.toString();
  return BankReconciliationTimingReviewStatus.values.firstWhere(
    (status) => status.name == normalized,
    orElse: () => BankReconciliationTimingReviewStatus.open,
  );
}

DateTime _reviewedAtFromJson(Object? value) {
  if (value == null) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.tryParse(value.toString()) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
