import 'field_config.dart';

class FormVersion {
  final String id;
  final int versionNumber;
  final String title;
  final List<FieldConfig> fields;
  final DateTime createdAt;
  final String createdBy;
  final String? changeLog;
  final Map<String, dynamic>? diff;
  final bool isPublished;
  final String? publishedAt;

  const FormVersion({
    required this.id,
    required this.versionNumber,
    required this.title,
    required this.fields,
    required this.createdAt,
    required this.createdBy,
    this.changeLog,
    this.diff,
    this.isPublished = false,
    this.publishedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': versionNumber,
      'title': title,
      'fields': fields.map((f) => f.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'changeLog': changeLog,
      'diff': diff,
      'isPublished': isPublished,
      'publishedAt': publishedAt,
    };
  }
}
