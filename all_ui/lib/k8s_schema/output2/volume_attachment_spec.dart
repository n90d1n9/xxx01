import 'volume_attachment_source.dart';

class VolumeAttachmentSpec {
  final String attacher;
  final VolumeAttachmentSource source;
  final String nodeName;
  VolumeAttachmentSpec({
    required this.attacher,
    required this.source,
    required this.nodeName,
  });
  factory VolumeAttachmentSpec.fromJson(Map<String, dynamic> json) {
    return VolumeAttachmentSpec(
      attacher: json['attacher'],
      source: VolumeAttachmentSource.fromJson(json['source']),
      nodeName: json['nodeName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'attacher': attacher,
      'source': source.toJson(),
      'nodeName': nodeName,
    };
  }
}
