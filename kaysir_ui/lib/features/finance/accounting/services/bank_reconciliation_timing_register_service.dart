import '../models/bank_reconciliation_resolution.dart';
import '../models/bank_reconciliation_timing_register.dart';

class BankReconciliationTimingRegisterService {
  final int staleThresholdDays;

  const BankReconciliationTimingRegisterService({this.staleThresholdDays = 30});

  List<BankReconciliationTimingRegisterItem> build({
    required BankReconciliationResolutionPlan resolutionPlan,
    required DateTime asOfDate,
  }) {
    final register = <BankReconciliationTimingRegisterItem>[
      for (final action in resolutionPlan.actions)
        if (!action.suggestsJournal) _itemFor(action, asOfDate),
    ];

    register.sort(_compareItems);
    return register;
  }

  BankReconciliationTimingRegisterItem _itemFor(
    BankReconciliationResolutionAction action,
    DateTime asOfDate,
  ) {
    final rawAgeDays = asOfDate.difference(action.date).inDays;
    final ageDays = rawAgeDays < 0 ? 0 : rawAgeDays;
    final bucket = _bucketFor(ageDays);

    return BankReconciliationTimingRegisterItem(
      reference: action.reference,
      date: action.date,
      description: action.description,
      amount: action.amount,
      ageDays: ageDays,
      clearByDate: action.date.add(Duration(days: staleThresholdDays)),
      bucket: bucket,
      type: action.type,
      clearanceStatus: _clearanceStatusFor(bucket),
      suggestedAction: action.suggestedAction,
    );
  }

  BankReconciliationTimingBucket _bucketFor(int ageDays) {
    final watchThresholdDays =
        staleThresholdDays > 7 ? staleThresholdDays - 7 : 0;
    if (ageDays >= staleThresholdDays) {
      return BankReconciliationTimingBucket.stale;
    }
    if (ageDays >= watchThresholdDays) {
      return BankReconciliationTimingBucket.watch;
    }
    return BankReconciliationTimingBucket.current;
  }

  BankReconciliationTimingClearanceStatus _clearanceStatusFor(
    BankReconciliationTimingBucket bucket,
  ) {
    switch (bucket) {
      case BankReconciliationTimingBucket.current:
        return BankReconciliationTimingClearanceStatus.open;
      case BankReconciliationTimingBucket.watch:
        return BankReconciliationTimingClearanceStatus.monitor;
      case BankReconciliationTimingBucket.stale:
        return BankReconciliationTimingClearanceStatus.escalate;
    }
  }

  int _compareItems(
    BankReconciliationTimingRegisterItem left,
    BankReconciliationTimingRegisterItem right,
  ) {
    final bucket = _bucketRank(
      left.bucket,
    ).compareTo(_bucketRank(right.bucket));
    if (bucket != 0) {
      return bucket;
    }
    final age = right.ageDays.compareTo(left.ageDays);
    if (age != 0) {
      return age;
    }
    return left.reference.compareTo(right.reference);
  }

  int _bucketRank(BankReconciliationTimingBucket bucket) {
    switch (bucket) {
      case BankReconciliationTimingBucket.stale:
        return 0;
      case BankReconciliationTimingBucket.watch:
        return 1;
      case BankReconciliationTimingBucket.current:
        return 2;
    }
  }
}
