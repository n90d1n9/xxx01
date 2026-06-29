import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureDBService {
  // Private constructor to prevent external instantiation.
  SecureDBService._privateConstructor();

  // The single instance of the class.
  static final SecureDBService _instance =
      SecureDBService._privateConstructor();

  // Factory constructor returns the single instance.
  factory SecureDBService() {
    return _instance;
  }

  // Helper methods for platform-specific options.
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  static IOSOptions _getIOSOptions() => const IOSOptions(
        // For example, setting the accessibility to first_unlock.
        accessibility: KeychainAccessibility.first_unlock,
      );

  // Returns macOS-specific options.
  static MacOsOptions _getMacOsOptions() => const MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );

  // Returns Windows-specific options.
  static WindowsOptions _getWindowsOptions() => const WindowsOptions(
      // Add any Windows-specific options here.
      );

  // Returns Linux-specific options.
  static LinuxOptions _getLinuxOptions() => const LinuxOptions();
  // Returns Web-specific options.
  static WebOptions _getWebOptions() => const WebOptions(
      // Add any Web-specific options here.
      );

  // Create the FlutterSecureStorage instance with dynamic options.
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    // If not running on web and the platform is Android, set AndroidOptions.
    aOptions: (!kIsWeb && Platform.isAndroid)
        ? _getAndroidOptions()
        : AndroidOptions.defaultOptions,
    // If not running on web and the platform is iOS, set IOSOptions.
    iOptions: (!kIsWeb && Platform.isIOS)
        ? _getIOSOptions()
        : IOSOptions.defaultOptions,
    // For web or other platforms, you can set specific options if needed.
    mOptions: (!kIsWeb && Platform.isMacOS)
        ? _getMacOsOptions()
        : MacOsOptions.defaultOptions,
    wOptions: (!kIsWeb && Platform.isWindows)
        ? _getWindowsOptions()
        : WindowsOptions.defaultOptions,
    lOptions: (!kIsWeb && Platform.isLinux)
        ? _getLinuxOptions()
        : LinuxOptions.defaultOptions,
    webOptions: kIsWeb ? _getWebOptions() : WebOptions.defaultOptions,
  );

  //final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  // The FlutterSecureStorage instance used to perform secure storage operations.
  //final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Writes a key-value pair to the secure storage.
  static Future<void> write(
      {required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  // An explicit update method (optional, as write() overwrites existing data).
  static Future<void> update(
      {required String key, required String newValue}) async {
    // Simply call write to update the value for the key.
    await _secureStorage.write(key: key, value: newValue);
  }

  // Reads the value associated with the provided key.
  static Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  // Reads all key-value pairs from the secure storage.
  static Future<Map<String, String>> readAll() async {
    return await _secureStorage.readAll();
  }

  // Deletes the value associated with the provided key.
  static Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  // Deletes the value associated with the provided key.
  static Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}
