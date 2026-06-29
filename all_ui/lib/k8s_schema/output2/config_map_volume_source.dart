import 'key_to_path.dart';

class ConfigMapVolumeSource {
  final String name;
  final List<KeyToPath>? items;
  final int? defaultMode;
  final bool? optional;
  ConfigMapVolumeSource({
    required this.name,
    this.items,
    this.defaultMode,
    this.optional,
  });
  factory ConfigMapVolumeSource.fromJson(Map<String, dynamic> json) {
    return ConfigMapVolumeSource(
      name: json['name'],
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map((e) => KeyToPath.fromJson(e))
                  .toList()
              : null,
      defaultMode: json['defaultMode'],
      optional: json['optional'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (defaultMode != null) 'defaultMode': defaultMode,
      if (optional != null) 'optional': optional,
    };
  }
}
