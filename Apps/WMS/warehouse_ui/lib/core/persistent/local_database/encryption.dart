import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static late final Key _key;
  static late final IV _iv;
  static late final Encrypter _encrypter;
  static final _storage = const FlutterSecureStorage();

  static Future<void> init() async {
    // Generate or retrieve encryption key
    final keyString = await _storage.read(key: 'encryption_key');
    if (keyString == null) {
      _key = Key.fromSecureRandom(32);
      await _storage.write(
        key: 'encryption_key',
        value: base64Encode(_key.bytes),
      );
    } else {
      _key = Key(base64Decode(keyString));
    }

    _iv = IV.fromSecureRandom(16);
    _encrypter = Encrypter(AES(_key));
  }

  static String encrypt(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  static String decrypt(String encryptedData) {
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }
}
