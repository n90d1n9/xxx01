import 'asset_metadata.dart';

class Asset {
  final String id;
  final String type; // image, video, audio, font, document
  final String name;
  final String url;
  final AssetMetadata? metadata;
  final Map<String, String>? variants; // Different sizes/formats

  Asset({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
    this.metadata,
    this.variants,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      metadata:
          json['metadata'] != null
              ? AssetMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
              : null,
      variants:
          json['variants'] != null
              ? Map<String, String>.from(json['variants'] as Map)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'url': url,
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (variants != null) 'variants': variants,
  };
}
