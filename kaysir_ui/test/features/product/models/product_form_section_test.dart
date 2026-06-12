import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';

void main() {
  test('product form section overview summarizes active pack attributes', () {
    final overview = buildProductFormSectionOverview(
      pack: groceryFreshGoodsProductManagementPack,
      isEditing: false,
    );

    expect(overview.sectionCount, 3);
    expect(overview.attributeCountLabel, '13 fields');
    expect(overview.requiredAttributeCountLabel, '8 required fields');
    expect(overview.sections.map((section) => section.title), [
      'Identity',
      'Commercial',
      'Pack extensions',
    ]);

    final packSection = overview.sections.last;
    expect(packSection.attributeCountLabel, '7 fields');
    expect(packSection.requiredAttributeCountLabel, '2 required fields');
    expect(packSection.attributes.map((attribute) => attribute.label), [
      'Barcode',
      'Unit',
      'Expiry date',
      'Batch number',
      'Weighted unit',
      'Shelf life',
      'Freshness status',
    ]);
    expect(packSection.attributes[2].typeLabel, 'Date');
    expect(packSection.attributes[2].requirementLabel, 'Required');
  });

  test('product form section overview relaxes initial stock while editing', () {
    final overview = buildProductFormSectionOverview(
      pack: coreProductManagementPack,
      isEditing: true,
    );
    final commercialSection = overview.sections.singleWhere(
      (section) => section.id == ProductFormSectionId.commercial,
    );

    expect(overview.attributeCountLabel, '8 fields');
    expect(overview.requiredAttributeCountLabel, '5 required fields');
    expect(commercialSection.requiredAttributeCountLabel, '1 required field');
    expect(
      commercialSection.attributes.last.description,
      'Locked after creation and managed through stock moves.',
    );
  });

  test('editable pack fields exclude base form fields', () {
    final fields = productManagementPackEditableFields(
      groceryFreshGoodsProductManagementPack,
    );

    expect(
      fields.map((field) => field.id),
      isNot(contains(ProductManagementFieldId.sku)),
    );
    expect(
      fields.map((field) => field.id),
      isNot(contains(ProductManagementFieldId.category)),
    );
    expect(fields.first.id, ProductManagementFieldId.barcode);
  });
}
