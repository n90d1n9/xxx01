enum ScrumTaskSort { laneOrder, priority, dueDate, newest, storyPoints }

extension ScrumTaskSortLabel on ScrumTaskSort {
  String get label {
    switch (this) {
      case ScrumTaskSort.laneOrder:
        return 'Lane order';
      case ScrumTaskSort.priority:
        return 'Priority';
      case ScrumTaskSort.dueDate:
        return 'Due date';
      case ScrumTaskSort.newest:
        return 'Newest';
      case ScrumTaskSort.storyPoints:
        return 'Story points';
    }
  }
}
