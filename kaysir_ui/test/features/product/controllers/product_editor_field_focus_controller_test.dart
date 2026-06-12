import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/controllers/product_editor_field_focus_controller.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';

void main() {
  test('product editor field focus controller creates stable anchors', () {
    final controller = ProductEditorFieldFocusController();
    addTearDown(controller.dispose);

    controller.ensureCoreInformationFieldAnchors();
    controller.ensurePackFieldAnchors(groceryFreshGoodsProductManagementPack);

    expect(
      controller.fieldFocusNodes,
      contains(ProductCoreInformationFieldIds.name),
    );
    expect(
      controller.fieldFocusNodes,
      contains(ProductCoreInformationFieldIds.price),
    );
    expect(
      controller.fieldFocusNodes,
      contains(ProductManagementFieldId.expiryDate.value),
    );
    expect(
      controller.fieldKeys,
      contains(ProductManagementFieldId.batchNumber.value),
    );
    expect(
      controller.focusNodeFor(ProductCoreInformationFieldIds.name),
      same(controller.focusNodeFor(ProductCoreInformationFieldIds.name)),
    );
    expect(
      controller.fieldKeyFor(ProductManagementFieldId.expiryDate.value),
      same(controller.fieldKeyFor(ProductManagementFieldId.expiryDate.value)),
    );
  });

  testWidgets('product editor field focus controller focuses attached field', (
    tester,
  ) async {
    final controller = ProductEditorFieldFocusController();
    addTearDown(controller.dispose);

    final fieldKey = controller.fieldKeyFor(
      ProductCoreInformationFieldIds.price,
    );
    final focusNode = controller.focusNodeFor(
      ProductCoreInformationFieldIds.price,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 900),
                KeyedSubtree(
                  key: fieldKey,
                  child: TextField(focusNode: focusNode),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final focusFuture = controller.focusFieldById(
      ProductCoreInformationFieldIds.price,
      isMounted: () => true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await focusFuture;

    expect(focusNode.hasFocus, isTrue);
  });
}
