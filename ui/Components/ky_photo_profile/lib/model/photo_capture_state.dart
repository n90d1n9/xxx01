import 'dart:io';

import 'photo_capture_step.dart';
import 'profile_photo.dart';

class PhotoCaptureState {
  final PhotoCaptureStep currentStep;
  final PhotoComplianceStatus complianceStatus;
  final List<PhotoQualityIssue> issues;
  final double faceSizeRatio;
  final double headTiltAngle;
  final bool hasGlasses;
  final double brightness;
  final double sharpness;
  final File? capturedImage;
  final ProfilePhoto? finalPhoto;

  PhotoCaptureState({
    required this.currentStep,
    required this.complianceStatus,
    this.issues = const [],
    this.faceSizeRatio = 0.0,
    this.headTiltAngle = 0.0,
    this.hasGlasses = false,
    this.brightness = 0.0,
    this.sharpness = 0.0,
    this.capturedImage,
    this.finalPhoto,
  });

  bool get isCompliant => complianceStatus == PhotoComplianceStatus.compliant;
  bool get hasIssues => issues.isNotEmpty;

  PhotoCaptureState copyWith({
    PhotoCaptureStep? currentStep,
    PhotoComplianceStatus? complianceStatus,
    List<PhotoQualityIssue>? issues,
    double? faceSizeRatio,
    double? headTiltAngle,
    bool? hasGlasses,
    double? brightness,
    double? sharpness,
    File? capturedImage,
    ProfilePhoto? finalPhoto,
  }) {
    return PhotoCaptureState(
      currentStep: currentStep ?? this.currentStep,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      issues: issues ?? this.issues,
      faceSizeRatio: faceSizeRatio ?? this.faceSizeRatio,
      headTiltAngle: headTiltAngle ?? this.headTiltAngle,
      hasGlasses: hasGlasses ?? this.hasGlasses,
      brightness: brightness ?? this.brightness,
      sharpness: sharpness ?? this.sharpness,
      capturedImage: capturedImage ?? this.capturedImage,
      finalPhoto: finalPhoto ?? this.finalPhoto,
    );
  }
}
