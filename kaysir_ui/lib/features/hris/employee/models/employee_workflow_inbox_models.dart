import 'employee_next_action_models.dart';

/// Source system represented by one employee workflow inbox item.
enum EmployeeWorkflowInboxSource {
  actionWorkflow('Workflow task'),
  profileChange('Profile change'),
  dataCorrection('Data correction'),
  jobAssignment('Job assignment');

  final String label;

  const EmployeeWorkflowInboxSource(this.label);
}

/// Saved view filters for reviewing an employee HR workflow inbox.
enum EmployeeWorkflowInboxFilter {
  all('All'),
  ready('Ready'),
  overdue('Overdue'),
  highPriority('High priority'),
  payroll('Payroll'),
  profileChange('Profile changes'),
  dataCorrection('Data corrections'),
  jobAssignment('Job assignments');

  final String label;

  const EmployeeWorkflowInboxFilter(this.label);
}

/// Primary action a reviewer can run from an employee workflow inbox item.
enum EmployeeWorkflowInboxAction {
  none('No action'),
  start('Start'),
  complete('Complete'),
  review('Review'),
  approve('Approve'),
  schedule('Schedule'),
  apply('Apply'),
  activate('Activate');

  final String label;

  const EmployeeWorkflowInboxAction(this.label);
}

/// Normalized inbox row for a pending employee HR workflow item.
class EmployeeWorkflowInboxItem {
  final String id;
  final String sourceRecordId;
  final String employeeId;
  final String employeeName;
  final String title;
  final String detail;
  final String owner;
  final EmployeeWorkflowInboxSource source;
  final EmployeeNextActionArea area;
  final EmployeeNextActionPriority priority;
  final String statusLabel;
  final DateTime dueDate;
  final bool isReady;
  final EmployeeWorkflowInboxAction primaryAction;

  const EmployeeWorkflowInboxItem({
    required this.id,
    required this.sourceRecordId,
    required this.employeeId,
    required this.employeeName,
    required this.title,
    required this.detail,
    required this.owner,
    required this.source,
    required this.area,
    required this.priority,
    required this.statusLabel,
    required this.dueDate,
    required this.isReady,
    required this.primaryAction,
  });

  bool get isCritical => priority == EmployeeNextActionPriority.critical;

  bool get hasPrimaryAction =>
      primaryAction != EmployeeWorkflowInboxAction.none;

  String get primaryActionLabel => primaryAction.label;

  bool get isHighPriority {
    return priority == EmployeeNextActionPriority.critical ||
        priority == EmployeeNextActionPriority.high;
  }

  bool isOverdue(DateTime asOfDate) {
    return dueDate.isBefore(_dateOnly(asOfDate));
  }

  String get sourceLabel => source.label;
}

/// Workload summary for one HR workflow inbox owner.
class EmployeeWorkflowInboxOwnerLoad {
  final String owner;
  final DateTime asOfDate;
  final List<EmployeeWorkflowInboxItem> items;

  const EmployeeWorkflowInboxOwnerLoad({
    required this.owner,
    required this.asOfDate,
    required this.items,
  });

  int get totalCount => items.length;

  int get readyCount => items.where((item) => item.isReady).length;

  int get overdueCount {
    return items.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get highPriorityCount {
    return items.where((item) => item.isHighPriority).length;
  }

  int get payrollCount {
    return items
        .where((item) => item.area == EmployeeNextActionArea.pay)
        .length;
  }

  bool get needsTriage => readyCount > 0 || overdueCount > 0;

  String get loadLabel {
    if (readyCount > 0) return '$readyCount ready';
    if (overdueCount > 0) return '$overdueCount overdue';
    if (highPriorityCount > 0) return '$highPriorityCount priority';
    return '$totalCount item${totalCount == 1 ? '' : 's'}';
  }
}

/// Aggregated per-employee HR workflow inbox.
class EmployeeWorkflowInboxProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkflowInboxItem> items;

  const EmployeeWorkflowInboxProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.items,
  });

  List<EmployeeWorkflowInboxItem> get sortedItems {
    return _sortItems(items);
  }

  List<EmployeeWorkflowInboxItem> itemsFor(
    EmployeeWorkflowInboxFilter filter, {
    String? owner,
  }) {
    return _sortItems(
      items.where(
        (item) =>
            _matchesFilter(item, filter, asOfDate) &&
            _matchesOwner(item, owner),
      ),
    );
  }

  int countFor(EmployeeWorkflowInboxFilter filter, {String? owner}) {
    return items
        .where(
          (item) =>
              _matchesFilter(item, filter, asOfDate) &&
              _matchesOwner(item, owner),
        )
        .length;
  }

  String nextActionFor(EmployeeWorkflowInboxFilter filter, {String? owner}) {
    if (filter == EmployeeWorkflowInboxFilter.all && owner == null) {
      return nextAction;
    }
    final count = countFor(filter, owner: owner);
    final ownerSuffix = owner == null ? '' : ' for $owner';
    if (count == 0) {
      return 'No ${filter.label.toLowerCase()} workflow items$ownerSuffix.';
    }
    return 'Review $count ${filter.label.toLowerCase()} workflow item${count == 1 ? '' : 's'}$ownerSuffix.';
  }

  List<EmployeeWorkflowInboxItem> _sortItems(
    Iterable<EmployeeWorkflowInboxItem> source,
  ) {
    final sorted = [...source]..sort((a, b) {
      final readyCompare = _readyRank(a).compareTo(_readyRank(b));
      if (readyCompare != 0) return readyCompare;

      final overdueCompare = _overdueRank(
        a,
        asOfDate,
      ).compareTo(_overdueRank(b, asOfDate));
      if (overdueCompare != 0) return overdueCompare;

      final priorityCompare = _priorityRank(
        a.priority,
      ).compareTo(_priorityRank(b.priority));
      if (priorityCompare != 0) return priorityCompare;

      return a.dueDate.compareTo(b.dueDate);
    });
    return sorted;
  }

  int get totalCount => items.length;

  int get readyCount => items.where((item) => item.isReady).length;

  int get overdueCount {
    return items.where((item) => item.isOverdue(asOfDate)).length;
  }

  int get highPriorityCount {
    return items.where((item) => item.isHighPriority).length;
  }

  int get payrollCount {
    return items
        .where((item) => item.area == EmployeeNextActionArea.pay)
        .length;
  }

  List<EmployeeWorkflowInboxOwnerLoad> get ownerLoads {
    final grouped = <String, List<EmployeeWorkflowInboxItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.owner, () => []).add(item);
    }

    final loads =
        grouped.entries
            .map(
              (entry) => EmployeeWorkflowInboxOwnerLoad(
                owner: entry.key,
                asOfDate: asOfDate,
                items: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) {
            final triageCompare = _ownerTriageRank(
              a,
            ).compareTo(_ownerTriageRank(b));
            if (triageCompare != 0) return triageCompare;

            final countCompare = b.totalCount.compareTo(a.totalCount);
            if (countCompare != 0) return countCompare;

            return a.owner.compareTo(b.owner);
          });
    return loads;
  }

  EmployeeWorkflowInboxOwnerLoad? ownerLoadFor(String? owner) {
    if (owner == null) return null;
    for (final load in ownerLoads) {
      if (load.owner == owner) return load;
    }
    return null;
  }

  String get nextAction {
    if (readyCount > 0) {
      return 'Act on $readyCount ready employee workflow item${readyCount == 1 ? '' : 's'}.';
    }
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue employee workflow item${overdueCount == 1 ? '' : 's'}.';
    }
    if (highPriorityCount > 0) {
      return 'Review $highPriorityCount high-priority employee workflow item${highPriorityCount == 1 ? '' : 's'}.';
    }
    if (totalCount > 0) {
      return 'Triage $totalCount employee workflow item${totalCount == 1 ? '' : 's'}.';
    }
    return 'Employee workflow inbox is clear.';
  }
}

bool _matchesOwner(EmployeeWorkflowInboxItem item, String? owner) {
  if (owner == null) return true;
  return item.owner == owner;
}

bool _matchesFilter(
  EmployeeWorkflowInboxItem item,
  EmployeeWorkflowInboxFilter filter,
  DateTime asOfDate,
) {
  return switch (filter) {
    EmployeeWorkflowInboxFilter.all => true,
    EmployeeWorkflowInboxFilter.ready => item.isReady,
    EmployeeWorkflowInboxFilter.overdue => item.isOverdue(asOfDate),
    EmployeeWorkflowInboxFilter.highPriority => item.isHighPriority,
    EmployeeWorkflowInboxFilter.payroll =>
      item.area == EmployeeNextActionArea.pay,
    EmployeeWorkflowInboxFilter.profileChange =>
      item.source == EmployeeWorkflowInboxSource.profileChange,
    EmployeeWorkflowInboxFilter.dataCorrection =>
      item.source == EmployeeWorkflowInboxSource.dataCorrection,
    EmployeeWorkflowInboxFilter.jobAssignment =>
      item.source == EmployeeWorkflowInboxSource.jobAssignment,
  };
}

int _ownerTriageRank(EmployeeWorkflowInboxOwnerLoad load) {
  if (load.readyCount > 0) return 0;
  if (load.overdueCount > 0) return 1;
  if (load.highPriorityCount > 0) return 2;
  return 3;
}

int _readyRank(EmployeeWorkflowInboxItem item) {
  return item.isReady ? 0 : 1;
}

int _overdueRank(EmployeeWorkflowInboxItem item, DateTime asOfDate) {
  return item.isOverdue(asOfDate) ? 0 : 1;
}

int _priorityRank(EmployeeNextActionPriority priority) {
  return switch (priority) {
    EmployeeNextActionPriority.critical => 0,
    EmployeeNextActionPriority.high => 1,
    EmployeeNextActionPriority.medium => 2,
    EmployeeNextActionPriority.low => 3,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
