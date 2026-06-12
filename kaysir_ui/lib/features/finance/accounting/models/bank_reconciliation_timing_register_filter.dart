import 'bank_reconciliation_timing_register.dart';

enum BankReconciliationTimingRegisterFilter {
  all,
  current,
  watch,
  stale,
  deadlineRisk,
  overdue,
  dueSoon,
  deposits,
  payments,
}

extension BankReconciliationTimingRegisterFilterLabel
    on BankReconciliationTimingRegisterFilter {
  BankReconciliationTimingRegisterSort get defaultSort {
    switch (this) {
      case BankReconciliationTimingRegisterFilter.deadlineRisk:
      case BankReconciliationTimingRegisterFilter.overdue:
      case BankReconciliationTimingRegisterFilter.dueSoon:
        return const BankReconciliationTimingRegisterSort(
          field: BankReconciliationTimingRegisterSortField.deadline,
          ascending: true,
        );
      case BankReconciliationTimingRegisterFilter.all:
      case BankReconciliationTimingRegisterFilter.current:
      case BankReconciliationTimingRegisterFilter.watch:
      case BankReconciliationTimingRegisterFilter.stale:
      case BankReconciliationTimingRegisterFilter.deposits:
      case BankReconciliationTimingRegisterFilter.payments:
        return const BankReconciliationTimingRegisterSort(
          field: BankReconciliationTimingRegisterSortField.age,
          ascending: false,
        );
    }
  }

  String get label {
    switch (this) {
      case BankReconciliationTimingRegisterFilter.all:
        return 'All';
      case BankReconciliationTimingRegisterFilter.current:
        return 'Current';
      case BankReconciliationTimingRegisterFilter.watch:
        return 'Watch';
      case BankReconciliationTimingRegisterFilter.stale:
        return 'Stale';
      case BankReconciliationTimingRegisterFilter.deadlineRisk:
        return 'At Risk';
      case BankReconciliationTimingRegisterFilter.overdue:
        return 'Overdue';
      case BankReconciliationTimingRegisterFilter.dueSoon:
        return 'Due Soon';
      case BankReconciliationTimingRegisterFilter.deposits:
        return 'Deposits';
      case BankReconciliationTimingRegisterFilter.payments:
        return 'Payments';
    }
  }

  bool matches(BankReconciliationTimingRegisterItem item) {
    switch (this) {
      case BankReconciliationTimingRegisterFilter.all:
        return true;
      case BankReconciliationTimingRegisterFilter.current:
        return item.bucket == BankReconciliationTimingBucket.current;
      case BankReconciliationTimingRegisterFilter.watch:
        return item.bucket == BankReconciliationTimingBucket.watch;
      case BankReconciliationTimingRegisterFilter.stale:
        return item.bucket == BankReconciliationTimingBucket.stale;
      case BankReconciliationTimingRegisterFilter.deadlineRisk:
        return item.deadlineStatus !=
            BankReconciliationTimingDeadlineStatus.onTrack;
      case BankReconciliationTimingRegisterFilter.overdue:
        return item.deadlineStatus ==
            BankReconciliationTimingDeadlineStatus.overdue;
      case BankReconciliationTimingRegisterFilter.dueSoon:
        return item.deadlineStatus ==
            BankReconciliationTimingDeadlineStatus.dueSoon;
      case BankReconciliationTimingRegisterFilter.deposits:
        return item.isDepositInTransit;
      case BankReconciliationTimingRegisterFilter.payments:
        return item.isOutstandingPayment;
    }
  }
}
