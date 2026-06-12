import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/bank_reconciliation.dart';
import 'bank_statement_repository.dart';

abstract class BankStatementSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbBankStatementSnapshotStore implements BankStatementSnapshotStore {
  static const defaultStorageKey = 'accounting.bank_statement.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbBankStatementSnapshotStore({
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

class LocalBankStatementRepository extends InMemoryBankStatementRepository
    implements HydratableBankStatementRepository {
  final BankStatementSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalBankStatementRepository({required this.store, super.lines});

  @override
  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromStore();
  }

  @override
  Future<void> persist() {
    return _queuePersist();
  }

  @override
  void appendLine(BankStatementLine line) {
    super.appendLine(line);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void appendLines(Iterable<BankStatementLine> lines) {
    super.appendLines(lines);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void removeLine(String id) {
    super.removeLine(id);
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

    final BankStatementRepositorySnapshot snapshot;
    try {
      snapshot = BankStatementRepositorySnapshot.fromJson(data);
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(snapshot.lines);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        BankStatementRepositorySnapshot(lines: loadLines()).toJson(),
      );
    });
  }
}

class BankStatementRepositorySnapshot {
  final List<BankStatementLine> lines;

  const BankStatementRepositorySnapshot({required this.lines});

  factory BankStatementRepositorySnapshot.fromJson(Map<String, dynamic> json) {
    final lines = <BankStatementLine>[];
    final rawLines = json['lines'];
    if (rawLines is Iterable) {
      for (final rawLine in rawLines) {
        final value = _asJsonMap(rawLine);
        if (value != null) {
          lines.add(BankStatementLine.fromJson(value));
        }
      }
    }
    return BankStatementRepositorySnapshot(lines: lines);
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'lines': lines.map((line) => line.toJson()).toList(),
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
