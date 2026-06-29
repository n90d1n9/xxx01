
class SurveyMetadata {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String lastModifiedBy;
  final int version;
  final String language;
  final List<String> tags;
  final String? category;
  final int? estimatedDuration;

  SurveyMetadata({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.lastModifiedBy,
    required this.version,
    required this.language,
    required this.tags,
    this.category,
    this.estimatedDuration,
  });

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'createdBy': createdBy,
        'lastModifiedBy': lastModifiedBy,
        'version': version,
        'language': language,
        'tags': tags,
        'category': category,
        'estimatedDuration': estimatedDuration,
      };

  factory SurveyMetadata.fromJson(Map<String, dynamic> json) => SurveyMetadata(
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        createdBy: json['createdBy'],
        lastModifiedBy: json['lastModifiedBy'],
        version: json['version'],
        language: json['language'],
        tags: List<String>.from(json['tags']),
        category: json['category'],
        estimatedDuration: json['estimatedDuration'],
      );
}
