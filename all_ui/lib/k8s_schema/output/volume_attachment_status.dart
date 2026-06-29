import 'volume_error.dart';

class VolumeAttachmentStatus {
  final bool attached;
  final Map<String, String>? attachmentMetadata;
  final VolumeError? attachError;
  final VolumeError? detachError;
  VolumeAttachmentStatus({
    required this.attached,
    this.attachmentMetadata,
    this.attachError,
    this.detachError,
  });
  factory VolumeAttachmentStatus.fromJson(Map<String, dynamic> json) {
    return VolumeAttachmentStatus(
      attached: json['attached'],
      attachmentMetadata:
          json['attachmentMetadata'] != null
              ? Map<String, String>.from(json['attachmentMetadata'])
              : null,
      attachError:
          json['attachError'] != null
              ? VolumeError.fromJson(json['attachError'])
              : null,
      detachError:
          json['detachError'] != null
              ? VolumeError.fromJson(json['detachError'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'attached': attached,
      if (attachmentMetadata != null) 'attachmentMetadata': attachmentMetadata,
      if (attachError != null) 'attachError': attachError!.toJson(),
      if (detachError != null) 'detachError': detachError!.toJson(),
    };
  }
}
