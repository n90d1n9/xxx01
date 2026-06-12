import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../services/project_delivery_command_view_service.dart';

abstract class ProjectDeliveryCommandViewSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbProjectDeliveryCommandViewSnapshotStore
    implements ProjectDeliveryCommandViewSnapshotStore {
  static const defaultStorageKey = 'project.delivery_command_view.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbProjectDeliveryCommandViewSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-project-command-view-local',
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

class MemoryProjectDeliveryCommandViewSnapshotStore
    implements ProjectDeliveryCommandViewSnapshotStore {
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

class ProjectDeliveryCommandViewRepository {
  const ProjectDeliveryCommandViewRepository({required this.store});

  final ProjectDeliveryCommandViewSnapshotStore store;

  Future<ProjectDeliveryCommandViewPreferences> load() async {
    final snapshot = await store.read();
    if (snapshot == null) return ProjectDeliveryCommandViewPreferences.initial;

    try {
      return ProjectDeliveryCommandViewPreferences.fromJson(snapshot);
    } catch (_) {
      return ProjectDeliveryCommandViewPreferences.initial;
    }
  }

  Future<void> save(ProjectDeliveryCommandViewPreferences preferences) async {
    await store.write(preferences.toJson());
  }

  Future<void> clear() async {
    await save(ProjectDeliveryCommandViewPreferences.initial);
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}
