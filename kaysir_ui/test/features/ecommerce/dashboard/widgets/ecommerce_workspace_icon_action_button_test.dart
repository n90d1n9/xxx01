import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_action_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('IconActionButton renders compact icon action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IconActionButton(
            valueKey: 'profile_menu',
            tooltip: 'Commerce profile',
            icon: Icons.view_quilt_outlined,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('profile_menu')), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byIcon(Icons.view_quilt_outlined), findsOneWidget);

    final button = tester.widget<IconButton>(find.byType(IconButton));
    final icon = tester.widget<Icon>(find.byIcon(Icons.view_quilt_outlined));

    expect(
      button.style?.fixedSize?.resolve(<WidgetState>{}),
      const Size.square(POSUiTokens.controlHeight),
    );
    expect(
      button.style?.minimumSize?.resolve(<WidgetState>{}),
      const Size.square(POSUiTokens.controlHeight),
    );
    expect(button.style?.tapTargetSize, MaterialTapTargetSize.shrinkWrap);
    expect(button.style?.visualDensity, VisualDensity.compact);
    expect(icon.size, 18);

    await tester.tap(find.byKey(const ValueKey('profile_menu')));
    await tester.pump();

    expect(pressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('IconActionButton can derive tonal colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: IconActionButton(
            tooltip: 'Commerce profile',
            icon: Icons.view_quilt_outlined,
            tone: VisualTone.primary,
            onPressed: null,
          ),
        ),
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    final style = button.style;

    expect(style?.foregroundColor?.resolve(<WidgetState>{}), scheme.primary);
    expect(
      style?.backgroundColor?.resolve(<WidgetState>{}),
      scheme.primaryContainer.withValues(alpha: 0.24),
    );
    expect(
      style?.side?.resolve(<WidgetState>{})?.color,
      scheme.primary.withValues(alpha: 0.18),
    );
    expect(
      style?.overlayColor?.resolve({WidgetState.pressed}),
      scheme.primary.withValues(alpha: 0.12),
    );
    expect(
      style?.foregroundColor?.resolve({WidgetState.disabled}),
      scheme.onSurface.withValues(alpha: 0.38),
    );
  });
}
