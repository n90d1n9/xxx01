import 'payroll_exception_models.dart';
import 'payroll_exception_resolution_models.dart';

enum PayrollExceptionSlaStatus {
  breached('Breached'),
  dueToday('Due today'),
  onTrack('On track');

  final String label;

  const PayrollExceptionSlaStatus(this.label);
}

class PayrollExceptionSlaItem {
  final String id;
  final String title;
  final String sourceLabel;
  final String owner;
  final String escalationOwner;
  final String action;
  final DateTime dueDate;
  final PayrollExceptionSeverity severity;
  final double amount;

  const PayrollExceptionSlaItem({
    required this.id,
    required this.title,
    required this.sourceLabel,
    required this.owner,
    required this.escalationOwner,
    required this.action,
    required this.dueDate,
    required this.severity,
    required this.amount,
  });

  PayrollExceptionSlaStatus statusOn(DateTime asOfDate) {
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final asOfDay = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (dueDay.isBefore(asOfDay)) return PayrollExceptionSlaStatus.breached;
    if (dueDay.isAtSameMomentAs(asOfDay)) {
      return PayrollExceptionSlaStatus.dueToday;
    }
    return PayrollExceptionSlaStatus.onTrack;
  }

  int priorityOn(DateTime asOfDate) {
    final statusWeight = switch (statusOn(asOfDate)) {
      PayrollExceptionSlaStatus.breached => 300,
      PayrollExceptionSlaStatus.dueToday => 200,
      PayrollExceptionSlaStatus.onTrack => 100,
    };
    final severityWeight = switch (severity) {
      PayrollExceptionSeverity.critical => 30,
      PayrollExceptionSeverity.warning => 20,
      PayrollExceptionSeverity.info => 10,
    };
    return statusWeight + severityWeight;
  }
}

class PayrollExceptionSlaOwnerLoad {
  final String owner;
  final int totalCount;
  final int breachedCount;
  final double amountAtRisk;

  const PayrollExceptionSlaOwnerLoad({
    required this.owner,
    required this.totalCount,
    required this.breachedCount,
    required this.amountAtRisk,
  });
}

class PayrollExceptionSlaSummary {
  final DateTime asOfDate;
  final List<PayrollExceptionSlaItem> items;

  const PayrollExceptionSlaSummary({
    required this.asOfDate,
    required this.items,
  });

  factory PayrollExceptionSlaSummary.fromRun({
    required DateTime asOfDate,
    required List<PayrollExceptionItem> exceptions,
    required PayrollExceptionResolutionSummary resolution,
  }) {
    final items = <PayrollExceptionSlaItem>[
      for (final exception in exceptions.where((exception) => exception.isOpen))
        PayrollExceptionSlaItem(
          id: exception.id,
          title: exception.title,
          sourceLabel: exception.employeeName,
          owner: exception.owner,
          escalationOwner: _escalationOwnerFor(exception.severity),
          action: exception.action,
          dueDate: exception.dueDate,
          severity: exception.severity,
          amount: 0,
        ),
      for (final line in resolution.lines)
        PayrollExceptionSlaItem(
          id: 'blocker-${line.id}',
          title: line.title,
          sourceLabel: line.source.label,
          owner: line.owner,
          escalationOwner: _escalationOwnerFor(line.severity),
          action: line.action,
          dueDate: _dueDateFor(line, asOfDate),
          severity: line.severity,
          amount: line.amount,
        ),
    ];

    items.sort((left, right) {
      final priority = right
          .priorityOn(asOfDate)
          .compareTo(left.priorityOn(asOfDate));
      if (priority != 0) return priority;
      final dueDate = left.dueDate.compareTo(right.dueDate);
      if (dueDate != 0) return dueDate;
      return right.amount.compareTo(left.amount);
    });

    return PayrollExceptionSlaSummary(asOfDate: asOfDate, items: items);
  }

  int get breachedCount =>
      items
          .where(
            (item) =>
                item.statusOn(asOfDate) == PayrollExceptionSlaStatus.breached,
          )
          .length;

  int get dueTodayCount =>
      items
          .where(
            (item) =>
                item.statusOn(asOfDate) == PayrollExceptionSlaStatus.dueToday,
          )
          .length;

  int get criticalCount =>
      items
          .where((item) => item.severity == PayrollExceptionSeverity.critical)
          .length;

  double get amountAtRisk =>
      items.fold(0, (total, item) => total + item.amount);

  List<PayrollExceptionSlaOwnerLoad> get ownerLoads {
    final loads = <String, List<PayrollExceptionSlaItem>>{};
    for (final item in items) {
      loads
          .putIfAbsent(item.owner, () => <PayrollExceptionSlaItem>[])
          .add(item);
    }

    final ownerLoads =
        loads.entries.map((entry) {
          final ownerItems = entry.value;
          return PayrollExceptionSlaOwnerLoad(
            owner: entry.key,
            totalCount: ownerItems.length,
            breachedCount:
                ownerItems
                    .where(
                      (item) =>
                          item.statusOn(asOfDate) ==
                          PayrollExceptionSlaStatus.breached,
                    )
                    .length,
            amountAtRisk: ownerItems.fold(
              0,
              (total, item) => total + item.amount,
            ),
          );
        }).toList();

    ownerLoads.sort((left, right) {
      final breached = right.breachedCount.compareTo(left.breachedCount);
      if (breached != 0) return breached;
      return right.amountAtRisk.compareTo(left.amountAtRisk);
    });
    return ownerLoads;
  }

  String get nextAction {
    if (items.isEmpty) return 'No payroll exception SLA items remain.';
    if (breachedCount > 0) {
      return 'Escalate $breachedCount breached payroll SLA items.';
    }
    if (dueTodayCount > 0) {
      return 'Clear $dueTodayCount payroll SLA items due today.';
    }
    return 'Monitor ${items.length} payroll SLA items before close.';
  }
}

DateTime _dueDateFor(PayrollExceptionResolutionLine line, DateTime asOfDate) {
  final dayOffset = switch (line.severity) {
    PayrollExceptionSeverity.critical => 0,
    PayrollExceptionSeverity.warning => 1,
    PayrollExceptionSeverity.info => 2,
  };
  return DateTime(asOfDate.year, asOfDate.month, asOfDate.day + dayOffset);
}

String _escalationOwnerFor(PayrollExceptionSeverity severity) {
  return switch (severity) {
    PayrollExceptionSeverity.critical => 'Payroll Controller',
    PayrollExceptionSeverity.warning => 'Payroll Manager',
    PayrollExceptionSeverity.info => 'Payroll Operations Lead',
  };
}
