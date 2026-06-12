import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('InsetSurface applies reusable inset chrome', (tester) async {
    const backgroundColor = Color(0xFFF1F5F9);
    const borderColor = Color(0xFF94A3B8);

    await tester.pumpWorkspaceWidget(
      const InsetSurface(
        color: backgroundColor,
        border: Border.fromBorderSide(BorderSide(color: borderColor)),
        child: Text('Signal tile'),
      ),
    );

    expect(find.text('Signal tile'), findsOneWidget);

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(InsetSurface),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;

    expect(decoration.color, backgroundColor);
    expect(decoration.border?.top.color, borderColor);
  });
}
