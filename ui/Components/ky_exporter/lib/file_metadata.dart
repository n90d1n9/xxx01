class FileMetadata {
  final String id;
  final String fileName;
  final String mimeType;
  final int size;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String hash;

  FileMetadata({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.hash,
  });
}
