import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_preview_pill.dart';

void main() {
  testWidgets('switch preview pill renders tone-aware icon and label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              POSSwitchPreviewPill(
                icon: Icons.check_circle_outline,
                label: 'Available',
                tone: POSSwitchPreviewTone.positive,
              ),
              POSSwitchPreviewPill(
                icon: Icons.info_outline,
                label: 'Review order',
                tone: POSSwitchPreviewTone.warning,
              ),
              POSSwitchPreviewPill(
                icon: Icons.block,
                label: 'Blocked',
                tone: POSSwitchPreviewTone.danger,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Review order'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byIcon(Icons.block), findsOneWidget);
  });

  test('switch preview pill colors resolve every tone', () {
    const colorScheme = ColorScheme.light();

    for (final tone in POSSwitchPreviewTone.values) {
      final colors = POSSwitchPreviewPillColors.resolve(colorScheme, tone);

      expect(colors.background, isNot(equals(Colors.transparent)));
      expect(colors.foreground, isNot(equals(Colors.transparent)));
      expect(colors.border, isNot(equals(Colors.transparent)));
    }
  });
}
