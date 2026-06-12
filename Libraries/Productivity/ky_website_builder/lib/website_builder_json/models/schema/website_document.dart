import 'component_definition.dart';
import 'page/page.dart';
import 'styles/global_styles.dart';
import 'website_metadata.dart';

/// Root document representing an entire website
class WebsiteDocument {
  final String id;
  final String version; // Schema version for future compatibility
  final WebsiteMetadata metadata;
  final List<Page> pages;
  final GlobalStyles? globalStyles;
  final Map<String, ComponentDefinition>? customComponents;
  final Map<String, dynamic>? assets; // Images, fonts, etc.
  final Map<String, dynamic>? variables; // Global variables/tokens

  WebsiteDocument({
    required this.id,
    required this.version,
    required this.metadata,
    required this.pages,
    this.globalStyles,
    this.customComponents,
    this.assets,
    this.variables,
  });

  factory WebsiteDocument.fromJson(Map<String, dynamic> json) {
    return WebsiteDocument(
      id: json['id'] as String,
      version: json['version'] as String,
      metadata: WebsiteMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      pages:
          (json['pages'] as List)
              .map((p) => Page.fromJson(p as Map<String, dynamic>))
              .toList(),
      globalStyles:
          json['globalStyles'] != null
              ? GlobalStyles.fromJson(
                json['globalStyles'] as Map<String, dynamic>,
              )
              : null,
      customComponents:
          json['customComponents'] != null
              ? (json['customComponents'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(
                  k,
                  ComponentDefinition.fromJson(v as Map<String, dynamic>),
                ),
              )
              : null,
      assets: json['assets'] as Map<String, dynamic>?,
      variables: json['variables'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'metadata': metadata.toJson(),
    'pages': pages.map((p) => p.toJson()).toList(),
    if (globalStyles != null) 'globalStyles': globalStyles!.toJson(),
    if (customComponents != null)
      'customComponents': customComponents!.map(
        (k, v) => MapEntry(k, v.toJson()),
      ),
    if (assets != null) 'assets': assets,
    if (variables != null) 'variables': variables,
  };
}
