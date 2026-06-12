import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

void main() {
  testWidgets('contained info row renders badge, copy, and trailing content', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppInfoRow(
              contained: true,
              iconStyle: AppInfoRowIconStyle.badge,
              icon: Icons.dark_mode_outlined,
              title: 'Dark mode',
              subtitle: 'Switch the admin shell appearance',
              trailing: const Icon(Icons.toggle_on_outlined),
              onTap: () => taps += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Switch the admin shell appearance'), findsOneWidget);
    expect(find.byIcon(Icons.toggle_on_outlined), findsOneWidget);

    await tester.tap(find.text('Dark mode'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('plain info row keeps subtitle overflow configurable', (
    tester,
  ) async {
    const subtitle = 'very-long-email-address-for-a-workspace@example.com';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: AppInfoRow(
                icon: Icons.mail_outline,
                title: 'Email',
                subtitle: subtitle,
                subtitleMaxLines: 2,
              ),
            ),
          ),
        ),
      ),
    );

    final subtitleText = tester.widget<Text>(find.text(subtitle));

    expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    expect(subtitleText.maxLines, 2);
    expect(subtitleText.overflow, TextOverflow.ellipsis);
  });
}
