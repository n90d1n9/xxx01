import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

import 'cache_policy.dart';
import 'db_encryption.dart';
import 'encryption_service.dart';

final _logger = Logger('LocalDBService');

class LocalDBService {
  // Private constructor
  LocalDBService._();

  // Singleton instance
  static final LocalDBService instance = LocalDBService._();

  // Stores for different data types
  static final _sensitiveStore = intMapStoreFactory.store('secret_store');
  static final _preferenceStore = intMapStoreFactory.store('preference_store');
  static final _cacheStore = intMapStoreFactory.store('cache_store');

  // Database instance with lazy initialization
  static Database? _database;
  static Completer<Database>? _databaseCompleter;
  static String? _encryptionPassword;

  /// Initialize database with encryption
  static Future<Database> initialize({
    required String encryptionPassword,
    String dbName = 'app_database.db',
  }) async {
    if (_database != null) return _database!;
    if (_databaseCompleter != null) return _databaseCompleter!.future;

    _databaseCompleter = Completer<Database>();
    _encryptionPassword = encryptionPassword;

    try {
      // Determine database factory based on platform
      final dbFactory = kIsWeb ? databaseFactoryWeb : databaseFactoryIo;

      // Get database path
      final dbPath =
          kIsWeb
              ? dbName
              : path.join(
                (await getApplicationDocumentsDirectory()).path,
                dbName,
              );

      // Open encrypted database
      _database = await dbFactory.openDatabase(
        dbPath,
        codec: getXXTeaCodec(password: encryptionPassword),
      );

      _databaseCompleter!.complete(_database);
      return _database!;
    } catch (e, stackTrace) {
      _databaseCompleter!.completeError(e, stackTrace);
      _logger.severe('Database initialization failed', e, stackTrace);
      rethrow;
    }
  }

  /// Ensures database is initialized or throws an exception
  static Future<Database> _ensureInitialized() async {
    if (_database != null) return _database!;
    if (_databaseCompleter != null) return _databaseCompleter!.future;

    throw StateError(
      'Database not initialized. Call LocalDBService.initialize() first.',
    );
  }

  /// Save sensitive data
  static Future<void> saveSecret({
    required String key,
    required dynamic value,
  }) async {
    final db = await _ensureInitialized();
    await _sensitiveStore.record(key.hashCode).put(db, {
      'key': key,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Retrieve sensitive data
  static Future<dynamic> getSecret({required String key}) async {
    final db = await _ensureInitialized();
    final record = await _sensitiveStore.record(key.hashCode).get(db);
    return record?['value'];
  }

  /// Delete sensitive data
  static Future<void> deleteSecret({required String key}) async {
    final db = await _ensureInitialized();
    await _sensitiveStore.record(key.hashCode).delete(db);
  }

  /// Save non-sensitive preferences or settings
  static Future<void> savePreference({
    required String key,
    required dynamic value,
  }) async {
    try {
      final db = await _ensureInitialized();
      await _preferenceStore.record(key.hashCode).put(db, {
        'key': key,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      _logger.severe('Error saving preference', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieve non-sensitive preferences
  static Future<dynamic> getPreference({required String key}) async {
    try {
      final db = await _ensureInitialized();
      final record = await _preferenceStore.record(key.hashCode).get(db);
      return record?['value'];
    } catch (e, stackTrace) {
      _logger.severe('Error retrieving preference', e, stackTrace);
      return null;
    }
  }

  /// Cache data with advanced options
  static Future<void> cacheData({
    required String key,
    required dynamic value,
    Duration? expiration,
    bool encrypted = false,
  }) async {
    try {
      final db = await _ensureInitialized();

      // Prepare cache entry
      final cacheEntry = {
        'key': key,
        'value':
            encrypted
                ? EncryptionService.encrypt(
                  value.toString(),
                  EncryptionService.generateSecureKey(),
                )
                : value.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'expiration':
            (expiration ?? CachePolicy.defaultExpiration).inMilliseconds,
        'is_encrypted': encrypted,
      };

      // Store in cache
      await _cacheStore.record(key.hashCode).put(db, cacheEntry);
    } catch (e, stackTrace) {
      _logger.severe('Error caching data', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieve cached data with advanced validation
  static Future<dynamic> getCachedData({
    required String key,
    bool decryptIfNeeded = true,
  }) async {
    try {
      final db = await _ensureInitialized();
      final record = await _cacheStore.record(key.hashCode).get(db);

      if (record == null) return null;

      // Check expiration
      final timestamp = DateTime.parse(record['timestamp'] as String);
      final expirationMs = record['expiration'] as int;
      final expiration = Duration(milliseconds: expirationMs);

      // Validate cache
      if (!CachePolicy.isValid(timestamp, expiration)) {
        // Remove expired cache
        await _cacheStore.record(key.hashCode).delete(db);
        return null;
      }

      // Handle encrypted data if needed
      final value = record['value'];
      final isEncrypted = record['is_encrypted'] as bool? ?? false;

      if (isEncrypted && decryptIfNeeded) {
        return EncryptionService.decrypt(
          value as String,
          EncryptionService.generateSecureKey(),
        );
      }

      return value;
    } catch (e, stackTrace) {
      _logger.severe('Error retrieving cached data', e, stackTrace);
      return null;
    }
  }

  /// Clear specific cache entry
  static Future<void> clearCache({required String key}) async {
    try {
      final db = await _ensureInitialized();
      await _cacheStore.record(key.hashCode).delete(db);
    } catch (e, stackTrace) {
      _logger.severe('Error clearing cache', e, stackTrace);
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    try {
      final db = await _ensureInitialized();
      await _cacheStore.delete(db);
    } catch (e, stackTrace) {
      _logger.severe('Error clearing all cache', e, stackTrace);
    }
  }

  /// Perform periodic cache cleanup
  static Future<void> performCacheCleanup() async {
    try {
      final db = await _ensureInitialized();
      final records = await _cacheStore.find(db);

      for (final record in records) {
        final timestamp = DateTime.parse(record['timestamp'] as String);
        final expirationMs = record['expiration'] as int;
        final expiration = Duration(milliseconds: expirationMs);

        if (!CachePolicy.isValid(timestamp, expiration)) {
          await _cacheStore.record(record.key).delete(db);
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('Cache cleanup failed', e, stackTrace);
    }
  }

  /// Close the database (for testing or cleanup)
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _databaseCompleter = null;
    }
  }
}
