import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_feature_module.dart';

void expectValidPOSExperienceMode(
  POSExperience experience, {
  Iterable<POSFeatureModule> requiredModules = const [],
  Iterable<POSExperienceFormFactor> requiredFormFactors = const [],
}) {
  final registry = POSExperienceRegistry(experiences: [experience]);
  final issues = registry.validate();

  expect(
    issues,
    isEmpty,
    reason:
        '${experience.id} should pass POS registry validation before release',
  );
  expect(experience.id.trim(), isNotEmpty);
  expect(experience.label.trim(), isNotEmpty);
  expect(experience.description.trim(), isNotEmpty);
  expect(experience.manifest.productLine.trim(), isNotEmpty);
  expect(experience.manifest.archetypeKey.trim(), isNotEmpty);
  expect(experience.manifest.archetypeLabel.trim(), isNotEmpty);
  expect(experience.manifest.supportedFormFactors, isNotEmpty);

  final moduleIds = experience.modules.map((module) => module.id).toList();
  expect(
    moduleIds.length,
    moduleIds.toSet().length,
    reason: '${experience.id} should not register duplicate module ids',
  );
  expect(
    moduleIds,
    containsAll(requiredModules.map((module) => module.id)),
    reason: '${experience.id} is missing required POS feature modules',
  );

  for (final formFactor in requiredFormFactors) {
    expect(
      experience.manifest.supportsFormFactor(formFactor),
      isTrue,
      reason:
          '${experience.id} should declare ${formFactor.label} support in its manifest',
    );
  }
}
