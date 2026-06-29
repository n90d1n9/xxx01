import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../models/auth_attempt.dart';
import '../models/auth_status.dart';
import '../models/face_auth_state.dart';
import '../models/face_template.dart';
import '../services/database_service.dart';
import '../services/face_auth_service.dart';

final faceAuthServiceProvider = Provider<EnhancedFaceAuthService>((ref) {
  final service = EnhancedFaceAuthService();
  ref.onDispose(() => service.dispose());
  return service;
});

class EnhancedFaceAuthNotifier extends StateNotifier<FaceAuthState> {
  final EnhancedFaceAuthService _faceAuthService;
  final DatabaseService _database;

  static const int _maxFailedAttempts = 5;
  static const Duration _lockDuration = Duration(minutes: 15);

  EnhancedFaceAuthNotifier(this._faceAuthService, this._database)
    : super(const FaceAuthState(status: AuthStatus.initializing)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Check biometric availability
      final biometricAvailable = await _faceAuthService
          .checkBiometricAvailability();

      // Load existing templates
      final templates = await _database.getAllFaceTemplates();
      final activeTemplate = templates.isNotEmpty ? templates.first : null;

      // Load recent attempts
      final recentAttempts = await _database.getRecentAuthAttempts();

      // Load settings
      final settings = await _database.getAllSettings();

      // Check if account is locked
      final lockUntil = await _getLockUntil();
      final isLocked = lockUntil != null && DateTime.now().isBefore(lockUntil);

      state = state.copyWith(
        status: activeTemplate != null
            ? AuthStatus.ready
            : AuthStatus.setupRequired,
        activeTemplate: activeTemplate,
        recentAttempts: recentAttempts,
        biometricAvailable: biometricAvailable,
        isLocked: isLocked,
        lockUntil: lockUntil,
        settings: settings,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to initialize: $e',
      );
    }
  }

  Future<void> setupFaceAuth(CameraImage image) async {
    if (state.isLocked) {
      state = state.copyWith(
        error: 'Account is locked. Please try again later.',
      );
      return;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      isLoading: true,
      error: null,
    );

    try {
      final inputImage = _convertCameraImage(image);
      final features = await _faceAuthService.extractAdvancedFaceFeatures(
        inputImage,
      );

      if (features != null) {
        final deviceId = await _faceAuthService.getDeviceId();
        final metadata = await _faceAuthService.getDeviceMetadata();

        final template = FaceTemplate(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          features: features,
          createdAt: DateTime.now(),
          lastUsed: DateTime.now(),
          deviceId: deviceId,
          metadata: metadata,
        );

        await _database.saveFaceTemplate(template);

        // Log successful setup
        await _logAuthAttempt(
          success: true,
          method: 'face_setup',
          metadata: metadata,
        );

        state = state.copyWith(
          status: AuthStatus.ready,
          isLoading: false,
          activeTemplate: template,
        );
      } else {
        await _logAuthAttempt(
          success: false,
          method: 'face_setup',
          failureReason: 'no_face_detected',
        );

        state = state.copyWith(
          status: AuthStatus.setupRequired,
          isLoading: false,
          error:
              'No face detected. Please ensure your face is clearly visible.',
        );
      }
    } catch (e) {
      await _logAuthAttempt(
        success: false,
        method: 'face_setup',
        failureReason: 'setup_error: $e',
      );

      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        error: 'Setup failed: $e',
      );
    }
  }

  Future<void> authenticateWithFace(CameraImage image) async {
    if (state.isLocked) {
      state = state.copyWith(
        error: 'Account is locked. Please try again later.',
      );
      return;
    }

    if (state.activeTemplate == null) {
      state = state.copyWith(error: 'Face authentication not set up');
      return;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      isLoading: true,
      error: null,
    );

    try {
      final inputImage = _convertCameraImage(image);
      final features = await _faceAuthService.extractAdvancedFaceFeatures(
        inputImage,
      );

      if (features != null) {
        final confidence = _faceAuthService.calculateMatchConfidence(
          state.activeTemplate!.features,
          features,
        );

        final isMatch = _faceAuthService.isMatchValid(confidence);
        final metadata = await _faceAuthService.getDeviceMetadata();

        if (isMatch) {
          // Update template usage
          final updatedTemplate = state.activeTemplate!.copyWith(
            lastUsed: DateTime.now(),
            usageCount: state.activeTemplate!.usageCount + 1,
          );

          await _database.saveFaceTemplate(updatedTemplate);

          // Log successful authentication
          await _logAuthAttempt(
            success: true,
            method: 'face',
            metadata: {...metadata, 'confidence': confidence},
          );

          // Reset failed attempts
          await _database.saveSetting('failed_attempts', 0);
          await _database.saveSetting('lock_until', null);

          state = state.copyWith(
            status: AuthStatus.authenticated,
            isLoading: false,
            activeTemplate: updatedTemplate,
            lastMatchConfidence: confidence,
            failedAttempts: 0,
            isLocked: false,
            lockUntil: null,
          );
        } else {
          await _handleFailedAttempt(
            method: 'face',
            failureReason: 'face_not_recognized',
            metadata: {...metadata, 'confidence': confidence},
          );
        }
      } else {
        await _handleFailedAttempt(
          method: 'face',
          failureReason: 'no_face_detected',
        );
      }
    } catch (e) {
      await _handleFailedAttempt(
        method: 'face',
        failureReason: 'authentication_error: $e',
      );
    }
  }

  Future<void> authenticateWithBiometrics() async {
    if (state.isLocked) {
      state = state.copyWith(
        error: 'Account is locked. Please try again later.',
      );
      return;
    }

    if (!state.biometricAvailable) {
      state = state.copyWith(error: 'Biometric authentication not available');
      return;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      isLoading: true,
      error: null,
    );

    try {
      final success = await _faceAuthService.authenticateWithBiometrics();
      final metadata = await _faceAuthService.getDeviceMetadata();

      if (success) {
        await _logAuthAttempt(
          success: true,
          method: 'biometric',
          metadata: metadata,
        );

        // Reset failed attempts
        await _database.saveSetting('failed_attempts', 0);
        await _database.saveSetting('lock_until', null);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          failedAttempts: 0,
          isLocked: false,
          lockUntil: null,
        );
      } else {
        await _handleFailedAttempt(
          method: 'biometric',
          failureReason: 'biometric_failed',
          metadata: metadata,
        );
      }
    } catch (e) {
      await _handleFailedAttempt(
        method: 'biometric',
        failureReason: 'biometric_error: $e',
      );
    }
  }

  Future<void> _handleFailedAttempt({
    required String method,
    required String failureReason,
    Map<String, dynamic>? metadata,
  }) async {
    final newFailedAttempts = state.failedAttempts + 1;

    await _logAuthAttempt(
      success: false,
      method: method,
      failureReason: failureReason,
      metadata: metadata ?? {},
    );

    if (newFailedAttempts >= _maxFailedAttempts) {
      final lockUntil = DateTime.now().add(_lockDuration);
      await _database.saveSetting('lock_until', lockUntil.toIso8601String());

      state = state.copyWith(
        status: AuthStatus.locked,
        isLoading: false,
        isLocked: true,
        lockUntil: lockUntil,
        failedAttempts: newFailedAttempts,
        error:
            'Too many failed attempts. Account locked for ${_lockDuration.inMinutes} minutes.',
      );
    } else {
      await _database.saveSetting('failed_attempts', newFailedAttempts);

      state = state.copyWith(
        status: AuthStatus.failed,
        isLoading: false,
        failedAttempts: newFailedAttempts,
        error:
            'Authentication failed. ${_maxFailedAttempts - newFailedAttempts} attempts remaining.',
      );
    }
  }

  Future<void> _logAuthAttempt({
    required bool success,
    required String method,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) async {
    final deviceId = await _faceAuthService.getDeviceId();
    final attempt = AuthAttempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      success: success,
      method: method,
      failureReason: failureReason,
      deviceId: deviceId,
      metadata: metadata ?? {},
    );

    await _database.saveAuthAttempt(attempt);

    // Update recent attempts in state
    final recentAttempts = await _database.getRecentAuthAttempts();
    state = state.copyWith(recentAttempts: recentAttempts);
  }

  Future<DateTime?> _getLockUntil() async {
    final lockUntilString = await _database.getSetting<String>('lock_until');
    if (lockUntilString != null) {
      return DateTime.parse(lockUntilString);
    }
    return null;
  }

  InputImage _convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final inputImageRotation =
        InputImageRotationValue.fromRawValue(0) ??
        InputImageRotation.rotation0deg;
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: inputImageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  void signOut() {
    state = state.copyWith(
      status: state.activeTemplate != null
          ? AuthStatus.ready
          : AuthStatus.setupRequired,
      error: null,
      lastMatchConfidence: null,
    );
  }

  Future<void> resetAllData() async {
    await _database.clearAllData();
    state = const FaceAuthState(status: AuthStatus.setupRequired);
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    for (final entry in newSettings.entries) {
      await _database.saveSetting(entry.key, entry.value);
    }

    final allSettings = await _database.getAllSettings();
    state = state.copyWith(settings: allSettings);
  }
}
