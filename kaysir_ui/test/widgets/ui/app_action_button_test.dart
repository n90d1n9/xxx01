import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  testWidgets('primary action renders a filled button and handles taps', (
    tester,
  ) async {
    var pressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppActionButton(
              label: 'Save',
              icon: Icons.save_outlined,
              onPressed: () => pressed += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(find.byIcon(Icons.save_outlined), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(pressed, 1);
  });

  testWidgets('text action renders a quiet text button with an icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppActionButton(
              label: 'Privacy',
              icon: Icons.privacy_tip_outlined,
              variant: AppActionButtonVariant.text,
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextButton, 'Privacy'), findsOneWidget);
    expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
  });

  testWidgets('dialog actions report cancel and destructive confirm', (
    tester,
  ) async {
    var cancelled = false;
    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppDialogActions(
              cancelLabel: 'Cancel',
              confirmLabel: 'Logout',
              confirmIcon: Icons.logout,
              confirmVariant: AppActionButtonVariant.destructive,
              onCancel: () => cancelled = true,
              onConfirm: () => confirmed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Logout'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(cancelled, isTrue);
    expect(confirmed, isFalse);

    await tester.tap(find.text('Logout'));
    await tester.pump();

    expect(confirmed, isTrue);
  });
}
