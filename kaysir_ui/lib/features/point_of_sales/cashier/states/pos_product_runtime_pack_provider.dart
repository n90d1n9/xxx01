import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../experiences/default_pos_product_runtime_pack.dart';
import '../experiences/pos_product_runtime_pack.dart';
import '../experiences/pos_product_runtime_pack_catalog.dart';

final posProductRuntimePackRegistryProvider =
    Provider<POSProductRuntimePackRegistry>(
      (ref) => defaultPOSProductRuntimePackRegistry,
    );

final selectedPOSProductRuntimePackIdProvider = StateProvider<String>(
  (ref) => ref.watch(posProductRuntimePackRegistryProvider).defaultPackId,
);

final posProductRuntimePackResolutionProvider =
    Provider<POSProductRuntimePackResolution>((ref) {
      final registry = ref.watch(posProductRuntimePackRegistryProvider);
      final selectedId = ref.watch(selectedPOSProductRuntimePackIdProvider);

      return registry.resolveDetailed(selectedId);
    });

final posProductRuntimePackCatalogProvider =
    Provider<POSProductRuntimePackCatalog>((ref) {
      return POSProductRuntimePackCatalog.fromPacks(
        ref.watch(posProductRuntimePackRegistryProvider).packs,
      );
    });

final posProductRuntimePackProvider = Provider<POSProductRuntimePack>(
  (ref) => ref.watch(posProductRuntimePackResolutionProvider).pack,
);

final posProductRuntimePackRegistryIssuesProvider =
    Provider<List<POSProductRuntimePackRegistryIssue>>(
      (ref) => ref.watch(posProductRuntimePackRegistryProvider).validate(),
    );

final posProductRuntimePackIssuesProvider =
    Provider<List<POSProductRuntimePackIssue>>(
      (ref) => ref.watch(posProductRuntimePackProvider).validate(),
    );
