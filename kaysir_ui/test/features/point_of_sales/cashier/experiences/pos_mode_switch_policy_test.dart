import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_contract.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';

void main() {
  test('switch policy allows ready product profiles', () {
    final decision = POSModeSwitchPolicy.evaluate(
      experience: defaultPOSExperience,
      viewportWidth: 1280,
      productProfile: POSProductProfile(
        id: 'standard',
        label: 'Standard',
        description: 'Ready standard profile.',
        recipe: POSExperienceRecipe.fromExperience(defaultPOSExperience),
        experienceOverride: defaultPOSExperience,
      ),
    );

    expect(decision.disposition, POSModeSwitchDisposition.allowed);
    expect(decision.canSwitch, isTrue);
    expect(decision.needsConfirmation, isFalse);
    expect(decision.statusLabel, 'Launch ready');
  });

  test('switch policy asks confirmation for screen mismatches', () {
    final decision = POSModeSwitchPolicy.evaluate(
      experience: quickCheckoutPOSExperience,
      viewportWidth: 1280,
    );

    expect(decision.disposition, POSModeSwitchDisposition.confirm);
    expect(decision.canSwitch, isTrue);
    expect(decision.needsConfirmation, isTrue);
    expect(decision.statusLabel, 'Confirm');
    expect(decision.message, contains('Desktop screens'));
  });

  test('switch policy blocks profiles with launch failures', () {
    final blockedMode = defaultPOSExperience.copyWith(
      id: 'blocked_menu',
      manifest: defaultPOSExperience.manifest.copyWith(
        dataTraits: const [POSDataTraitKeys.modifierGroups],
        releaseStage: POSExperienceReleaseStage.stable,
      ),
    );
    final profile = POSProductProfile(
      id: 'blocked_profile',
      label: 'Blocked Profile',
      description: 'Profile with incomplete modifier contract support.',
      recipe: POSExperienceRecipe.fromExperience(blockedMode),
      experienceOverride: blockedMode,
      dataAdapters: const [
        POSDataTraitAdapter(
          id: 'incomplete_menu_api',
          label: 'Incomplete Menu API',
          fieldsByTrait: {
            POSDataTraitKeys.modifierGroups: ['group_id', 'option_id'],
          },
        ),
      ],
    );
    final decision = POSModeSwitchPolicy.evaluate(
      experience: blockedMode,
      viewportWidth: 1280,
      productProfile: profile,
    );

    expect(decision.disposition, POSModeSwitchDisposition.blocked);
    expect(decision.canSwitch, isFalse);
    expect(decision.statusLabel, 'Blocked');
    expect(decision.message, contains('Data contracts'));
    expect(decision.message, contains('Price delta'));
  });
}
