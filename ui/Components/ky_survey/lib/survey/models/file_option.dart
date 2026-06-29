
class FileOptions {
  final int maxFileSize;
  final List<String> allowedFileTypes;
  final int maxFiles;
  final int minFiles;
  final bool requireDescription;
  final String? storageLocation;
  final String? namingConvention;

  FileOptions({
    required this.maxFileSize,
    required this.allowedFileTypes,
    required this.maxFiles,
    required this.minFiles,
    required this.requireDescription,
    this.storageLocation,
    this.namingConvention,
  });

  Map<String, dynamic> toJson() => {
        'maxFileSize': maxFileSize,
        'allowedFileTypes': allowedFileTypes,
        'maxFiles': maxFiles,
        'minFiles': minFiles,
        'requireDescription': requireDescription,
        'storageLocation': storageLocation,
        'namingConvention': namingConvention,
      };

  factory FileOptions.fromJson(Map<String, dynamic> json) => FileOptions(
        maxFileSize: json['maxFileSize'],
        allowedFileTypes: List<String>.from(json['allowedFileTypes']),
        maxFiles: json['maxFiles'],
        minFiles: json['minFiles'],
        requireDescription: json['requireDescription'],
        storageLocation: json['storageLocation'],
        namingConvention: json['namingConvention'],
      );
}
