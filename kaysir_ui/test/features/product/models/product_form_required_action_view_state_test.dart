import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_form_required_action_view_state.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';

void main() {
  test('required action view state limits hidden missing fields', () {
    final progress = _progressWithFourMissingFields();
    final viewState = ProductFormRequiredActionViewState.fromProgress(
      progress: progress,
      maxVisibleAttributes: 3,
      expanded: false,
    );

    expect(viewState.hasMissingAttributes, isTrue);
    expect(viewState.nextAttribute?.fieldId, 'price');
    expect(
      viewState.visibleAdditionalAttributes.map((attribute) => attribute.label),
      ['Initial Stock', 'Expiry date'],
    );
    expect(viewState.hiddenAdditionalAttributeCount, 1);
    expect(viewState.canExpand, isTrue);
    expect(viewState.canCollapse, isFalse);
    expect(viewState.additionalToggleLabel, 'Show 1 more');
  });

  test('required action view state reveals all hidden missing fields', () {
    final progress = _progressWithFourMissingFields();
    final viewState = ProductFormRequiredActionViewState.fromProgress(
      progress: progress,
      maxVisibleAttributes: 3,
      expanded: true,
    );

    expect(
      viewState.visibleAdditionalAttributes.map((attribute) => attribute.label),
      ['Initial Stock', 'Expiry date', 'Batch number'],
    );
    expect(viewState.hiddenAdditionalAttributeCount, 0);
    expect(viewState.canExpand, isFalse);
    expect(viewState.canCollapse, isTrue);
    expect(viewState.additionalToggleLabel, 'Show less');
  });

  test('required action view state clamps minimum visible count', () {
    final progress = _progressWithFourMissingFields();
    final viewState = ProductFormRequiredActionViewState.fromProgress(
      progress: progress,
      maxVisibleAttributes: 0,
      expanded: false,
    );

    expect(viewState.maxVisibleAttributes, 1);
    expect(viewState.visibleAdditionalAttributes, isEmpty);
    expect(viewState.hiddenAdditionalAttributeCount, 3);
    expect(viewState.additionalToggleLabel, 'Show 3 more');
  });
}

ProductFormSectionProgressOverview _progressWithFourMissingFields() {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );

  return buildProductFormSectionProgressOverview(
    overview: overview,
    values: const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    },
  );
}
