class AuthSecurityConfig {
  final int maxLoginAttempts;
  final Duration lockoutDuration;
  final Duration sessionTimeout;
  final int minPasswordStrength;

  const AuthSecurityConfig({
    this.maxLoginAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 30),
    this.sessionTimeout = const Duration(minutes: 30),
    this.minPasswordStrength = 3,
  });
}
