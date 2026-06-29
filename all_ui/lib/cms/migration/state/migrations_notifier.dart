import 'package:flutter_riverpod/legacy.dart';

import '../../schema/model/schema_migration.dart';
import '../model/migration_status.dart';

class MigrationsNotifier extends StateNotifier<List<SchemaMigration>> {
  MigrationsNotifier() : super([]);
  void addMigration(SchemaMigration migration) {
    state = [...state, migration];
  }

  void updateMigrationStatus(String id, MigrationStatus status) {
    state =
        state.map((m) => m.id == id ? m.copyWith(status: status) : m).toList();
  }

  void clear() {
    state = [];
  }
}
