import 'package:flutter_riverpod/legacy.dart';

import '../service/database_service.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  final db = DatabaseService();
  db.initialize();
  return db;
});
