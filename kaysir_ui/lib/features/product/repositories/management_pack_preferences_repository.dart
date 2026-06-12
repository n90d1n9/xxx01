import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../../inventory/models/inventory_product_catalog_presentation_state.dart';
import '../../inventory/models/inventory_product_catalog_saved_view.dart';
import '../../inventory/models/inventory_product_catalog_table_view_state.dart';
import '../../inventory/models/inventory_product_catalog_view_mode.dart';
import '../models/product_availability_rule_authoring_session.dart';
import '../models/management_pack.dart';
import '../models/sales_channel_profile.dart';

/// Persisted workspace preferences for management-pack product workflows.
class ProductManagementPackPreferences {
  const ProductManagementPackPreferences({
    required this.selectedPackId,
    this.selectedChannelProfileId,
    this.catalogPresentationState =
        const InventoryProductCatalogPresentationState(),
    this.catalogSavedViews = const <InventoryProductCatalogSavedView>[],
    this.activeCatalogSavedViewId,
    this.defaultCatalogSavedViewId,
    this.availabilityAuthoringSession =
        ProductAvailabilityRuleAuthoringSession.defaults,
  });

  final String selectedPackId;
  final String? selectedChannelProfileId;
  final InventoryProductCatalogPresentationState catalogPresentationState;
  final List<InventoryProductCatalogSavedView> catalogSavedViews;
  final String? activeCatalogSavedViewId;
  final String? defaultCatalogSavedViewId;
  final ProductAvailabilityRuleAuthoringSession availabilityAuthoringSession;

  static const initial = ProductManagementPackPreferences(
    selectedPackId: ProductManagementPackId.coreCatalogValue,
  );
  static const _catalogPresentationStateJsonKey = 'catalogPresentationState';
  static const _catalogSavedViewsJsonKey = 'catalogSavedViews';
  static const _activeCatalogSavedViewIdJsonKey = 'activeCatalogSavedViewId';
  static const _defaultCatalogSavedViewIdJsonKey = 'defaultCatalogSavedViewId';
  static const _catalogViewModeJsonKey = 'catalogViewMode';
  static const _catalogTableViewStateJsonKey = 'catalogTableViewState';
  static const _availabilityAuthoringSessionJsonKey =
      'availabilityAuthoringSession';

  factory ProductManagementPackPreferences.fromJson(Map<String, Object?> json) {
    final selectedPackId = json['selectedPackId']?.toString().trim();
    final selectedChannelProfileId =
        json['selectedChannelProfileId']?.toString().trim();
    final catalogPresentationState = _decodeCatalogPresentationState(json);
    final catalogSavedViews = _decodeCatalogSavedViews(json);

    return ProductManagementPackPreferences(
      selectedPackId:
          selectedPackId == null || selectedPackId.isEmpty
              ? initial.selectedPackId
              : selectedPackId,
      selectedChannelProfileId:
          selectedChannelProfileId == null || selectedChannelProfileId.isEmpty
              ? null
              : selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState,
      catalogSavedViews: catalogSavedViews,
      activeCatalogSavedViewId:
          _activeSavedViewId(
            json[_activeCatalogSavedViewIdJsonKey],
            catalogSavedViews,
          ) ??
          _matchingSavedViewId(catalogSavedViews, catalogPresentationState),
      defaultCatalogSavedViewId: _activeSavedViewId(
        json[_defaultCatalogSavedViewIdJsonKey],
        catalogSavedViews,
      ),
      availabilityAuthoringSession: _decodeAvailabilityAuthoringSession(json),
    );
  }

  ProductManagementPackId get packId {
    return ProductManagementPackId(selectedPackId);
  }

  ProductSalesChannelProfileId? get channelProfileId {
    final value = selectedChannelProfileId?.trim();
    if (value == null || value.isEmpty) return null;

    return ProductSalesChannelProfileId(value);
  }

  InventoryProductCatalogViewMode get catalogViewMode {
    return catalogPresentationState.viewMode;
  }

  InventoryProductCatalogTableViewState get catalogTableViewState {
    return catalogPresentationState.tableViewState;
  }

  InventoryProductCatalogSavedView? get defaultCatalogSavedView {
    return _savedViewById(catalogSavedViews, defaultCatalogSavedViewId);
  }

  InventoryProductCatalogPresentationState get startupCatalogPresentationState {
    return defaultCatalogSavedView?.presentationState ??
        catalogPresentationState;
  }

  String? get startupCatalogSavedViewId {
    return defaultCatalogSavedView?.id ?? activeCatalogSavedViewId;
  }

  Map<String, Object?> toJson() {
    final snapshot = <String, Object?>{'selectedPackId': selectedPackId};
    final channelProfileId = selectedChannelProfileId?.trim();
    if (channelProfileId != null && channelProfileId.isNotEmpty) {
      snapshot['selectedChannelProfileId'] = channelProfileId;
    }
    final presentationState = catalogPresentationState.normalized;
    if (!presentationState.isDefault) {
      snapshot[_catalogPresentationStateJsonKey] = presentationState.toJson();
    }
    final savedViews = normalizeInventoryProductCatalogSavedViews(
      catalogSavedViews,
    );
    if (savedViews.isNotEmpty) {
      snapshot[_catalogSavedViewsJsonKey] = savedViews
          .map((view) => view.toJson())
          .toList(growable: false);
    }
    final activeSavedViewId = _activeSavedViewId(
      activeCatalogSavedViewId,
      savedViews,
    );
    if (activeSavedViewId != null) {
      snapshot[_activeCatalogSavedViewIdJsonKey] = activeSavedViewId;
    }
    final defaultSavedViewId = _activeSavedViewId(
      defaultCatalogSavedViewId,
      savedViews,
    );
    if (defaultSavedViewId != null) {
      snapshot[_defaultCatalogSavedViewIdJsonKey] = defaultSavedViewId;
    }
    if (!availabilityAuthoringSession.isDefault) {
      snapshot[_availabilityAuthoringSessionJsonKey] =
          availabilityAuthoringSession.toJson();
    }

    return snapshot;
  }

  ProductManagementPackPreferences withSelection({
    required String selectedPackId,
    String? selectedChannelProfileId,
  }) {
    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState,
      catalogSavedViews: catalogSavedViews,
      activeCatalogSavedViewId: activeCatalogSavedViewId,
      defaultCatalogSavedViewId: defaultCatalogSavedViewId,
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withCatalogViewMode(
    InventoryProductCatalogViewMode viewMode,
  ) {
    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState.copyWith(
        viewMode: viewMode,
      ),
      catalogSavedViews: catalogSavedViews,
      activeCatalogSavedViewId: _matchingSavedViewId(
        catalogSavedViews,
        catalogPresentationState.copyWith(viewMode: viewMode),
      ),
      defaultCatalogSavedViewId: _activeSavedViewId(
        defaultCatalogSavedViewId,
        catalogSavedViews,
      ),
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withCatalogTableViewState(
    InventoryProductCatalogTableViewState tableViewState,
  ) {
    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState.copyWith(
        tableViewState: tableViewState,
      ),
      catalogSavedViews: catalogSavedViews,
      activeCatalogSavedViewId: _matchingSavedViewId(
        catalogSavedViews,
        catalogPresentationState.copyWith(tableViewState: tableViewState),
      ),
      defaultCatalogSavedViewId: _activeSavedViewId(
        defaultCatalogSavedViewId,
        catalogSavedViews,
      ),
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withCatalogPresentationState(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: presentationState.normalized,
      catalogSavedViews: catalogSavedViews,
      activeCatalogSavedViewId: _matchingSavedViewId(
        catalogSavedViews,
        presentationState,
      ),
      defaultCatalogSavedViewId: _activeSavedViewId(
        defaultCatalogSavedViewId,
        catalogSavedViews,
      ),
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withCatalogSavedView(
    InventoryProductCatalogSavedView view,
  ) {
    final normalizedViews = normalizeInventoryProductCatalogSavedViews([view]);
    if (normalizedViews.isEmpty) return this;

    final normalizedView = normalizedViews.first;
    final nextViews = [
      for (final existingView in catalogSavedViews)
        if (existingView.id != normalizedView.id) existingView,
      normalizedView,
    ];

    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: normalizedView.presentationState,
      catalogSavedViews: nextViews,
      activeCatalogSavedViewId: normalizedView.id,
      defaultCatalogSavedViewId: _activeSavedViewId(
        defaultCatalogSavedViewId,
        nextViews,
      ),
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withCatalogSavedViewMetadata(
    InventoryProductCatalogSavedView view,
  ) {
    final normalizedViews = normalizeInventoryProductCatalogSavedViews([view]);
    if (normalizedViews.isEmpty) return this;

    final normalizedView = normalizedViews.first;
    final nextViews = normalizeInventoryProductCatalogSavedViews([
      for (final existingView in catalogSavedViews)
        if (existingView.id != normalizedView.id) existingView,
      normalizedView,
    ]);

    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState,
      catalogSavedViews: nextViews,
      activeCatalogSavedViewId:
          _activeSavedViewId(activeCatalogSavedViewId, nextViews) ??
          _matchingSavedViewId(nextViews, catalogPresentationState),
      defaultCatalogSavedViewId: _activeSavedViewId(
        defaultCatalogSavedViewId,
        nextViews,
      ),
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withoutCatalogSavedView(String viewId) {
    final normalizedViews = normalizeInventoryProductCatalogSavedViews(
      catalogSavedViews,
    );
    final trimmedViewId = viewId.trim();
    if (trimmedViewId.isEmpty) return this;

    final nextViews = normalizeInventoryProductCatalogSavedViews([
      for (final view in normalizedViews)
        if (view.id != trimmedViewId) view,
    ]);
    if (nextViews.length == normalizedViews.length) return this;

    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState,
      catalogSavedViews: nextViews,
      activeCatalogSavedViewId: _matchingSavedViewId(
        nextViews,
        catalogPresentationState,
      ),
      defaultCatalogSavedViewId: _activeSavedViewId(
        defaultCatalogSavedViewId,
        nextViews,
      ),
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withActiveCatalogSavedView(String viewId) {
    final normalizedViews = normalizeInventoryProductCatalogSavedViews(
      catalogSavedViews,
    );
    final trimmedViewId = viewId.trim();
    for (final view in normalizedViews) {
      if (view.id != trimmedViewId) continue;

      return ProductManagementPackPreferences(
        selectedPackId: selectedPackId,
        selectedChannelProfileId: selectedChannelProfileId,
        catalogPresentationState: view.presentationState,
        catalogSavedViews: normalizedViews,
        activeCatalogSavedViewId: view.id,
        defaultCatalogSavedViewId: _activeSavedViewId(
          defaultCatalogSavedViewId,
          normalizedViews,
        ),
        availabilityAuthoringSession: availabilityAuthoringSession,
      );
    }

    return this;
  }

  ProductManagementPackPreferences withDefaultCatalogSavedView(String? viewId) {
    final normalizedViews = normalizeInventoryProductCatalogSavedViews(
      catalogSavedViews,
    );
    final defaultSavedViewId = _activeSavedViewId(viewId, normalizedViews);

    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState,
      catalogSavedViews: normalizedViews,
      activeCatalogSavedViewId:
          _activeSavedViewId(activeCatalogSavedViewId, normalizedViews) ??
          _matchingSavedViewId(normalizedViews, catalogPresentationState),
      defaultCatalogSavedViewId: defaultSavedViewId,
      availabilityAuthoringSession: availabilityAuthoringSession,
    );
  }

  ProductManagementPackPreferences withAvailabilityAuthoringSession(
    ProductAvailabilityRuleAuthoringSession session,
  ) {
    return ProductManagementPackPreferences(
      selectedPackId: selectedPackId,
      selectedChannelProfileId: selectedChannelProfileId,
      catalogPresentationState: catalogPresentationState,
      catalogSavedViews: catalogSavedViews,
      activeCatalogSavedViewId: activeCatalogSavedViewId,
      defaultCatalogSavedViewId: defaultCatalogSavedViewId,
      availabilityAuthoringSession: session,
    );
  }

  static InventoryProductCatalogPresentationState
  _decodeCatalogPresentationState(Map<String, Object?> json) {
    final nestedState = _asJsonMap(json[_catalogPresentationStateJsonKey]);
    if (nestedState != null) {
      return InventoryProductCatalogPresentationState.fromJson(nestedState);
    }

    return InventoryProductCatalogPresentationState(
      viewMode: decodeInventoryProductCatalogViewMode(
        json[_catalogViewModeJsonKey],
      ),
      tableViewState: InventoryProductCatalogTableViewState.fromJson(
        _asJsonMap(json[_catalogTableViewStateJsonKey]) ?? const {},
      ),
    ).normalized;
  }

  static List<InventoryProductCatalogSavedView> _decodeCatalogSavedViews(
    Map<String, Object?> json,
  ) {
    final rawViews = json[_catalogSavedViewsJsonKey];
    if (rawViews is! Iterable) {
      return const <InventoryProductCatalogSavedView>[];
    }

    return normalizeInventoryProductCatalogSavedViews([
      for (final rawView in rawViews)
        if (_asJsonMap(rawView) != null)
          InventoryProductCatalogSavedView.fromJson(_asJsonMap(rawView)!),
    ]);
  }

  static ProductAvailabilityRuleAuthoringSession
  _decodeAvailabilityAuthoringSession(Map<String, Object?> json) {
    final sessionJson = _asJsonMap(json[_availabilityAuthoringSessionJsonKey]);
    if (sessionJson == null) {
      return ProductAvailabilityRuleAuthoringSession.defaults;
    }

    return ProductAvailabilityRuleAuthoringSession.fromJson(sessionJson);
  }
}

/// Tenant and outlet boundary used to isolate management-pack preferences.
class ProductManagementPackPreferenceScope {
  const ProductManagementPackPreferenceScope({
    this.tenantId = 'default',
    this.outletId = 'default',
  });

  final String tenantId;
  final String outletId;

  static const defaultScope = ProductManagementPackPreferenceScope();

  String get storageKey {
    return 'product.management.pack_preferences.v1.$tenantId.$outletId';
  }
}

/// Storage adapter used by the management-pack preferences repository.
abstract class ProductManagementPackPreferencesStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

/// Local database-backed preferences store for persisted product workspaces.
class LocalDbProductManagementPackPreferencesStore
    implements ProductManagementPackPreferencesStore {
  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbProductManagementPackPreferencesStore({
    ProductManagementPackPreferenceScope scope =
        ProductManagementPackPreferenceScope.defaultScope,
    this.encryptionPassword = 'kaysir-product-management-pack-local',
  }) : storageKey = scope.storageKey;

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

/// In-memory preferences store used by tests and isolated workflows.
class MemoryProductManagementPackPreferencesStore
    implements ProductManagementPackPreferencesStore {
  Map<String, Object?>? _snapshot;

  MemoryProductManagementPackPreferencesStore({
    Map<String, Object?>? initialSnapshot,
  }) : _snapshot =
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

/// Repository that loads, merges, and serializes product workspace preferences.
class ProductManagementPackPreferencesRepository {
  ProductManagementPackPreferencesRepository({required this.store});

  final ProductManagementPackPreferencesStore store;
  Future<void> _writeQueue = Future<void>.value();

  Future<ProductManagementPackPreferences> load() async {
    try {
      final snapshot = await store.read();
      if (snapshot == null) return ProductManagementPackPreferences.initial;

      return ProductManagementPackPreferences.fromJson(snapshot);
    } catch (_) {
      return ProductManagementPackPreferences.initial;
    }
  }

  Future<void> save(ProductManagementPackPreferences preferences) {
    return _enqueueWrite(() => _writePreferences(preferences));
  }

  Future<ProductManagementPackPreferences> saveSelection({
    required String selectedPackId,
    String? selectedChannelProfileId,
  }) {
    return _saveMerged(
      (current) => current.withSelection(
        selectedPackId: selectedPackId,
        selectedChannelProfileId: selectedChannelProfileId,
      ),
    );
  }

  Future<ProductManagementPackPreferences> saveCatalogTableViewState(
    InventoryProductCatalogTableViewState tableViewState,
  ) {
    return _saveMerged(
      (current) => current.withCatalogTableViewState(tableViewState),
    );
  }

  Future<ProductManagementPackPreferences> saveCatalogViewMode(
    InventoryProductCatalogViewMode viewMode,
  ) {
    return _saveMerged((current) => current.withCatalogViewMode(viewMode));
  }

  Future<ProductManagementPackPreferences> saveCatalogPresentation({
    required InventoryProductCatalogViewMode viewMode,
    required InventoryProductCatalogTableViewState tableViewState,
  }) {
    return saveCatalogPresentationState(
      InventoryProductCatalogPresentationState(
        viewMode: viewMode,
        tableViewState: tableViewState,
      ),
    );
  }

  Future<ProductManagementPackPreferences> saveCatalogPresentationState(
    InventoryProductCatalogPresentationState presentationState,
  ) {
    return _saveMerged(
      (current) => current.withCatalogPresentationState(presentationState),
    );
  }

  Future<ProductManagementPackPreferences> saveCatalogSavedView(
    InventoryProductCatalogSavedView view,
  ) {
    return _saveMerged((current) => current.withCatalogSavedView(view));
  }

  Future<ProductManagementPackPreferences> saveCatalogSavedViewMetadata(
    InventoryProductCatalogSavedView view,
  ) {
    return _saveMerged((current) => current.withCatalogSavedViewMetadata(view));
  }

  Future<ProductManagementPackPreferences> selectCatalogSavedView(
    String viewId,
  ) {
    return _saveMerged((current) => current.withActiveCatalogSavedView(viewId));
  }

  Future<ProductManagementPackPreferences> setDefaultCatalogSavedView(
    String? viewId,
  ) {
    return _saveMerged(
      (current) => current.withDefaultCatalogSavedView(viewId),
    );
  }

  Future<ProductManagementPackPreferences> deleteCatalogSavedView(
    String viewId,
  ) {
    return _saveMerged((current) => current.withoutCatalogSavedView(viewId));
  }

  Future<ProductManagementPackPreferences> saveAvailabilityAuthoringSession(
    ProductAvailabilityRuleAuthoringSession session,
  ) {
    return _saveMerged(
      (current) => current.withAvailabilityAuthoringSession(session),
    );
  }

  Future<ProductManagementPackPreferences> _saveMerged(
    ProductManagementPackPreferences Function(
      ProductManagementPackPreferences current,
    )
    merge,
  ) {
    return _enqueueWrite(() async {
      final next = merge(await load());
      await _writePreferences(next);

      return next;
    });
  }

  Future<void> _writePreferences(
    ProductManagementPackPreferences preferences,
  ) async {
    await store.write(preferences.toJson());
  }

  Future<T> _enqueueWrite<T>(Future<T> Function() operation) {
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

String? _activeSavedViewId(
  Object? value,
  List<InventoryProductCatalogSavedView> savedViews,
) {
  final id = value?.toString().trim();
  if (id == null || id.isEmpty) return null;

  for (final view in savedViews) {
    if (view.id == id) return id;
  }

  return null;
}

String? _matchingSavedViewId(
  List<InventoryProductCatalogSavedView> savedViews,
  InventoryProductCatalogPresentationState presentationState,
) {
  for (final view in savedViews) {
    if (view.presentationState.matches(presentationState.normalized)) {
      return view.id;
    }
  }

  return null;
}

InventoryProductCatalogSavedView? _savedViewById(
  List<InventoryProductCatalogSavedView> savedViews,
  String? viewId,
) {
  final id = viewId?.trim();
  if (id == null || id.isEmpty) return null;

  for (final view in savedViews) {
    if (view.id == id) return view;
  }

  return null;
}
