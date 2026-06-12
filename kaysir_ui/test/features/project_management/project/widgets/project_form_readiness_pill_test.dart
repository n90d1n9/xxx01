import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_readiness_pill.dart';

void main() {
  testWidgets('project form readiness pill renders ready and review states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              ProjectFormReadinessPill(issueCount: 0),
              ProjectFormReadinessPill(issueCount: 3),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(ProjectFormReadinessPill.pillKey), findsNWidgets(2));
    expect(find.text('Ready to save'), findsOneWidget);
    expect(find.text('3 items to review'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);
    expect(
      find.byTooltip('All required project form fields are ready.'),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Review the remaining project form fields before saving.'),
      findsOneWidget,
    );
  });
}
