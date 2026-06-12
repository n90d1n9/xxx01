import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';

void main() {
  test('product form section progress reports missing required fields', () {
    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );
    final progress = buildProductFormSectionProgressOverview(
      overview: overview,
      values: const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'price': '12',
        'description': 'Leafy greens',
        'expiry_date': '2026-07-01',
      },
    );

    expect(progress.requiredProgressLabel, '6/8 ready');
    expect(progress.readinessLabel, '2 required missing');
    expect(progress.isReady, isFalse);
    expect(progress.missingRequiredAttributes, hasLength(2));
    expect(progress.nextMissingRequiredAttribute?.fieldId, 'initial_stock');
    expect(progress.nextMissingRequiredAttribute?.label, 'Initial Stock');

    final identity = progress.progressFor(ProductFormSectionId.identity);
    expect(identity.readinessLabel, 'Ready');
    expect(identity.requiredProgressLabel, '4/4 required');

    final commercial = progress.progressFor(ProductFormSectionId.commercial);
    expect(commercial.readinessLabel, '1 missing required');
    expect(commercial.requiredProgressLabel, '1/2 required');

    final pack = progress.progressFor(ProductFormSectionId.packExtensions);
    expect(pack.readinessLabel, '1 missing required');
    expect(pack.requiredProgressLabel, '1/2 required');
    expect(pack.missingRequiredAttributes.single.attribute.id, 'batch_number');
  });

  test('product form section progress reports ready form', () {
    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );
    final progress = buildProductFormSectionProgressOverview(
      overview: overview,
      values: const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'price': '12',
        'initial_stock': '8',
        'description': 'Leafy greens',
        'expiry_date': '2026-07-01',
        'batch_number': 'B-01',
      },
    );

    expect(progress.requiredProgressLabel, '8/8 ready');
    expect(progress.readinessLabel, 'Ready to save');
    expect(progress.isReady, isTrue);
    expect(progress.missingRequiredAttributes, isEmpty);
    expect(progress.nextMissingRequiredAttribute, isNull);
  });
}
