import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_form_submission_feedback_service.dart';

void main() {
  test('project form submission feedback formats outcomes', () {
    expect(
      projectFormSubmissionFeedbackMessage(
        projectName: 'Campus Renovation',
        kind: ProjectFormSubmissionFeedbackKind.created,
      ),
      'Project created: Campus Renovation',
    );
    expect(
      projectFormSubmissionFeedbackMessage(
        projectName: 'Campus Phase 2',
        kind: ProjectFormSubmissionFeedbackKind.updated,
      ),
      'Project updated: Campus Phase 2',
    );
  });

  testWidgets('project form submission feedback shows snackbar action', (
    tester,
  ) async {
    var viewTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showProjectFormSubmissionFeedback(
                        context,
                        projectName: 'Campus Renovation',
                        kind: ProjectFormSubmissionFeedbackKind.created,
                        action: SnackBarAction(
                          label: 'View',
                          onPressed: () => viewTapCount++,
                        ),
                      ),
                  child: const Text('Show feedback'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show feedback'));
    await tester.pump();

    expect(find.text('Project created: Campus Renovation'), findsOneWidget);

    final action = tester.widget<SnackBarAction>(
      find.widgetWithText(SnackBarAction, 'View'),
    );
    action.onPressed();
    await tester.pump();

    expect(viewTapCount, 1);
  });
}
