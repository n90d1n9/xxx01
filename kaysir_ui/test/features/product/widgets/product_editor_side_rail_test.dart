import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_form_save_action.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';
import 'package:kaysir/features/product/widgets/product_editor_side_rail.dart';

void main() {
  testWidgets('product editor side rail composes guidance and save action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(460, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final overview = _overview();
    final progress = _progressFor(overview, const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });
    final groupProgress = _groupProgressFor(const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });
    ProductFormMissingRequiredAttribute? selectedMissingAttribute;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductEditorSideRail(
              overview: overview,
              progress: progress,
              groupProgress: groupProgress,
              saveSummary: buildProductFormSaveActionSummary(
                progress: progress,
                submitLabel: 'Add product',
                isEditing: false,
                groupProgress: groupProgress,
              ),
              onSelectMissingAttribute: (attribute) {
                selectedMissingAttribute = attribute;
              },
              onSubmit: () {
                submitCount += 1;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product setup sections'), findsOneWidget);
    expect(find.text('Editor sections'), findsOneWidget);
    expect(find.text('Commercial'), findsWidgets);
    expect(find.text('Expiry tracking'), findsOneWidget);
    expect(find.text('Required field guide'), findsOneWidget);
    expect(find.text('Product still needs required data'), findsOneWidget);
    expect(find.text('Review Price'), findsNWidgets(2));

    final navigatorReviewButton = find.widgetWithText(
      TextButton,
      'Review Price',
    );
    await tester.ensureVisible(navigatorReviewButton);
    await tester.pumpAndSettle();
    await tester.tap(navigatorReviewButton);
    await tester.pump();
    expect(selectedMissingAttribute?.fieldId, 'price');

    final reviewButton = find.widgetWithText(OutlinedButton, 'Review Price');
    await tester.ensureVisible(reviewButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewButton);
    await tester.pump();
    expect(selectedMissingAttribute?.fieldId, 'price');

    final submitButton = find.widgetWithText(FilledButton, 'Add product');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    expect(submitCount, 1);
  });

  testWidgets('product editor side rail reviews invalid pack save blockers', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(460, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final overview = _overview();
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
    final groupProgress = _groupProgressFor(values);
    ProductFormMissingRequiredAttribute? selectedReviewAttribute;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductEditorSideRail(
              overview: overview,
              progress: progress,
              groupProgress: groupProgress,
              saveSummary: buildProductFormSaveActionSummary(
                progress: progress,
                submitLabel: 'Add product',
                isEditing: false,
                groupProgress: groupProgress,
              ),
              onSelectMissingAttribute: (attribute) {
                selectedReviewAttribute = attribute;
              },
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Review product data'), findsOneWidget);
    expect(find.text('1 invalid'), findsWidgets);
    expect(find.text('Invalid Expiry date'), findsOneWidget);
    expect(find.text('Review Expiry date'), findsWidgets);

    final issueChip = find.text('Invalid Expiry date');
    await tester.ensureVisible(issueChip);
    await tester.pumpAndSettle();
    await tester.tap(issueChip);
    await tester.pump();
    expect(selectedReviewAttribute?.fieldId, 'expiry_date');

    selectedReviewAttribute = null;
    final reviewButton = find.widgetWithText(
      OutlinedButton,
      'Review Expiry date',
    );
    await tester.ensureVisible(reviewButton);
    await tester.pumpAndSettle();
    await tester.tap(reviewButton);
    await tester.pump();

    expect(selectedReviewAttribute?.fieldId, 'expiry_date');
  });
}

ProductFormSectionOverview _overview() {
  return buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
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

ProductFormSectionProgressOverview _progressFor(
  ProductFormSectionOverview overview,
  Map<String, String> values,
) {
  return buildProductFormSectionProgressOverview(
    overview: overview,
    values: values,
  );
}
