import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/screens/auth/widgets/login_settings_section.dart';

void main() {
  testWidgets('emits remember, locale, and theme changes', (tester) async {
    bool? rememberValue;
    Locale? selectedLocale;
    var themeToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginSettingsSection(
            rememberMe: true,
            isLoading: false,
            locale: const Locale('en', 'EN'),
            supportedLocales: const [Locale('en', 'EN'), Locale('id', 'ID')],
            isDarkMode: false,
            localeLabel:
                (locale) =>
                    locale.languageCode == 'id' ? 'Indonesia' : 'English',
            onRememberChanged: (value) => rememberValue = value,
            onLocaleChanged: (locale) => selectedLocale = locale,
            onThemeToggle: () => themeToggled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Remember me'));
    await tester.pump();
    expect(rememberValue, isFalse);

    await tester.tap(find.byType(DropdownButtonFormField<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Indonesia').last);
    await tester.pumpAndSettle();
    expect(selectedLocale, const Locale('id', 'ID'));

    await tester.tap(find.byTooltip('Use dark theme'));
    await tester.pump();
    expect(themeToggled, isTrue);
  });

  testWidgets('disables mutable controls while loading', (tester) async {
    bool? rememberValue;
    Locale? selectedLocale;
    var themeToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginSettingsSection(
            rememberMe: true,
            isLoading: true,
            locale: const Locale('en', 'EN'),
            supportedLocales: const [Locale('en', 'EN'), Locale('id', 'ID')],
            isDarkMode: true,
            localeLabel:
                (locale) =>
                    locale.languageCode == 'id' ? 'Indonesia' : 'English',
            onRememberChanged: (value) => rememberValue = value,
            onLocaleChanged: (locale) => selectedLocale = locale,
            onThemeToggle: () => themeToggled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Remember me'));
    await tester.pump();
    expect(rememberValue, isNull);

    await tester.tap(find.byType(DropdownButtonFormField<Locale>));
    await tester.pumpAndSettle();
    expect(find.text('Indonesia'), findsNothing);
    expect(selectedLocale, isNull);

    await tester.tap(find.byTooltip('Use light theme'));
    await tester.pump();
    expect(themeToggled, isFalse);
  });
}
