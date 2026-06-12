import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/screens/auth/widgets/auth_text_field.dart';

void main() {
  testWidgets('renders label, prefix icon, and visibility toggle', (
    tester,
  ) async {
    var toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            controller: TextEditingController(),
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
            showVisibilityToggle: true,
            onVisibilityToggle: () => toggled = true,
          ),
        ),
      ),
    );

    expect(find.text('Password'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(toggled, isTrue);
  });
}
