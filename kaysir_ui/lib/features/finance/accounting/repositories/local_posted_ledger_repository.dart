import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../accounting_core/models/ledger_posting.dart';
import 'posted_ledger_repository.dart';

abstract class PostedLedgerSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbPostedLedgerSnapshotStore implements PostedLedgerSnapshotStore {
  static const defaultStorageKey = 'accounting.posted_ledger.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbPostedLedgerSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'your-secure-password',
  });

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

class LocalPostedLedgerRepository extends InMemoryPostedLedgerRepository
    implements HydratablePostedLedgerRepository {
  final PostedLedgerSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalPostedLedgerRepository({required this.store, super.postings});

  @override
  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromStore();
  }

  @override
  Future<void> persist() {
    return _queuePersist();
  }

  @override
  void appendPosting(LedgerPosting posting) {
    super.appendPosting(posting);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void clear() {
    super.clear();
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

    final PostedLedgerRepositorySnapshot snapshot;
    try {
      snapshot = PostedLedgerRepositorySnapshot.fromJson(data);
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(snapshot.postings);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        PostedLedgerRepositorySnapshot(postings: loadPostings()).toJson(),
      );
    });
  }
}

class PostedLedgerRepositorySnapshot {
  final List<LedgerPosting> postings;

  const PostedLedgerRepositorySnapshot({required this.postings});

  factory PostedLedgerRepositorySnapshot.fromJson(Map<String, dynamic> json) {
    final postings = <LedgerPosting>[];
    final rawPostings = json['postings'];
    if (rawPostings is Iterable) {
      for (final rawPosting in rawPostings) {
        final value = _asJsonMap(rawPosting);
        if (value != null) {
          postings.add(LedgerPosting.fromJson(value));
        }
      }
    }
    return PostedLedgerRepositorySnapshot(postings: postings);
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'postings': postings.map((posting) => posting.toJson()).toList(),
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
