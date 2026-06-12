import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/accounting_policy_profile.dart';
import 'accounting_policy_repository.dart';

abstract class AccountingPolicySnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbAccountingPolicySnapshotStore
    implements AccountingPolicySnapshotStore {
  static const defaultStorageKey = 'accounting.policy_profile.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbAccountingPolicySnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'your-secure-password',
  });

  @override
  Future<Map<String, dynamic>?> read() async {
    final stored = await _tryRead();
    if (stored == null) {
      return null;
    }
    if (stored is Map<String, dynamic>) {
      return stored;
    }
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }
    return null;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
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

  Future<Object?> _tryRead() async {
    try {
      await _ensureInitialized();
      return LocalDBService.getPreference(key: storageKey);
    } catch (_) {
      return null;
    }
  }
}

class LocalAccountingPolicyRepository extends InMemoryAccountingPolicyRepository
    implements HydratableAccountingPolicyRepository {
  final AccountingPolicySnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalAccountingPolicyRepository({required this.store, super.profile});

  @override
  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromStore();
  }

  @override
  Future<void> persist() {
    return _queuePersist();
  }

  @override
  void saveProfile(AccountingPolicyProfile profile) {
    super.saveProfile(profile);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  Future<void> _hydrateFromStore() async {
    final Map<String, dynamic>? data;
    try {
      data = await store.read();
    } catch (_) {
      return;
    }

    if (data == null || _dirtyDuringHydrate) {
      if (_dirtyDuringHydrate) {
        await _queuePersist();
      }
      return;
    }

    final rawProfile = data['profile'];
    final profileJson = _asJsonMap(rawProfile);
    if (profileJson == null) {
      return;
    }

    try {
      super.saveProfile(AccountingPolicyProfile.fromJson(profileJson));
    } catch (_) {
      return;
    }
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write({
        'schemaVersion': 1,
        'profile': loadProfile().toJson(),
      });
    });
  }
}

Map<String, dynamic>? _asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
