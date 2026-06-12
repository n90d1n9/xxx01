import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../services/project_status_update_preferences_service.dart';

abstract class ProjectStatusUpdatePreferencesSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbProjectStatusUpdatePreferencesSnapshotStore
    implements ProjectStatusUpdatePreferencesSnapshotStore {
  static const defaultStorageKey =
      'project.status_update_preferences.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbProjectStatusUpdatePreferencesSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-project-status-update-local',
  });

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

class MemoryProjectStatusUpdatePreferencesSnapshotStore
    implements ProjectStatusUpdatePreferencesSnapshotStore {
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

class ProjectStatusUpdatePreferencesRepository {
  const ProjectStatusUpdatePreferencesRepository({required this.store});

  final ProjectStatusUpdatePreferencesSnapshotStore store;

  Future<ProjectStatusUpdatePreferences> load() async {
    final snapshot = await store.read();
    if (snapshot == null) return ProjectStatusUpdatePreferences.initial;

    try {
      return ProjectStatusUpdatePreferences.fromJson(snapshot);
    } catch (_) {
      return ProjectStatusUpdatePreferences.initial;
    }
  }

  Future<void> save(ProjectStatusUpdatePreferences preferences) async {
    await store.write(preferences.toJson());
  }

  Future<void> clear() async {
    await save(ProjectStatusUpdatePreferences.initial);
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}
