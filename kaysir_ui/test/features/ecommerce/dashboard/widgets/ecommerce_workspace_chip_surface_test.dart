import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/chip_surface.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ChipSurface applies reusable chip chrome', (tester) async {
    const backgroundColor = Color(0xFFE8F5E9);
    const borderColor = Color(0xFF66BB6A);

    await tester.pumpWorkspaceWidget(
      const ChipSurface(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        child: Text('Marketplace'),
      ),
    );

    expect(find.text('Marketplace'), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(ChipSurface),
        matching: find.byType(DecoratedBox),
      ),
    );
    final padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(ChipSurface),
        matching: find.byType(Padding),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.color, backgroundColor);
    expect(decoration.border?.top.color, borderColor);
    expect(
      padding.padding,
      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  });
}
