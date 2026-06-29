import 'field_config.dart';

class FormTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final String thumbnail;
  final List<FieldConfig> fields;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final int usageCount;
  final double rating;

  const FormTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.thumbnail,
    required this.fields,
    required this.metadata,
    required this.createdAt,
    this.usageCount = 0,
    this.rating = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'tags': tags,
      'thumbnail': thumbnail,
      'fields': fields.map((f) => f.toJson()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'usageCount': usageCount,
      'rating': rating,
    };
  }
}
