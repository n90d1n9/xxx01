
// Supporting Classes

import '../task/task.dart';

class FilterOptions {
  DateTime? startDate;
  DateTime? endDate;
  Set<TaskPriority> priorities;
  Set<TaskStatus> statuses;
  String assignedToSearch;

  FilterOptions({
    this.startDate,
    this.endDate,
    Set<TaskPriority>? priorities,
    Set<TaskStatus>? statuses,
    this.assignedToSearch = '',
  })  : priorities = priorities ?? {},
        statuses = statuses ?? {};

  bool get isActive =>
      startDate != null ||
      endDate != null ||
      priorities.isNotEmpty ||
      statuses.isNotEmpty ||
      assignedToSearch.isNotEmpty;

  int get activeFilterCount {
    int count = 0;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (priorities.isNotEmpty) count++;
    if (statuses.isNotEmpty) count++;
    if (assignedToSearch.isNotEmpty) count++;
    return count;
  }

  FilterOptions copy() {
    return FilterOptions(
      startDate: startDate,
      endDate: endDate,
      priorities: Set.from(priorities),
      statuses: Set.from(statuses),
      assignedToSearch: assignedToSearch,
    );
  }
}

