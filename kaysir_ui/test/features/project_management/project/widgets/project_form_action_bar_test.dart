import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_action_bar.dart';

void main() {
  testWidgets('project form action bar renders reset and submit actions', (
    tester,
  ) async {
    var resetCount = 0;
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectFormActionBar(
            submitLabel: 'Save Changes',
            onReset: () => resetCount++,
            onSubmit: () => submitCount++,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('project-form-action-bar')),
      findsOneWidget,
    );
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.save_outlined), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.tap(find.text('Save Changes'));

    expect(resetCount, 1);
    expect(submitCount, 1);
  });
}
