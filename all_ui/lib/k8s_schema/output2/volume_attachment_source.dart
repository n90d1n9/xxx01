import 'persistent_volume_spec.dart';

class VolumeAttachmentSource {
  final String? persistentVolumeName;
  final PersistentVolumeSpec? inlineVolumeSpec;
  VolumeAttachmentSource({this.persistentVolumeName, this.inlineVolumeSpec});
  factory VolumeAttachmentSource.fromJson(Map<String, dynamic> json) {
    return VolumeAttachmentSource(
      persistentVolumeName: json['persistentVolumeName'],
      inlineVolumeSpec:
          json['inlineVolumeSpec'] != null
              ? PersistentVolumeSpec.fromJson(json['inlineVolumeSpec'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (persistentVolumeName != null)
        'persistentVolumeName': persistentVolumeName,
      if (inlineVolumeSpec != null)
        'inlineVolumeSpec': inlineVolumeSpec!.toJson(),
    };
  }
}
