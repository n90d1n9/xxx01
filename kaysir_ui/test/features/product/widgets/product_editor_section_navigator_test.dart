import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_editor_section_navigator_view_state.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_editor_section_navigator.dart';

void main() {
  testWidgets('product editor section navigator renders reviewable rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(520, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ProductEditorSectionNavigatorItem? selectedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductEditorSectionNavigator(
              viewState: _viewStateFor(const {
                'name': 'Spinach',
                'sku': 'SP-001',
                'category': 'Fresh',
                'description': 'Leafy greens',
              }),
              onSelectItem: (item) {
                selectedItem = item;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Editor sections'), findsOneWidget);
    expect(
      find.text('Product readiness by section and capability'),
      findsOneWidget,
    );
    expect(find.text('4 required missing'), findsOneWidget);
    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Commercial'), findsOneWidget);
    expect(find.text('Expiry tracking'), findsOneWidget);
    expect(find.text('Open'), findsWidgets);
    expect(find.text('Review Price'), findsOneWidget);
    expect(find.text('Review Expiry date'), findsOneWidget);

    final identityOpen = find.widgetWithText(TextButton, 'Open').first;
    await tester.ensureVisible(identityOpen);
    await tester.pumpAndSettle();
    await tester.tap(identityOpen);
    await tester.pump();

    expect(selectedItem?.title, 'Identity');
    expect(selectedItem?.primaryAttribute?.id, 'name');

    final expiryReview = find.widgetWithText(TextButton, 'Review Expiry date');
    await tester.ensureVisible(expiryReview);
    await tester.pumpAndSettle();
    await tester.tap(expiryReview);
    await tester.pump();

    expect(selectedItem?.title, 'Expiry tracking');
    expect(selectedItem?.nextMissingAttribute?.fieldId, 'expiry_date');
  });
}

ProductEditorSectionNavigatorViewState _viewStateFor(
  Map<String, String> values,
) {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
  final progress = buildProductFormSectionProgressOverview(
    overview: overview,
    values: values,
  );

  return ProductEditorSectionNavigatorViewState.from(
    progress: progress,
    groupProgress: buildProductManagementPackFieldGroupProgressOverview(
      groups: buildProductManagementPackFieldGroups(
        groceryFreshGoodsProductManagementPack,
      ),
      values: values,
    ),
  );
}
