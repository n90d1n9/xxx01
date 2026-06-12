class CachePolicy {
  /// Default cache duration
  static const Duration defaultExpiration = Duration(hours: 1);

  /// Determines if cached data is still valid
  static bool isValid(DateTime timestamp, Duration expiration) {
    return DateTime.now().difference(timestamp) <= expiration;
  }

  /// Calculate time remaining for cached data
  static Duration timeRemaining(DateTime timestamp, Duration expiration) {
    final expirationTime = timestamp.add(expiration);
    return expirationTime.difference(DateTime.now());
  }
}

class CacheOptions {
  final Duration expiration;
  final bool encrypted;
  final String? encryptionKey;
  final int? schemaVersion;
  final String? namespace;
  final int? maxValueBytes;
  final int? maxNamespaceBytes;
  final int? maxTotalBytes;
  final bool pinned;
  final int priority;
  final bool decryptIfNeeded;
  final bool cleanupExpired;

  const CacheOptions({
    this.expiration = CachePolicy.defaultExpiration,
    this.encrypted = false,
    this.encryptionKey,
    this.schemaVersion,
    this.namespace,
    this.maxValueBytes,
    this.maxNamespaceBytes,
    this.maxTotalBytes,
    this.pinned = false,
    this.priority = 1,
    this.decryptIfNeeded = true,
    this.cleanupExpired = true,
  });
}
