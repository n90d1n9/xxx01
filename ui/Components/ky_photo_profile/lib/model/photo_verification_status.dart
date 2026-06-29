import 'profile_photo.dart';

enum PhotoVerificationStatus {
  notStarted,
  capturing,
  processing,
  verified,
  failed,
}

class PhotoVerificationState {
  final PhotoVerificationStatus status;
  final ProfilePhoto? photo;
  final String? errorMessage;
  final double confidence;

  PhotoVerificationState({
    required this.status,
    this.photo,
    this.errorMessage,
    this.confidence = 0.0,
  });

  PhotoVerificationState copyWith({
    PhotoVerificationStatus? status,
    ProfilePhoto? photo,
    String? errorMessage,
    double? confidence,
  }) {
    return PhotoVerificationState(
      status: status ?? this.status,
      photo: photo ?? this.photo,
      errorMessage: errorMessage,
      confidence: confidence ?? this.confidence,
    );
  }
}
