class PdfDownloadProgress {
  final String bookId;
  final double progress;
  final bool isDownloading;
  final bool isCompleted;
  final String? localPath;
  final int receivedBytes;
  final int totalBytes;

  PdfDownloadProgress({
    required this.bookId,
    this.progress = 0.0,
    this.isDownloading = false,
    this.isCompleted = false,
    this.localPath,
    this.receivedBytes = 0,
    this.totalBytes = 0,
  });

  PdfDownloadProgress copyWith({
    String? bookId,
    double? progress,
    bool? isDownloading,
    bool? isCompleted,
    String? localPath,
    int? receivedBytes,
    int? totalBytes,
  }) {
    return PdfDownloadProgress(
      bookId: bookId ?? this.bookId,
      progress: progress ?? this.progress,
      isDownloading: isDownloading ?? this.isDownloading,
      isCompleted: isCompleted ?? this.isCompleted,
      localPath: localPath ?? this.localPath,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}
