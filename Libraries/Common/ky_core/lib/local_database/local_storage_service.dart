import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
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
  static const String _cacheVersionKey = 'cache_schema_version';
  static const int _currentCacheVersion = 1;

  // Stores for different data types
  static final _sensitiveStore = intMapStoreFactory.store('secret_store');
  static final _preferenceStore = intMapStoreFactory.store('preference_store');
  static final _cacheStore = intMapStoreFactory.store('cache_store');

  // Database instance with lazy initialization
  static Database? _database;
  static Completer<Database>? _databaseCompleter;
  static String? _cacheEncryptionKey;
  static Timer? _cleanupTimer;
  static int _cacheHits = 0;
  static int _cacheMisses = 0;

  /// Initialize database with encryption
  static Future<Database> initialize({
    required String encryptionPassword,
    String dbName = 'app_database.db',
  }) async {
    if (_database != null) return _database!;
    if (_databaseCompleter != null) return _databaseCompleter!.future;

    _databaseCompleter = Completer<Database>();
    _cacheEncryptionKey = encryptionPassword;

    try {
      // Determine database factory based on platform
      final dbFactory = kIsWeb ? databaseFactoryWeb : databaseFactoryIo;

      // Get database path
      String docsPath;
      try {
        if (kIsWeb) {
          docsPath = '';
        } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          docsPath = Directory.current.path;
        } else {
          docsPath = (await getApplicationDocumentsDirectory()).path;
        }
      } catch (e) {
        // Fallback for path binding crash
        _logger.warning('Failed to get docs path, falling back to current dir');
        docsPath = kIsWeb ? '' : Directory.current.path;
      }
      final dbPath = kIsWeb ? dbName : path.join(docsPath, dbName);

      // Try to open encrypted database, if it fails, delete and recreate
      try {
        _database = await dbFactory.openDatabase(
          dbPath,
          codec: getXXTeaCodec(password: encryptionPassword),
        );
      } catch (e) {
        // If database corruption or codec mismatch, delete and recreate
        _logger.warning('Database corruption detected, recreating...');
        await dbFactory.deleteDatabase(dbPath);
        _database = await dbFactory.openDatabase(
          dbPath,
          codec: getXXTeaCodec(password: encryptionPassword),
        );
      }

      _databaseCompleter!.complete(_database);

      // Ensure cache version is initialized after DB open.
      await _ensureCacheVersion();
      return _database!;
    } catch (e, stackTrace) {
      final completer = _databaseCompleter!;
      _databaseCompleter = null;
      if (!completer.isCompleted) {
        completer.completeError(e, stackTrace);
      }
      _logger.severe('Database initialization failed', e, stackTrace);
      rethrow;
    }
  }

  /// Initialize database only if needed (safe to call multiple times).
  static Future<Database> initializeIfNeeded({
    required String encryptionPassword,
    String dbName = 'app_database.db',
  }) async {
    if (_database != null || _databaseCompleter != null) {
      return _ensureInitialized();
    }
    return initialize(encryptionPassword: encryptionPassword, dbName: dbName);
  }

  /// Ensures database is initialized or throws an exception
  static Future<Database> _ensureInitialized() async {
    if (_database != null) return _database!;
    if (_databaseCompleter != null) return _databaseCompleter!.future;

    throw StateError(
      'Database not initialized. Call LocalDBService.initialize() first.',
    );
  }

  static Future<void> _ensureCacheVersion() async {
    final db = await _ensureInitialized();
    final record = await _preferenceStore.record(_cacheVersionKey.hashCode).get(db);
    if (record == null) {
      await _preferenceStore.record(_cacheVersionKey.hashCode).put(db, {
        'key': _cacheVersionKey,
        'value': _currentCacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Returns whether cache schema migration was performed.
  static Future<bool> migrateCacheIfNeeded({
    required int targetVersion,
    bool clearOnMismatch = true,
  }) async {
    try {
      final db = await _ensureInitialized();
      final record = await _preferenceStore
          .record(_cacheVersionKey.hashCode)
          .get(db);
      final current = record?['value'] as int? ?? _currentCacheVersion;
      if (current >= targetVersion) {
        return false;
      }
      if (clearOnMismatch) {
        await _cacheStore.delete(db);
      }
      await _preferenceStore.record(_cacheVersionKey.hashCode).put(db, {
        'key': _cacheVersionKey,
        'value': targetVersion,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Cache migration failed', e, stackTrace);
      return false;
    }
  }

  /// Lightweight DB health check.
  static Future<bool> health() async {
    try {
      final db = await _ensureInitialized();
      await _preferenceStore
          .record('__health__'.hashCode)
          .put(db, {'ok': true, 'ts': DateTime.now().toIso8601String()});
      return true;
    } catch (e, stackTrace) {
      _logger.severe('DB health check failed', e, stackTrace);
      return false;
    }
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

  /// Save JSON preference
  static Future<void> saveJsonPreference({
    required String key,
    required Object value,
  }) async {
    await savePreference(key: key, value: jsonEncode(value));
  }

  /// Retrieve JSON preference
  static Future<T?> getJsonPreference<T>({
    required String key,
    required T Function(dynamic json) parser,
  }) async {
    final raw = await getPreference(key: key);
    if (raw == null) return null;
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      return parser(decoded);
    } catch (e, stackTrace) {
      _logger.severe('Error decoding preference JSON', e, stackTrace);
      return null;
    }
  }

  /// Cache data with advanced options
  static Future<void> cacheData({
    required String key,
    required dynamic value,
    Duration? expiration,
    bool encrypted = false,
    String? encryptionKey,
    int? schemaVersion,
    String? namespace,
    int? maxValueBytes,
    int? maxNamespaceBytes,
    int? maxTotalBytes,
    bool pinned = false,
    int priority = 1,
  }) async {
    try {
      final db = await _ensureInitialized();
      final effectiveKey = encryptionKey ?? _cacheEncryptionKey;
      if (encrypted && (effectiveKey == null || effectiveKey.isEmpty)) {
        throw StateError('Encryption key is not initialized.');
      }

      // Prepare cache entry
      final valueString = encrypted
          ? EncryptionService.encrypt(
              value.toString(),
              effectiveKey!,
            )
          : value.toString();
      final bytes = utf8.encode(valueString).length;
      final maxBytes = maxValueBytes ?? 0;
      if (maxBytes > 0 && bytes > maxBytes) {
        _logger.warning(
          'Cache value exceeds max bytes ($bytes > $maxBytes). Skipping key: $key',
        );
        return;
      }

      final cacheEntry = {
        'key': key,
        'value': valueString,
        'timestamp': DateTime.now().toIso8601String(),
        'expiration':
            (expiration ?? CachePolicy.defaultExpiration).inMilliseconds,
        'is_encrypted': encrypted,
        'schema_version': schemaVersion ?? _currentCacheVersion,
        'namespace': namespace ?? 'default',
        'size_bytes': bytes,
        'pinned': pinned,
        'priority': priority,
      };

      // Store in cache
      await _cacheStore.record(key.hashCode).put(db, cacheEntry);

      // Enforce namespace size budget if provided.
      if (maxNamespaceBytes != null && maxNamespaceBytes > 0) {
        await _enforceNamespaceBudget(
          db,
          namespace ?? 'default',
          maxNamespaceBytes,
        );
      }

      // Enforce global size budget if provided.
      if (maxTotalBytes != null && maxTotalBytes > 0) {
        await _enforceGlobalBudget(db, maxTotalBytes);
      }
    } catch (e, stackTrace) {
      _logger.severe('Error caching data', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieve cached data with advanced validation
  static Future<dynamic> getCachedData({
    required String key,
    bool decryptIfNeeded = true,
    String? encryptionKey,
    int? schemaVersion,
    String? namespace,
    bool cleanupExpired = true,
  }) async {
    try {
      final db = await _ensureInitialized();
      final record = await _cacheStore.record(key.hashCode).get(db);

      if (record == null) {
        _cacheMisses += 1;
        return null;
      }

      final entryNamespace = record['namespace']?.toString() ?? 'default';
      final expectedNamespace = namespace ?? 'default';
      if (entryNamespace != expectedNamespace) {
        await _cacheStore.record(key.hashCode).delete(db);
        _cacheMisses += 1;
        return null;
      }

      final entrySchema = record['schema_version'] as int? ?? _currentCacheVersion;
      final expectedSchema = schemaVersion ?? _currentCacheVersion;
      if (entrySchema != expectedSchema) {
        await _cacheStore.record(key.hashCode).delete(db);
        _cacheMisses += 1;
        return null;
      }

      // Check expiration
      final timestamp = DateTime.parse(record['timestamp'] as String);
      final expirationMs = record['expiration'] as int;
      final expiration = Duration(milliseconds: expirationMs);

      // Validate cache
      if (!CachePolicy.isValid(timestamp, expiration)) {
        // Remove expired cache
        if (cleanupExpired) {
          await _cacheStore.record(key.hashCode).delete(db);
        }
        _cacheMisses += 1;
        return null;
      }

      // Handle encrypted data if needed
      final value = record['value'];
      final isEncrypted = record['is_encrypted'] as bool? ?? false;

      if (isEncrypted && decryptIfNeeded) {
        final effectiveKey = encryptionKey ?? _cacheEncryptionKey;
        if (effectiveKey == null || effectiveKey.isEmpty) {
          _cacheMisses += 1;
          throw StateError('Encryption key is not initialized.');
        }
        try {
          final decrypted = EncryptionService.decrypt(value as String, effectiveKey);
          _cacheHits += 1;
          return decrypted;
        } catch (e) {
          // If decryption fails, treat as stale and clear entry.
          await _cacheStore.record(key.hashCode).delete(db);
          _cacheMisses += 1;
          return null;
        }
      }

      _cacheHits += 1;
      return value;
    } catch (e, stackTrace) {
      _logger.severe('Error retrieving cached data', e, stackTrace);
      _cacheMisses += 1;
      return null;
    }
  }

  /// Retrieve raw cache record (optionally allow expired data).
  static Future<Map<String, dynamic>?> getCacheRecord({
    required String key,
    bool decryptIfNeeded = true,
    String? encryptionKey,
    int? schemaVersion,
    String? namespace,
    bool allowExpired = false,
    bool cleanupExpired = true,
  }) async {
    try {
      final db = await _ensureInitialized();
      final record = await _cacheStore.record(key.hashCode).get(db);
      if (record == null) {
        _cacheMisses += 1;
        return null;
      }

      final entryNamespace = record['namespace']?.toString() ?? 'default';
      final expectedNamespace = namespace ?? 'default';
      if (entryNamespace != expectedNamespace) {
        _cacheMisses += 1;
        return null;
      }

      final entrySchema =
          record['schema_version'] as int? ?? _currentCacheVersion;
      final expectedSchema = schemaVersion ?? _currentCacheVersion;
      if (entrySchema != expectedSchema) {
        _cacheMisses += 1;
        return null;
      }

      final timestamp = DateTime.parse(record['timestamp'] as String);
      final expirationMs = record['expiration'] as int;
      final expiration = Duration(milliseconds: expirationMs);
      final isExpired = !CachePolicy.isValid(timestamp, expiration);
      if (isExpired && !allowExpired) {
        if (cleanupExpired) {
          await _cacheStore.record(key.hashCode).delete(db);
        }
        _cacheMisses += 1;
        return null;
      }

      dynamic value = record['value'];
      final isEncrypted = record['is_encrypted'] as bool? ?? false;
      if (isEncrypted && decryptIfNeeded) {
        final effectiveKey = encryptionKey ?? _cacheEncryptionKey;
        if (effectiveKey == null || effectiveKey.isEmpty) {
          _cacheMisses += 1;
          throw StateError('Encryption key is not initialized.');
        }
        try {
          value = EncryptionService.decrypt(value as String, effectiveKey);
        } catch (_) {
          if (cleanupExpired) {
            await _cacheStore.record(key.hashCode).delete(db);
          }
          _cacheMisses += 1;
          return null;
        }
      }

      _cacheHits += 1;
      return {
        ...record,
        'value': value,
        'is_expired': isExpired,
      };
    } catch (e, stackTrace) {
      _logger.severe('Error retrieving cache record', e, stackTrace);
      _cacheMisses += 1;
      return null;
    }
  }

  /// Cache JSON-serializable value.
  static Future<void> cacheJson({
    required String key,
    required Object value,
    Duration? expiration,
    bool encrypted = false,
    String? encryptionKey,
    int? schemaVersion,
    String? namespace,
    int? maxValueBytes,
    int? maxNamespaceBytes,
    int? maxTotalBytes,
    bool pinned = false,
    int priority = 1,
  }) async {
    await cacheData(
      key: key,
      value: jsonEncode(value),
      expiration: expiration,
      encrypted: encrypted,
      encryptionKey: encryptionKey,
      schemaVersion: schemaVersion,
      namespace: namespace,
      maxValueBytes: maxValueBytes,
      maxNamespaceBytes: maxNamespaceBytes,
      maxTotalBytes: maxTotalBytes,
      pinned: pinned,
      priority: priority,
    );
  }

  /// Retrieve cached JSON and parse using a mapper.
  static Future<T?> getCachedJson<T>({
    required String key,
    required T Function(dynamic json) parser,
    bool decryptIfNeeded = true,
    String? encryptionKey,
    int? schemaVersion,
    String? namespace,
    bool cleanupExpired = true,
  }) async {
    final raw = await getCachedData(
      key: key,
      decryptIfNeeded: decryptIfNeeded,
      encryptionKey: encryptionKey,
      schemaVersion: schemaVersion,
      namespace: namespace,
      cleanupExpired: cleanupExpired,
    );
    if (raw == null) return null;
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      return parser(decoded);
    } catch (e, stackTrace) {
      _logger.severe('Error decoding cached JSON', e, stackTrace);
      return null;
    }
  }

  /// Cache a typed value with unified options.
  static Future<void> cacheTyped<T>({
    required String key,
    required T value,
    CacheOptions options = const CacheOptions(),
    Object Function(T value)? encoder,
  }) async {
    final payload = encoder != null ? encoder(value) : value as Object;
    await cacheJson(
      key: key,
      value: payload,
      expiration: options.expiration,
      encrypted: options.encrypted,
      encryptionKey: options.encryptionKey,
      schemaVersion: options.schemaVersion,
      namespace: options.namespace,
      maxValueBytes: options.maxValueBytes,
      maxNamespaceBytes: options.maxNamespaceBytes,
      maxTotalBytes: options.maxTotalBytes,
      pinned: options.pinned,
      priority: options.priority,
    );
  }

  /// Retrieve a typed value with unified options.
  static Future<T?> getCachedTyped<T>({
    required String key,
    required T Function(dynamic json) decoder,
    CacheOptions options = const CacheOptions(),
  }) async {
    return getCachedJson(
      key: key,
      parser: decoder,
      decryptIfNeeded: options.decryptIfNeeded,
      encryptionKey: options.encryptionKey,
      schemaVersion: options.schemaVersion,
      namespace: options.namespace,
      cleanupExpired: options.cleanupExpired,
    );
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

  /// Clear cache entries for a specific namespace.
  static Future<void> clearCacheNamespace(String namespace) async {
    try {
      final db = await _ensureInitialized();
      final records = await _cacheStore.find(db);
      for (final record in records) {
        final entryNamespace = record.value['namespace']?.toString() ?? 'default';
        if (entryNamespace == namespace) {
          await _cacheStore.record(record.key).delete(db);
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('Error clearing cache namespace', e, stackTrace);
    }
  }

  /// Clear cache entries by key prefix within a namespace.
  static Future<int> clearCacheByPrefix({
    required String namespace,
    required String prefix,
  }) async {
    var removed = 0;
    try {
      final db = await _ensureInitialized();
      final records = await _cacheStore.find(db);
      for (final record in records) {
        final entryNamespace = record.value['namespace']?.toString() ?? 'default';
        if (entryNamespace != namespace) continue;
        final key = record.value['key']?.toString() ?? '';
        if (key.startsWith(prefix)) {
          await _cacheStore.record(record.key).delete(db);
          removed += 1;
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('Error clearing cache by prefix', e, stackTrace);
    }
    return removed;
  }

  /// Enforce LRU-style size budget within a namespace.
  static Future<void> _enforceNamespaceBudget(
    Database db,
    String namespace,
    int maxBytes,
  ) async {
    final records = await _cacheStore.find(db);
    final entries = records
        .where(
          (r) => (r.value['namespace']?.toString() ?? 'default') == namespace,
        )
        .toList();

    int totalBytes = 0;
    for (final entry in entries) {
      totalBytes += (entry.value['size_bytes'] as int?) ?? 0;
    }

    if (totalBytes <= maxBytes) {
      return;
    }

    // Sort by priority (low to high), then oldest first for LRU.
    entries.sort((a, b) {
      final pa = (a.value['priority'] as int?) ?? 1;
      final pb = (b.value['priority'] as int?) ?? 1;
      if (pa != pb) return pa.compareTo(pb);
      final ta = DateTime.tryParse(a.value['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final tb = DateTime.tryParse(b.value['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return ta.compareTo(tb);
    });

    for (final entry in entries) {
      if (totalBytes <= maxBytes) break;
      final pinned = entry.value['pinned'] as bool? ?? false;
      if (pinned) {
        continue;
      }
      final size = (entry.value['size_bytes'] as int?) ?? 0;
      await _cacheStore.record(entry.key).delete(db);
      totalBytes -= size;
    }
  }

  /// Enforce LRU-style global cache size budget.
  static Future<void> _enforceGlobalBudget(
    Database db,
    int maxBytes,
  ) async {
    final records = await _cacheStore.find(db);
    int totalBytes = 0;
    for (final record in records) {
      totalBytes += (record.value['size_bytes'] as int?) ?? 0;
    }

    if (totalBytes <= maxBytes) {
      return;
    }

    final entries = records.toList();
    entries.sort((a, b) {
      final pa = (a.value['priority'] as int?) ?? 1;
      final pb = (b.value['priority'] as int?) ?? 1;
      if (pa != pb) return pa.compareTo(pb);
      final ta = DateTime.tryParse(a.value['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final tb = DateTime.tryParse(b.value['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return ta.compareTo(tb);
    });

    for (final entry in entries) {
      if (totalBytes <= maxBytes) break;
      final pinned = entry.value['pinned'] as bool? ?? false;
      if (pinned) {
        continue;
      }
      final size = (entry.value['size_bytes'] as int?) ?? 0;
      await _cacheStore.record(entry.key).delete(db);
      totalBytes -= size;
    }
  }

  /// Get cache entry metadata without value (safe for diagnostics).
  static Future<Map<String, dynamic>?> getCacheEntryInfo({
    required String key,
    String? namespace,
  }) async {
    try {
      final db = await _ensureInitialized();
      final record = await _cacheStore.record(key.hashCode).get(db);
      if (record == null) return null;

      final entryNamespace = record['namespace']?.toString() ?? 'default';
      final expectedNamespace = namespace ?? 'default';
      if (entryNamespace != expectedNamespace) {
        return null;
      }

      return {
        'key': record['key'],
        'timestamp': record['timestamp'],
        'expiration': record['expiration'],
        'is_encrypted': record['is_encrypted'],
        'schema_version': record['schema_version'],
        'namespace': record['namespace'] ?? 'default',
        'size_bytes': record['size_bytes'] ?? 0,
      };
    } catch (e, stackTrace) {
      _logger.severe('Error reading cache entry info', e, stackTrace);
      return null;
    }
  }

  /// Cache hit/miss counters since app start (or last reset).
  static Map<String, int> getCacheHitMissStats() {
    return {'hits': _cacheHits, 'misses': _cacheMisses};
  }

  /// Reset cache hit/miss counters.
  static void resetCacheHitMissStats() {
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Get cache stats grouped by namespace.
  static Future<Map<String, Map<String, int>>> getCacheStatsByNamespace() async {
    try {
      final db = await _ensureInitialized();
      final records = await _cacheStore.find(db);
      final stats = <String, Map<String, int>>{};

      for (final record in records) {
        final ns = record.value['namespace']?.toString() ?? 'default';
        stats.putIfAbsent(ns, () => {'total': 0, 'active': 0, 'expired': 0});
        final bucket = stats[ns]!;
        bucket['total'] = (bucket['total'] ?? 0) + 1;

        final timestamp = DateTime.parse(record.value['timestamp'] as String);
        final expirationMs = record.value['expiration'] as int;
        final expiration = Duration(milliseconds: expirationMs);
        if (CachePolicy.isValid(timestamp, expiration)) {
          bucket['active'] = (bucket['active'] ?? 0) + 1;
        } else {
          bucket['expired'] = (bucket['expired'] ?? 0) + 1;
        }
      }
      return stats;
    } catch (e, stackTrace) {
      _logger.severe('Error computing cache stats by namespace', e, stackTrace);
      return {};
    }
  }

  /// Start periodic cache cleanup.
  static void startCacheCleanupScheduler({
    Duration interval = const Duration(hours: 6),
  }) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) {
      performCacheCleanup();
    });
  }

  /// Stop periodic cache cleanup.
  static void stopCacheCleanupScheduler() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Warm up cache by preloading a list of keys.
  static Future<Map<String, dynamic>> warmCache({
    required List<String> keys,
    String? namespace,
    int? schemaVersion,
    bool decryptIfNeeded = true,
  }) async {
    final results = <String, dynamic>{};
    for (final key in keys) {
      final value = await getCachedData(
        key: key,
        namespace: namespace,
        schemaVersion: schemaVersion,
        decryptIfNeeded: decryptIfNeeded,
      );
      if (value != null) {
        results[key] = value;
      }
    }
    return results;
  }

  /// Get cache stats (total/active/expired).
  static Future<Map<String, int>> getCacheStats() async {
    try {
      final db = await _ensureInitialized();
      final records = await _cacheStore.find(db);
      var total = 0;
      var active = 0;
      var expired = 0;

      for (final record in records) {
        total += 1;
        final timestamp = DateTime.parse(record.value['timestamp'] as String);
        final expirationMs = record.value['expiration'] as int;
        final expiration = Duration(milliseconds: expirationMs);
        if (CachePolicy.isValid(timestamp, expiration)) {
          active += 1;
        } else {
          expired += 1;
        }
      }

      return {'total': total, 'active': active, 'expired': expired};
    } catch (e, stackTrace) {
      _logger.severe('Error computing cache stats', e, stackTrace);
      return {'total': 0, 'active': 0, 'expired': 0};
    }
  }

  /// Extend cache expiration for a specific key.
  static Future<bool> touchCache({
    required String key,
    Duration? extendBy,
  }) async {
    try {
      final db = await _ensureInitialized();
      final record = await _cacheStore.record(key.hashCode).get(db);
      if (record == null) return false;

      final expirationMs = record['expiration'] as int;
      final currentExpiration = Duration(milliseconds: expirationMs);
      final newExpiration = currentExpiration + (extendBy ?? Duration.zero);

      final updated = Map<String, dynamic>.from(record);
      updated['timestamp'] = DateTime.now().toIso8601String();
      updated['expiration'] = newExpiration.inMilliseconds;
      await _cacheStore.record(key.hashCode).put(db, updated);
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error touching cache', e, stackTrace);
      return false;
    }
  }

  /// Remove encrypted cache entries that can no longer be decrypted.
  static Future<void> removeCorruptEncryptedCache({
    String? encryptionKey,
  }) async {
    try {
      final db = await _ensureInitialized();
      final records = await _cacheStore.find(db);
      final effectiveKey = encryptionKey ?? _cacheEncryptionKey;
      if (effectiveKey == null || effectiveKey.isEmpty) {
        return;
      }

      for (final record in records) {
        final value = record.value['value'];
        final isEncrypted = record.value['is_encrypted'] as bool? ?? false;
        if (!isEncrypted) {
          continue;
        }
        try {
          EncryptionService.decrypt(value as String, effectiveKey);
        } catch (_) {
          await _cacheStore.record(record.key).delete(db);
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('Corrupt cache cleanup failed', e, stackTrace);
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

  // Add these methods to your LocalDBService class
  static Future<Database> getDatabase() async {
    return await _ensureInitialized();
  }

  static Future<List<RecordSnapshot<int, Map<String, dynamic>>>>
  getCacheRecords() async {
    final db = await _ensureInitialized();
    return await _cacheStore.find(db);
  }

  static Future<List<RecordSnapshot<int, Map<String, dynamic>>>>
  getCacheRecordsByNamespace(String namespace) async {
    final db = await _ensureInitialized();
    final records = await _cacheStore.find(db);
    return records
        .where(
          (record) =>
              (record.value['namespace']?.toString() ?? 'default') == namespace,
        )
        .toList();
  }

  static Future<void> deleteCacheRecord(int key) async {
    final db = await _ensureInitialized();
    await _cacheStore.record(key).delete(db);
  }

  static Future<void> saveFavoritePosts(Set<String> favoriteIds) async {
    await LocalDBService.savePreference(
      key: 'favorite_posts',
      value: favoriteIds.toList(),
    );
  }

  static Future<Set<String>> getFavoritePosts() async {
    final favorites = await LocalDBService.getPreference(key: 'favorite_posts');
    if (favorites is List) {
      return Set<String>.from(favorites.cast<String>());
    }
    return <String>{};
  }
}
