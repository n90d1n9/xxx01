class DailyStats {
  final DateTime date;
  final int totalEvents;
  final int completedEvents;
  final double hoursScheduled;

  DailyStats({
    required this.date,
    required this.totalEvents,
    required this.completedEvents,
    required this.hoursScheduled,
  });
}
