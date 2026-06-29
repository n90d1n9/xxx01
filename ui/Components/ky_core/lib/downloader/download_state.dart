class DownloadState {
  final bool isDownloading;
  final double progress;
  final bool isCompleted;
  final String? localPath;
  final String? error;
  final int receivedBytes;
  final int totalBytes;

  const DownloadState({
    this.isDownloading = false,
    this.progress = 0,
    this.isCompleted = false,
    this.localPath,
    this.error,
    this.receivedBytes = 0,
    this.totalBytes = 0,
  });

  DownloadState copyWith({
    bool? isDownloading,
    double? progress,
    bool? isCompleted,
    String? localPath,
    String? error,
    int? receivedBytes,
    int? totalBytes,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      localPath: localPath ?? this.localPath,
      error: error ?? this.error,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}
