import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import '../models/auth_attempt.dart';
import '../models/face_template.dart';
import 'encryption_service.dart';

class DatabaseService {
  static const String _dbName = 'face_auth.db';
  static const String _faceTemplatesStore = 'face_templates';
  static const String _authAttemptsStore = 'auth_attempts';
  static const String _settingsStore = 'settings';

  Database? _db;
  final EncryptionService _encryption;

  DatabaseService(this._encryption);

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  // Face Templates
  Future<void> saveFaceTemplate(FaceTemplate template) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);

    final jsonData = jsonEncode(template.toJson());
    final encryptedData = await _encryption.encrypt(jsonData);

    await store.record(template.id).put(db, {
      'data': encryptedData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<FaceTemplate?> getFaceTemplate(String id) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);

    final record = await store.record(id).get(db);
    if (record == null) return null;

    final decryptedData = await _encryption.decrypt(record['data'] as String);
    final jsonData = jsonDecode(decryptedData);

    return FaceTemplate.fromJson(jsonData);
  }

  Future<List<FaceTemplate>> getAllFaceTemplates() async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);

    final records = await store.find(db);
    final templates = <FaceTemplate>[];

    for (final record in records) {
      try {
        final decryptedData = await _encryption.decrypt(
          record.value['data'] as String,
        );
        final jsonData = jsonDecode(decryptedData);
        templates.add(FaceTemplate.fromJson(jsonData));
      } catch (e) {
        print('Error decrypting template: $e');
      }
    }

    return templates;
  }

  Future<void> deleteFaceTemplate(String id) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_faceTemplatesStore);
    await store.record(id).delete(db);
  }

  // Auth Attempts
  Future<void> saveAuthAttempt(AuthAttempt attempt) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_authAttemptsStore);

    final jsonData = jsonEncode(attempt.toJson());
    final encryptedData = await _encryption.encrypt(jsonData);

    await store.record(attempt.id).put(db, {
      'data': encryptedData,
      'timestamp': attempt.timestamp.toIso8601String(),
    });

    // Keep only last 100 attempts
    await _cleanupOldAttempts();
  }

  Future<List<AuthAttempt>> getRecentAuthAttempts({int limit = 10}) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_authAttemptsStore);

    final finder = Finder(
      sortOrders: [SortOrder('timestamp', false)],
      limit: limit,
    );

    final records = await store.find(db, finder: finder);
    final attempts = <AuthAttempt>[];

    for (final record in records) {
      try {
        final decryptedData = await _encryption.decrypt(
          record.value['data'] as String,
        );
        final jsonData = jsonDecode(decryptedData);
        attempts.add(AuthAttempt.fromJson(jsonData));
      } catch (e) {
        print('Error decrypting attempt: $e');
      }
    }

    return attempts;
  }

  Future<void> _cleanupOldAttempts() async {
    final db = await database;
    final store = stringMapStoreFactory.store(_authAttemptsStore);

    final finder = Finder(
      sortOrders: [SortOrder('timestamp', false)],
      offset: 100,
    );

    await store.delete(db, finder: finder);
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_settingsStore);

    final jsonData = jsonEncode({'value': value});
    final encryptedData = await _encryption.encrypt(jsonData);

    await store.record(key).put(db, {
      'data': encryptedData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<T?> getSetting<T>(String key) async {
    final db = await database;
    final store = stringMapStoreFactory.store(_settingsStore);

    final record = await store.record(key).get(db);
    if (record == null) return null;

    try {
      final decryptedData = await _encryption.decrypt(record['data'] as String);
      final jsonData = jsonDecode(decryptedData);
      return jsonData['value'] as T?;
    } catch (e) {
      print('Error decrypting setting: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    final db = await database;
    final store = stringMapStoreFactory.store(_settingsStore);

    final records = await store.find(db);
    final settings = <String, dynamic>{};

    for (final record in records) {
      try {
        final decryptedData = await _encryption.decrypt(
          record.value['data'] as String,
        );
        final jsonData = jsonDecode(decryptedData);
        settings[record.key] = jsonData['value'];
      } catch (e) {
        print('Error decrypting setting: $e');
      }
    }

    return settings;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.close();

    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);
    final file = File(dbPath);

    if (await file.exists()) {
      await file.delete();
    }

    _db = null;
  }
}
