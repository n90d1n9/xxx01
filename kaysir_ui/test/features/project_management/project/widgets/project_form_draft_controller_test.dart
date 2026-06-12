import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_draft_controller.dart';

void main() {
  test('project form draft controller reports invalid submit attempts', () {
    final controller = ProjectFormDraftController(
      initialDraft: ProjectFormDraft.initial(today: DateTime(2026, 6)),
    );

    final attempt = controller.submit();

    expect(attempt.canSubmit, isFalse);
    expect(attempt.draft, controller.draft);
    expect(
      controller.issues.map((issue) => issue.message),
      contains('Project name is required.'),
    );
  });

  test(
    'project form draft controller previews issues without storing them',
    () {
      final controller = ProjectFormDraftController(
        initialDraft: ProjectFormDraft.initial(today: DateTime(2026, 6)),
      );

      final previewIssues = controller.previewIssues();

      expect(
        previewIssues.map((issue) => issue.message),
        contains('Owner is required.'),
      );
      expect(controller.issues, isEmpty);
    },
  );

  test('project form draft controller refreshes existing issues on edits', () {
    final controller = ProjectFormDraftController(
      initialDraft: ProjectFormDraft.initial(today: DateTime(2026, 6)),
    );

    controller.submit();
    controller.updateDraft(_validDraft(name: 'Release Cutover'));

    expect(controller.draft.name, 'Release Cutover');
    expect(controller.issues, isEmpty);
  });

  test('project form draft controller resets draft and clears issues', () {
    final initialDraft = _validDraft(name: 'Release Cutover');
    final controller = ProjectFormDraftController(initialDraft: initialDraft);

    controller.updateDraft(initialDraft.copyWith(name: ''));
    controller.submit();
    controller.reset();

    expect(controller.draft, initialDraft);
    expect(controller.issues, isEmpty);
  });

  test('project form draft controller replaces initial reset target', () {
    final controller = ProjectFormDraftController(
      initialDraft: _validDraft(name: 'Release Cutover'),
    );
    final replacement = _validDraft(name: 'Campus Renovation');

    controller.replaceInitialDraft(replacement);
    controller.updateDraft(replacement.copyWith(name: 'Temporary Edit'));
    controller.reset();

    expect(controller.draft, replacement);
    expect(controller.issues, isEmpty);
  });
}

ProjectFormDraft _validDraft({required String name}) {
  return ProjectFormDraft(
    name: name,
    client: 'Platform Team',
    owner: 'Alya',
    sponsor: 'Technology Office',
    businessDomain: 'Software Development',
    summary:
        'Coordinates release readiness, rollback, and stakeholder rollout.',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 6, 10),
    health: ProjectHealth.onTrack,
    progress: 0.45,
    budgetUsed: 0.25,
  );
}
