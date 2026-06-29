import 'volume_attachment_spec.dart';
import 'volume_attachment_status.dart';
import 'object_meta.dart';

class VolumeAttachment {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final VolumeAttachmentSpec spec;
  final VolumeAttachmentStatus? status;
  VolumeAttachment({
    this.apiVersion = 'storage.k8s.io/v1',
    this.kind = 'VolumeAttachment',
    required this.metadata,
    required this.spec,
    this.status,
  });
  factory VolumeAttachment.fromJson(Map<String, dynamic> json) {
    return VolumeAttachment(
      apiVersion: json['apiVersion'] ?? 'storage.k8s.io/v1',
      kind: json['kind'] ?? 'VolumeAttachment',
      metadata: ObjectMeta.fromJson(json['metadata']),
      spec: VolumeAttachmentSpec.fromJson(json['spec']),
      status:
          json['status'] != null
              ? VolumeAttachmentStatus.fromJson(json['status'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'spec': spec.toJson(),
      if (status != null) 'status': status!.toJson(),
    };
  }
}
