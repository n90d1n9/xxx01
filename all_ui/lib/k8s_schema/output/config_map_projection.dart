import 'key_to_path.dart';

class ConfigMapProjection {
  final String name;
  final List<KeyToPath>? items;
  final bool? optional;
  ConfigMapProjection({required this.name, this.items, this.optional});
  factory ConfigMapProjection.fromJson(Map<String, dynamic> json) {
    return ConfigMapProjection(
      name: json['name'],
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map((e) => KeyToPath.fromJson(e))
                  .toList()
              : null,
      optional: json['optional'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (optional != null) 'optional': optional,
    };
  }
}
