class TimelineCollection {
  final String id;
  final String name;
  final String description;
  final List<String> eventIds;
  final DateTime createdAt;
  final String? color;
  final String? icon;

  TimelineCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.eventIds,
    required this.createdAt,
    this.color,
    this.icon,
  });
}
