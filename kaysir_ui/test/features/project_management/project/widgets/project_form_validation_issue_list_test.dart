import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_form_validation_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_validation_issue_list.dart';

void main() {
  testWidgets('project form validation issue list renders issue messages', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectFormValidationIssueList(
            issues: [
              ProjectFormIssue(
                field: 'name',
                message: 'Project name is required.',
              ),
              ProjectFormIssue(
                field: 'summary',
                message: 'Summary should explain the business outcome.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Before saving'), findsOneWidget);
    expect(find.byKey(ProjectFormValidationIssueList.listKey), findsOneWidget);
    expect(find.byKey(ProjectFormValidationIssueList.countKey), findsOneWidget);
    expect(find.text('2 items need attention'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_right_rounded), findsNWidgets(2));
    expect(find.text('Project name is required.'), findsOneWidget);
    expect(
      find.text('Summary should explain the business outcome.'),
      findsOneWidget,
    );
  });
}
