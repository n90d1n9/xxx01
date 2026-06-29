// build.yaml
targets:
  $default:
    builders:
      flavor_config_generator:
        options:
          flavors:
            - dev
            - staging
            - prod

// lib/core/config/flavor_config.dart
import 'package:flutter/foundation.dart';

enum Flavor { dev, staging, prod }

class FlavorConfig {
  static late Flavor _currentFlavor;
  
  static void setFlavor(Flavor flavor) {
    _currentFlavor = flavor;
  }

  static Flavor get currentFlavor => _currentFlavor;

  static bool get isDev => _currentFlavor == Flavor.dev;
  static bool get isStaging => _currentFlavor == Flavor.staging;
  static bool get isProd => _currentFlavor == Flavor.prod;
}

// lib/core/secrets/secret_manager.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecretManager {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static Future<void> storeSecret(String key, String value) async {
    final encryptionKey = await _getOrCreateEncryptionKey();
    final encryptedValue = _encryptValue(value, encryptionKey);
    await _secureStorage.write(key: key, value: encryptedValue);
  }

  static Future<String?> retrieveSecret(String key) async {
    final encryptionKey = await _getOrCreateEncryptionKey();
    final encryptedValue = await _secureStorage.read(key: key);
    
    return encryptedValue != null 
      ? _decryptValue(encryptedValue, encryptionKey)
      : null;
  }

  static Future<String> _getOrCreateEncryptionKey() async {
    const keyStorageKey = 'app_encryption_key';
    var storedKey = await _secureStorage.read(key: keyStorageKey);
    
    if (storedKey == null) {
      storedKey = _generateEncryptionKey();
      await _secureStorage.write(key: keyStorageKey, value: storedKey);
    }
    
    return storedKey;
  }

  static String _generateEncryptionKey() {
    return encrypt.Key.fromSecureRandom(32).base64;
  }

  static String _encryptValue(String value, String keyString) {
    final key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    final encrypted = encrypter.encrypt(value, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static String _decryptValue(String encryptedValue, String keyString) {
    final parts = encryptedValue.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);
    
    final key = encrypt.Key.fromBase64(keyString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    return encrypter.decrypt(encryptedData, iv: iv);
  }
}

// Flavor-specific configuration generator
class FlavorConfigGenerator {
  static Map<Flavor, Map<String, dynamic>> generateConfigs() {
    return {
      Flavor.dev: {
        'baseUrl': 'https://dev-api.example.com',
        'apiKey': 'dev_secret_key',
        'logLevel': 'debug',
      },
      Flavor.staging: {
        'baseUrl': 'https://staging-api.example.com',
        'apiKey': 'staging_secret_key',
        'logLevel': 'info',
      },
      Flavor.prod: {
        'baseUrl': 'https://api.example.com',
        'apiKey': 'prod_secret_key',
        'logLevel': 'error',
      }
    };
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect and set flavor based on build configuration
  Flavor flavor = _determineFlavor();
  FlavorConfig.setFlavor(flavor);

  // Store secrets securely
  final flavorConfigs = FlavorConfigGenerator.generateConfigs();
  final currentConfig = flavorConfigs[flavor]!;

  await SecretManager.storeSecret('base_url', currentConfig['baseUrl']);
  await SecretManager.storeSecret('api_key', currentConfig['apiKey']);

  runApp(MyApp(flavor: flavor));
}

Flavor _determineFlavor() {
  if (kDebugMode) return Flavor.dev;
  if (kProfileMode) return Flavor.staging;
  return Flavor.prod;
}
