class WhileLoopNodeDefinition {
  final String id;
  final String name;
  final String description;
  final String condition;
  final int maxIterations;
  final Duration? timeout;
  final bool breakOnError;
  final Map<String, dynamic> metadata;

  WhileLoopNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    this.maxIterations = 100,
    this.timeout,
    this.breakOnError = true,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'condition': condition,
    'maxIterations': maxIterations,
    'timeout': timeout?.inMilliseconds,
    'breakOnError': breakOnError,
    'metadata': metadata,
  };

  factory WhileLoopNodeDefinition.fromJson(Map<String, dynamic> json) =>
      WhileLoopNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        condition: json['condition'],
        maxIterations: json['maxIterations'] ?? 100,
        timeout: json['timeout'] != null
            ? Duration(milliseconds: json['timeout'])
            : null,
        breakOnError: json['breakOnError'] ?? true,
        metadata: json['metadata'] ?? {},
      );
}
