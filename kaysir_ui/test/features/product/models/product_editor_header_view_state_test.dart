import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_editor_header_view_state.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';

void main() {
  test('product editor header view state describes add workflow', () {
    final overview = _overview(isEditing: false);
    final progress = _progressFor(overview, const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });
    final viewState = ProductEditorHeaderViewState.from(
      pack: groceryFreshGoodsProductManagementPack,
      saveSummary: buildProductFormSaveActionSummary(
        progress: progress,
        submitLabel: 'Add product',
        isEditing: false,
      ),
      isEditing: false,
    );

    expect(viewState.title, 'Add product');
    expect(viewState.modeLabel, 'New product');
    expect(viewState.packLabel, 'Grocery Fresh Goods');
    expect(viewState.businessModelLabel, 'Grocery and fresh goods');
    expect(viewState.readinessLabel, '50% ready');
    expect(viewState.requiredReadinessLabel, '4/8 required');
    expect(viewState.capabilityCountLabel, '8 capabilities');
    expect(viewState.packRequiredFieldCountLabel, '4 pack required fields');
    expect(viewState.isReady, isFalse);
    expect(viewState.isEditing, isFalse);
  });

  test('product editor header view state describes edit workflow', () {
    final overview = _overview(isEditing: true);
    final progress = _progressFor(overview, const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': '2026-07-01',
      'batch_number': 'B-01',
    });
    final viewState = ProductEditorHeaderViewState.from(
      pack: groceryFreshGoodsProductManagementPack,
      saveSummary: buildProductFormSaveActionSummary(
        progress: progress,
        submitLabel: 'Update product',
        isEditing: true,
      ),
      isEditing: true,
    );

    expect(viewState.title, 'Edit product');
    expect(viewState.modeLabel, 'Edit mode');
    expect(viewState.readinessLabel, '100% ready');
    expect(viewState.requiredReadinessLabel, '7/7 required');
    expect(viewState.isReady, isTrue);
    expect(viewState.isEditing, isTrue);
  });

  test('product editor header view state flags invalid pack data', () {
    final overview = _overview(isEditing: false);
    const values = {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': 'soon',
      'batch_number': 'B-01',
    };
    final progress = _progressFor(overview, values);
    final viewState = ProductEditorHeaderViewState.from(
      pack: groceryFreshGoodsProductManagementPack,
      saveSummary: buildProductFormSaveActionSummary(
        progress: progress,
        submitLabel: 'Add product',
        isEditing: false,
        groupProgress: _groupProgressFor(values),
      ),
      isEditing: false,
    );

    expect(viewState.readinessLabel, 'Needs review');
    expect(viewState.requiredReadinessLabel, '8/8 required');
    expect(viewState.isReady, isFalse);
  });
}

ProductFormSectionOverview _overview({required bool isEditing}) {
  return buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: isEditing,
  );
}

ProductFormSectionProgressOverview _progressFor(
  ProductFormSectionOverview overview,
  Map<String, String> values,
) {
  return buildProductFormSectionProgressOverview(
    overview: overview,
    values: values,
  );
}

ProductManagementPackFieldGroupProgressOverview _groupProgressFor(
  Map<String, String> values,
) {
  return buildProductManagementPackFieldGroupProgressOverview(
    groups: buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    ),
    values: values,
  );
}
