import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/order_saved_workspace.dart';

const ecommerceOrderSavedWorkspaceDefaultProfileId = 'all_commerce';

class OrderSavedWorkspaceSnapshot {
  final Map<String, List<OrderSavedWorkspace>> workspacesByProfileId;

  const OrderSavedWorkspaceSnapshot({this.workspacesByProfileId = const {}});

  static const empty = OrderSavedWorkspaceSnapshot();

  factory OrderSavedWorkspaceSnapshot.fromJson(Map<String, Object?> json) {
    final workspacesByProfileId = _workspacesByProfileIdFromJson(
      json['profiles'],
    );
    final legacyWorkspaces = _savedWorkspacesFromJson(json['workspaces']);
    if (legacyWorkspaces.isEmpty) {
      return OrderSavedWorkspaceSnapshot(
        workspacesByProfileId: workspacesByProfileId,
      );
    }

    final mergedWorkspaces = {
      ...workspacesByProfileId,
      if (!workspacesByProfileId.containsKey(
        ecommerceOrderSavedWorkspaceDefaultProfileId,
      ))
        ecommerceOrderSavedWorkspaceDefaultProfileId: legacyWorkspaces,
    };

    return OrderSavedWorkspaceSnapshot(
      workspacesByProfileId: Map.unmodifiable(mergedWorkspaces),
    );
  }

  List<OrderSavedWorkspace> workspacesForProfile(String profileId) {
    return workspacesByProfileId[normalizeOrderSavedWorkspaceProfileId(
          profileId,
        )] ??
        const [];
  }

  OrderSavedWorkspaceSnapshot withProfileWorkspaces({
    required String profileId,
    required List<OrderSavedWorkspace> workspaces,
  }) {
    final normalizedProfileId = normalizeOrderSavedWorkspaceProfileId(
      profileId,
    );
    final nextWorkspacesByProfileId = {
      ...workspacesByProfileId,
      if (workspaces.isNotEmpty)
        normalizedProfileId: List<OrderSavedWorkspace>.unmodifiable(workspaces),
    };
    if (workspaces.isEmpty) {
      nextWorkspacesByProfileId.remove(normalizedProfileId);
    }

    return OrderSavedWorkspaceSnapshot(
      workspacesByProfileId: Map.unmodifiable(nextWorkspacesByProfileId),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'profiles': {
        for (final entry in workspacesByProfileId.entries)
          entry.key: entry.value
              .map((workspace) => workspace.toJson())
              .toList(growable: false),
      },
    };
  }
}

abstract class OrderSavedWorkspaceStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbOrderSavedWorkspaceStore implements OrderSavedWorkspaceStore {
  static const defaultStorageKey = 'ecommerce.order.saved_workspaces.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbOrderSavedWorkspaceStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-ecommerce-order-saved-workspaces-local',
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

class MemoryOrderSavedWorkspaceStore implements OrderSavedWorkspaceStore {
  Map<String, Object?>? _snapshot;

  MemoryOrderSavedWorkspaceStore({Map<String, Object?>? initialSnapshot})
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

class OrderSavedWorkspaceRepository {
  final OrderSavedWorkspaceStore store;
  Future<void>? _writeFuture;

  OrderSavedWorkspaceRepository({required this.store});

  Future<List<OrderSavedWorkspace>> load({
    String profileId = ecommerceOrderSavedWorkspaceDefaultProfileId,
  }) async {
    try {
      final snapshot = await _loadSnapshot();
      return snapshot.workspacesForProfile(profileId);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(
    List<OrderSavedWorkspace> workspaces, {
    String profileId = ecommerceOrderSavedWorkspaceDefaultProfileId,
  }) {
    final normalizedProfileId = normalizeOrderSavedWorkspaceProfileId(
      profileId,
    );
    final workspaceSnapshot = List<OrderSavedWorkspace>.unmodifiable(
      workspaces,
    );
    final pending = _writeFuture?.catchError((_) {}) ?? Future<void>.value();

    return _writeFuture = pending.then((_) async {
      final snapshot = await _loadSnapshot(waitForWrites: false);
      await store.write(
        snapshot
            .withProfileWorkspaces(
              profileId: normalizedProfileId,
              workspaces: workspaceSnapshot,
            )
            .toJson(),
      );
    });
  }

  Future<OrderSavedWorkspaceSnapshot> _loadSnapshot({
    bool waitForWrites = true,
  }) async {
    final pendingWrite = _writeFuture;
    if (waitForWrites && pendingWrite != null) {
      await pendingWrite.catchError((_) {});
    }

    final snapshot = await store.read();
    if (snapshot == null) return OrderSavedWorkspaceSnapshot.empty;

    return OrderSavedWorkspaceSnapshot.fromJson(snapshot);
  }
}

String normalizeOrderSavedWorkspaceProfileId(String profileId) {
  final normalizedProfileId = profileId.trim();
  if (normalizedProfileId.isEmpty) {
    return ecommerceOrderSavedWorkspaceDefaultProfileId;
  }

  return normalizedProfileId;
}

Map<String, List<OrderSavedWorkspace>> _workspacesByProfileIdFromJson(
  Object? value,
) {
  if (value is! Map) return const {};

  final workspacesByProfileId = <String, List<OrderSavedWorkspace>>{};
  for (final entry in value.entries) {
    final profileId = normalizeOrderSavedWorkspaceProfileId(
      entry.key.toString(),
    );
    final workspaces = _savedWorkspacesFromJson(entry.value);
    if (workspaces.isEmpty) continue;

    workspacesByProfileId[profileId] = workspaces;
  }

  return Map.unmodifiable(workspacesByProfileId);
}

List<OrderSavedWorkspace> _savedWorkspacesFromJson(Object? value) {
  if (value is! List) return const [];

  var workspaces = const <OrderSavedWorkspace>[];
  for (final item in value) {
    final json = _asJsonMap(item);
    if (json == null) continue;

    try {
      workspaces = ecommerceOrderSavedWorkspacesWithSaved(
        workspaces,
        OrderSavedWorkspace.fromJson(json),
      );
    } catch (_) {
      continue;
    }
  }

  return List.unmodifiable(workspaces);
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}
