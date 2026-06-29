import 'package:flutter_riverpod/legacy.dart';

import 'schema_version.dart';

class SchemaVersionsNotifier extends StateNotifier<List<SchemaVersion>> {
  SchemaVersionsNotifier() : super([]);
  void addVersion(SchemaVersion version) {
    state = [...state, version];
  }

  void restoreVersion(int version) {
    final targetVersion = state.where((v) => v.version == version).firstOrNull;
    if (targetVersion != null) {}
  }
}
