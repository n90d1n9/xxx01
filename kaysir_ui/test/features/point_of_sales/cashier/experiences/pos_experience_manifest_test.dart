import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';

void main() {
  test('manifest labels release stages and supported form factors', () {
    const manifest = POSExperienceManifest(
      productLine: 'Kaysir Cafe',
      archetypeKey: 'counter_cafe',
      archetypeLabel: 'Counter cafe',
      releaseStage: POSExperienceReleaseStage.preview,
      supportedFormFactors: [
        POSExperienceFormFactor.tablet,
        POSExperienceFormFactor.kiosk,
      ],
      traits: ['modifiers', 'fast-service'],
      dataTraits: ['menu', 'orders', 'payments'],
    );

    expect(manifest.releaseStage.label, 'Preview');
    expect(manifest.supportsFormFactor(POSExperienceFormFactor.tablet), isTrue);
    expect(
      manifest.supportsFormFactor(POSExperienceFormFactor.desktop),
      isFalse,
    );
    expect(
      manifest.supportedFormFactors.map((formFactor) => formFactor.label),
      ['Tablet', 'Kiosk'],
    );
  });

  test(
    'manifest copyWith replaces launch metadata without touching traits',
    () {
      const manifest = POSExperienceManifest(
        productLine: 'Kaysir Retail',
        archetypeKey: 'fashion_retail',
        archetypeLabel: 'Fashion retail',
        traits: ['variants', 'returns'],
        dataTraits: ['sku', 'inventory'],
      );

      final experimental = manifest.copyWith(
        releaseStage: POSExperienceReleaseStage.experimental,
        supportedFormFactors: [POSExperienceFormFactor.mobile],
      );

      expect(experimental.productLine, 'Kaysir Retail');
      expect(experimental.releaseStage, POSExperienceReleaseStage.experimental);
      expect(experimental.supportedFormFactors, [
        POSExperienceFormFactor.mobile,
      ]);
      expect(experimental.traits, ['variants', 'returns']);
      expect(experimental.dataTraits, ['sku', 'inventory']);
    },
  );
}
