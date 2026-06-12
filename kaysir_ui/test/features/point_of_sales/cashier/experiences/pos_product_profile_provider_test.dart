import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/pos/pos_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('default product profiles back the POS experience registry', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(posProductProfileCatalogProvider),
      defaultPOSProductProfileCatalog,
    );
    expect(
      container.read(posProductProfileValidationReportProvider).isValid,
      isTrue,
    );
    expect(container.read(posExperienceProvider), same(defaultPOSExperience));
    expect(container.read(posExperienceRegistryProvider).experienceIds, [
      defaultPOSExperience.id,
      quickCheckoutPOSExperience.id,
      assistedServicePOSExperience.id,
      ecommercePOSExperience.id,
    ]);
    expect(
      container.read(posProductProfileProvider)?.id,
      'kaysir_core_standard_cashier',
    );
    expect(
      container.read(posProductProfileLaunchChecklistProvider)?.canLaunch,
      isTrue,
    );
    expect(container.read(posLaunchableProductProfilesProvider).length, 4);
    expect(container.read(posBlockedProductProfilesProvider), isEmpty);
  });

  test(
    'default catalog includes ecommerce as a product profile contribution',
    () {
      final ecommerceProfile = defaultPOSProductProfileCatalog.findById(
        ecommercePOSProductProfileId,
      );

      expect(corePOSProductProfiles.length, 3);
      expect(ecommerceProfile, same(ecommercePOSProductProfile));
      expect(
        defaultPOSProductProfileCatalog.experienceRegistry.isRegistered(
          ecommercePOSExperience.id,
        ),
        isTrue,
      );
      expect(ecommerceProfile?.canLaunch, isTrue);
    },
  );

  test('active product profile follows the selected POS experience', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedPOSExperienceIdProvider.notifier).state =
        quickCheckoutPOSExperience.id;

    expect(
      container.read(posExperienceProvider),
      same(quickCheckoutPOSExperience),
    );
    expect(
      container.read(posProductProfileProvider)?.id,
      'kaysir_core_quick_checkout',
    );
    expect(
      container.read(posProductProfileLaunchChecklistProvider)?.experience,
      same(quickCheckoutPOSExperience),
    );
  });

  test('overridden product profile catalogs drive runtime mode resolution', () {
    final customExperience = defaultPOSExperience.copyWith(
      id: 'custom_profile_mode',
      label: 'Custom Profile Mode',
      preferredLayout: POSLayoutPreference.compact,
      manifest: defaultPOSExperience.manifest.copyWith(
        productLine: 'Custom Product',
        archetypeKey: 'custom_profile',
        archetypeLabel: 'Custom profile',
        releaseStage: POSExperienceReleaseStage.stable,
      ),
    );
    final customProfile = POSProductProfile(
      id: 'custom_profile',
      label: 'Custom Profile',
      description: 'Custom profile package for test runtime selection.',
      recipe: POSExperienceRecipe.fromExperience(customExperience),
      experienceOverride: customExperience,
      requiredModules: customExperience.modules,
      requiredFormFactors: customExperience.manifest.supportedFormFactors,
      requiredDataTraits: customExperience.manifest.dataTraits,
    );
    final customCatalog = POSProductProfileCatalog(profiles: [customProfile]);
    final container = ProviderContainer(
      overrides: [
        posProductProfileCatalogProvider.overrideWithValue(customCatalog),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(posExperienceProvider), same(customExperience));
    expect(
      container.read(posExperienceResolutionProvider).usedFallback,
      isTrue,
    );

    container.read(selectedPOSExperienceIdProvider.notifier).state =
        customExperience.id;

    expect(container.read(posExperienceProvider), same(customExperience));
    expect(
      container.read(posExperienceResolutionProvider).usedFallback,
      isFalse,
    );
    expect(container.read(posProductProfileProvider), same(customProfile));
    expect(
      container.read(posProductProfileValidationReportProvider).isValid,
      isTrue,
    );
  });
}
