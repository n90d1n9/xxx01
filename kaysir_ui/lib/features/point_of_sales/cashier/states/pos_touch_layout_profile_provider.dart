import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../experiences/pos_experience_provider.dart';
import '../experiences/pos_experience_screen_fit.dart';
import '../models/pos_quick_button.dart';
import '../models/pos_touch_layout_profile.dart';
import '../models/pos_touch_layout_profile_catalog.dart';
import 'pos_layout_provider.dart';
import 'pos_product_runtime_pack_provider.dart';

/// Coordinates touch layout profile selection for the active POS runtime pack.
class POSTouchLayoutProfileController {
  final Ref _ref;

  const POSTouchLayoutProfileController(this._ref);

  void select(String profileId, {bool syncLayoutPreference = true}) {
    final profile = _ref
        .read(posTouchLayoutProfileCatalogProvider)
        .profileForId(profileId);
    _ref.read(selectedPOSTouchLayoutProfileIdProvider.notifier).state =
        profile.id;

    if (syncLayoutPreference) {
      _ref.read(posLayoutPreferenceProvider.notifier).state =
          profile.preferredLayout;
    }
  }

  void selectRecommendedForWidth(
    double viewportWidth, {
    bool syncLayoutPreference = true,
  }) {
    final profile = _ref.read(
      recommendedPOSTouchLayoutProfileProvider(viewportWidth),
    );
    select(profile.id, syncLayoutPreference: syncLayoutPreference);
  }
}

final posTouchLayoutProfileCatalogProvider = Provider<
  POSTouchLayoutProfileCatalog
>((ref) => ref.watch(posProductRuntimePackProvider).touchLayoutProfileCatalog);

final selectedPOSTouchLayoutProfileIdProvider = StateProvider<String>(
  (ref) => ref.watch(posTouchLayoutProfileCatalogProvider).defaultProfileId,
);

final posTouchLayoutProfileResolutionProvider =
    Provider<POSTouchLayoutProfileResolution>((ref) {
      final catalog = ref.watch(posTouchLayoutProfileCatalogProvider);
      final selectedId = ref.watch(selectedPOSTouchLayoutProfileIdProvider);

      return catalog.resolveDetailed(selectedId);
    });

final posTouchLayoutProfileProvider = Provider<POSTouchLayoutProfile>(
  (ref) => ref.watch(posTouchLayoutProfileResolutionProvider).profile,
);

final posTouchLayoutProfileCatalogIssuesProvider =
    Provider<List<POSTouchLayoutProfileCatalogIssue>>(
      (ref) => ref.watch(posTouchLayoutProfileCatalogProvider).validate(),
    );

final recommendedPOSTouchLayoutProfileProvider =
    Provider.family<POSTouchLayoutProfile, double>((ref, viewportWidth) {
      final catalog = ref.watch(posTouchLayoutProfileCatalogProvider);
      final experience = ref.watch(posExperienceProvider);

      return catalog.recommendFor(
        productLine: experience.manifest.productLine,
        formFactor: resolvePOSRuntimeFormFactor(viewportWidth),
        preferredLayout: experience.preferredLayout,
        traits: [
          ...experience.manifest.traits,
          ...experience.manifest.dataTraits,
        ],
      );
    });

final posTouchLayoutProfileControllerProvider =
    Provider<POSTouchLayoutProfileController>(
      (ref) => POSTouchLayoutProfileController(ref),
    );

final posTouchLayoutSurfaceGroupsProvider =
    Provider.family<List<POSQuickButtonGroup>, POSQuickButtonSurface>((
      ref,
      surface,
    ) {
      return ref.watch(posTouchLayoutProfileProvider).groupsForSurface(surface);
    });
