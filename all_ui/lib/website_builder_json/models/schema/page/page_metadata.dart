/// Page-specific metadata
class PageMetadata {
  final String? title;
  final String? description;
  final List<String>? keywords;
  final String? ogImage;
  final Map<String, dynamic>? customMeta;

  PageMetadata({
    this.title,
    this.description,
    this.keywords,
    this.ogImage,
    this.customMeta,
  });

  factory PageMetadata.fromJson(Map<String, dynamic> json) {
    return PageMetadata(
      title: json['title'] as String?,
      description: json['description'] as String?,
      keywords:
          json['keywords'] != null
              ? List<String>.from(json['keywords'] as List)
              : null,
      ogImage: json['ogImage'] as String?,
      customMeta: json['customMeta'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (keywords != null) 'keywords': keywords,
    if (ogImage != null) 'ogImage': ogImage,
    if (customMeta != null) 'customMeta': customMeta,
  };
}
