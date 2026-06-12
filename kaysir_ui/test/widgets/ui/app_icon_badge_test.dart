import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';

void main() {
  testWidgets('renders a themed fixed-size icon badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppIconBadge(
              icon: Icons.inventory_2_outlined,
              size: 40,
              iconSize: 20,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              borderColor: Colors.black,
              tooltip: 'Inventory',
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppIconBadge),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    final icon = tester.widget<Icon>(find.byIcon(Icons.inventory_2_outlined));
    final badgeSize = tester.getSize(
      find.descendant(
        of: find.byType(AppIconBadge),
        matching: find.byType(Container),
      ),
    );

    expect(find.byTooltip('Inventory'), findsOneWidget);
    expect(badgeSize, const Size.square(40));
    expect(decoration.color, Colors.blue);
    expect(decoration.border, isNotNull);
    expect(icon.color, Colors.white);
    expect(icon.size, 20);
  });
}
