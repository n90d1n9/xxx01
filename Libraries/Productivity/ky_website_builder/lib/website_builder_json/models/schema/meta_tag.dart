class MetaTag {
  final String name;
  final String content;
  final String? property;

  MetaTag({required this.name, required this.content, this.property});

  factory MetaTag.fromJson(Map<String, dynamic> json) {
    return MetaTag(
      name: json['name'] as String,
      content: json['content'] as String,
      property: json['property'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'content': content,
    if (property != null) 'property': property,
  };
}
