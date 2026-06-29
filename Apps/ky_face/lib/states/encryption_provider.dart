import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/face_auth_state.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import 'face_auth_provider.dart';

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final encryption = ref.watch(encryptionServiceProvider);
  return DatabaseService(encryption);
});

final faceAuthProvider =
    StateNotifierProvider<EnhancedFaceAuthNotifier, FaceAuthState>((ref) {
      return EnhancedFaceAuthNotifier(
        ref.read(faceAuthServiceProvider),
        ref.read(databaseServiceProvider),
      );
    });
