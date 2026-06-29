import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:local_auth/local_auth.dart';

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
            landmark!.position.x.toDouble(),
            landmark.position.y.toDouble(),
          ]);
        }
      }

      // Contours
      if (face.contours.isNotEmpty) {
        for (final contour in face.contours.values) {
          for (final point in contour!.points) {
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
