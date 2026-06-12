import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/journal_approval.dart';
import 'journal_approval_repository.dart';

/// Snapshot store used by local journal approval persistence.
abstract class JournalApprovalSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

/// Local database-backed snapshot store for journal approval queue state.
class LocalDbJournalApprovalSnapshotStore
    implements JournalApprovalSnapshotStore {
  static const defaultStorageKey = 'accounting.journal_approval.snapshot.v1';

  LocalDbJournalApprovalSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'your-secure-password',
  });

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  @override
  Future<Map<String, dynamic>?> read() async {
    await _ensureInitialized();
    final stored = await LocalDBService.getPreference(key: storageKey);
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
    await _ensureInitialized();
    await LocalDBService.savePreference(key: storageKey, value: snapshot);
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= LocalDBService.initialize(
      encryptionPassword: encryptionPassword,
    ).then((_) {});
  }
}

/// Local journal approval repository with async hydration and snapshot writes.
class LocalJournalApprovalRepository extends InMemoryJournalApprovalRepository
    implements HydratableJournalApprovalRepository {
  LocalJournalApprovalRepository({required this.store, super.requests});

  final JournalApprovalSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  @override
  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromStore();
  }

  @override
  Future<void> persist() {
    return _queuePersist();
  }

  @override
  void replaceAll(Iterable<JournalApprovalRequest> requests) {
    super.replaceAll(requests);
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

    if (data == null) {
      return;
    }

    final JournalApprovalRepositorySnapshot snapshot;
    try {
      snapshot = JournalApprovalRepositorySnapshot.fromJson(data);
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    super.replaceAll(snapshot.requests);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        JournalApprovalRepositorySnapshot(requests: loadRequests()).toJson(),
      );
    });
  }
}

/// Versioned local snapshot for journal approval queue persistence.
class JournalApprovalRepositorySnapshot {
  const JournalApprovalRepositorySnapshot({required this.requests});

  final List<JournalApprovalRequest> requests;

  factory JournalApprovalRepositorySnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final requests = <JournalApprovalRequest>[];
    final rawRequests = json['requests'];
    if (rawRequests is Iterable) {
      for (final rawRequest in rawRequests) {
        final value = _asJsonMap(rawRequest);
        if (value != null) {
          requests.add(JournalApprovalRequest.fromJson(value));
        }
      }
    }

    return JournalApprovalRepositorySnapshot(requests: requests);
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'requests': requests.map((request) => request.toJson()).toList(),
    };
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
