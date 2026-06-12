import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_contract.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_launch_checklist.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';

void main() {
  test('product profile bundles recipe, launch gates, and data adapters', () {
    final profile = POSProductProfile(
      id: 'kaysir_cafe_counter',
      label: 'Kaysir Cafe Counter',
      description: 'Counter-service cafe product package.',
      recipe: _counterCafeRecipe(),
      requiredModules: const [
        POSFeatureModules.catalogBrowsing,
        POSFeatureModules.cartManagement,
        POSFeatureModules.payments,
      ],
      requiredFormFactors: const [
        POSExperienceFormFactor.tablet,
        POSExperienceFormFactor.kiosk,
      ],
      requiredDataTraits: const [
        POSDataTraitKeys.menu,
        POSDataTraitKeys.modifierGroups,
      ],
      dataAdapters: const [_completeCafeAdapter],
    );

    final checklist = profile.launchChecklist;
    final dataContractCheck = checklist.items.singleWhere(
      (item) => item.id == 'data_contracts',
    );

    expect(profile.experience.id, 'counter_cafe');
    expect(profile.canLaunch, isTrue);
    expect(profile.fullyReady, isTrue);
    expect(profile.dataTraitLabels, contains('Modifier groups'));
    expect(profile.requiresDataTrait(POSDataTraitKeys.menu), isTrue);
    expect(dataContractCheck.status, POSLaunchCheckStatus.passed);
  });

  test('product profile blocks launch when adapters miss contract fields', () {
    final profile = POSProductProfile(
      id: 'incomplete_cafe_counter',
      label: 'Incomplete Cafe Counter',
      description: 'Cafe package missing modifier adapter fields.',
      recipe: _counterCafeRecipe(),
      dataAdapters: const [_incompleteCafeAdapter],
    );

    final checklist = profile.launchChecklist;
    final dataContractCheck = checklist.items.singleWhere(
      (item) => item.id == 'data_contracts',
    );

    expect(profile.canLaunch, isFalse);
    expect(dataContractCheck.status, POSLaunchCheckStatus.failed);
    expect(dataContractCheck.detail, contains('Modifier groups'));
    expect(dataContractCheck.detail, contains('Price delta'));
  });

  test('product profile catalog exposes launchable profiles and registry', () {
    final launchable = POSProductProfile(
      id: 'cafe',
      label: 'Cafe',
      description: 'Ready cafe package.',
      recipe: _counterCafeRecipe(),
      dataAdapters: const [_completeCafeAdapter],
    );
    final blocked = POSProductProfile(
      id: 'blocked_cafe',
      label: 'Blocked Cafe',
      description: 'Blocked cafe package.',
      recipe: _counterCafeRecipe(id: 'blocked_counter_cafe'),
      dataAdapters: const [_incompleteCafeAdapter],
    );
    final catalog = POSProductProfileCatalog(profiles: [launchable, blocked]);

    expect(catalog.profileIds, ['cafe', 'blocked_cafe']);
    expect(catalog.findById('cafe'), launchable);
    expect(catalog.findByModeId('blocked_counter_cafe'), blocked);
    expect(catalog.launchableProfiles, [launchable]);
    expect(catalog.blockedProfiles, [blocked]);
    expect(catalog.experienceRegistry.isRegistered('counter_cafe'), isTrue);
  });

  test('product profile catalog validation accepts ready profiles', () {
    final profile = POSProductProfile(
      id: 'cafe',
      label: 'Cafe',
      description: 'Ready cafe package.',
      recipe: _counterCafeRecipe(),
      dataAdapters: const [_completeCafeAdapter],
    );
    final catalog = POSProductProfileCatalog(profiles: [profile]);
    final report = catalog.validationReport;

    expect(catalog.isValid, isTrue);
    expect(report.isValid, isTrue);
    expect(report.statusLabel, 'Ready');
    expect(report.profileCount, 1);
    expect(report.launchableCount, 1);
    expect(report.blockedCount, 0);
  });

  test('product profile catalog validation reports duplicates', () {
    final first = POSProductProfile(
      id: 'cafe',
      label: 'Cafe',
      description: 'Ready cafe package.',
      recipe: _counterCafeRecipe(),
      dataAdapters: const [_completeCafeAdapter],
    );
    final duplicate = POSProductProfile(
      id: 'cafe',
      label: 'Cafe Copy',
      description: 'Duplicate cafe package.',
      recipe: _counterCafeRecipe(),
      dataAdapters: const [_completeCafeAdapter],
    );
    final report =
        POSProductProfileCatalog(profiles: [first, duplicate]).validationReport;

    expect(report.isValid, isFalse);
    expect(
      report.issues.map((issue) => issue.type),
      containsAll([
        POSProductProfileIssueType.duplicateProfileId,
        POSProductProfileIssueType.duplicateModeId,
        POSProductProfileIssueType.registryIssue,
      ]),
    );
    expect(
      report.issues.map((issue) => issue.message).join('\n'),
      contains('cafe'),
    );
    expect(
      report.issues.map((issue) => issue.message).join('\n'),
      contains('counter_cafe'),
    );
  });

  test('product profile catalog validation reports blocked launches', () {
    final profile = POSProductProfile(
      id: 'blocked_cafe',
      label: 'Blocked Cafe',
      description: 'Blocked cafe package.',
      recipe: _counterCafeRecipe(),
      dataAdapters: const [_incompleteCafeAdapter],
    );
    final report =
        POSProductProfileCatalog(profiles: [profile]).validationReport;

    final blockedIssue = report.issues.singleWhere(
      (issue) => issue.type == POSProductProfileIssueType.blockedLaunch,
    );

    expect(report.isValid, isFalse);
    expect(report.statusLabel, 'Needs attention');
    expect(report.hasBlockedProfiles, isTrue);
    expect(report.launchableCount, 0);
    expect(report.blockedCount, 1);
    expect(blockedIssue.launchArea, POSLaunchCheckArea.data);
    expect(blockedIssue.message, contains('Data contracts'));
    expect(report.throwIfInvalid, throwsStateError);
  });

  test('product profile catalog validation rejects empty catalogs', () {
    final report =
        POSProductProfileCatalog(profiles: const []).validationReport;

    expect(report.isValid, isFalse);
    expect(report.statusLabel, 'Empty');
    expect(
      report.issues.map((issue) => issue.type),
      contains(POSProductProfileIssueType.emptyCatalog),
    );
  });

  test('product profile protects launch gate lists from mutation', () {
    final requiredModules = [POSFeatureModules.payments];
    final requiredTraits = [POSDataTraitKeys.payments];
    final adapters = [_completeCafeAdapter];
    final profile = POSProductProfile(
      id: 'immutable_profile',
      label: 'Immutable Profile',
      description: 'Profile with protected release gates.',
      recipe: _counterCafeRecipe(),
      requiredModules: requiredModules,
      requiredDataTraits: requiredTraits,
      dataAdapters: adapters,
    );

    requiredModules.clear();
    requiredTraits.clear();
    adapters.clear();

    expect(profile.requiredModules, [POSFeatureModules.payments]);
    expect(profile.requiredDataTraits, [POSDataTraitKeys.payments]);
    expect(profile.dataAdapters, [_completeCafeAdapter]);
    expect(
      () => profile.requiredModules.add(POSFeatureModules.promotions),
      throwsUnsupportedError,
    );
  });
}

POSExperienceRecipe _counterCafeRecipe({String id = 'counter_cafe'}) {
  return POSExperienceRecipe.quickCheckout(
    id: id,
    label: 'Counter Cafe',
    description: 'Touch-first cafe counter for menu items and fast tender.',
    productLine: 'Kaysir Cafe',
    archetypeKey: 'counter_cafe',
    archetypeLabel: 'Counter cafe',
    releaseStage: POSExperienceReleaseStage.stable,
    dataTraits: const [
      POSDataTraitKeys.menu,
      POSDataTraitKeys.orders,
      POSDataTraitKeys.payments,
      POSDataTraitKeys.modifierGroups,
    ],
  );
}

const _completeCafeAdapter = POSDataTraitAdapter(
  id: 'cafe_api',
  label: 'Cafe API',
  fieldsByTrait: {
    POSDataTraitKeys.menu: ['menu_item_id', 'menu_name', 'base_price'],
    POSDataTraitKeys.orders: ['order_id', 'line_items', 'total', 'status'],
    POSDataTraitKeys.payments: [
      'payment_method',
      'tendered_amount',
      'payment_status',
    ],
    POSDataTraitKeys.modifierGroups: ['group_id', 'option_id', 'price_delta'],
  },
);

const _incompleteCafeAdapter = POSDataTraitAdapter(
  id: 'incomplete_cafe_api',
  label: 'Incomplete Cafe API',
  fieldsByTrait: {
    POSDataTraitKeys.menu: ['menu_item_id', 'menu_name', 'base_price'],
    POSDataTraitKeys.orders: ['order_id', 'line_items', 'total', 'status'],
    POSDataTraitKeys.payments: [
      'payment_method',
      'tendered_amount',
      'payment_status',
    ],
    POSDataTraitKeys.modifierGroups: ['group_id', 'option_id'],
  },
);
