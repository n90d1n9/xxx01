class SecurityConstants {
  static const int maxConcurrentSessions = 3;
  static const Duration passwordExpiryDuration = Duration(days: 90);
  static const int passwordHistoryLimit = 5;
  static const Duration suspiciousActivityLockDuration = Duration(hours: 24);
  static const int maxDevicesPerUser = 5;
}
