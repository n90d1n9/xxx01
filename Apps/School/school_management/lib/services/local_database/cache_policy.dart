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
