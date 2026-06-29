import 'auth_attempt.dart';
import 'auth_status.dart';
import 'face_template.dart';

class FaceAuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? error;
  final FaceTemplate? activeTemplate;
  final List<AuthAttempt> recentAttempts;
  final bool biometricAvailable;
  final bool isLocked;
  final DateTime? lockUntil;
  final int failedAttempts;
  final double? lastMatchConfidence;
  final Map<String, dynamic> settings;

  const FaceAuthState({
    this.status = AuthStatus.idle,
    this.isLoading = false,
    this.error,
    this.activeTemplate,
    this.recentAttempts = const [],
    this.biometricAvailable = false,
    this.isLocked = false,
    this.lockUntil,
    this.failedAttempts = 0,
    this.lastMatchConfidence,
    this.settings = const {},
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isSetup => activeTemplate != null;
  bool get canAuthenticate => status == AuthStatus.ready && !isLocked;

  FaceAuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? error,
    FaceTemplate? activeTemplate,
    List<AuthAttempt>? recentAttempts,
    bool? biometricAvailable,
    bool? isLocked,
    DateTime? lockUntil,
    int? failedAttempts,
    double? lastMatchConfidence,
    Map<String, dynamic>? settings,
  }) => FaceAuthState(
    status: status ?? this.status,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    activeTemplate: activeTemplate ?? this.activeTemplate,
    recentAttempts: recentAttempts ?? this.recentAttempts,
    biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    isLocked: isLocked ?? this.isLocked,
    lockUntil: lockUntil ?? this.lockUntil,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lastMatchConfidence: lastMatchConfidence ?? this.lastMatchConfidence,
    settings: settings ?? this.settings,
  );
}
