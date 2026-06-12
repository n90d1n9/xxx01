import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/sales_channel_profile_pack_overview.dart';
import '../models/sales_channel_readiness.dart';
import 'management_pack_provider.dart';

/// Profile packs contributed by the active product management pack.
final productSalesChannelProfilePacksProvider =
    Provider<List<ProductSalesChannelProfilePack>>((ref) {
      return ref.watch(productManagementProfilePacksProvider);
    });

/// Optional fallback profile override for the active sales-channel registry.
final productSalesChannelFallbackProfileIdProvider =
    Provider<ProductSalesChannelProfileId?>((ref) {
      return null;
    });

/// Registry provider for the active sales-channel profile set.
final productSalesChannelProfileRegistryProvider =
    Provider<ProductSalesChannelProfileRegistry>((ref) {
      return ProductSalesChannelProfileRegistry.fromPacks(
        ref.watch(productSalesChannelProfilePacksProvider),
        fallbackProfileId: ref.watch(
          productSalesChannelFallbackProfileIdProvider,
        ),
      );
    });

/// Active sales-channel profiles available to product screens.
final productSalesChannelProfilesProvider =
    Provider<List<ProductSalesChannelProfile>>((ref) {
      return ref.watch(productSalesChannelProfileRegistryProvider).profiles;
    });

/// Selected sales-channel profile identifier.
final productSalesChannelProfileIdProvider =
    StateProvider<ProductSalesChannelProfileId>((ref) {
      return ref
          .watch(productSalesChannelProfileRegistryProvider)
          .fallbackProfile
          .id;
    });

/// Resolved selected sales-channel profile with fallback handling.
final productSalesChannelProfileProvider = Provider<ProductSalesChannelProfile>(
  (ref) {
    final baseRegistry = ref.watch(productSalesChannelProfileRegistryProvider);
    final profiles = ref.watch(productSalesChannelProfilesProvider);
    final selectedId = ref.watch(productSalesChannelProfileIdProvider);
    final registry =
        identical(profiles, baseRegistry.profiles)
            ? baseRegistry
            : ProductSalesChannelProfileRegistry(
              profiles: profiles,
              fallbackProfileId: baseRegistry.fallbackProfileId,
            );

    return registry.resolve(selectedId);
  },
);

/// Overview provider that explains which profile pack owns each channel profile.
final productSalesChannelProfilePackOverviewProvider =
    Provider<ProductSalesChannelProfilePackOverview>((ref) {
      final registry = ref.watch(productSalesChannelProfileRegistryProvider);

      return buildProductSalesChannelProfilePackOverview(
        packs: ref.watch(productSalesChannelProfilePacksProvider),
        registry: registry,
        selectedProfile: ref.watch(productSalesChannelProfileProvider),
      );
    });

/// Definitions used to evaluate product readiness for the selected profile.
final productSalesChannelDefinitionsProvider =
    Provider<List<ProductSalesChannelDefinition>>((ref) {
      return ref.watch(productSalesChannelProfileProvider).definitions;
    });
