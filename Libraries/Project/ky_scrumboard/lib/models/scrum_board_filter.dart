import 'package:flutter/foundation.dart';

import 'scrum_task.dart';
import 'scrum_task_priority.dart';
import 'scrum_task_sort.dart';
import 'scrum_task_status.dart';

@immutable
class ScrumBoardFilter {
  const ScrumBoardFilter({
    this.query = '',
    this.status,
    this.priorities = const {},
    this.assignees = const {},
    this.sort = ScrumTaskSort.laneOrder,
  });

  final String query;
  final ScrumTaskStatus? status;
  final Set<ScrumTaskPriority> priorities;
  final Set<String> assignees;
  final ScrumTaskSort sort;

  bool get hasQuery => query.trim().isNotEmpty;

  bool get hasStatus => status != null;

  bool get hasPriorities => priorities.isNotEmpty;

  bool get hasAssignees => assignees.isNotEmpty;

  bool get hasCustomSort => sort != ScrumTaskSort.laneOrder;

  bool get isActive {
    return hasQuery ||
        hasStatus ||
        hasPriorities ||
        hasAssignees ||
        hasCustomSort;
  }

  bool get hasTaskFacets => hasQuery || hasPriorities || hasAssignees;

  ScrumBoardFilter copyWith({
    String? query,
    ScrumTaskStatus? status,
    Set<ScrumTaskPriority>? priorities,
    Set<String>? assignees,
    ScrumTaskSort? sort,
    bool clearStatus = false,
  }) {
    return ScrumBoardFilter(
      query: query ?? this.query,
      status: clearStatus ? null : status ?? this.status,
      priorities: priorities ?? this.priorities,
      assignees: assignees ?? this.assignees,
      sort: sort ?? this.sort,
    );
  }

  ScrumBoardFilter withStatus(ScrumTaskStatus? nextStatus) {
    return copyWith(status: nextStatus, clearStatus: nextStatus == null);
  }

  ScrumBoardFilter togglePriority(ScrumTaskPriority priority) {
    final nextPriorities = Set<ScrumTaskPriority>.of(priorities);
    if (!nextPriorities.add(priority)) nextPriorities.remove(priority);
    return copyWith(priorities: nextPriorities);
  }

  ScrumBoardFilter withoutPriority(ScrumTaskPriority priority) {
    if (!priorities.contains(priority)) return this;
    final nextPriorities = Set<ScrumTaskPriority>.of(priorities)
      ..remove(priority);
    return copyWith(priorities: nextPriorities);
  }

  ScrumBoardFilter toggleAssignee(String assignee) {
    final normalizedAssignee = assignee.trim();
    if (normalizedAssignee.isEmpty) return this;

    final nextAssignees = Set<String>.of(assignees);
    if (!nextAssignees.add(normalizedAssignee)) {
      nextAssignees.remove(normalizedAssignee);
    }
    return copyWith(assignees: nextAssignees);
  }

  ScrumBoardFilter withoutAssignee(String assignee) {
    final normalizedAssignee = assignee.trim();
    if (!assignees.contains(normalizedAssignee)) return this;
    final nextAssignees = Set<String>.of(assignees)..remove(normalizedAssignee);
    return copyWith(assignees: nextAssignees);
  }

  ScrumBoardFilter clearQuery() {
    return copyWith(query: '');
  }

  ScrumBoardFilter clearSort() {
    return copyWith(sort: ScrumTaskSort.laneOrder);
  }

  ScrumBoardFilter clearTaskFacets() {
    return ScrumBoardFilter(status: status, sort: sort);
  }

  ScrumBoardFilter clearAll() {
    return const ScrumBoardFilter();
  }

  bool hasSameCriteria(ScrumBoardFilter other) {
    return _normalize(query) == _normalize(other.query) &&
        status == other.status &&
        sort == other.sort &&
        _sameSet(priorities, other.priorities) &&
        _sameSet(assignees, other.assignees);
  }

  bool matches(ScrumTask task, {bool includeStatus = true}) {
    if (includeStatus && status != null && task.status != status) return false;
    if (hasPriorities && !priorities.contains(task.priority)) return false;
    if (hasAssignees && !assignees.contains(task.assignee.trim())) {
      return false;
    }

    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return true;

    return _normalize(task.title).contains(normalizedQuery) ||
        _normalize(task.description).contains(normalizedQuery) ||
        _normalize(task.assignee).contains(normalizedQuery) ||
        _normalize(task.label ?? '').contains(normalizedQuery);
  }
}

String _normalize(String value) => value.trim().toLowerCase();

bool _sameSet<T>(Set<T> first, Set<T> second) {
  if (first.length != second.length) return false;
  for (final item in first) {
    if (!second.contains(item)) return false;
  }
  return true;
}
