import 'package:flutter/material.dart' hide ActionChip;
import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  testWidgets('EcommerceWorkspaceActionChip applies compact action chrome', (
    tester,
  ) async {
    const foregroundColor = Color(0xFF4338CA);
    const backgroundColor = Color(0xFFE0E7FF);
    const borderColor = Color(0xFFA5B4FC);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EcommerceWorkspaceActionChip(
            icon: Icons.search_rounded,
            label: 'Seller center',
            tooltip: 'Search Seller center',
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    final chip = tester.widget<material.ActionChip>(
      find.byType(material.ActionChip),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.search_rounded));

    expect(chip.backgroundColor, backgroundColor);
    expect(chip.side?.color, borderColor);
    expect(chip.visualDensity, VisualDensity.compact);
    expect(icon.color, foregroundColor);
    expect(chip.labelStyle?.color, foregroundColor);
    expect(chip.labelStyle?.fontWeight, FontWeight.w800);

    await tester.tap(find.text('Seller center'));
    await tester.pump();

    expect(pressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EcommerceWorkspaceActionChip can derive tonal colors', (
    tester,
  ) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: Scaffold(
          body: EcommerceWorkspaceActionChip(
            icon: Icons.storefront_outlined,
            label: 'Marketplace',
            tone: VisualTone.secondary,
            backgroundSource: ToneBackgroundSource.foreground,
            backgroundAlpha: 0.08,
            borderAlpha: 0.16,
            onPressed: () {},
          ),
        ),
      ),
    );

    final chip = tester.widget<material.ActionChip>(
      find.byType(material.ActionChip),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.storefront_outlined));

    expect(chip.backgroundColor, scheme.secondary.withValues(alpha: 0.08));
    expect(chip.side?.color, scheme.secondary.withValues(alpha: 0.16));
    expect(icon.color, scheme.secondary);
    expect(chip.labelStyle?.color, scheme.secondary);
  });
}
