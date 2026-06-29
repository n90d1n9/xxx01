class RouterRoute {
  final String id;
  final String label;
  final String? condition; // CEL expression
  final int weight; // For weighted routing
  final int priority; // For priority routing
  final Map<String, dynamic> metadata;

  RouterRoute({
    required this.id,
    required this.label,
    this.condition,
    this.weight = 1,
    this.priority = 0,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'condition': condition,
    'weight': weight,
    'priority': priority,
    'metadata': metadata,
  };

  factory RouterRoute.fromJson(Map<String, dynamic> json) => RouterRoute(
    id: json['id'],
    label: json['label'],
    condition: json['condition'],
    weight: json['weight'] ?? 1,
    priority: json['priority'] ?? 0,
    metadata: json['metadata'] ?? {},
  );
}
