class CacheEntry {
  final dynamic value;
  final DateTime createdAt;
  DateTime lastAccessedAt;
  int accessCount;

  CacheEntry(this.value)
    : createdAt = DateTime.now(),
      lastAccessedAt = DateTime.now(),
      accessCount = 1;

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(createdAt) > ttl;
  }
}
