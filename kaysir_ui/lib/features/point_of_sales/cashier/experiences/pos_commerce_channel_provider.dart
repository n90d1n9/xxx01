import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/pos_product_runtime_pack_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_behavior.dart';
import 'pos_commerce_channel_registry.dart';

final posCommerceChannelRegistryProvider = Provider<POSCommerceChannelRegistry>(
  (ref) => ref.watch(posProductRuntimePackProvider).commerceChannelRegistry,
);

final posCommerceChannelBehaviorRegistryProvider =
    Provider<POSCommerceChannelBehaviorRegistry>(
      (ref) =>
          ref
              .watch(posProductRuntimePackProvider)
              .commerceChannelBehaviorRegistry,
    );

final selectedPOSCommerceChannelIdProvider = StateProvider<String>(
  (ref) => ref.watch(posCommerceChannelRegistryProvider).defaultChannelId,
);

final posCommerceChannelRegistryIssuesProvider =
    Provider<List<POSCommerceChannelRegistryIssue>>((ref) {
      return ref.watch(posCommerceChannelRegistryProvider).validate();
    });

final posCommerceChannelBehaviorRegistryIssuesProvider =
    Provider<List<POSCommerceChannelBehaviorRegistryIssue>>((ref) {
      return ref
          .watch(posCommerceChannelBehaviorRegistryProvider)
          .validate(
            commerceChannelRegistry: ref.watch(
              posCommerceChannelRegistryProvider,
            ),
          );
    });

final posCommerceChannelProvider = Provider<POSCommerceChannel>((ref) {
  final registry = ref.watch(posCommerceChannelRegistryProvider);
  final selectedId = ref.watch(selectedPOSCommerceChannelIdProvider);

  return registry.findById(selectedId) ?? registry.defaultChannel;
});

final posCommerceChannelBehaviorProfileProvider =
    Provider<POSCommerceChannelBehaviorProfile?>((ref) {
      final registry = ref.watch(posCommerceChannelBehaviorRegistryProvider);
      final channel = ref.watch(posCommerceChannelProvider);

      return registry.findByChannelId(channel.id);
    });

final posCommerceChannelBehaviorModulesProvider =
    Provider<List<POSCommerceChannelBehaviorModule>>((ref) {
      return ref.watch(posCommerceChannelBehaviorProfileProvider)?.modules ??
          const [];
    });
