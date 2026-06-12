import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_contract.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_launch_checklist.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_payment_behavior.dart';

void main() {
  test('launch checklist marks stable complete modes as ready', () {
    final checklist = POSExperienceLaunchChecklist.evaluate(
      experience: defaultPOSExperience,
      requiredModules: const [
        POSFeatureModules.catalogBrowsing,
        POSFeatureModules.customerSelection,
        POSFeatureModules.payments,
      ],
      requiredFormFactors: const [
        POSExperienceFormFactor.desktop,
        POSExperienceFormFactor.tablet,
      ],
      requiredDataTraits: POSDataTraitKeys.standardCommerce,
    );

    expect(checklist.statusLabel, 'Ready');
    expect(checklist.canLaunch, isTrue);
    expect(checklist.fullyReady, isTrue);
    expect(checklist.failureCount, 0);
    expect(checklist.warningCount, 0);
    expect(
      checklist.items
          .where((item) => item.status == POSLaunchCheckStatus.passed)
          .length,
      checklist.items.length,
    );
  });

  test('launch checklist keeps preview recipes launchable but reviewed', () {
    final recipe = POSExperienceRecipe.quickCheckout(
      id: 'counter_cafe',
      label: 'Counter Cafe',
      description: 'Touch-first cafe counter for menu items and fast tender.',
      productLine: 'Kaysir Cafe',
      archetypeKey: 'counter_cafe',
      archetypeLabel: 'Counter cafe',
      dataTraits: const [
        ...POSDataTraitKeys.quickCheckout,
        POSDataTraitKeys.modifierGroups,
      ],
    );
    final checklist = POSExperienceLaunchChecklist.fromRecipe(
      recipe,
      requiredModules: const [POSFeatureModules.payments],
      requiredFormFactors: const [POSExperienceFormFactor.tablet],
      requiredDataTraits: const [
        POSDataTraitKeys.payments,
        POSDataTraitKeys.modifierGroups,
      ],
    );

    expect(checklist.statusLabel, 'Needs review');
    expect(checklist.canLaunch, isTrue);
    expect(checklist.fullyReady, isFalse);
    expect(checklist.failureCount, 0);
    expect(checklist.warningCount, 1);
    expect(checklist.warnings.single.area, POSLaunchCheckArea.release);
  });

  test('launch checklist blocks missing modules, screens, and data traits', () {
    final mode = defaultPOSExperience.copyWith(
      modules:
          defaultPOSExperience.modules
              .where((module) => module.id != POSFeatureModules.payments.id)
              .toList(),
      manifest: defaultPOSExperience.manifest.copyWith(
        supportedFormFactors: const [POSExperienceFormFactor.mobile],
        dataTraits: const [POSDataTraitKeys.catalog, POSDataTraitKeys.orders],
      ),
    );
    final checklist = POSExperienceLaunchChecklist.evaluate(
      experience: mode,
      requiredModules: const [POSFeatureModules.payments],
      requiredFormFactors: const [POSExperienceFormFactor.desktop],
      requiredDataTraits: const [
        POSDataTraitKeys.payments,
        POSDataTraitKeys.customers,
      ],
    );

    expect(checklist.statusLabel, 'Blocked');
    expect(checklist.canLaunch, isFalse);
    expect(checklist.failureCount, greaterThanOrEqualTo(4));
    expect(
      checklist.failures.map((item) => item.area),
      containsAll([
        POSLaunchCheckArea.registry,
        POSLaunchCheckArea.modules,
        POSLaunchCheckArea.screens,
        POSLaunchCheckArea.data,
        POSLaunchCheckArea.actions,
      ]),
    );
    expect(
      checklist.items
          .singleWhere((item) => item.id == 'required_data_traits')
          .detail,
      'Missing Payments, Customers.',
    );
  });

  test('launch checklist blocks invalid payment method configuration', () {
    final mode = defaultPOSExperience.copyWith(
      behaviors: defaultPOSExperience.behaviors.copyWith(
        payment: const POSPaymentBehavior(
          paymentMethods: ['Cash'],
          defaultMethod: 'Debit Card',
        ),
      ),
    );
    final checklist = POSExperienceLaunchChecklist.evaluate(experience: mode);

    final paymentCheck = checklist.items.singleWhere(
      (item) => item.area == POSLaunchCheckArea.payment,
    );
    expect(paymentCheck.status, POSLaunchCheckStatus.failed);
    expect(paymentCheck.detail, contains('Debit Card'));
    expect(checklist.canLaunch, isFalse);
  });

  test('launch checklist validates data adapters against contracts', () {
    const cafeAdapter = POSDataTraitAdapter(
      id: 'cafe_api',
      label: 'Cafe API',
      fieldsByTrait: {
        POSDataTraitKeys.modifierGroups: ['group_id'],
      },
    );
    final mode = defaultPOSExperience.copyWith(
      manifest: defaultPOSExperience.manifest.copyWith(
        dataTraits: const [POSDataTraitKeys.modifierGroups],
      ),
    );
    final checklist = POSExperienceLaunchChecklist.evaluate(
      experience: mode,
      dataAdapters: const [cafeAdapter],
    );

    final contractCheck = checklist.items.singleWhere(
      (item) => item.id == 'data_contracts',
    );
    expect(contractCheck.status, POSLaunchCheckStatus.failed);
    expect(contractCheck.detail, contains('Modifier groups'));
    expect(contractCheck.detail, contains('Option id'));
    expect(contractCheck.detail, contains('Price delta'));
    expect(checklist.canLaunch, isFalse);
  });

  test('launch checklist warns when payments are disabled', () {
    final mode = defaultPOSExperience.copyWith(
      capabilities: const POSExperienceCapabilities(payments: false),
      modules:
          defaultPOSExperience.modules
              .where((module) => module.id != POSFeatureModules.payments.id)
              .toList(),
    );
    final checklist = POSExperienceLaunchChecklist.evaluate(experience: mode);

    final paymentCheck = checklist.items.singleWhere(
      (item) => item.area == POSLaunchCheckArea.payment,
    );
    expect(paymentCheck.status, POSLaunchCheckStatus.warning);
    expect(checklist.canLaunch, isTrue);
    expect(checklist.fullyReady, isFalse);
  });
}
