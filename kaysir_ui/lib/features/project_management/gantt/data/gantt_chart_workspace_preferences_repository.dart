import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../services/gantt_chart_workspace_preferences_service.dart';

abstract class GanttChartWorkspacePreferencesSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbGanttChartWorkspacePreferencesSnapshotStore
    implements GanttChartWorkspacePreferencesSnapshotStore {
  static const defaultStorageKey = 'gantt.chart_workspace_preferences.v1';

  LocalDbGanttChartWorkspacePreferencesSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-gantt-chart-workspace-local',
  });

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  @override
  Future<Map<String, Object?>?> read() async {
    await _ensureInitialized();
    final stored = await LocalDBService.getPreference(key: storageKey);
    return _asJsonMap(stored);
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    await _ensureInitialized();
    await LocalDBService.savePreference(key: storageKey, value: snapshot);
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= LocalDBService.initialize(
      encryptionPassword: encryptionPassword,
    ).then((_) {});
  }
}

class MemoryGanttChartWorkspacePreferencesSnapshotStore
    implements GanttChartWorkspacePreferencesSnapshotStore {
  Map<String, Object?>? _snapshot;

  Map<String, Object?>? get snapshot {
    final value = _snapshot;
    if (value == null) return null;

    return Map<String, Object?>.unmodifiable(value);
  }

  @override
  Future<Map<String, Object?>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    _snapshot = Map<String, Object?>.unmodifiable(snapshot);
  }
}

class GanttChartWorkspacePreferencesRepository {
  const GanttChartWorkspacePreferencesRepository({required this.store});

  final GanttChartWorkspacePreferencesSnapshotStore store;

  Future<GanttChartWorkspacePreferences> load() async {
    final snapshot = await store.read();
    if (snapshot == null) return GanttChartWorkspacePreferences.initial;

    try {
      return GanttChartWorkspacePreferences.fromJson(snapshot);
    } catch (_) {
      return GanttChartWorkspacePreferences.initial;
    }
  }

  Future<void> save(GanttChartWorkspacePreferences preferences) async {
    await store.write(preferences.toJson());
  }

  Future<void> clear() async {
    await save(GanttChartWorkspacePreferences.initial);
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}
