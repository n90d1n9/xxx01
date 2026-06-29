import 'object_field_selector.dart';
import 'resource_field_selector.dart';

class DownwardAPIVolumeFile {
  final String path;
  final ObjectFieldSelector? fieldRef;
  final ResourceFieldSelector? resourceFieldRef;
  final int? mode;
  DownwardAPIVolumeFile({
    required this.path,
    this.fieldRef,
    this.resourceFieldRef,
    this.mode,
  });
  factory DownwardAPIVolumeFile.fromJson(Map<String, dynamic> json) {
    return DownwardAPIVolumeFile(
      path: json['path'],
      fieldRef:
          json['fieldRef'] != null
              ? ObjectFieldSelector.fromJson(json['fieldRef'])
              : null,
      resourceFieldRef:
          json['resourceFieldRef'] != null
              ? ResourceFieldSelector.fromJson(json['resourceFieldRef'])
              : null,
      mode: json['mode'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      if (fieldRef != null) 'fieldRef': fieldRef!.toJson(),
      if (resourceFieldRef != null)
        'resourceFieldRef': resourceFieldRef!.toJson(),
      if (mode != null) 'mode': mode,
    };
  }
}
