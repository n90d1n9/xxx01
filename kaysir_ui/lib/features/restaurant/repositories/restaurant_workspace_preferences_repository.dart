import 'package:kaysir/services/local_database/local_storage_service.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

abstract class RestaurantWorkspacePreferencesSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbRestaurantWorkspacePreferencesSnapshotStore
    implements RestaurantWorkspacePreferencesSnapshotStore {
  LocalDbRestaurantWorkspacePreferencesSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-restaurant-workspace-local',
  });

  static const defaultStorageKey = 'restaurant.workspace_preferences.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  @override
  Future<Map<String, Object?>?> read() async {
    try {
      await _ensureInitialized();
      return _asJsonMap(await LocalDBService.getPreference(key: storageKey));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    try {
      await _ensureInitialized();
      await LocalDBService.savePreference(key: storageKey, value: snapshot);
    } catch (_) {
      return;
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= LocalDBService.initialize(
      encryptionPassword: encryptionPassword,
    ).then((_) {}).catchError((_) {});
  }
}

class MemoryRestaurantWorkspacePreferencesSnapshotStore
    implements RestaurantWorkspacePreferencesSnapshotStore {
  MemoryRestaurantWorkspacePreferencesSnapshotStore({
    Map<String, Object?>? initialSnapshot,
  }) : _snapshot = _immutableSnapshot(initialSnapshot);

  Map<String, Object?>? _snapshot;

  Map<String, Object?>? get snapshot => _immutableSnapshot(_snapshot);

  @override
  Future<Map<String, Object?>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    _snapshot = Map<String, Object?>.unmodifiable(snapshot);
  }
}

class RestaurantWorkspacePreferencesRepository {
  const RestaurantWorkspacePreferencesRepository({required this.store});

  factory RestaurantWorkspacePreferencesRepository.local() {
    return RestaurantWorkspacePreferencesRepository(
      store: LocalDbRestaurantWorkspacePreferencesSnapshotStore(),
    );
  }

  final RestaurantWorkspacePreferencesSnapshotStore store;

  Future<RestaurantWorkspacePreferences> load() async {
    final snapshot = await store.read();
    if (snapshot == null) return const RestaurantWorkspacePreferences();

    return RestaurantWorkspacePreferences.fromJson(snapshot);
  }

  Future<void> save(RestaurantWorkspacePreferences preferences) async {
    await store.write(preferences.toJson());
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is! Map) return null;

  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

Map<String, Object?>? _immutableSnapshot(Map<String, Object?>? snapshot) {
  if (snapshot == null) return null;
  return Map<String, Object?>.unmodifiable(snapshot);
}
