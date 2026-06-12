import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../order/utils/order_save_outbox_sync_behavior.dart';
import 'default_pos_experience.dart';
import '../states/pos_product_runtime_pack_provider.dart';
import 'pos_behavior_set.dart';
import 'pos_cart_behavior.dart';
import 'pos_catalog_behavior.dart';
import 'pos_commerce_channel_provider.dart';
import 'pos_checkout_behavior.dart';
import 'pos_experience.dart';
import 'pos_experience_action_policy.dart';
import 'pos_experience_catalog.dart';
import 'pos_experience_launch_checklist.dart';
import 'pos_experience_registry.dart';
import 'pos_feature_module.dart';
import 'pos_payment_behavior.dart';
import 'pos_product_profile.dart';

final posProductProfileCatalogProvider = Provider<POSProductProfileCatalog>(
  (ref) => ref.watch(posProductRuntimePackProvider).productProfileCatalog,
);

final posProductProfileValidationReportProvider =
    Provider<POSProductProfileValidationReport>(
      (ref) => ref.watch(posProductProfileCatalogProvider).validationReport,
    );

final posLaunchableProductProfilesProvider = Provider<List<POSProductProfile>>(
  (ref) => ref.watch(posProductProfileCatalogProvider).launchableProfiles,
);

final posBlockedProductProfilesProvider = Provider<List<POSProductProfile>>(
  (ref) => ref.watch(posProductProfileCatalogProvider).blockedProfiles,
);

final posExperienceRegistryProvider = Provider<POSExperienceRegistry>(
  (ref) => ref.watch(posProductProfileCatalogProvider).experienceRegistry,
);

final posExperienceCatalogProvider = Provider<POSExperienceCatalog>(
  (ref) => POSExperienceCatalog.fromExperiences(
    ref.watch(posExperienceRegistryProvider).experiences,
  ),
);

final selectedPOSExperienceIdProvider = StateProvider<String>(
  (ref) => defaultPOSExperience.id,
);

final posExperienceResolutionProvider = Provider<POSExperienceResolution>((
  ref,
) {
  final registry = ref.watch(posExperienceRegistryProvider);
  final selectedId = ref.watch(selectedPOSExperienceIdProvider);
  return registry.resolveDetailed(selectedId);
});

final posExperienceProvider = Provider<POSExperience>(
  (ref) => ref.watch(posExperienceResolutionProvider).experience,
);

final posProductProfileProvider = Provider<POSProductProfile?>((ref) {
  final catalog = ref.watch(posProductProfileCatalogProvider);
  final experience = ref.watch(posExperienceProvider);
  return catalog.findByModeId(experience.id);
});

final posProductProfileLaunchChecklistProvider =
    Provider<POSExperienceLaunchChecklist?>(
      (ref) => ref.watch(posProductProfileProvider)?.launchChecklist,
    );

final posExperienceRegistryIssuesProvider =
    Provider<List<POSExperienceRegistryIssue>>(
      (ref) => ref.watch(posExperienceRegistryProvider).validate(),
    );

final posExperienceModulesProvider = Provider<List<POSFeatureModule>>(
  (ref) => ref.watch(posExperienceProvider).modules,
);

final posExperienceActionPolicyProvider = Provider<POSExperienceActionPolicy>(
  (ref) => POSExperienceActionPolicy(
    experience: ref.watch(posExperienceProvider),
    commerceChannel: ref.watch(posCommerceChannelProvider),
  ),
);

final posBehaviorSetProvider = Provider<POSBehaviorSet>(
  (ref) => ref.watch(posExperienceProvider).behaviors,
);

final posCatalogBehaviorProvider = Provider<POSCatalogBehavior>(
  (ref) => ref.watch(posBehaviorSetProvider).catalog,
);

final posCartBehaviorProvider = Provider<POSCartBehavior>(
  (ref) => ref.watch(posBehaviorSetProvider).cart,
);

final posCheckoutBehaviorProvider = Provider<POSCheckoutBehavior>(
  (ref) => ref.watch(posBehaviorSetProvider).checkout,
);

final posPaymentBehaviorProvider = Provider<POSPaymentBehavior>(
  (ref) => ref.watch(posBehaviorSetProvider).payment,
);

final posOrderSaveOutboxSyncBehaviorProvider =
    Provider<POSOrderSaveOutboxSyncBehavior>(
      (ref) => ref.watch(posBehaviorSetProvider).orderSync,
    );
