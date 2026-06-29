import 'metadata.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final Metadata? metadata;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.metadata,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }
}
