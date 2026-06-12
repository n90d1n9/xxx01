import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../utils/order_save_outbox.dart';
import '../utils/order_save_outbox_codec.dart';

abstract class POSOrderSaveOutboxSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbPOSOrderSaveOutboxSnapshotStore
    implements POSOrderSaveOutboxSnapshotStore {
  static const defaultStorageKey = 'pos.order_save_outbox.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbPOSOrderSaveOutboxSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-pos-outbox-local',
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

class MemoryPOSOrderSaveOutboxSnapshotStore
    implements POSOrderSaveOutboxSnapshotStore {
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

class POSOrderSaveOutboxRepository {
  final POSOrderSaveOutboxSnapshotStore store;
  final POSOrderSaveOutboxCodec codec;

  const POSOrderSaveOutboxRepository({
    required this.store,
    this.codec = const POSOrderSaveOutboxCodec(),
  });

  Future<POSOrderSaveOutbox> load() async {
    final snapshot = await store.read();
    if (snapshot == null) {
      return const POSOrderSaveOutbox.empty();
    }

    try {
      return codec.decode(snapshot);
    } catch (_) {
      return const POSOrderSaveOutbox.empty();
    }
  }

  Future<void> save(POSOrderSaveOutbox outbox) async {
    await store.write(codec.encode(outbox));
  }

  Future<void> clear() async {
    await save(const POSOrderSaveOutbox.empty());
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return Map<String, Object?>.from(value);
  }

  return null;
}
