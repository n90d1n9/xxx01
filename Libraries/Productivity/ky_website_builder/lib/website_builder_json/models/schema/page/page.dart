import '../layout/section.dart';
import 'page_styles.dart';
import 'page_metadata.dart';

/// Individual page in the website
class Page {
  final String id;
  final String name;
  final String path; // URL path
  final PageMetadata? metadata;
  final List<Section> sections;
  final PageStyles? styles;
  final Map<String, dynamic>? data; // Page-specific data

  Page({
    required this.id,
    required this.name,
    required this.path,
    this.metadata,
    required this.sections,
    this.styles,
    this.data,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      metadata:
          json['metadata'] != null
              ? PageMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
              : null,
      sections:
          (json['sections'] as List)
              .map((s) => Section.fromJson(s as Map<String, dynamic>))
              .toList(),
      styles:
          json['styles'] != null
              ? PageStyles.fromJson(json['styles'] as Map<String, dynamic>)
              : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    if (metadata != null) 'metadata': metadata!.toJson(),
    'sections': sections.map((s) => s.toJson()).toList(),
    if (styles != null) 'styles': styles!.toJson(),
    if (data != null) 'data': data,
  };
}
