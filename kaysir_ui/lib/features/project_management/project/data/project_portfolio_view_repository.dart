import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../services/project_portfolio_view_service.dart';

abstract class ProjectPortfolioViewSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbProjectPortfolioViewSnapshotStore
    implements ProjectPortfolioViewSnapshotStore {
  static const defaultStorageKey = 'project.portfolio_view.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbProjectPortfolioViewSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-project-portfolio-view-local',
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

class MemoryProjectPortfolioViewSnapshotStore
    implements ProjectPortfolioViewSnapshotStore {
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

class ProjectPortfolioViewRepository {
  const ProjectPortfolioViewRepository({required this.store});

  final ProjectPortfolioViewSnapshotStore store;

  Future<ProjectPortfolioViewPreferences> load() async {
    final snapshot = await store.read();
    if (snapshot == null) return ProjectPortfolioViewPreferences.initial;

    try {
      return ProjectPortfolioViewPreferences.fromJson(snapshot);
    } catch (_) {
      return ProjectPortfolioViewPreferences.initial;
    }
  }

  Future<void> save(ProjectPortfolioViewPreferences preferences) async {
    await store.write(preferences.toJson());
  }

  Future<void> clear() async {
    await save(ProjectPortfolioViewPreferences.initial);
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}
