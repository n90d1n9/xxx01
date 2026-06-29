/// Website metadata
class WebsiteMetadata {
  final String name;
  final String? description;
  final String? author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? seo; // SEO settings
  final Map<String, dynamic>? analytics; // Analytics configs

  WebsiteMetadata({
    required this.name,
    this.description,
    this.author,
    required this.createdAt,
    required this.updatedAt,
    this.seo,
    this.analytics,
  });

  factory WebsiteMetadata.fromJson(Map<String, dynamic> json) {
    return WebsiteMetadata(
      name: json['name'] as String,
      description: json['description'] as String?,
      author: json['author'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      seo: json['seo'] as Map<String, dynamic>?,
      analytics: json['analytics'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (author != null) 'author': author,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (seo != null) 'seo': seo,
    if (analytics != null) 'analytics': analytics,
  };
}
