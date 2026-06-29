import 'dart:async';
import 'dart:io';
import 'package:golok/core/utils/config.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../../../features/auth/models/user.dart';
import 'encryption.dart';

class LocalDatabase {
  static Database? _database;
  // Key for encryption
  static String encryptionKey = "bismillah";

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  static Future<Database> _openDatabase() async {
    // Get a platform-specific directory where persistent app data can be stored
    Directory appDocDir = await getApplicationDocumentsDirectory();

    await appDocDir.create(recursive: true);

    String dbPath = join(appDocDir.path, dbName);
    final codec = getEncryptCodec(password: encryptionKey);

    // Initialize the encryption codec with a user password
    return await databaseFactoryIo.openDatabase(dbPath,
        version: 1, codec: codec);
  }

  Future<void> insertUser(User user) async {
    var store = StoreRef.main();
    await store
        .record('title')
        .add(database as DatabaseClient , 'Simple application');
  }

  static getEncryptCodec({required String password}) {
    return EncryptionService.encrypt(password);
  }
}
