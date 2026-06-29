class AuthSecurityState {
  final int loginAttempts;
  final DateTime? lockoutUntil;
  final List<String> registeredDevices;
  final List<String> backupCodes;
  final Map<String, dynamic> auditLogs;
  final List<String> passwordHistory;
  final DateTime? passwordLastChanged;
  final Map<String, DateTime> activeSessions;
  final List<Map<String, dynamic>> securityEvents;
  final Map<String, dynamic> locationHistory;
  final bool biometricEnabled;

  AuthSecurityState({
    this.loginAttempts = 0,
    this.lockoutUntil,
    this.registeredDevices = const [],
    this.backupCodes = const [],
    this.auditLogs = const {},
    this.passwordHistory = const [],
    this.passwordLastChanged,
    this.activeSessions = const {},
    this.securityEvents = const [],
    this.locationHistory = const {},
    this.biometricEnabled = false,
  });
}
