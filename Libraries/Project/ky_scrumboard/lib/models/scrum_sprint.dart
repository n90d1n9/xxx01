class ScrumSprint {
  const ScrumSprint({
    required this.id,
    required this.name,
    required this.goal,
    required this.startAt,
    required this.endAt,
    this.capacityStoryPoints,
    this.velocityTargetStoryPoints,
  });

  final String id;
  final String name;
  final String goal;
  final DateTime startAt;
  final DateTime endAt;
  final int? capacityStoryPoints;
  final int? velocityTargetStoryPoints;

  int get durationDays {
    final days = endAt.difference(startAt).inDays + 1;
    return days < 1 ? 1 : days;
  }

  bool isActiveAt(DateTime now) {
    return !_dateOnly(now).isBefore(_dateOnly(startAt)) &&
        !_dateOnly(now).isAfter(_dateOnly(endAt));
  }

  bool isPastAt(DateTime now) {
    return _dateOnly(now).isAfter(_dateOnly(endAt));
  }

  int daysElapsedAt(DateTime now) {
    if (_dateOnly(now).isBefore(_dateOnly(startAt))) return 0;
    if (_dateOnly(now).isAfter(_dateOnly(endAt))) return durationDays;
    return _dateOnly(now).difference(_dateOnly(startAt)).inDays + 1;
  }

  int daysRemainingAt(DateTime now) {
    if (_dateOnly(now).isAfter(_dateOnly(endAt))) return 0;
    if (_dateOnly(now).isBefore(_dateOnly(startAt))) return durationDays;
    return _dateOnly(endAt).difference(_dateOnly(now)).inDays + 1;
  }

  double timeProgressAt(DateTime now) {
    return (daysElapsedAt(now) / durationDays).clamp(0, 1);
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
