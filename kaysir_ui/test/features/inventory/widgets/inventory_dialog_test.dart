import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dialog.dart';

void main() {
  testWidgets('inventory dialog frame applies shared modal chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: InventoryDialogFrame(child: Text('Dialog body'))),
    );

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.insetPadding, InventoryDialogFrame.insetPadding);
    expect(dialog.clipBehavior, Clip.antiAlias);
    expect(find.text('Dialog body'), findsOneWidget);
  });

  testWidgets('showInventoryDialog wraps dialog content and returns result', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await showInventoryDialog<String>(
                    context: context,
                    builder:
                        (dialogContext) => Center(
                          child: TextButton(
                            onPressed:
                                () => Navigator.of(dialogContext).pop('saved'),
                            child: const Text('Save'),
                          ),
                        ),
                  );
                },
                child: const Text('Open dialog'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.insetPadding, InventoryDialogFrame.insetPadding);
    expect(dialog.clipBehavior, Clip.antiAlias);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'saved');
    expect(find.byType(Dialog), findsNothing);
  });
}
