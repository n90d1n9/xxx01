import 'pwa_icon.dart';

class PWAConfig {
  final bool enabled;
  final String name;
  final String shortName;
  final String? description;
  final String themeColor;
  final String backgroundColor;
  final String display; // fullscreen, standalone, minimal-ui, browser
  final String? startUrl;
  final List<PWAIcon>? icons;
  final Map<String, dynamic>? manifest;

  PWAConfig({
    required this.enabled,
    required this.name,
    required this.shortName,
    this.description,
    required this.themeColor,
    required this.backgroundColor,
    required this.display,
    this.startUrl,
    this.icons,
    this.manifest,
  });

  factory PWAConfig.fromJson(Map<String, dynamic> json) {
    return PWAConfig(
      enabled: json['enabled'] as bool,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      description: json['description'] as String?,
      themeColor: json['themeColor'] as String,
      backgroundColor: json['backgroundColor'] as String,
      display: json['display'] as String,
      startUrl: json['startUrl'] as String?,
      icons:
          json['icons'] != null
              ? (json['icons'] as List)
                  .map((i) => PWAIcon.fromJson(i as Map<String, dynamic>))
                  .toList()
              : null,
      manifest: json['manifest'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'name': name,
    'shortName': shortName,
    if (description != null) 'description': description,
    'themeColor': themeColor,
    'backgroundColor': backgroundColor,
    'display': display,
    if (startUrl != null) 'startUrl': startUrl,
    if (icons != null) 'icons': icons!.map((i) => i.toJson()).toList(),
    if (manifest != null) 'manifest': manifest,
  };
}
