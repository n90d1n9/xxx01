class CachedResponse<T> {
  final T data;
  final bool isFromCache;
  final bool isStale;
  final DateTime? cachedAt;
  final String? etag;
  final String? lastModified;

  const CachedResponse({
    required this.data,
    this.isFromCache = false,
    this.isStale = false,
    this.cachedAt,
    this.etag,
    this.lastModified,
  });
}
