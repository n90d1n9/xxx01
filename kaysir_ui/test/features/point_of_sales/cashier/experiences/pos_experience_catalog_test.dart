import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_catalog.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_factory.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';

void main() {
  test('catalog groups experiences by product line without changing order', () {
    final cafeMode = POSExperienceFactory.quickCheckout(
      id: 'counter_cafe',
      label: 'Counter Cafe',
      description: 'Fast cafe counter checkout.',
      manifest: const POSExperienceManifest(
        productLine: 'Kaysir Cafe',
        archetypeKey: 'counter_cafe',
        archetypeLabel: 'Counter cafe',
      ),
    );

    final catalog = POSExperienceCatalog.fromExperiences([
      defaultPOSExperience,
      quickCheckoutPOSExperience,
      cafeMode,
      assistedServicePOSExperience,
    ]);

    expect(catalog.isEmpty, isFalse);
    expect(catalog.isSingleExperience, isFalse);
    expect(catalog.sections.map((section) => section.productLine), [
      'Kaysir Core',
      'Kaysir Cafe',
    ]);
    expect(catalog.sections.first.experienceCount, 3);
    expect(catalog.sections.first.experiences.map((mode) => mode.id), [
      defaultPOSExperience.id,
      quickCheckoutPOSExperience.id,
      assistedServicePOSExperience.id,
    ]);
    expect(catalog.sections.last.experiences.single, cafeMode);
  });

  test('catalog treats blank product lines as unassigned', () {
    final unassignedMode = defaultPOSExperience.copyWith(
      id: 'unassigned',
      manifest: defaultPOSExperience.manifest.copyWith(productLine: ' '),
    );

    final catalog = POSExperienceCatalog.fromExperiences([unassignedMode]);

    expect(catalog.isSingleExperience, isTrue);
    expect(catalog.sections.single.productLine, 'Unassigned');
  });
}
