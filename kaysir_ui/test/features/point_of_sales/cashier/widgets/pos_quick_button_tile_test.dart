import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_quick_button_tile.dart';

void main() {
  testWidgets('quick button tile dispatches taps when enabled', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 132,
            child: POSQuickButtonTile(
              button: _button,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Produce'), findsOneWidget);

    await tester.tap(find.text('Produce'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('quick button tile explains disabled handlers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 132,
            child: POSQuickButtonTile(button: _button, onPressed: null),
          ),
        ),
      ),
    );

    expect(
      find.byTooltip('Produce: handler not available for this POS surface.'),
      findsOneWidget,
    );
  });
}

const _button = POSQuickButton(
  id: 'produce',
  label: 'Produce',
  description: 'Open produce shortcuts.',
  intent: POSQuickButtonIntent.category('produce'),
  surface: POSQuickButtonSurface.primaryGrid,
  iconKey: 'nutrition',
);
