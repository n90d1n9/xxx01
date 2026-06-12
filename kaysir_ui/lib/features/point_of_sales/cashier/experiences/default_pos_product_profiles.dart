import '../../../ecommerce/pos/pos_profile.dart';
import 'default_pos_experience.dart';
import 'pos_experience.dart';
import 'pos_experience_recipe.dart';
import 'pos_product_profile.dart';

final corePOSProductProfiles = [
  _profileFromExperience(
    id: 'kaysir_core_standard_cashier',
    label: 'Kaysir Core Cashier',
    experience: defaultPOSExperience,
    archetype: POSExperienceRecipeArchetype.standardCashier,
  ),
  _profileFromExperience(
    id: 'kaysir_core_quick_checkout',
    label: 'Kaysir Core Quick Checkout',
    experience: quickCheckoutPOSExperience,
    archetype: POSExperienceRecipeArchetype.quickCheckout,
  ),
  _profileFromExperience(
    id: 'kaysir_core_assisted_service',
    label: 'Kaysir Core Assisted Service',
    experience: assistedServicePOSExperience,
    archetype: POSExperienceRecipeArchetype.assistedService,
  ),
];

final defaultPOSProductProfiles = [
  ...corePOSProductProfiles,
  ecommercePOSProductProfile,
];

final defaultPOSProductProfileCatalog = POSProductProfileCatalog(
  profiles: defaultPOSProductProfiles,
);

POSProductProfile _profileFromExperience({
  required String id,
  required String label,
  required POSExperience experience,
  required POSExperienceRecipeArchetype archetype,
}) {
  return POSProductProfile(
    id: id,
    label: label,
    description: experience.description,
    recipe: POSExperienceRecipe.fromExperience(
      experience,
      archetype: archetype,
    ),
    experienceOverride: experience,
    requiredModules: experience.modules,
    requiredFormFactors: experience.manifest.supportedFormFactors,
    requiredDataTraits: experience.manifest.dataTraits,
  );
}
