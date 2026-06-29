import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

class EncryptionService {
  static String encryptAES(String message, String key) {
    try {
      final keyHash = sha256.convert(utf8.encode(key)).bytes;
      final keyParam = KeyParameter(
        Uint8List.fromList(keyHash.take(32).toList()),
      );

      final cipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESEngine()),
      );

      cipher.init(true, PaddedBlockCipherParameters(keyParam, null));
      final encrypted = cipher.process(utf8.encode(message));
      return base64.encode(encrypted);
    } catch (e) {
      return 'Error: $e';
    }
  }

  static String decryptAES(String encrypted, String key) {
    try {
      final keyHash = sha256.convert(utf8.encode(key)).bytes;
      final keyParam = KeyParameter(
        Uint8List.fromList(keyHash.take(32).toList()),
      );

      final cipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESEngine()),
      );

      cipher.init(false, PaddedBlockCipherParameters(keyParam, null));
      final decrypted = cipher.process(base64.decode(encrypted));
      return utf8.decode(decrypted);
    } catch (e) {
      return 'Decryption failed: $e';
    }
  }

  static String encryptXOR(String message, String key) {
    final bytes = utf8.encode(message);
    final keyBytes = utf8.encode(key);
    final encrypted = List.generate(
      bytes.length,
      (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64.encode(encrypted);
  }

  static String decryptXOR(String encrypted, String key) {
    try {
      final bytes = base64.decode(encrypted);
      final keyBytes = utf8.encode(key);
      final decrypted = List.generate(
        bytes.length,
        (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(decrypted);
    } catch (e) {
      return 'Decryption failed: $e';
    }
  }
}
