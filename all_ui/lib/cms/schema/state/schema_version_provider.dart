// Provider for schema versions
import 'package:flutter_riverpod/legacy.dart';

import '../model/schema_version.dart';

final schemaVersionsProvider =
    StateNotifierProvider<SchemaVersionsNotifier, List<SchemaVersion>>((ref) {
      return SchemaVersionsNotifier();
    });

class SchemaVersionsNotifier extends StateNotifier<List<SchemaVersion>> {
  SchemaVersionsNotifier() : super([]);

  void addVersion(SchemaVersion version) {
    state = [...state, version];
  }

  void restoreVersion(int version) {
    final targetVersion = state.where((v) => v.version == version).firstOrNull;
    if (targetVersion != null) {
      // In real implementation, this would restore the schemas
    }
  }
}
