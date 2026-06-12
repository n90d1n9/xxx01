import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/models/auth/user.dart';
import 'package:kaysir/features/admin/widgets/admin_account_profile_panel.dart';
import 'package:kaysir/features/admin/widgets/admin_account_settings_panel.dart';
import 'package:kaysir/features/admin/widgets/admin_logout_confirmation_panel.dart';

void main() {
  const user = User(
    id: 1,
    firstName: 'Aisyah',
    lastName: 'Rahman',
    username: 'aisyah',
    email: 'aisyah@example.com',
    role: UserRole.admin,
  );

  testWidgets('profile panel renders account identity details', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(640, 720)),
          child: Scaffold(body: AdminAccountProfilePanel(user: user)),
        ),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Aisyah Rahman'), findsOneWidget);
    expect(find.text('aisyah@example.com'), findsOneWidget);
    expect(find.text('aisyah'), findsOneWidget);
    expect(find.text('Admin'), findsAtLeastNWidgets(1));
  });

  testWidgets('settings panel reports theme and locale changes', (
    tester,
  ) async {
    var toggledTheme = false;
    Locale? selectedLocale;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(640, 720)),
          child: Scaffold(
            body: AdminAccountSettingsPanel(
              themeMode: ThemeMode.light,
              locale: const Locale('id', 'ID'),
              supportedLocales: const [Locale('en', 'EN'), Locale('id', 'ID')],
              onToggleTheme: () => toggledTheme = true,
              onLocaleChanged: (locale) => selectedLocale = locale,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(toggledTheme, isTrue);

    await tester.tap(find.text('Bahasa Indonesia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(selectedLocale, const Locale('en', 'EN'));
  });

  testWidgets('logout confirmation reports cancel and confirm actions', (
    tester,
  ) async {
    var cancelled = false;
    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminLogoutConfirmationPanel(
            onCancel: () => cancelled = true,
            onConfirm: () => confirmed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(cancelled, isTrue);
    expect(confirmed, isFalse);

    await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
    await tester.pump();

    expect(confirmed, isTrue);
  });
}
