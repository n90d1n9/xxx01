import 'dart:ui';

class BuilderComponentKind {
  final String key;
  final String label;
  final String category;
  final Size defaultSize;
  final String description;
  final List<String> tags;

  const BuilderComponentKind({
    required this.key,
    required this.label,
    required this.category,
    required this.defaultSize,
    this.description = '',
    this.tags = const [],
  });

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return label.toLowerCase().contains(normalized) ||
        key.toLowerCase().contains(normalized) ||
        category.toLowerCase().contains(normalized) ||
        description.toLowerCase().contains(normalized) ||
        tags.any((tag) => tag.toLowerCase().contains(normalized));
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'category': category,
      'defaultWidth': defaultSize.width,
      'defaultHeight': defaultSize.height,
      'description': description,
      'tags': tags,
    };
  }

  factory BuilderComponentKind.fromJson(Map<String, dynamic> json) {
    return BuilderComponentKind(
      key: json['key'] as String,
      label: json['label'] as String,
      category: json['category'] as String? ?? 'General',
      defaultSize: Size(
        (json['defaultWidth'] as num?)?.toDouble() ?? 160,
        (json['defaultHeight'] as num?)?.toDouble() ?? 120,
      ),
      description: json['description'] as String? ?? '',
      tags: [for (final tag in json['tags'] as List? ?? const []) '$tag'],
    );
  }
}
