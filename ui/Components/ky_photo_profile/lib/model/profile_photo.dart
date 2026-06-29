import 'dart:io';
import 'dart:ui';

class ProfilePhoto {
  final String id;
  final String path;
  final DateTime capturedAt;
  final Rect? faceRect;
  final double confidence;
  final Map<String, dynamic> metadata;

  ProfilePhoto({
    required this.id,
    required this.path,
    required this.capturedAt,
    this.faceRect,
    required this.confidence,
    this.metadata = const {},
  });

  factory ProfilePhoto.fromFile(
    File file, {
    Rect? faceRect,
    double confidence = 1.0,
  }) {
    return ProfilePhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: file.path,
      capturedAt: DateTime.now(),
      faceRect: faceRect,
      confidence: confidence,
    );
  }
}
