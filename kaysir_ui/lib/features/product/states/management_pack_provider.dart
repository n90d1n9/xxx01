import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/management_pack.dart';
import '../models/sales_channel_profile.dart';
import '../repositories/management_pack_preferences_repository.dart';

/// Ordered list of product management packs available in the product feature.
final productManagementPacksProvider = Provider<List<ProductManagementPack>>((
  ref,
) {
  return defaultProductManagementPacks;
});

/// Default pack identifier used when no preference or route mode is selected.
final productManagementFallbackPackIdProvider =
    Provider<ProductManagementPackId?>((ref) {
      return ProductManagementPackId.coreCatalog;
    });

/// Registry provider that resolves product management packs with a fallback.
final productManagementPackRegistryProvider =
    Provider<ProductManagementPackRegistry>((ref) {
      return ProductManagementPackRegistry.fromPacks(
        ref.watch(productManagementPacksProvider),
        fallbackPackId: ref.watch(productManagementFallbackPackIdProvider),
      );
    });

/// Currently selected product management pack.
final productManagementPackProvider = Provider<ProductManagementPack>((ref) {
  final registry = ref.watch(productManagementPackRegistryProvider);

  return registry.resolve(ref.watch(productManagementPackIdProvider));
});

/// Preference scope used to persist the selected management pack.
final productManagementPackPreferenceScopeProvider =
    Provider<ProductManagementPackPreferenceScope>((ref) {
      return ProductManagementPackPreferenceScope.defaultScope;
    });

/// Repository provider for product management pack preferences.
final productManagementPackPreferencesRepositoryProvider =
    Provider<ProductManagementPackPreferencesRepository>((ref) {
      return ProductManagementPackPreferencesRepository(
        store: LocalDbProductManagementPackPreferencesStore(
          scope: ref.watch(productManagementPackPreferenceScopeProvider),
        ),
      );
    });

/// Selected product management pack identifier with async preference hydration.
final productManagementPackIdProvider = StateNotifierProvider<
  ProductManagementPackIdNotifier,
  ProductManagementPackId
>((ref) {
  final registry = ref.watch(productManagementPackRegistryProvider);

  return ProductManagementPackIdNotifier(
    repository: ref.watch(productManagementPackPreferencesRepositoryProvider),
    registry: registry,
  );
});

/// Controller that resolves, persists, and hydrates the selected management pack.
class ProductManagementPackIdNotifier
    extends StateNotifier<ProductManagementPackId> {
  ProductManagementPackIdNotifier({
    required this.repository,
    required this.registry,
    ProductManagementPackId? initialPackId,
    bool autoHydrate = true,
  }) : super(registry.resolve(initialPackId).id) {
    if (autoHydrate) hydrate();
  }

  final ProductManagementPackPreferencesRepository repository;
  final ProductManagementPackRegistry registry;

  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _hydrated = false;
  bool _selectionChangedBeforeHydration = false;

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrate();
  }

  Future<void> selectPack(
    ProductManagementPackId packId, {
    ProductSalesChannelProfileId? channelProfileId,
  }) {
    final resolvedPackId = registry.resolve(packId).id;
    if (resolvedPackId == state && channelProfileId == null) {
      return Future<void>.value();
    }

    _selectionChangedBeforeHydration = !_hydrated;
    state = resolvedPackId;

    return _persist(channelProfileId: channelProfileId);
  }

  Future<void> flush() {
    return _persistFuture ?? Future<void>.value();
  }

  Future<void> _hydrate() async {
    try {
      final preferences = await repository.load();
      final persistedPackId = preferences.packId;

      if (!_selectionChangedBeforeHydration) {
        state = registry.resolve(persistedPackId).id;
      }
    } finally {
      _hydrated = true;
    }
  }

  Future<void> _persist({ProductSalesChannelProfileId? channelProfileId}) {
    return _persistFuture = repository
        .saveSelection(
          selectedPackId: state.value,
          selectedChannelProfileId: channelProfileId?.value,
        )
        .then((_) {})
        .catchError((_) {});
  }
}

/// Available management pack options for selector widgets.
final productManagementPackOptionsProvider =
    Provider<List<ProductManagementPack>>((ref) {
      return ref.watch(productManagementPackRegistryProvider).packs;
    });

/// Sales-channel profile packs exposed by the selected management pack.
final productManagementProfilePacksProvider =
    Provider<List<ProductSalesChannelProfilePack>>((ref) {
      return ref.watch(productManagementPackProvider).profilePacks;
    });
