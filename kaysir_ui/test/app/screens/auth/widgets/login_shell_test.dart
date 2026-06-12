import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/screens/auth/widgets/login_form_card.dart';
import 'package:kaysir/app/screens/auth/widgets/login_shell.dart';

void main() {
  testWidgets('uses the wide brand panel on desktop widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginShell(
            appName: 'Kaysir',
            logoAsset: 'missing.png',
            formPanel: const LoginFormCard(
              title: 'Sign In',
              subtitle: 'Welcome back',
              child: Text('Form body'),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Kaysir'), findsOneWidget);
    expect(find.text('POS ready'), findsOneWidget);
    expect(find.text('Form body'), findsOneWidget);
  });

  testWidgets('uses the compact brand panel on narrow widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 760);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginShell(
            appName: 'Kaysir',
            logoAsset: 'missing.png',
            formPanel: const LoginFormCard(
              title: 'Sign In',
              subtitle: 'Welcome back',
              child: Text('Form body'),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Kaysir'), findsOneWidget);
    expect(find.text('POS ready'), findsNothing);
    expect(find.text('Form body'), findsOneWidget);
  });
}
