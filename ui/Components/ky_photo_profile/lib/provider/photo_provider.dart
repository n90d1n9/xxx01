import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PhotoNotifier extends StateNotifier<PhotoVerificationState> {
  PhotoNotifier()
    : super(PhotoVerificationState(status: PhotoVerificationStatus.notStarted));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> verifyPhoto(ProfilePhoto photo) async {
    state = state.copyWith(
      status: PhotoVerificationStatus.processing,
      photo: photo,
    );

    try {
      // Additional validation
      final isValid = _validatePhoto(photo);

      if (isValid) {
        // Save photo reference securely
        await _savePhotoReference(photo);

        state = state.copyWith(
          status: PhotoVerificationStatus.verified,
          confidence: 1.0,
        );
      } else {
        state = state.copyWith(
          status: PhotoVerificationStatus.failed,
          errorMessage: 'Foto tidak memenuhi standar',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PhotoVerificationStatus.failed,
        errorMessage: 'Verifikasi gagal: $e',
      );
    }
  }

  bool _validatePhoto(ProfilePhoto photo) {
    // Check confidence score
    if (photo.confidence < 0.7) return false;

    // Additional validation rules
    return true;
  }

  Future<void> _savePhotoReference(ProfilePhoto photo) async {
    await _storage.write(key: 'profile_photo_path', value: photo.path);
  }

  Future<String?> getSavedPhotoPath() async {
    return await _storage.read(key: 'profile_photo_path');
  }

  void reset() {
    state = PhotoVerificationState(status: PhotoVerificationStatus.notStarted);
  }
}

final photoProvider =
    StateNotifierProvider<PhotoNotifier, PhotoVerificationState>((ref) {
      return PhotoNotifier();
    });
