import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/pos_quick_button_customization.dart';

/// Tenant, outlet, and operator boundary for persisted POS quick buttons.
class POSQuickButtonCustomizationScope {
  final String tenantId;
  final String outletId;
  final String operatorId;

  const POSQuickButtonCustomizationScope({
    this.tenantId = 'default',
    this.outletId = 'default',
    this.operatorId = 'default',
  });

  static const defaultScope = POSQuickButtonCustomizationScope();

  String get storageKey {
    return 'pos.quick_button_customization.v1.$tenantId.$outletId.$operatorId';
  }
}

/// Raw snapshot store used by the quick-button customization repository.
abstract class POSQuickButtonCustomizationSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

/// Local database-backed store for persisted quick-button customization.
class LocalDbPOSQuickButtonCustomizationSnapshotStore
    implements POSQuickButtonCustomizationSnapshotStore {
  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbPOSQuickButtonCustomizationSnapshotStore({
    POSQuickButtonCustomizationScope scope =
        POSQuickButtonCustomizationScope.defaultScope,
    this.encryptionPassword = 'kaysir-pos-quick-button-customization-local',
  }) : storageKey = scope.storageKey;

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

/// In-memory quick-button customization store used by tests and previews.
class MemoryPOSQuickButtonCustomizationSnapshotStore
    implements POSQuickButtonCustomizationSnapshotStore {
  Map<String, Object?>? _snapshot;

  MemoryPOSQuickButtonCustomizationSnapshotStore({
    Map<String, Object?>? initialSnapshot,
  }) : _snapshot = _immutableSnapshot(initialSnapshot);

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

/// Repository that serializes POS quick-button customization preferences.
class POSQuickButtonCustomizationRepository {
  final POSQuickButtonCustomizationSnapshotStore store;
  Future<void> _writeQueue = Future<void>.value();

  POSQuickButtonCustomizationRepository({required this.store});

  Future<POSQuickButtonCustomization> load() async {
    try {
      final snapshot = await store.read();
      if (snapshot == null) return POSQuickButtonCustomization.empty;

      return POSQuickButtonCustomization.fromJson(snapshot);
    } catch (_) {
      return POSQuickButtonCustomization.empty;
    }
  }

  Future<void> save(POSQuickButtonCustomization customization) {
    return _enqueueWrite(() => store.write(customization.toJson()));
  }

  Future<void> _enqueueWrite(Future<void> Function() operation) {
    final queued = _writeQueue.then(
      (_) => operation(),
      onError: (_) => operation(),
    );
    _writeQueue = queued.then<void>((_) {}, onError: (_) {});

    return queued;
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}

Map<String, Object?>? _immutableSnapshot(Map<String, Object?>? snapshot) {
  if (snapshot == null) return null;

  return Map<String, Object?>.unmodifiable(snapshot);
}
