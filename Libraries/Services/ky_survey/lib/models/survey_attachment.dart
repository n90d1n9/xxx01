enum SurveyAttachmentType { image, audio, file }

enum SurveyAttachmentUploadStatus { local, queued, uploading, uploaded, failed }

SurveyAttachmentType surveyAttachmentTypeFromJson(Object? value) {
  if (value is SurveyAttachmentType) {
    return value;
  }

  if (value is String) {
    for (final type in SurveyAttachmentType.values) {
      if (type.name == value) {
        return type;
      }
    }
  }

  return SurveyAttachmentType.file;
}

SurveyAttachmentUploadStatus surveyAttachmentUploadStatusFromJson(
  Object? value,
) {
  if (value is SurveyAttachmentUploadStatus) {
    return value;
  }

  if (value is String) {
    for (final status in SurveyAttachmentUploadStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
  }

  return SurveyAttachmentUploadStatus.local;
}

class SurveyAttachment {
  final String id;
  final SurveyAttachmentType type;
  final String fileName;
  final DateTime capturedAt;
  final String? localPath;
  final String? remoteUrl;
  final String? thumbnailPath;
  final String? mimeType;
  final int? sizeBytes;
  final int? durationMilliseconds;
  final SurveyAttachmentUploadStatus uploadStatus;
  final String? uploadError;
  final Map<String, dynamic> metadata;

  const SurveyAttachment({
    required this.id,
    required this.type,
    required this.fileName,
    required this.capturedAt,
    this.localPath,
    this.remoteUrl,
    this.thumbnailPath,
    this.mimeType,
    this.sizeBytes,
    this.durationMilliseconds,
    this.uploadStatus = SurveyAttachmentUploadStatus.local,
    this.uploadError,
    this.metadata = const {},
  });

  bool get hasStorageReference => _hasText(localPath) || _hasText(remoteUrl);

  bool get isUploaded => uploadStatus == SurveyAttachmentUploadStatus.uploaded;

  Duration? get duration {
    final milliseconds = durationMilliseconds;
    if (milliseconds == null) {
      return null;
    }

    return Duration(milliseconds: milliseconds);
  }

  SurveyAttachment copyWith({
    String? id,
    SurveyAttachmentType? type,
    String? fileName,
    DateTime? capturedAt,
    String? localPath,
    String? remoteUrl,
    String? thumbnailPath,
    String? mimeType,
    int? sizeBytes,
    int? durationMilliseconds,
    SurveyAttachmentUploadStatus? uploadStatus,
    String? uploadError,
    Map<String, dynamic>? metadata,
  }) {
    return SurveyAttachment(
      id: id ?? this.id,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      capturedAt: capturedAt ?? this.capturedAt,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      durationMilliseconds: durationMilliseconds ?? this.durationMilliseconds,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadError: uploadError ?? this.uploadError,
      metadata: metadata ?? this.metadata,
    );
  }

  SurveyAttachment withUploadState({
    required SurveyAttachmentUploadStatus uploadStatus,
    String? remoteUrl,
    String? uploadError,
    Map<String, dynamic> metadata = const {},
  }) {
    return SurveyAttachment(
      id: id,
      type: type,
      fileName: fileName,
      capturedAt: capturedAt,
      localPath: localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbnailPath: thumbnailPath,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      durationMilliseconds: durationMilliseconds,
      uploadStatus: uploadStatus,
      uploadError: uploadError,
      metadata: {...this.metadata, ...metadata},
    );
  }

  factory SurveyAttachment.fromJson(Map<String, dynamic> json) {
    return SurveyAttachment(
      id: json['id'] as String,
      type: surveyAttachmentTypeFromJson(json['type']),
      fileName: json['fileName'] as String? ?? 'attachment',
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      localPath: json['localPath'] as String?,
      remoteUrl: json['remoteUrl'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: json['sizeBytes'] as int?,
      durationMilliseconds: json['durationMilliseconds'] as int?,
      uploadStatus: surveyAttachmentUploadStatusFromJson(json['uploadStatus']),
      uploadError: json['uploadError'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'fileName': fileName,
      'capturedAt': capturedAt.toIso8601String(),
      'localPath': localPath,
      'remoteUrl': remoteUrl,
      'thumbnailPath': thumbnailPath,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'durationMilliseconds': durationMilliseconds,
      'uploadStatus': uploadStatus.name,
      'uploadError': uploadError,
      'metadata': metadata,
    };
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
