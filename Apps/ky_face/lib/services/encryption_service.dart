import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
