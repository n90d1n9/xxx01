class FaceTemplate {
  final String id;
  final List<double> features;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int usageCount;
  final String deviceId;
  final Map<String, dynamic> metadata;

  FaceTemplate({
    required this.id,
    required this.features,
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
    required this.deviceId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'features': features,
    'createdAt': createdAt.toIso8601String(),
    'lastUsed': lastUsed.toIso8601String(),
    'usageCount': usageCount,
    'deviceId': deviceId,
    'metadata': metadata,
  };

  factory FaceTemplate.fromJson(Map<String, dynamic> json) => FaceTemplate(
    id: json['id'],
    features: List<double>.from(json['features']),
    createdAt: DateTime.parse(json['createdAt']),
    lastUsed: DateTime.parse(json['lastUsed']),
    usageCount: json['usageCount'] ?? 0,
    deviceId: json['deviceId'],
    metadata: json['metadata'] ?? {},
  );

  FaceTemplate copyWith({
    String? id,
    List<double>? features,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) => FaceTemplate(
    id: id ?? this.id,
    features: features ?? this.features,
    createdAt: createdAt ?? this.createdAt,
    lastUsed: lastUsed ?? this.lastUsed,
    usageCount: usageCount ?? this.usageCount,
    deviceId: deviceId ?? this.deviceId,
    metadata: metadata ?? this.metadata,
  );
}
