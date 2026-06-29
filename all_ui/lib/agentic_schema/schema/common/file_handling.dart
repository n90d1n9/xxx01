class FileHandling {
  final bool? upload;
  final List<String>? supportedTypes;
  final int? maxSize;

  FileHandling({
    this.upload = false,
    this.supportedTypes,
    this.maxSize = 10485760, // 10MB
  });

  factory FileHandling.fromJson(Map<String, dynamic> json) {
    return FileHandling(
      upload: json['upload'] as bool?,
      supportedTypes: json['supportedTypes'] != null
          ? List<String>.from(json['supportedTypes'] as List)
          : null,
      maxSize: json['maxSize'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (upload != null) 'upload': upload,
      if (supportedTypes != null) 'supportedTypes': supportedTypes,
      if (maxSize != null) 'maxSize': maxSize,
    };
  }
}
