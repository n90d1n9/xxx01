import 'bank_reconciliation_resolution.dart';

enum BankReconciliationTimingBucket { current, watch, stale }

extension BankReconciliationTimingBucketLabel
    on BankReconciliationTimingBucket {
  String get label {
    switch (this) {
      case BankReconciliationTimingBucket.current:
        return 'Current';
      case BankReconciliationTimingBucket.watch:
        return 'Watch';
      case BankReconciliationTimingBucket.stale:
        return 'Stale';
    }
  }
}

enum BankReconciliationTimingClearanceStatus { open, monitor, escalate }

extension BankReconciliationTimingClearanceStatusLabel
    on BankReconciliationTimingClearanceStatus {
  String get label {
    switch (this) {
      case BankReconciliationTimingClearanceStatus.open:
        return 'Open';
      case BankReconciliationTimingClearanceStatus.monitor:
        return 'Monitor';
      case BankReconciliationTimingClearanceStatus.escalate:
        return 'Escalate';
    }
  }
}

enum BankReconciliationTimingDeadlineStatus { onTrack, dueSoon, overdue }

extension BankReconciliationTimingDeadlineStatusLabel
    on BankReconciliationTimingDeadlineStatus {
  String get label {
    switch (this) {
      case BankReconciliationTimingDeadlineStatus.onTrack:
        return 'On track';
      case BankReconciliationTimingDeadlineStatus.dueSoon:
        return 'Due soon';
      case BankReconciliationTimingDeadlineStatus.overdue:
        return 'Overdue';
    }
  }

  int get priority {
    switch (this) {
      case BankReconciliationTimingDeadlineStatus.overdue:
        return 0;
      case BankReconciliationTimingDeadlineStatus.dueSoon:
        return 1;
      case BankReconciliationTimingDeadlineStatus.onTrack:
        return 2;
    }
  }
}

class BankReconciliationTimingRegisterItem {
  final String reference;
  final DateTime date;
  final String description;
  final double amount;
  final int ageDays;
  final DateTime clearByDate;
  final BankReconciliationTimingBucket bucket;
  final BankReconciliationResolutionType type;
  final BankReconciliationTimingClearanceStatus clearanceStatus;
  final String suggestedAction;

  const BankReconciliationTimingRegisterItem({
    required this.reference,
    required this.date,
    required this.description,
    required this.amount,
    required this.ageDays,
    required this.clearByDate,
    required this.bucket,
    required this.type,
    required this.clearanceStatus,
    required this.suggestedAction,
  });

  String get bucketLabel => bucket.label;

  String get typeLabel => type.label;

  String get clearanceStatusLabel => clearanceStatus.label;

  bool get isStale => bucket == BankReconciliationTimingBucket.stale;

  bool get isDepositInTransit =>
      type == BankReconciliationResolutionType.depositInTransit;

  bool get isOutstandingPayment =>
      type == BankReconciliationResolutionType.outstandingPayment;

  DateTime get agedAsOfDate => date.add(Duration(days: ageDays));

  int get daysUntilClearBy => clearByDate.difference(agedAsOfDate).inDays;

  BankReconciliationTimingDeadlineStatus get deadlineStatus {
    if (daysUntilClearBy <= 0) {
      return BankReconciliationTimingDeadlineStatus.overdue;
    }
    if (daysUntilClearBy <= 7) {
      return BankReconciliationTimingDeadlineStatus.dueSoon;
    }
    return BankReconciliationTimingDeadlineStatus.onTrack;
  }

  String get deadlineStatusLabel => deadlineStatus.label;

  String get daysUntilClearByLabel {
    final days = daysUntilClearBy;
    if (days <= 0) {
      return 'Overdue';
    }
    if (days == 1) {
      return '1d left';
    }
    return '${days}d left';
  }

  bool matchesSearch(String query) {
    final normalizedQuery = _normalizeSearchValue(query);
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return [
      reference,
      description,
      amount.toStringAsFixed(2),
      amount.abs().toStringAsFixed(2),
      ageDays.toString(),
      clearByDate.toIso8601String(),
      daysUntilClearByLabel,
      bucketLabel,
      typeLabel,
      clearanceStatusLabel,
      deadlineStatusLabel,
      suggestedAction,
    ].any((value) => _normalizeSearchValue(value).contains(normalizedQuery));
  }
}

String _normalizeSearchValue(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

enum BankReconciliationTimingRegisterSortField {
  bucket,
  type,
  date,
  reference,
  age,
  clearBy,
  deadline,
  amount,
  status,
}

class BankReconciliationTimingRegisterSort {
  final BankReconciliationTimingRegisterSortField field;
  final bool ascending;

  const BankReconciliationTimingRegisterSort({
    required this.field,
    required this.ascending,
  });

  List<BankReconciliationTimingRegisterItem> apply(
    Iterable<BankReconciliationTimingRegisterItem> items,
  ) {
    final sorted = items.toList();
    sorted.sort((left, right) {
      final primary = _compare(left, right);
      if (primary != 0) {
        return ascending ? primary : -primary;
      }
      return left.reference.compareTo(right.reference);
    });
    return sorted;
  }

  int _compare(
    BankReconciliationTimingRegisterItem left,
    BankReconciliationTimingRegisterItem right,
  ) {
    switch (field) {
      case BankReconciliationTimingRegisterSortField.bucket:
        return left.bucket.index.compareTo(right.bucket.index);
      case BankReconciliationTimingRegisterSortField.type:
        return left.typeLabel.compareTo(right.typeLabel);
      case BankReconciliationTimingRegisterSortField.date:
        return left.date.compareTo(right.date);
      case BankReconciliationTimingRegisterSortField.reference:
        return left.reference.compareTo(right.reference);
      case BankReconciliationTimingRegisterSortField.age:
        return left.ageDays.compareTo(right.ageDays);
      case BankReconciliationTimingRegisterSortField.clearBy:
        return left.clearByDate.compareTo(right.clearByDate);
      case BankReconciliationTimingRegisterSortField.deadline:
        return _compareDeadline(left, right);
      case BankReconciliationTimingRegisterSortField.amount:
        return left.amount.abs().compareTo(right.amount.abs());
      case BankReconciliationTimingRegisterSortField.status:
        return left.clearanceStatus.index.compareTo(
          right.clearanceStatus.index,
        );
    }
  }

  int _compareDeadline(
    BankReconciliationTimingRegisterItem left,
    BankReconciliationTimingRegisterItem right,
  ) {
    final priority = left.deadlineStatus.priority.compareTo(
      right.deadlineStatus.priority,
    );
    if (priority != 0) {
      return priority;
    }

    final remainingDays = left.daysUntilClearBy.compareTo(
      right.daysUntilClearBy,
    );
    if (remainingDays != 0) {
      return remainingDays;
    }

    return left.clearByDate.compareTo(right.clearByDate);
  }
}

class BankReconciliationTimingRegisterSummary {
  final int itemCount;
  final int depositCount;
  final int outstandingPaymentCount;
  final int staleCount;
  final int dueSoonCount;
  final int overdueCount;
  final int oldestAgeDays;
  final double netAmount;
  final double depositAmount;
  final double outstandingPaymentAmount;
  final double staleAmount;
  final BankReconciliationTimingRegisterItem? nextDeadlineItem;

  const BankReconciliationTimingRegisterSummary({
    required this.itemCount,
    required this.depositCount,
    required this.outstandingPaymentCount,
    required this.staleCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.oldestAgeDays,
    required this.netAmount,
    required this.depositAmount,
    required this.outstandingPaymentAmount,
    required this.staleAmount,
    required this.nextDeadlineItem,
  });

  factory BankReconciliationTimingRegisterSummary.fromItems(
    Iterable<BankReconciliationTimingRegisterItem> items,
  ) {
    var itemCount = 0;
    var depositCount = 0;
    var outstandingPaymentCount = 0;
    var staleCount = 0;
    var dueSoonCount = 0;
    var overdueCount = 0;
    var oldestAgeDays = 0;
    var netAmount = 0.0;
    var depositAmount = 0.0;
    var outstandingPaymentAmount = 0.0;
    var staleAmount = 0.0;
    BankReconciliationTimingRegisterItem? nextDeadlineItem;

    for (final item in items) {
      itemCount += 1;
      netAmount += item.amount;
      if (item.ageDays > oldestAgeDays) {
        oldestAgeDays = item.ageDays;
      }
      if (item.isDepositInTransit) {
        depositCount += 1;
        depositAmount += item.amount;
      }
      if (item.isOutstandingPayment) {
        outstandingPaymentCount += 1;
        outstandingPaymentAmount += item.amount;
      }
      if (item.isStale) {
        staleCount += 1;
        staleAmount += item.amount;
      }
      switch (item.deadlineStatus) {
        case BankReconciliationTimingDeadlineStatus.onTrack:
          break;
        case BankReconciliationTimingDeadlineStatus.dueSoon:
          dueSoonCount += 1;
          if (_isEarlierDeadlineRisk(item, nextDeadlineItem)) {
            nextDeadlineItem = item;
          }
        case BankReconciliationTimingDeadlineStatus.overdue:
          overdueCount += 1;
          if (_isEarlierDeadlineRisk(item, nextDeadlineItem)) {
            nextDeadlineItem = item;
          }
      }
    }

    return BankReconciliationTimingRegisterSummary(
      itemCount: itemCount,
      depositCount: depositCount,
      outstandingPaymentCount: outstandingPaymentCount,
      staleCount: staleCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      oldestAgeDays: oldestAgeDays,
      netAmount: netAmount,
      depositAmount: depositAmount,
      outstandingPaymentAmount: outstandingPaymentAmount,
      staleAmount: staleAmount,
      nextDeadlineItem: nextDeadlineItem,
    );
  }

  bool get hasItems => itemCount > 0;

  double get absoluteOutstandingPaymentAmount => outstandingPaymentAmount.abs();

  double get staleExposureAmount => staleAmount.abs();

  int get deadlineRiskCount => dueSoonCount + overdueCount;

  bool get hasDeadlineRisk => deadlineRiskCount > 0;

  String get oldestAgeLabel => hasItems ? '${oldestAgeDays}d' : '-';
}

bool _isEarlierDeadlineRisk(
  BankReconciliationTimingRegisterItem candidate,
  BankReconciliationTimingRegisterItem? current,
) {
  if (current == null) {
    return true;
  }

  final priority = candidate.deadlineStatus.priority.compareTo(
    current.deadlineStatus.priority,
  );
  if (priority != 0) {
    return priority < 0;
  }

  final remainingDays = candidate.daysUntilClearBy.compareTo(
    current.daysUntilClearBy,
  );
  if (remainingDays != 0) {
    return remainingDays < 0;
  }

  final clearBy = candidate.clearByDate.compareTo(current.clearByDate);
  if (clearBy != 0) {
    return clearBy < 0;
  }

  return candidate.reference.compareTo(current.reference) < 0;
}
