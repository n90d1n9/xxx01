import 'package:encrypt/encrypt.dart' as encrypt;

// Encryption Service
class EncryptionService {
  static final _key = encrypt.Key.fromLength(32);
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static String encryptMessage(String text) {
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  static String decryptMessage(String encrypted) {
    final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
    return decrypted;
  }
}
