import 'package:queue_ui/website_builder_json/models/schema/meta_tag.dart'
    show MetaTag;

import 'structured_data.dart';

class SEOConfig {
  final String? title;
  final String? description;
  final List<String>? keywords;
  final String? ogTitle;
  final String? ogDescription;
  final String? ogImage;
  final String? ogType;
  final String? twitterCard;
  final String? twitterTitle;
  final String? twitterDescription;
  final String? twitterImage;
  final String? canonicalUrl;
  final List<MetaTag>? customMeta;
  final StructuredData? structuredData;

  SEOConfig({
    this.title,
    this.description,
    this.keywords,
    this.ogTitle,
    this.ogDescription,
    this.ogImage,
    this.ogType,
    this.twitterCard,
    this.twitterTitle,
    this.twitterDescription,
    this.twitterImage,
    this.canonicalUrl,
    this.customMeta,
    this.structuredData,
  });

  factory SEOConfig.fromJson(Map<String, dynamic> json) {
    return SEOConfig(
      title: json['title'] as String?,
      description: json['description'] as String?,
      keywords:
          json['keywords'] != null
              ? List<String>.from(json['keywords'] as List)
              : null,
      ogTitle: json['ogTitle'] as String?,
      ogDescription: json['ogDescription'] as String?,
      ogImage: json['ogImage'] as String?,
      ogType: json['ogType'] as String?,
      twitterCard: json['twitterCard'] as String?,
      twitterTitle: json['twitterTitle'] as String?,
      twitterDescription: json['twitterDescription'] as String?,
      twitterImage: json['twitterImage'] as String?,
      canonicalUrl: json['canonicalUrl'] as String?,
      customMeta:
          json['customMeta'] != null
              ? (json['customMeta'] as List)
                  .map((m) => MetaTag.fromJson(m as Map<String, dynamic>))
                  .toList()
              : null,
      structuredData:
          json['structuredData'] != null
              ? StructuredData.fromJson(
                json['structuredData'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (keywords != null) 'keywords': keywords,
    if (ogTitle != null) 'ogTitle': ogTitle,
    if (ogDescription != null) 'ogDescription': ogDescription,
    if (ogImage != null) 'ogImage': ogImage,
    if (ogType != null) 'ogType': ogType,
    if (twitterCard != null) 'twitterCard': twitterCard,
    if (twitterTitle != null) 'twitterTitle': twitterTitle,
    if (twitterDescription != null) 'twitterDescription': twitterDescription,
    if (twitterImage != null) 'twitterImage': twitterImage,
    if (canonicalUrl != null) 'canonicalUrl': canonicalUrl,
    if (customMeta != null)
      'customMeta': customMeta!.map((m) => m.toJson()).toList(),
    if (structuredData != null) 'structuredData': structuredData!.toJson(),
  };
}
