import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/management_pack_preset.dart';
import 'management_pack_provider.dart';
import 'sales_channel_definition_provider.dart';

/// Provides the product workspace presets available to the current tenant.
final productManagementPackPresetsProvider =
    Provider<List<ProductManagementPackPreset>>((ref) {
      return defaultProductManagementPackPresets;
    });

/// Resolves the preset matching the active management pack and channel profile.
final activeProductManagementPackPresetProvider =
    Provider<ProductManagementPackPreset?>((ref) {
      return activeProductManagementPackPresetFor(
        presets: ref.watch(productManagementPackPresetsProvider),
        pack: ref.watch(productManagementPackProvider),
        profile: ref.watch(productSalesChannelProfileProvider),
      );
    });
