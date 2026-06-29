import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:pointycastle/export.dart';

class EncryptionService {
  static final _secureRandom = FortunaRandom();

  /// Initialize secure random generator
  static void _initSecureRandom() {
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (var i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(256));
    }
    _secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  }

  /// Generate a cryptographically secure random key
  static String generateSecureKey({int length = 32}) {
    _initSecureRandom();
    final random = List<int>.generate(length, (i) => _secureRandom.nextUint8());
    return base64Encode(random);
  }

  /// Generate a secure random IV (Initialization Vector)
  static String generateIV({int length = 16}) {
    _initSecureRandom();
    final random = List<int>.generate(length, (i) => _secureRandom.nextUint8());
    return base64Encode(random);
  }

  /// Derive a key from a password using PBKDF2
  static Uint8List deriveKey({
    required String password,
    required String salt,
    int iterations = 100000,
    int keyLength = 32,
  }) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(
        Pbkdf2Parameters(
          Uint8List.fromList(utf8.encode(salt)),
          iterations,
          keyLength,
        ),
      );

    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Encrypt data using AES-256-CBC with PBKDF2 key derivation
  static String encrypt(String data, String key) {
    try {
      // Generate a random salt and IV
      final salt = generateSecureKey(length: 16);
      final iv = encryption.IV.fromBase64(generateIV());

      // Derive the encryption key
      final derivedKey = deriveKey(password: key, salt: salt);
      final encrypter = encryption.Encrypter(
        encryption.AES(
          encryption.Key(derivedKey),
          mode: encryption.AESMode.cbc,
        ),
      );

      // Encrypt the data
      final encrypted = encrypter.encrypt(data, iv: iv);

      // Combine salt, IV and encrypted data into a single string
      return base64Encode(
        utf8.encode('$salt:${iv.base64}:${encrypted.base64}'),
      );
    } catch (e) {
      throw EncryptionException('Encryption failed: $e');
    }
  }

  /// Decrypt data encrypted with the above method
  static String decrypt(String encryptedData, String key) {
    try {
      // Split the combined string into its components
      final decoded = utf8.decode(base64Decode(encryptedData));
      final parts = decoded.split(':');
      if (parts.length != 3) {
        throw EncryptionException('Invalid encrypted data format');
      }

      final salt = parts[0];
      final iv = encryption.IV.fromBase64(parts[1]);
      final encryptedText = parts[2];

      // Derive the same key used for encryption
      final derivedKey = deriveKey(password: key, salt: salt);
      final encrypter = encryption.Encrypter(
        encryption.AES(
          encryption.Key(derivedKey),
          mode: encryption.AESMode.cbc,
        ),
      );

      // Decrypt the data
      return encrypter.decrypt(
        encryption.Encrypted.fromBase64(encryptedText),
        iv: iv,
      );
    } catch (e) {
      throw EncryptionException('Decryption failed: $e');
    }
  }

  /// Verify encrypted data by decrypting and comparing
  static bool verify(String data, String key, String encryptedData) {
    try {
      return data == decrypt(encryptedData, key);
    } catch (_) {
      return false;
    }
  }

  /// Create a cryptographic hash of data (for verification without decryption)
  static String createHash(String data, {String? salt}) {
    salt ??= generateSecureKey(length: 16);
    final bytes = utf8.encode(data + salt);
    final digest = sha512.convert(bytes);
    return '$salt:${base64Encode(digest.bytes)}';
  }

  /// Verify data against a stored hash
  static bool verifyHash(String data, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;
      final salt = parts[0];
      final newHash = createHash(data, salt: salt);
      return newHash == storedHash;
    } catch (_) {
      return false;
    }
  }
}

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
