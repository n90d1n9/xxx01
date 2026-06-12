import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';

void main() {
  testWidgets('renders a fixed-size icon action and handles taps', (
    tester,
  ) async {
    var pressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppIconActionButton(
              icon: Icons.search,
              tooltip: 'Search pages',
              onPressed: () => pressed += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Search pages'), findsOneWidget);
    expect(tester.getSize(find.byType(IconButton)), const Size.square(40));

    await tester.tap(find.byTooltip('Search pages'));
    await tester.pump();

    expect(pressed, 1);
  });

  testWidgets('caps badge counts and supports tonal actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppIconActionButton(
              icon: Icons.notifications_outlined,
              tooltip: 'Notifications',
              badgeCount: 42,
              variant: AppIconActionButtonVariant.tonal,
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('renders selected icon when selected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppIconActionButton(
              icon: Icons.nightlight_round,
              selectedIcon: Icons.wb_sunny_outlined,
              tooltip: 'Toggle theme',
              isSelected: true,
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
    expect(find.byIcon(Icons.nightlight_round), findsNothing);
  });
}
