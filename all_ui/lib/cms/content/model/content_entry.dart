/// Content Entry with full metadata
class ContentEntry {
  final String id;
  final String contentTypeId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final bool published;
  final DateTime? publishedAt;
  final int version;
  final Map<String, dynamic>? metadata;

  const ContentEntry({
    required this.id,
    required this.contentTypeId,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.published = false,
    this.publishedAt,
    this.version = 1,
    this.metadata,
  });

  ContentEntry copyWith({
    String? id,
    String? contentTypeId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? published,
    DateTime? publishedAt,
    int? version,
    Map<String, dynamic>? metadata,
  }) {
    return ContentEntry(
      id: id ?? this.id,
      contentTypeId: contentTypeId ?? this.contentTypeId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      published: published ?? this.published,
      publishedAt: publishedAt ?? this.publishedAt,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'contentTypeId': contentTypeId,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'updatedBy': updatedBy,
    'published': published,
    'publishedAt': publishedAt?.toIso8601String(),
    'version': version,
    'metadata': metadata,
  };
}
