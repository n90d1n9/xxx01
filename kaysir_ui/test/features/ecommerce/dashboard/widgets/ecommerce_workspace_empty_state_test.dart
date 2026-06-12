import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('EmptyState applies reusable quiet copy', (tester) async {
    await tester.pumpWorkspaceWidget(
      const EmptyState(
        message: 'Nothing queued.',
        centered: true,
        prominent: true,
      ),
    );

    expect(find.text('Nothing queued.'), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);

    final text = tester.widget<Text>(find.text('Nothing queued.'));
    expect(text.textAlign, TextAlign.center);
    expect(text.style?.fontWeight, FontWeight.w700);
    expect(tester.takeException(), isNull);
  });
}
