import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/models/inventory_product_catalog_presentation_state.dart';
import '../../inventory/models/inventory_product_catalog_saved_view.dart';
import '../../inventory/models/inventory_product_catalog_table_view_state.dart';
import '../../inventory/models/inventory_product_catalog_view_mode.dart';
import '../models/management_pack.dart';
import '../models/management_pack_preset.dart';
import '../models/sales_channel_profile.dart';
import '../repositories/management_pack_preferences_repository.dart';
import 'management_pack_provider.dart';
import 'sales_channel_definition_provider.dart';

final productManagementWorkspacePreferencesControllerProvider =
    Provider<ProductManagementWorkspacePreferencesController>((ref) {
      return ProductManagementWorkspacePreferencesController(ref);
    });

/// Resolved product workspace mode and preferences after hydration or changes.
class ProductManagementWorkspaceSelection {
  const ProductManagementWorkspaceSelection({
    required this.pack,
    required this.channelProfile,
    this.preferences = ProductManagementPackPreferences.initial,
  });

  final ProductManagementPack pack;
  final ProductSalesChannelProfile channelProfile;
  final ProductManagementPackPreferences preferences;
}

/// Coordinates persisted management-pack preferences with active product state.
class ProductManagementWorkspacePreferencesController {
  const ProductManagementWorkspacePreferencesController(this.ref);

  final Ref ref;

  Future<ProductManagementWorkspaceSelection> hydrate({
    bool applyChannelProfile = true,
  }) async {
    final preferences =
        await ref
            .read(productManagementPackPreferencesRepositoryProvider)
            .load();
    final pack = ref
        .read(productManagementPackRegistryProvider)
        .resolve(preferences.packId);
    final requestedProfileId =
        preferences.channelProfileId ?? pack.defaultChannelProfileId;

    await ref
        .read(productManagementPackIdProvider.notifier)
        .selectPack(pack.id, channelProfileId: requestedProfileId);

    final profile = ref
        .read(productSalesChannelProfileRegistryProvider)
        .resolve(requestedProfileId);

    if (applyChannelProfile) {
      ref.read(productSalesChannelProfileIdProvider.notifier).state =
          profile.id;
    }

    final savedPreferences = await persist(
      packId: pack.id,
      channelProfileId: profile.id,
      catalogPresentationState: preferences.catalogPresentationState,
    );

    return ProductManagementWorkspaceSelection(
      pack: pack,
      channelProfile: profile,
      preferences: savedPreferences,
    );
  }

  Future<ProductManagementWorkspaceSelection> selectPack(
    ProductManagementPackId packId,
  ) {
    final pack = ref
        .read(productManagementPackRegistryProvider)
        .resolve(packId);

    return applySelection(
      packId: pack.id,
      channelProfileId: pack.defaultChannelProfileId,
    );
  }

  Future<ProductManagementWorkspaceSelection> selectPreset(
    ProductManagementPackPreset preset,
  ) {
    final pack = ref
        .read(productManagementPackRegistryProvider)
        .resolve(preset.packId);

    return applySelection(
      packId: pack.id,
      channelProfileId: preset.channelProfileId,
    );
  }

  Future<ProductManagementWorkspaceSelection> selectChannelProfile(
    ProductSalesChannelProfileId profileId,
  ) {
    return applySelection(
      packId: ref.read(productManagementPackProvider).id,
      channelProfileId: profileId,
    );
  }

  Future<ProductManagementWorkspaceSelection> resetToDefault() {
    final pack = ref.read(productManagementPackRegistryProvider).fallbackPack;

    return applySelection(
      packId: pack.id,
      channelProfileId: pack.defaultChannelProfileId,
    );
  }

  Future<ProductManagementWorkspaceSelection> applyRouteSelection({
    ProductManagementPackId? packId,
    ProductSalesChannelProfileId? channelProfileId,
  }) {
    final pack = ref
        .read(productManagementPackRegistryProvider)
        .resolve(packId ?? ref.read(productManagementPackProvider).id);

    return applySelection(
      packId: pack.id,
      channelProfileId: channelProfileId ?? pack.defaultChannelProfileId,
    );
  }

  Future<ProductManagementWorkspaceSelection> applySelection({
    required ProductManagementPackId packId,
    required ProductSalesChannelProfileId channelProfileId,
  }) async {
    final pack = ref
        .read(productManagementPackRegistryProvider)
        .resolve(packId);
    await ref
        .read(productManagementPackIdProvider.notifier)
        .selectPack(pack.id, channelProfileId: channelProfileId);

    final profile = ref
        .read(productSalesChannelProfileRegistryProvider)
        .resolve(channelProfileId);
    ref.read(productSalesChannelProfileIdProvider.notifier).state = profile.id;

    final preferences = await persist(
      packId: pack.id,
      channelProfileId: profile.id,
    );

    return ProductManagementWorkspaceSelection(
      pack: pack,
      channelProfile: profile,
      preferences: preferences,
    );
  }

  Future<ProductManagementPackPreferences> persist({
    required ProductManagementPackId packId,
    required ProductSalesChannelProfileId channelProfileId,
    InventoryProductCatalogPresentationState? catalogPresentationState,
  }) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: packId.value,
      selectedChannelProfileId: channelProfileId.value,
      catalogPresentationState:
          catalogPresentationState ??
          const InventoryProductCatalogPresentationState(),
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .saveSelection(
            selectedPackId: packId.value,
            selectedChannelProfileId: channelProfileId.value,
          );
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> saveCatalogViewMode(
    InventoryProductCatalogViewMode viewMode,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogPresentationState: InventoryProductCatalogPresentationState(
        viewMode: viewMode,
      ),
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .saveCatalogViewMode(viewMode);
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> saveCatalogPresentation({
    required InventoryProductCatalogViewMode viewMode,
    required InventoryProductCatalogTableViewState tableViewState,
  }) async {
    return saveCatalogPresentationState(
      InventoryProductCatalogPresentationState(
        viewMode: viewMode,
        tableViewState: tableViewState,
      ),
    );
  }

  Future<ProductManagementPackPreferences> saveCatalogPresentationState(
    InventoryProductCatalogPresentationState presentationState,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogPresentationState: presentationState,
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .saveCatalogPresentationState(presentationState);
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> saveCatalogSavedView(
    InventoryProductCatalogSavedView view,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogPresentationState: view.presentationState,
      catalogSavedViews: [view],
      activeCatalogSavedViewId: view.id,
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .saveCatalogSavedView(view);
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> saveCatalogSavedViewMetadata(
    InventoryProductCatalogSavedView view,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogSavedViews: [view],
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .saveCatalogSavedViewMetadata(view);
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> selectCatalogSavedView(
    InventoryProductCatalogSavedView view,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogPresentationState: view.presentationState,
      catalogSavedViews: [view],
      activeCatalogSavedViewId: view.id,
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .selectCatalogSavedView(view.id);
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> setDefaultCatalogSavedView(
    InventoryProductCatalogSavedView? view,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogSavedViews:
          view == null ? const <InventoryProductCatalogSavedView>[] : [view],
      defaultCatalogSavedViewId: view?.id,
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .setDefaultCatalogSavedView(view?.id);
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> deleteCatalogSavedView(
    InventoryProductCatalogSavedView view,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogPresentationState: view.presentationState,
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .deleteCatalogSavedView(view.id);
    } catch (_) {
      return fallback;
    }
  }

  Future<ProductManagementPackPreferences> saveCatalogTableViewState(
    InventoryProductCatalogTableViewState tableViewState,
  ) async {
    final fallback = ProductManagementPackPreferences(
      selectedPackId: ref.read(productManagementPackProvider).id.value,
      selectedChannelProfileId:
          ref.read(productSalesChannelProfileProvider).id.value,
      catalogPresentationState: InventoryProductCatalogPresentationState(
        tableViewState: tableViewState,
      ),
    );

    try {
      return await ref
          .read(productManagementPackPreferencesRepositoryProvider)
          .saveCatalogTableViewState(tableViewState);
    } catch (_) {
      return fallback;
    }
  }
}
