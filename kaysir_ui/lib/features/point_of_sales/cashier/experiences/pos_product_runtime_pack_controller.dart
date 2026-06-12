import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../order/models/order.dart';
import '../states/pos_layout_provider.dart';
import '../states/pos_product_runtime_pack_provider.dart';
import 'pos_commerce_channel_provider.dart';
import 'pos_experience_provider.dart';
import 'pos_product_runtime_pack.dart';
import 'pos_product_runtime_pack_catalog.dart';
import 'pos_product_runtime_pack_switch_availability_filter.dart';
import 'pos_product_runtime_pack_switch_plan.dart';

class POSProductRuntimePackSwitchController {
  final Ref _ref;
  final POSProductRuntimePackRegistry registry;
  final POSProductRuntimePackResolution resolution;

  const POSProductRuntimePackSwitchController({
    required Ref ref,
    required this.registry,
    required this.resolution,
  }) : _ref = ref;

  POSProductRuntimePack get currentPack => resolution.pack;

  POSLayoutPreference get currentLayoutPreference {
    return _ref.read(posLayoutPreferenceProvider);
  }

  List<POSProductRuntimePack> get packs => registry.packs;

  POSProductRuntimePackCatalog get catalog {
    return POSProductRuntimePackCatalog.fromPacks(packs);
  }

  bool get isSingleOption => packs.length <= 1;

  POSProductRuntimePackSwitchAvailabilityFilterResult filterAvailability(
    POSProductRuntimePackSwitchAvailabilityFilter filter,
  ) {
    return filter.apply(
      catalog: catalog,
      currentPack: currentPack,
      currentExperienceId: _ref.read(selectedPOSExperienceIdProvider),
      currentCommerceChannelId: _ref.read(selectedPOSCommerceChannelIdProvider),
    );
  }

  POSProductRuntimePackSwitchAvailabilityCounts availabilityCounts({
    String query = '',
    Order? order,
    bool preserveCurrentSelections = true,
  }) {
    return POSProductRuntimePackSwitchAvailabilityCounts.fromCatalog(
      catalog: catalog,
      currentPack: currentPack,
      currentExperienceId: _ref.read(selectedPOSExperienceIdProvider),
      currentCommerceChannelId: _ref.read(selectedPOSCommerceChannelIdProvider),
      query: query,
      order: order,
      preserveCurrentSelections: preserveCurrentSelections,
    );
  }

  POSProductRuntimePack packFor(String packId) {
    final pack = registry.findById(packId);
    if (pack == null) {
      throw StateError('POS product runtime pack "$packId" is not available.');
    }

    return pack;
  }

  POSProductRuntimePackSwitchPlan planFor(
    POSProductRuntimePack pack, {
    bool preserveCurrentSelections = true,
  }) {
    if (registry.findById(pack.id) == null) {
      throw StateError(
        'POS product runtime pack "${pack.id}" is not available.',
      );
    }

    return POSProductRuntimePackSwitchPlan.resolve(
      pack: pack,
      currentExperienceId: _ref.read(selectedPOSExperienceIdProvider),
      currentCommerceChannelId: _ref.read(selectedPOSCommerceChannelIdProvider),
      preserveCurrentSelections: preserveCurrentSelections,
    );
  }

  void apply(
    POSProductRuntimePack pack, {
    bool preserveCurrentSelections = true,
    bool applyPreferredLayout = true,
  }) {
    final plan = planFor(
      pack,
      preserveCurrentSelections: preserveCurrentSelections,
    );

    _ref.read(selectedPOSProductRuntimePackIdProvider.notifier).state = pack.id;

    if (plan.experience != null) {
      _ref.read(selectedPOSExperienceIdProvider.notifier).state =
          plan.experience!.id;
    }

    if (plan.commerceChannel != null) {
      _ref.read(selectedPOSCommerceChannelIdProvider.notifier).state =
          plan.commerceChannel!.id;
    }

    final nextLayoutPreference = plan.layoutPreference;
    if (applyPreferredLayout && nextLayoutPreference != null) {
      _ref.read(posLayoutPreferenceProvider.notifier).state =
          nextLayoutPreference;
    }
  }
}

final posProductRuntimePackSwitchControllerProvider =
    Provider<POSProductRuntimePackSwitchController>((ref) {
      return POSProductRuntimePackSwitchController(
        ref: ref,
        registry: ref.watch(posProductRuntimePackRegistryProvider),
        resolution: ref.watch(posProductRuntimePackResolutionProvider),
      );
    });
