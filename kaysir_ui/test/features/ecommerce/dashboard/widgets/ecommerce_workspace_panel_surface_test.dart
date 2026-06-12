import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('PanelSurface applies dashboard panel chrome', (tester) async {
    const backgroundColor = Color(0xFFF8FAFC);
    const borderColor = Color(0xFFCBD5E1);

    await tester.pumpWorkspaceWidget(
      const PanelSurface(
        color: backgroundColor,
        border: Border.fromBorderSide(BorderSide(color: borderColor)),
        elevated: true,
        child: Text('Operations'),
      ),
    );

    expect(find.text('Operations'), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(PanelSurface),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.color, backgroundColor);
    expect(decoration.border?.top.color, borderColor);
    expect(decoration.boxShadow, isNotNull);
  });
}
