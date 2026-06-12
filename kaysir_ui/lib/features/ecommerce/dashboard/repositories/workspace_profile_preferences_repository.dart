import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/product_profile.dart';

class ProfilePreferences {
  final String selectedProfileId;

  const ProfilePreferences({required this.selectedProfileId});

  static final initial = ProfilePreferences(
    selectedProfileId: ProductProfile.standard.id,
  );

  factory ProfilePreferences.fromJson(Map<String, Object?> json) {
    final selectedProfileId = json['selectedProfileId']?.toString().trim();

    return ProfilePreferences(
      selectedProfileId:
          selectedProfileId == null || selectedProfileId.isEmpty
              ? initial.selectedProfileId
              : selectedProfileId,
    );
  }

  Map<String, Object?> toJson() {
    return {'selectedProfileId': selectedProfileId};
  }
}

abstract class ProfilePreferencesStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbProfilePreferencesStore implements ProfilePreferencesStore {
  static const defaultStorageKey = 'ecommerce.workspace.profile_preferences.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbProfilePreferencesStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-ecommerce-workspace-profile-local',
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

class MemoryProfilePreferencesStore implements ProfilePreferencesStore {
  Map<String, Object?>? _snapshot;

  MemoryProfilePreferencesStore({Map<String, Object?>? initialSnapshot})
    : _snapshot =
          initialSnapshot == null
              ? null
              : Map<String, Object?>.unmodifiable(initialSnapshot);

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

class ProfilePreferencesRepository {
  final ProfilePreferencesStore store;

  const ProfilePreferencesRepository({required this.store});

  Future<ProfilePreferences> load() async {
    try {
      final snapshot = await store.read();
      if (snapshot == null) return ProfilePreferences.initial;

      return ProfilePreferences.fromJson(snapshot);
    } catch (_) {
      return ProfilePreferences.initial;
    }
  }

  Future<void> save(ProfilePreferences preferences) async {
    await store.write(preferences.toJson());
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}
