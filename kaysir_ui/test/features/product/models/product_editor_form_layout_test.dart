import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_editor_form_layout.dart';

void main() {
  test('product editor layout stacks compact content', () {
    final layout = ProductEditorFormLayout.forWidth(900);

    expect(layout.mode, ProductEditorFormLayoutMode.stacked);
    expect(layout.isSplit, isFalse);
    expect(layout.sideRailWidth, 0);
    expect(layout.gap, 16);
  });

  test('product editor layout splits wide content into a side rail', () {
    final layout = ProductEditorFormLayout.forWidth(1100);

    expect(layout.mode, ProductEditorFormLayoutMode.split);
    expect(layout.isSplit, isTrue);
    expect(layout.sideRailWidth, 360);
    expect(layout.gap, 20);
  });
}
