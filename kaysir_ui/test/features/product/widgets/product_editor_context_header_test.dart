import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_editor_header_view_state.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_editor_context_header.dart';

void main() {
  testWidgets('product editor context header renders workspace status', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(460, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductEditorContextHeader(
            viewState: _viewStateFor(const {
              'name': 'Spinach',
              'sku': 'SP-001',
              'category': 'Fresh',
              'description': 'Leafy greens',
            }),
          ),
        ),
      ),
    );

    expect(find.text('Add product'), findsOneWidget);
    expect(
      find.text(
        'Track freshness-critical product data before selling across channels',
      ),
      findsOneWidget,
    );
    expect(find.text('New product'), findsOneWidget);
    expect(find.text('Grocery and fresh goods'), findsOneWidget);
    expect(find.text('50% ready'), findsOneWidget);
    expect(find.text('4/8 required'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods'), findsOneWidget);
    expect(find.text('8 capabilities'), findsOneWidget);
    expect(find.text('4 pack required fields'), findsOneWidget);
  });
}

ProductEditorHeaderViewState _viewStateFor(Map<String, String> values) {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
  final progress = buildProductFormSectionProgressOverview(
    overview: overview,
    values: values,
  );

  return ProductEditorHeaderViewState.from(
    pack: groceryFreshGoodsProductManagementPack,
    saveSummary: buildProductFormSaveActionSummary(
      progress: progress,
      submitLabel: 'Add product',
      isEditing: false,
    ),
    isEditing: false,
  );
}
