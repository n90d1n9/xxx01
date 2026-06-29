// pubspec.yaml dependencies needed:
// flutter_riverpod: ^2.4.9
// camera: ^0.10.5+5
// google_ml_kit: ^0.16.3
// sembast: ^3.5.0
// sembast_web: ^2.1.3
// path_provider: ^2.1.1
// path: ^1.8.3
// crypto: ^3.0.3
// local_auth: ^2.1.7
// permission_handler: ^11.1.0
// lottie: ^3.0.0
// flutter_secure_storage: ^9.0.0
// device_info_plus: ^9.1.1
// connectivity_plus: ^5.0.2

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

// Enhanced Models
class FaceTemplate {
  final String id;
  final List<double> features;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int usageCount;
  final String deviceId;
  final Map<String, dynamic> metadata;

  FaceTemplate({
    required this.id,
    required this.features,
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
    required this.deviceId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'features': features,
    'createdAt': createdAt.toIso8601String(),
    'lastUsed': lastUsed.toIso8601String(),
    'usageCount': usageCount,
    'deviceId': deviceId,
    'metadata': metadata,
  };

  factory FaceTemplate.fromJson(Map<String, dynamic> json) => FaceTemplate(
    id: json['id'],
    features: List<double>.from(json['features']),
    createdAt: DateTime.parse(json['createdAt']),
    lastUsed: DateTime.parse(json['lastUsed']),
    usageCount: json['usageCount'] ?? 0,
    deviceId: json['deviceId'],
    metadata: json['metadata'] ?? {},
  );

  FaceTemplate copyWith({
    String? id,
    List<double>? features,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) => FaceTemplate(
    id: id ?? this.id,
    features: features ?? this.features,
    createdAt: createdAt ?? this.createdAt,
    lastUsed: lastUsed ?? this.lastUsed,
    usageCount: usageCount ?? this.usageCount,
    deviceId: deviceId ?? this.deviceId,
    metadata: metadata ?? this.metadata,
  );
}

class AuthAttempt {
  final String id;
  final DateTime timestamp;
  final bool success;
  final String method; // 'face', 'biometric', 'fallback'
  final String? failureReason;
  final String deviceId;
  final Map<String, dynamic> metadata;

  AuthAttempt({
    required this.id,
    required this.timestamp,
    required this.success,
    required this.method,
    this.failureReason,
    required this.deviceId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
    'method': method,
    'failureReason': failureReason,
    'deviceId': deviceId,
    'metadata': metadata,
  };

  factory AuthAttempt.fromJson(Map<String, dynamic> json) => AuthAttempt(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    success: json['success'],
    method: json['method'],
    failureReason: json['failureReason'],
    deviceId: json['deviceId'],
    metadata: json['metadata'] ?? {},
  );
}

enum AuthStatus {
  idle,
  initializing,
  setupRequired,
  ready,
  authenticating,
  authenticated,
  failed,
  locked,
  error,
}

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

// Enhanced Services
class EncryptionService {
  static const _keyLength = 32;
  static const _ivLength = 16;

  final FlutterSecureStorage _secureStorage;

  EncryptionService()
    : _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
          storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'face_auth_key');
    if (key == null) {
      key = _generateKey();
      await _secureStorage.write(key: 'face_auth_key', value: key);
    }
    return key;
  }

  String _generateKey() {
    final bytes = List<int>.generate(
      _keyLength,
      (i) => DateTime.now().millisecondsSinceEpoch.hashCode + i,
    );
    return base64Encode(bytes);
  }

  Future<String> encrypt(String data) async {
    final key = await _getEncryptionKey();
    final keyBytes = base64Decode(key);
    final dataBytes = utf8.encode(data);

    // Simple XOR encryption (use proper AES in production)
    final encrypted = <int>[];
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(encrypted);
  }

  Future<String> decrypt(String encryptedData) async {
    final key = await _getEncryptionKey();
    final keyBytes = base64Decode(key);
    final encryptedBytes = base64Decode(encryptedData);

    // Simple XOR decryption
    final decrypted = <int>[];
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decrypted);
  }

  Future<void> clearKeys() async {
    await _secureStorage.deleteAll();
  }
}

class DatabaseService {
  static const String _dbName = 'face_auth.db';
  static const String _faceTemplatesStore = 'face_templates';
  static const String _authAttemptsStore = 'auth_attempts';
  static const String _settingsStore = 'settings';

  Database? _db;
  final EncryptionService _encryption;

  DatabaseService(this._encryption);

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  // Face Templates
  Future<void> saveFaceTemplate(FaceTemplate template) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);

    final jsonData = jsonEncode(template.toJson());
    final encryptedData = await _encryption.encrypt(jsonData);

    await store.record(template.id).put(db, {
      'data': encryptedData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<FaceTemplate?> getFaceTemplate(String id) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);

    final record = await store.record(id).get(db);
    if (record == null) return null;

    final decryptedData = await _encryption.decrypt(record['data']);
    final jsonData = jsonDecode(decryptedData);

    return FaceTemplate.fromJson(jsonData);
  }

  Future<List<FaceTemplate>> getAllFaceTemplates() async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);

    final records = await store.find(db);
    final templates = <FaceTemplate>[];

    for (final record in records) {
      try {
        final decryptedData = await _encryption.decrypt(record.value['data']);
        final jsonData = jsonDecode(decryptedData);
        templates.add(FaceTemplate.fromJson(jsonData));
      } catch (e) {
        print('Error decrypting template: $e');
      }
    }

    return templates;
  }

  Future<void> deleteFaceTemplate(String id) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);
    await store.record(id).delete(db);
  }

  // Auth Attempts
  Future<void> saveAuthAttempt(AuthAttempt attempt) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_authAttemptsStore);

    final jsonData = jsonEncode(attempt.toJson());
    final encryptedData = await _encryption.encrypt(jsonData);

    await store.record(attempt.id).put(db, {
      'data': encryptedData,
      'timestamp': attempt.timestamp.toIso8601String(),
    });

    // Keep only last 100 attempts
    await _cleanupOldAttempts();
  }

  Future<List<AuthAttempt>> getRecentAuthAttempts({int limit = 10}) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_authAttemptsStore);

    final finder = Finder(
      sortOrders: [SortOrder('timestamp', false)],
      limit: limit,
    );

    final records = await store.find(db, finder: finder);
    final attempts = <AuthAttempt>[];

    for (final record in records) {
      try {
        final decryptedData = await _encryption.decrypt(record.value['data']);
        final jsonData = jsonDecode(decryptedData);
        attempts.add(AuthAttempt.fromJson(jsonData));
      } catch (e) {
        print('Error decrypting attempt: $e');
      }
    }

    return attempts;
  }

  Future<void> _cleanupOldAttempts() async {
    final db = await database;
    final store = stringMapStoreFactory.store(_authAttemptsStore);

    final finder = Finder(
      sortOrders: [SortOrder('timestamp', false)],
      offset: 100,
    );

    await store.delete(db, finder: finder);
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_settingsStore);

    final jsonData = jsonEncode({'value': value});
    final encryptedData = await _encryption.encrypt(jsonData);

    await store.record(key).put(db, {
      'data': encryptedData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<T?> getSetting<T>(String key) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_settingsStore);

    final record = await store.record(key).get(db);
    if (record == null) return null;

    try {
      final decryptedData = await _encryption.decrypt(record['data']);
      final jsonData = jsonDecode(decryptedData);
      return jsonData['value'] as T?;
    } catch (e) {
      print('Error decrypting setting: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    final db = await database;
    final store = stringMapStoreFactory.store(_settingsStore);

    final records = await store.find(db);
    final settings = <String, dynamic>{};

    for (final record in records) {
      try {
        final decryptedData = await _encryption.decrypt(record.value['data']);
        final jsonData = jsonDecode(decryptedData);
        settings[record.key] = jsonData['value'];
      } catch (e) {
        print('Error decrypting setting: $e');
      }
    }

    return settings;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.close();

    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);
    final file = File(dbPath);

    if (await file.exists()) {
      await file.delete();
    }

    _db = null;
  }
}

class EnhancedFaceAuthService {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  Future<List<double>?> extractAdvancedFaceFeatures(InputImage image) async {
    try {
      final faces = await _faceDetector.processImage(image);
      if (faces.isEmpty) return null;

      final face = faces.first;
      final features = <double>[];

      // Geometric features
      features.addAll([
        face.boundingBox.center.dx,
        face.boundingBox.center.dy,
        face.boundingBox.width.toDouble(),
        face.boundingBox.height.toDouble(),
      ]);

      // Facial expressions
      features.addAll([
        face.leftEyeOpenProbability ?? 0.0,
        face.rightEyeOpenProbability ?? 0.0,
        face.smilingProbability ?? 0.0,
      ]);

      // Landmarks
      if (face.landmarks.isNotEmpty) {
        for (final landmark in face.landmarks.values) {
          features.addAll([
            landmark.position.x.toDouble(),
            landmark.position.y.toDouble(),
          ]);
        }
      }

      // Contours
      if (face.contours.isNotEmpty) {
        for (final contour in face.contours.values) {
          for (final point in contour.points) {
            features.addAll([point.x.toDouble(), point.y.toDouble()]);
          }
        }
      }

      return features;
    } catch (e) {
      print('Error extracting face features: $e');
      return null;
    }
  }

  double calculateMatchConfidence(List<double> stored, List<double> current) {
    if (stored.length != current.length) return 0.0;

    double totalDifference = 0.0;
    double maxDifference = 0.0;

    for (int i = 0; i < stored.length; i++) {
      final diff = (stored[i] - current[i]).abs();
      totalDifference += diff;
      maxDifference = maxDifference > diff ? maxDifference : diff;
    }

    // Normalize confidence score (0.0 to 1.0)
    final avgDifference = totalDifference / stored.length;
    final confidence = 1.0 - (avgDifference / 100.0).clamp(0.0, 1.0);

    return confidence;
  }

  bool isMatchValid(double confidence, {double threshold = 0.75}) {
    return confidence >= threshold;
  }

  Future<bool> checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Error authenticating with biometrics: $e');
      return false;
    }
  }

  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      print('Error getting device ID: $e');
      return 'unknown';
    }
  }

  Future<Map<String, dynamic>> getDeviceMetadata() async {
    try {
      final connectivity = await _connectivity.checkConnectivity();

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'connectivity': connectivity.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
          'connectivity': connectivity.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      return {
        'platform': 'unknown',
        'connectivity': connectivity.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting device metadata: $e');
      return {
        'platform': 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}

// Enhanced Providers
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final encryption = ref.watch(encryptionServiceProvider);
  return DatabaseService(encryption);
});

final faceAuthServiceProvider = Provider<EnhancedFaceAuthService>((ref) {
  final service = EnhancedFaceAuthService();
  ref.onDispose(() => service.dispose());
  return service;
});

final faceAuthProvider =
    StateNotifierProvider<EnhancedFaceAuthNotifier, FaceAuthState>((ref) {
      return EnhancedFaceAuthNotifier(
        ref.read(faceAuthServiceProvider),
        ref.read(databaseServiceProvider),
      );
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
      final biometricAvailable =
          await _faceAuthService.checkBiometricAvailability();

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
        status:
            activeTemplate != null
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
      status:
          state.activeTemplate != null
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

// Enhanced UI Components
void main() {
  runApp(const ProviderScope(child: FaceAuthApp()));
}

class FaceAuthApp extends StatelessWidget {
  const FaceAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Face Auth',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      home: const EnhancedFaceAuthScreen(),
    );
  }
}

class EnhancedFaceAuthScreen extends ConsumerStatefulWidget {
  const EnhancedFaceAuthScreen({super.key});

  @override
  ConsumerState<EnhancedFaceAuthScreen> createState() =>
      _EnhancedFaceAuthScreenState();
}

class _EnhancedFaceAuthScreenState extends ConsumerState<EnhancedFaceAuthScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  late AnimationController _pulseController;
  late AnimationController _statusController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _statusAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _statusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statusController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.nv21,
        );
        await _controller!.initialize();
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(faceAuthProvider);
    final authNotifier = ref.watch(faceAuthProvider.notifier);

    // Trigger status animation when status changes
    ref.listen<FaceAuthState>(faceAuthProvider, (previous, current) {
      if (previous?.status != current.status) {
        _statusController.forward(from: 0.0);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, authState, authNotifier),
      body: Container(
        decoration: _buildBackgroundDecoration(authState),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(flex: 3, child: _buildCameraSection(authState)),
              Expanded(
                flex: 2,
                child: _buildControlPanel(authState, authNotifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'SecureAuth Pro',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        if (authState.isAuthenticated)
          IconButton(
            onPressed: () => _showSecurityReport(context, authState),
            icon: const Icon(Icons.security),
            tooltip: 'Security Report',
          ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'settings':
                await _showSettings(context, authState, authNotifier);
                break;
              case 'history':
                await _showAuthHistory(context, authState);
                break;
              case 'reset':
                await _showResetDialog(context, authNotifier);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('Auth History'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Reset Data'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
      ],
    );
  }

  BoxDecoration _buildBackgroundDecoration(FaceAuthState authState) {
    Color startColor, endColor;

    switch (authState.status) {
      case AuthStatus.authenticated:
        startColor = const Color(0xFF00C851);
        endColor = const Color(0xFF007E33);
        break;
      case AuthStatus.failed:
      case AuthStatus.locked:
        startColor = const Color(0xFFFF4444);
        endColor = const Color(0xFFCC0000);
        break;
      case AuthStatus.authenticating:
        startColor = const Color(0xFFFFBB33);
        endColor = const Color(0xFFFF8800);
        break;
      default:
        startColor = const Color(0xFF667EEA);
        endColor = const Color(0xFF764BA2);
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
        stops: const [0.0, 1.0],
      ),
    );
  }

  Widget _buildCameraSection(FaceAuthState authState) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            _buildCameraPreview(),
            _buildCameraOverlay(authState),
            _buildStatusOverlay(authState),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: CameraPreview(_controller!),
    );
  }

  Widget _buildCameraOverlay(FaceAuthState authState) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: EnhancedFaceOverlayPainter(
            pulseScale: _pulseAnimation.value,
            status: authState.status,
            confidence: authState.lastMatchConfidence,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildStatusOverlay(FaceAuthState authState) {
    if (authState.status == AuthStatus.initializing) return const SizedBox();

    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _statusAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _statusAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusIcon(authState.status),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(authState),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (authState.lastMatchConfidence != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(authState.lastMatchConfidence! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(AuthStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case AuthStatus.authenticated:
        icon = Icons.verified_user;
        color = Colors.green;
        break;
      case AuthStatus.authenticating:
        icon = Icons.face_retouching_natural;
        color = Colors.orange;
        break;
      case AuthStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case AuthStatus.locked:
        icon = Icons.lock;
        color = Colors.red;
        break;
      case AuthStatus.ready:
        icon = Icons.face;
        color = Colors.blue;
        break;
      case AuthStatus.setupRequired:
        icon = Icons.add_a_photo;
        color = Colors.white;
        break;
      default:
        icon = Icons.hourglass_empty;
        color = Colors.white;
    }

    return Icon(icon, color: color, size: 18);
  }

  String _getStatusText(FaceAuthState authState) {
    switch (authState.status) {
      case AuthStatus.authenticated:
        return 'Authenticated Successfully';
      case AuthStatus.authenticating:
        return 'Scanning...';
      case AuthStatus.failed:
        return 'Authentication Failed';
      case AuthStatus.locked:
        if (authState.lockUntil != null) {
          final remaining = authState.lockUntil!.difference(DateTime.now());
          return 'Locked for ${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
        }
        return 'Account Locked';
      case AuthStatus.ready:
        return 'Ready to Authenticate';
      case AuthStatus.setupRequired:
        return 'Setup Required';
      default:
        return 'Initializing...';
    }
  }

  Widget _buildControlPanel(
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMainActionButton(authState, authNotifier),
          const SizedBox(height: 20),
          if (authState.biometricAvailable && !authState.isAuthenticated) ...[
            _buildBiometricButton(authState, authNotifier),
            const SizedBox(height: 16),
          ],
          if (authState.error != null) ...[
            _buildErrorMessage(authState.error!),
            const SizedBox(height: 16),
          ],
          _buildInfoRow(authState),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    if (authState.isLoading) {
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text(
                  'Processing...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () => authNotifier.signOut(),
          icon: const Icon(Icons.logout, size: 24),
          label: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
        ),
      );
    }

    if (authState.isLocked) {
      return SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.lock, size: 24),
          label: const Text(
            'Account Locked',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () => _takePicture(authNotifier, authState.isSetup),
        icon: Icon(
          authState.isSetup ? Icons.camera_alt : Icons.face_retouching_natural,
          size: 24,
        ),
        label: Text(
          authState.isSetup ? 'Authenticate with Face' : 'Setup Face ID',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildBiometricButton(
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed:
            authState.canAuthenticate
                ? () => authNotifier.authenticateWithBiometrics()
                : null,
        icon: const Icon(Icons.fingerprint, size: 22),
        label: const Text(
          'Use Biometric',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(FaceAuthState authState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoItem(
          icon: Icons.security,
          label: 'Security',
          value: authState.isSetup ? 'Active' : 'Setup',
          color: authState.isSetup ? Colors.green : Colors.orange,
        ),
        _buildInfoItem(
          icon: Icons.devices,
          label: 'Device',
          value: 'Secured',
          color: Colors.blue,
        ),
        _buildInfoItem(
          icon: Icons.history,
          label: 'Attempts',
          value: authState.recentAttempts.length.toString(),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _takePicture(
    EnhancedFaceAuthNotifier notifier,
    bool isSetup,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      HapticFeedback.mediumImpact();

      await _controller!.startImageStream((image) async {
        await _controller!.stopImageStream();

        if (isSetup) {
          await notifier.authenticateWithFace(image);
        } else {
          await notifier.setupFaceAuth(image);
        }
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _showSecurityReport(
    BuildContext context,
    FaceAuthState authState,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => SecurityReportDialog(authState: authState),
    );
  }

  Future<void> _showSettings(
    BuildContext context,
    FaceAuthState authState,
    EnhancedFaceAuthNotifier authNotifier,
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) =>
              SettingsDialog(authState: authState, authNotifier: authNotifier),
    );
  }

  Future<void> _showAuthHistory(
    BuildContext context,
    FaceAuthState authState,
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) => AuthHistoryDialog(attempts: authState.recentAttempts),
    );
  }

  Future<void> _showResetDialog(
    BuildContext context,
    EnhancedFaceAuthNotifier authNotifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset All Data'),
            content: const Text(
              'This will permanently delete all face templates, authentication history, and settings. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await authNotifier.resetAllData();
    }
  }
}

// Enhanced Face Overlay Painter
class EnhancedFaceOverlayPainter extends CustomPainter {
  final double pulseScale;
  final AuthStatus status;
  final double? confidence;

  EnhancedFaceOverlayPainter({
    required this.pulseScale,
    required this.status,
    this.confidence,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.25;
    final radius = baseRadius * pulseScale;

    // Main circle
    final mainPaint =
        Paint()
          ..color = _getStatusColor().withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    canvas.drawCircle(center, radius, mainPaint);

    // Pulse effect
    final pulsePaint =
        Paint()
          ..color = _getStatusColor().withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 1.2, pulsePaint);

    // Corner brackets
    _drawCornerBrackets(canvas, center, radius);

    // Status indicator
    _drawStatusIndicator(canvas, center, radius);

    // Confidence meter
    if (confidence != null) {
      _drawConfidenceMeter(canvas, center, radius, confidence!);
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case AuthStatus.authenticated:
        return Colors.green;
      case AuthStatus.authenticating:
        return Colors.orange;
      case AuthStatus.failed:
      case AuthStatus.locked:
        return Colors.red;
      case AuthStatus.ready:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  void _drawCornerBrackets(Canvas canvas, Offset center, double radius) {
    final bracketSize = radius * 0.3;
    final bracketPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius + bracketSize),
      Offset(center.dx - radius, center.dy - radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx - radius + bracketSize, center.dy - radius),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(center.dx + radius - bracketSize, center.dy - radius),
      Offset(center.dx + radius, center.dy - radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx + radius, center.dy - radius + bracketSize),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius - bracketSize),
      Offset(center.dx - radius, center.dy + radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius),
      Offset(center.dx - radius + bracketSize, center.dy + radius),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(center.dx + radius - bracketSize, center.dy + radius),
      Offset(center.dx + radius, center.dy + radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy + radius),
      Offset(center.dx + radius, center.dy + radius - bracketSize),
      bracketPaint,
    );
  }

  void _drawStatusIndicator(Canvas canvas, Offset center, double radius) {
    final indicatorPaint =
        Paint()
          ..color = _getStatusColor()
          ..style = PaintingStyle.fill;

    switch (status) {
      case AuthStatus.authenticated:
        // Checkmark
        final path =
            Path()
              ..moveTo(center.dx - radius * 0.2, center.dy)
              ..lineTo(center.dx - radius * 0.05, center.dy + radius * 0.15)
              ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.15);
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
        break;
      case AuthStatus.authenticating:
        // Scanning animation
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.3),
          -0.5,
          2.0,
          false,
          indicatorPaint,
        );
        break;
      case AuthStatus.failed:
      case AuthStatus.locked:
        // X mark
        canvas.drawLine(
          Offset(center.dx - radius * 0.2, center.dy - radius * 0.2),
          Offset(center.dx + radius * 0.2, center.dy + radius * 0.2),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(center.dx + radius * 0.2, center.dy - radius * 0.2),
          Offset(center.dx - radius * 0.2, center.dy + radius * 0.2),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
        break;
      default:
        // Face icon
        canvas.drawCircle(center, radius * 0.15, indicatorPaint);
        canvas.drawCircle(
          Offset(center.dx - radius * 0.1, center.dy - radius * 0.05),
          radius * 0.03,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(center.dx + radius * 0.1, center.dy - radius * 0.05),
          radius * 0.03,
          Paint()..color = Colors.white,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + radius * 0.05),
            width: radius * 0.3,
            height: radius * 0.2,
          ),
          0.2,
          2.8,
          false,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  void _drawConfidenceMeter(
    Canvas canvas,
    Offset center,
    double radius,
    double confidence,
  ) {
    final meterWidth = radius * 0.8;
    final meterHeight = 8.0;
    final meterY = center.dy + radius * 0.6;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, meterY),
          width: meterWidth,
          height: meterHeight,
        ),
        Radius.circular(meterHeight / 2),
      ),
      Paint()..color = Colors.white.withOpacity(0.3),
    );

    // Progress
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx - meterWidth / 2 + (meterWidth * confidence) / 2,
            meterY,
          ),
          width: meterWidth * confidence,
          height: meterHeight,
        ),
        Radius.circular(meterHeight / 2),
      ),
      Paint()..color = _getConfidenceColor(confidence),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.lightGreen;
    if (confidence > 0.4) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant EnhancedFaceOverlayPainter oldDelegate) {
    return oldDelegate.pulseScale != pulseScale ||
        oldDelegate.status != status ||
        oldDelegate.confidence != confidence;
  }
}

// Dialog Widgets
class SecurityReportDialog extends StatelessWidget {
  final FaceAuthState authState;

  const SecurityReportDialog({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Security Report'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSecurityItem(
              icon: Icons.face,
              label: 'Face ID Status',
              value: authState.isSetup ? 'Configured' : 'Not Configured',
              isSecure: authState.isSetup,
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              icon: Icons.fingerprint,
              label: 'Biometric Status',
              value: authState.biometricAvailable ? 'Available' : 'Unavailable',
              isSecure: authState.biometricAvailable,
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              icon: Icons.device_unknown,
              label: 'Device Security',
              value: 'Secured',
              isSecure: true,
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              icon: Icons.history,
              label: 'Recent Attempts',
              value: '${authState.recentAttempts.length} records',
              isSecure:
                  authState.recentAttempts.where((a) => !a.success).isEmpty,
            ),
            const SizedBox(height: 16),
            if (authState.activeTemplate != null) ...[
              const Text(
                'Face Template Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Created: ${authState.activeTemplate!.createdAt}'),
              Text('Last Used: ${authState.activeTemplate!.lastUsed}'),
              Text('Usage Count: ${authState.activeTemplate!.usageCount}'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isSecure,
  }) {
    return Row(
      children: [
        Icon(icon, color: isSecure ? Colors.green : Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSecure ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isSecure ? Icons.check_circle : Icons.warning,
          color: isSecure ? Colors.green : Colors.orange,
        ),
      ],
    );
  }
}

class SettingsDialog extends StatefulWidget {
  final FaceAuthState authState;
  final EnhancedFaceAuthNotifier authNotifier;

  const SettingsDialog({
    super.key,
    required this.authState,
    required this.authNotifier,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late Map<String, dynamic> _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = Map.from(widget.authState.settings);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authentication Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Enable Fallback to Biometric'),
              value: _currentSettings['biometric_fallback'] ?? true,
              onChanged: (value) {
                setState(() {
                  _currentSettings['biometric_fallback'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Require Strong Match'),
              subtitle: const Text('Higher security, lower convenience'),
              value: _currentSettings['strong_match'] ?? false,
              onChanged: (value) {
                setState(() {
                  _currentSettings['strong_match'] = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Privacy Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Store Metadata'),
              subtitle: const Text('Device info, location, etc.'),
              value: _currentSettings['store_metadata'] ?? true,
              onChanged: (value) {
                setState(() {
                  _currentSettings['store_metadata'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Help improve the app'),
              value: _currentSettings['analytics'] ?? true,
              onChanged: (value) {
                setState(() {
                  _currentSettings['analytics'] = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.authNotifier.updateSettings(_currentSettings);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AuthHistoryDialog extends StatelessWidget {
  final List<AuthAttempt> attempts;

  const AuthHistoryDialog({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Authentication History'),
      content: SizedBox(
        width: double.maxFinite,
        child:
            attempts.isEmpty
                ? const Center(
                  child: Text('No authentication attempts recorded'),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: attempts.length,
                  itemBuilder: (context, index) {
                    final attempt = attempts[index];
                    return _buildAttemptItem(attempt);
                  },
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildAttemptItem(AuthAttempt attempt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: attempt.success ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              attempt.success
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                attempt.success ? Icons.check_circle : Icons.error,
                color: attempt.success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                attempt.method.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: attempt.success ? Colors.green : Colors.red,
                ),
              ),
              const Spacer(),
              Text(
                '${attempt.timestamp.hour}:${attempt.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            attempt.timestamp.toLocal().toString(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (attempt.failureReason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reason: ${attempt.failureReason}',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
