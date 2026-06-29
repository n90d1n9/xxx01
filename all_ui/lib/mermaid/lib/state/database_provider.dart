import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/database_service.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  final db = DatabaseService();
  db.initialize();
  return db;
});
