import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';

void main() {
  test('POSExperienceRegistry exposes registered ids and validity', () {
    expect(defaultPOSExperienceRegistry.isValid, isTrue);
    expect(defaultPOSExperienceRegistry.validate(), isEmpty);
    expect(defaultPOSExperienceRegistry.experienceIds, [
      defaultPOSExperience.id,
      quickCheckoutPOSExperience.id,
      assistedServicePOSExperience.id,
    ]);
  });

  test('resolveDetailed reports whether fallback was used', () {
    final resolved = defaultPOSExperienceRegistry.resolveDetailed(
      quickCheckoutPOSExperience.id,
    );
    final fallback = defaultPOSExperienceRegistry.resolveDetailed('missing');

    expect(resolved.experience, quickCheckoutPOSExperience);
    expect(resolved.usedFallback, isFalse);
    expect(resolved.fallbackReason, isNull);

    expect(fallback.experience, defaultPOSExperience);
    expect(fallback.usedFallback, isTrue);
    expect(fallback.fallbackReason, contains('missing'));
  });

  test('validate reports duplicate and blank experience ids', () {
    final registry = POSExperienceRegistry(
      experiences: [
        defaultPOSExperience,
        defaultPOSExperience.copyWith(label: 'Duplicate Standard'),
        defaultPOSExperience.copyWith(id: ' ', label: 'Blank Id'),
      ],
    );

    final issues = registry.validate();

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        POSExperienceRegistryIssueType.duplicateExperienceId,
        POSExperienceRegistryIssueType.blankExperienceId,
      ]),
    );
    expect(
      issues.map((issue) => issue.message).join('\n'),
      contains('Duplicate POS experience id "standard_cashier" found'),
    );
  });

  test('validate reports duplicate module ids inside a mode', () {
    final registry = POSExperienceRegistry(
      experiences: [
        defaultPOSExperience.copyWith(
          modules: const [
            POSFeatureModules.catalogBrowsing,
            POSFeatureModules.catalogBrowsing,
          ],
        ),
      ],
    );

    final issues = registry.validate();

    expect(
      issues.map((issue) => issue.type),
      contains(POSExperienceRegistryIssueType.duplicateModuleId),
    );
    expect(
      issues.map((issue) => issue.message).join('\n'),
      contains('duplicate module id "catalog_browsing"'),
    );
  });

  test('validate reports enabled capabilities without required modules', () {
    final registry = POSExperienceRegistry(
      experiences: [
        quickCheckoutPOSExperience.copyWith(
          modules: const [
            POSFeatureModules.catalogBrowsing,
            POSFeatureModules.cartManagement,
            POSFeatureModules.payments,
          ],
        ),
      ],
    );

    final issues = registry.validate();

    expect(
      issues.map((issue) => issue.type),
      contains(POSExperienceRegistryIssueType.enabledCapabilityMissingModule),
    );
    expect(
      issues.map((issue) => issue.message).join('\n'),
      contains('enables Barcode scanning but is missing module'),
    );
  });

  test('validate reports modules registered for disabled capabilities', () {
    final registry = POSExperienceRegistry(
      experiences: [
        quickCheckoutPOSExperience.copyWith(
          modules: const [
            ...POSFeatureModules.quickCheckout,
            POSFeatureModules.promotions,
          ],
        ),
      ],
    );

    final issues = registry.validate();

    expect(
      issues.map((issue) => issue.type),
      contains(POSExperienceRegistryIssueType.disabledCapabilityHasModule),
    );
    expect(
      issues.map((issue) => issue.message).join('\n'),
      contains('registers module "promotions" but disables Promotions'),
    );
  });

  test('validate reports incomplete experience manifests', () {
    final registry = POSExperienceRegistry(
      experiences: [
        defaultPOSExperience.copyWith(
          manifest: const POSExperienceManifest(
            productLine: ' ',
            archetypeKey: '',
            archetypeLabel: ' ',
            supportedFormFactors: [],
            traits: ['touch-first', ''],
          ),
        ),
      ],
    );

    final issues = registry.validate();

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        POSExperienceRegistryIssueType.blankManifestProductLine,
        POSExperienceRegistryIssueType.blankManifestArchetypeKey,
        POSExperienceRegistryIssueType.blankManifestArchetypeLabel,
        POSExperienceRegistryIssueType.emptyManifestFormFactors,
        POSExperienceRegistryIssueType.blankManifestTrait,
      ]),
    );
  });

  test('throwIfInvalid raises a readable registry error', () {
    const registry = POSExperienceRegistry(experiences: []);

    expect(
      registry.throwIfInvalid,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('must contain at least one mode'),
        ),
      ),
    );
  });
}
