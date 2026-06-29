import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;
  final _storage = const FlutterSecureStorage();

  Future<void> init() async {
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

  String encrypt(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  String decrypt(String encryptedData) {
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }
}
