enum ScrumTaskStatus { backlog, todo, inProgress, review, done }

extension ScrumTaskStatusLabel on ScrumTaskStatus {
  String get label {
    switch (this) {
      case ScrumTaskStatus.backlog:
        return 'Backlog';
      case ScrumTaskStatus.todo:
        return 'To Do';
      case ScrumTaskStatus.inProgress:
        return 'In Progress';
      case ScrumTaskStatus.review:
        return 'Review';
      case ScrumTaskStatus.done:
        return 'Done';
    }
  }
}
