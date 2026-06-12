import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_close_button.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('DialogCloseButton renders reusable action', (tester) async {
    var closed = false;

    await tester.pumpWorkspaceWidget(
      DialogCloseButton(onPressed: () => closed = true),
    );

    expect(find.text('Close'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pump();

    expect(closed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
