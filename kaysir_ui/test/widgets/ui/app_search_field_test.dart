import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';

void main() {
  testWidgets('read-only search field behaves like a command trigger', (
    tester,
  ) async {
    var pressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppSearchField(
              width: 280,
              hintText: 'Search pages...',
              readOnly: true,
              tooltip: 'Search pages',
              trailing: const Text('K'),
              onTap: () => pressed += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Search pages'), findsOneWidget);
    expect(find.text('Search pages...'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);
    expect(tester.getSize(find.byType(AppSearchField)), const Size(280, 44));

    await tester.tap(find.byTooltip('Search pages'));
    await tester.pump();

    expect(pressed, 1);
  });

  testWidgets('editable search field reports changes and submitted query', (
    tester,
  ) async {
    final controller = TextEditingController();
    var changed = '';
    var submitted = '';

    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppSearchField(
              width: 320,
              controller: controller,
              hintText: 'Search pages',
              trailing: const Icon(Icons.close),
              onChanged: (value) => changed = value,
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cash');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(controller.text, 'cash');
    expect(changed, 'cash');
    expect(submitted, 'cash');
  });
}
