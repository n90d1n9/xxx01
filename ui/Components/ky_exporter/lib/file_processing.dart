enum CompressionLevel {
  none,
  fast,
  normal,
  best,
}

class FileProcessingOptions {
  final CompressionLevel compressionLevel;
  final bool validateIntegrity;
  final int chunkSize;
  final bool encryptInTransit;
  final Map<String, String> metadata;

  FileProcessingOptions({
    this.compressionLevel = CompressionLevel.normal,
    this.validateIntegrity = true,
    this.chunkSize = 1024 * 1024,
    this.encryptInTransit = true,
    this.metadata = const {},
  });
}

class FileProcessingProgress {
  final double progress;
  final String stage;
  final int bytesProcessed;
  final int totalBytes;

  FileProcessingProgress({
    required this.progress,
    required this.stage,
    required this.bytesProcessed,
    required this.totalBytes,
  });
}
