import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/layout_spec.dart';

void main() {
  test('LayoutSpec selects compact layout', () {
    final spec = LayoutSpec.fromWidth(390);

    expect(spec.mode, LayoutMode.compact);
    expect(spec.usesSidePanel, isFalse);
    expect(spec.contentPadding, 12);
    expect(spec.actionPanelWidth, 320);
  });

  test('LayoutSpec selects standard layout', () {
    final spec = LayoutSpec.fromWidth(720);

    expect(spec.mode, LayoutMode.standard);
    expect(spec.usesSidePanel, isFalse);
    expect(spec.contentPadding, 16);
    expect(spec.actionPanelWidth, 320);
  });

  test('LayoutSpec selects side panel layout', () {
    final spec = LayoutSpec.fromWidth(1100);

    expect(spec.mode, LayoutMode.sidePanel);
    expect(spec.usesSidePanel, isTrue);
    expect(spec.contentPadding, 16);
    expect(spec.actionPanelWidth, 360);
  });
}
