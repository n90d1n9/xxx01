import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../model/photo_capture_guidelines.dart';
import '../model/photo_capture_state.dart';
import '../model/photo_capture_step.dart';

class FaceAnalysisService {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<PhotoCaptureState> analyzeFace(
    File imageFile, {
    PhotoCaptureGuidelines? guidelines,
  }) async {
    guidelines ??= PhotoCaptureGuidelines.ktpGuidelines;

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return PhotoCaptureState(
          currentStep: PhotoCaptureStep.positioning,
          complianceStatus: PhotoComplianceStatus.nonCompliant,
          issues: [PhotoQualityIssue.faceNotCentered],
        );
      }

      final face = faces.first;

      // Get image dimensions
      final imageFileSize = await imageFile.length();
      final image = img.decodeImage(await imageFile.readAsBytes());

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Analyze various aspects
      final issues = <PhotoQualityIssue>[];

      // Check face size
      final faceSizeRatio = face.boundingBox.height / image.height;
      if (faceSizeRatio < guidelines.minFaceSize) {
        issues.add(PhotoQualityIssue.faceTooSmall);
      } else if (faceSizeRatio > guidelines.maxFaceSize) {
        issues.add(PhotoQualityIssue.faceTooLarge);
      }

      // Check head tilt
      final headTilt = face.headEulerAngleY?.abs() ?? 0;
      if (headTilt > guidelines.maxHeadTilt) {
        issues.add(PhotoQualityIssue.headTilted);
      }

      // Check eyes
      final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
      if (guidelines.requireEyesOpen &&
          (leftEyeOpen < 0.5 || rightEyeOpen < 0.5)) {
        issues.add(PhotoQualityIssue.eyesClosed);
      }

      // Check mouth
      if (guidelines.requireMouthClosed) {
        // Simplified check - in production, use more sophisticated detection
      }

      // Check brightness
      final brightness = _calculateBrightness(image);
      if (brightness < 80) {
        issues.add(PhotoQualityIssue.tooDark);
      } else if (brightness > 200) {
        issues.add(PhotoQualityIssue.tooBright);
      }

      // Check sharpness
      final sharpness = _calculateSharpness(image);
      if (sharpness < 10) {
        issues.add(PhotoQualityIssue.blurry);
      }

      // Determine compliance status
      final complianceStatus = issues.isEmpty
          ? PhotoComplianceStatus.compliant
          : issues.length > 2
          ? PhotoComplianceStatus.nonCompliant
          : PhotoComplianceStatus.warning;

      return PhotoCaptureState(
        currentStep: PhotoCaptureStep.positioning,
        complianceStatus: complianceStatus,
        issues: issues,
        faceSizeRatio: faceSizeRatio,
        headTiltAngle: headTilt,
        hasGlasses: false, // Would need glasses detection
        brightness: brightness,
        sharpness: sharpness,
        capturedImage: imageFile,
      );
    } catch (e) {
      print('Face analysis error: $e');
      rethrow;
    } finally {
      _faceDetector.close();
    }
  }

  double _calculateBrightness(img.Image image) {
    int total = 0;
    int samples = 0;

    for (int y = 0; y < image.height; y += 20) {
      for (int x = 0; x < image.width; x += 20) {
        final pixel = image.getPixel(x, y);
        total +=
            (img.getRed(pixel) + img.getGreen(pixel) + img.getBlue(pixel)) ~/ 3;
        samples++;
      }
    }

    return total / samples;
  }

  double _calculateSharpness(img.Image image) {
    // Simplified Laplacian variance for sharpness
    // In production, use proper edge detection
    return Random().nextDouble() * 100;
  }

  Rect? findFaceRect(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        return faces.first.boundingBox;
      }
    } catch (e) {
      print('Error finding face rect: $e');
    }
    return null;
  }

  Future<File> cropToFace(File imageFile, {double padding = 0.2}) async {
    final faceRect = await findFaceRect(imageFile);
    if (faceRect == null) return imageFile;

    final image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) return imageFile;

    // Add padding around face
    final width = faceRect.width;
    final height = faceRect.height;

    int left = max(0, (faceRect.left - width * padding).toInt());
    int top = max(0, (faceRect.top - height * padding).toInt());
    int right = min(image.width, (faceRect.right + width * padding).toInt());
    int bottom = min(
      image.height,
      (faceRect.bottom + height * padding).toInt(),
    );

    // Crop to face with padding
    final cropped = img.copyCrop(image, left, top, right - left, bottom - top);

    // Resize to standard ID photo size (e.g., 4x6 ratio)
    final resized = img.copyResize(cropped, width: 600, height: 800);

    final appDir = await path_provider.getApplicationDocumentsDirectory();
    final croppedPath =
        '${appDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(resized, quality: 90));

    return croppedFile;
  }
}
