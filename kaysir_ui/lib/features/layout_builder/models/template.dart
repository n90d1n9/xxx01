class Template {
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic> layout;
  final DateTime createdAt;
  final DateTime updatedAt;

  Template({
    required this.id,
    required this.name,
    this.description,
    required this.layout,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Template copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? layout,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      layout: layout ?? this.layout,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'layout': layout,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Untitled template',
      description: json['description'] as String?,
      layout: Map<String, dynamic>.from(json['layout'] as Map? ?? const {}),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

enum ResizeDirection {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  left,
  right,
  top,
  bottom,
  none,
  horizontal,
  vertical,
  diagonal,
}

extension ResizeDirectionX on ResizeDirection {
  bool get isLeft =>
      this == ResizeDirection.left ||
      this == ResizeDirection.topLeft ||
      this == ResizeDirection.bottomLeft;

  bool get isTop =>
      this == ResizeDirection.top ||
      this == ResizeDirection.topLeft ||
      this == ResizeDirection.topRight;

  bool get isBottom =>
      this == ResizeDirection.bottom ||
      this == ResizeDirection.bottomLeft ||
      this == ResizeDirection.bottomRight;

  bool get isRight =>
      this == ResizeDirection.right ||
      this == ResizeDirection.topRight ||
      this == ResizeDirection.bottomRight;
}
