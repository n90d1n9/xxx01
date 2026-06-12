import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_dialog_surface.dart';

void main() {
  testWidgets('dialog surface respects narrow viewport constraints', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(320, 560)),
          child: Scaffold(
            body: AdminDialogSurface(
              maxWidth: 640,
              minWidth: 360,
              child: SizedBox(height: 120, child: Text('Adaptive content')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Adaptive content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
