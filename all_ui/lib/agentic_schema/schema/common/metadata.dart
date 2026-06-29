class Metadata {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? version;
  final List<String>? tags;
  final String? description;
  final String? notes;
  final String? color;
  final String? icon;

  Metadata({
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.version,
    this.tags,
    this.description,
    this.notes,
    this.color,
    this.icon,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      version: json['version'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (version != null) 'version': version,
      if (tags != null) 'tags': tags,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
    };
  }

  Metadata copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? version,
    List<String>? tags,
    String? description,
    String? notes,
    String? color,
    String? icon,
  }) {
    return Metadata(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      version: version ?? this.version,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
