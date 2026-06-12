class TimelineEvent {
  final String period;
  final String title;
  final List<String> events;

  TimelineEvent({
    required this.period,
    required this.title,
    required this.events,
  });

  TimelineEvent copyWith({
    String? period,
    String? title,
    List<String>? events,
  }) {
    return TimelineEvent(
      period: period ?? this.period,
      title: title ?? this.title,
      events: events ?? this.events,
    );
  }

  @override
  String toString() {
    return 'TimelineEvent(period: $period, title: $title, events: $events)';
  }
}
