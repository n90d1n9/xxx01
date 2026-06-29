import 'downward_apivolume_file.dart';

class DownwardAPIProjection {
  final List<DownwardAPIVolumeFile>? items;
  DownwardAPIProjection({this.items});
  factory DownwardAPIProjection.fromJson(Map<String, dynamic> json) {
    return DownwardAPIProjection(
      items:
          json['items'] != null
              ? (json['items'] as List)
                  .map((e) => DownwardAPIVolumeFile.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {if (items != null) 'items': items!.map((e) => e.toJson()).toList()};
  }
}
