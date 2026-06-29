import 'downward_apivolume_file.dart';

class DownwardAPIVolumeSource {
  final List<DownwardAPIVolumeFile>? items;
  final int? defaultMode;
  DownwardAPIVolumeSource({this.items, this.defaultMode});
  factory DownwardAPIVolumeSource.fromJson(Map<String, dynamic> json) {
    return DownwardAPIVolumeSource(
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map((e) => DownwardAPIVolumeFile.fromJson(e))
                  .toList()
              : null,
      defaultMode: json['defaultMode'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (defaultMode != null) 'defaultMode': defaultMode,
    };
  }
}
