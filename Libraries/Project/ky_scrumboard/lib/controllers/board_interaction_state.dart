import 'dart:collection';

import '../models/scrum_task_status.dart';

/// Mutable presentation state for board task selection and lane collapse.
class BoardInteractionState {
  final Set<String> _selectedTaskIds = <String>{};
  final Set<ScrumTaskStatus> _collapsedStatuses = <ScrumTaskStatus>{};

  Set<String> get selectedTaskIds => UnmodifiableSetView(_selectedTaskIds);

  Set<ScrumTaskStatus> get collapsedStatuses {
    return UnmodifiableSetView(_collapsedStatuses);
  }

  int get selectedCount => _selectedTaskIds.length;

  bool get hasSelection => _selectedTaskIds.isNotEmpty;

  List<String> selectedTaskIdList() {
    return List<String>.unmodifiable(_selectedTaskIds);
  }

  void setTaskSelection(String taskId, bool selected) {
    if (selected) {
      _selectedTaskIds.add(taskId);
    } else {
      _selectedTaskIds.remove(taskId);
    }
  }

  void setTaskGroupSelection(Iterable<String> taskIds, bool selected) {
    if (selected) {
      _selectedTaskIds.addAll(taskIds);
    } else {
      _selectedTaskIds.removeAll(taskIds);
    }
  }

  void clearSelection() {
    _selectedTaskIds.clear();
  }

  void removeSelectedTask(String taskId) {
    _selectedTaskIds.remove(taskId);
  }

  void removeSelectedTasks(Iterable<String> taskIds) {
    _selectedTaskIds.removeAll(taskIds);
  }

  void pruneSelection(bool Function(String taskId) shouldKeep) {
    _selectedTaskIds.removeWhere((taskId) => !shouldKeep(taskId));
  }

  void setColumnCollapsed(ScrumTaskStatus status, bool collapsed) {
    if (collapsed) {
      _collapsedStatuses.add(status);
    } else {
      _collapsedStatuses.remove(status);
    }
  }

  void setVisibleColumnsCollapsed(
    Iterable<ScrumTaskStatus> statuses,
    bool collapsed,
  ) {
    if (collapsed) {
      _collapsedStatuses.addAll(statuses);
    } else {
      _collapsedStatuses.removeAll(statuses);
    }
  }

  void retainCollapsedStatusesWhere(
    bool Function(ScrumTaskStatus status) shouldKeep,
  ) {
    _collapsedStatuses.removeWhere((status) => !shouldKeep(status));
  }
}
