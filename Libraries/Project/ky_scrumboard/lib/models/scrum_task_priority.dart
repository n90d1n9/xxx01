enum ScrumTaskPriority { low, medium, high, critical }

extension ScrumTaskPriorityLabel on ScrumTaskPriority {
  String get label {
    switch (this) {
      case ScrumTaskPriority.low:
        return 'Low';
      case ScrumTaskPriority.medium:
        return 'Medium';
      case ScrumTaskPriority.high:
        return 'High';
      case ScrumTaskPriority.critical:
        return 'Critical';
    }
  }
}
