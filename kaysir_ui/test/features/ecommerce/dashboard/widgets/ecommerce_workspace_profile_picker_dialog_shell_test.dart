import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_close_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_picker_dialog_shell.dart';

void main() {
  test('profilePickerDialogHeightFor clamps viewport height', () {
    expect(profilePickerDialogHeightFor(const Size(1024, 420)), 360);
    expect(profilePickerDialogHeightFor(const Size(1024, 700)), 520);
    expect(profilePickerDialogHeightFor(const Size(1024, 900)), 560);
  });

  testWidgets('ProfilePickerDialogShell renders reusable picker chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfilePickerDialogShell(
            height: 420,
            child: ColoredBox(
              key: ValueKey('profile_picker_shell_child'),
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('profile_picker_dialog')), findsOneWidget);
    expect(find.byType(DialogHeader), findsOneWidget);
    expect(find.byType(DialogCloseButton), findsOneWidget);
    expect(find.text('Commerce profile'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('profile_picker_shell_child'))),
      const Size(640, 420),
    );
    expect(tester.takeException(), isNull);
  });
}
