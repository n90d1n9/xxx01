import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/pos/pos_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_launch_checklist.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('ecommerce profile declares a launchable web store POS mode', () {
    final profile = ecommercePOSProductProfile;
    final checklist = profile.launchChecklist;
    final dataContractCheck = checklist.items.singleWhere(
      (item) => item.id == 'data_contracts',
    );

    expect(profile.id, ecommercePOSProductProfileId);
    expect(profile.experience, same(ecommercePOSExperience));
    expect(profile.canLaunch, isTrue);
    expect(profile.fullyReady, isFalse);
    expect(profile.dataAdapters, contains(ecommercePOSDataAdapter));
    expect(dataContractCheck.status, POSLaunchCheckStatus.passed);
    expect(
      checklist.warnings.map((item) => item.id),
      contains('release_stage'),
    );
  });

  test('ecommerce experience fits storefront screens and capabilities', () {
    final experience = ecommercePOSExperience;
    final policy = POSExperienceActionPolicy(experience: experience);

    expect(experience.preferredLayout, POSLayoutPreference.checkout);
    expect(
      experience.manifest.supportedFormFactors,
      containsAll([
        POSExperienceFormFactor.desktop,
        POSExperienceFormFactor.tablet,
        POSExperienceFormFactor.mobile,
      ]),
    );
    expect(
      experience.modules,
      containsAll([
        POSFeatureModules.catalogBrowsing,
        POSFeatureModules.cartManagement,
        POSFeatureModules.customerSelection,
        POSFeatureModules.payments,
      ]),
    );
    expect(policy.allows(POSExperienceAction.customerSelection), isTrue);
    expect(policy.allows(POSExperienceAction.payments), isTrue);
    expect(policy.allows(POSExperienceAction.barcodeScanning), isFalse);
    expect(policy.allows(POSExperienceAction.heldOrders), isFalse);
  });

  test(
    'ecommerce adapter satisfies catalog, order, customer, and payment data',
    () {
      expect(ecommercePOSExperience.manifest.dataTraits, [
        POSDataTraitKeys.catalog,
        POSDataTraitKeys.orders,
        POSDataTraitKeys.customers,
        POSDataTraitKeys.payments,
      ]);
      expect(
        ecommercePOSDataAdapter.supportsField(
          POSDataTraitKeys.customers,
          'contact',
        ),
        isTrue,
      );
      expect(
        ecommercePOSDataAdapter.supportsField(
          POSDataTraitKeys.payments,
          'payment_status',
        ),
        isTrue,
      );
    },
  );
}
