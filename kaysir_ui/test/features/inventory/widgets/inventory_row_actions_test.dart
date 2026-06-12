import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_row_actions.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';

void main() {
  testWidgets('inventory row actions render shared icon buttons', (
    tester,
  ) async {
    var opened = false;
    var edited = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryRowActions(
            actions: [
              InventoryRowAction(
                icon: Icons.open_in_new_rounded,
                tooltip: 'Open row',
                variant: AppIconActionButtonVariant.tonal,
                onPressed: () => opened = true,
              ),
              InventoryRowAction(
                icon: Icons.edit_rounded,
                tooltip: 'Edit row',
                onPressed: () => edited = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppIconActionButton), findsNWidgets(2));

    await tester.tap(find.byTooltip('Open row'));
    await tester.tap(find.byTooltip('Edit row'));

    expect(opened, isTrue);
    expect(edited, isTrue);
  });

  testWidgets('inventory row actions collapse when empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: InventoryRowActions(actions: []))),
    );

    expect(find.byType(AppIconActionButton), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
