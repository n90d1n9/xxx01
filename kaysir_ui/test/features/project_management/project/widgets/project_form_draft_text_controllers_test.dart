import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_form_draft.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_draft_text_controllers.dart';

void main() {
  test('project form draft text controllers initialize from draft', () {
    final controllers = ProjectFormDraftTextControllers.fromDraft(_draft);
    addTearDown(controllers.dispose);

    expect(controllers.name.text, 'Release Cutover');
    expect(controllers.client.text, 'Platform Team');
    expect(controllers.owner.text, 'Alya');
    expect(controllers.sponsor.text, 'Technology Office');
    expect(
      controllers.summary.text,
      'Coordinates release readiness, rollback, and stakeholder rollout.',
    );
  });

  test('project form draft text controllers apply replacement draft', () {
    final controllers = ProjectFormDraftTextControllers.fromDraft(_draft);
    addTearDown(controllers.dispose);

    controllers.applyDraft(
      _draft.copyWith(
        name: 'Campus Renovation',
        client: 'Education Office',
        owner: 'Dewi',
        sponsor: 'Academic Operations',
        summary:
            'Coordinates classroom renovation, inspection proof, and opening readiness.',
      ),
    );

    expect(controllers.name.text, 'Campus Renovation');
    expect(controllers.client.text, 'Education Office');
    expect(controllers.owner.text, 'Dewi');
    expect(controllers.sponsor.text, 'Academic Operations');
    expect(
      controllers.summary.text,
      'Coordinates classroom renovation, inspection proof, and opening readiness.',
    );
  });
}

final _draft = ProjectFormDraft.initial(today: DateTime(2026, 6)).copyWith(
  name: 'Release Cutover',
  client: 'Platform Team',
  owner: 'Alya',
  sponsor: 'Technology Office',
  businessDomain: 'Software Development',
  summary: 'Coordinates release readiness, rollback, and stakeholder rollout.',
  health: ProjectHealth.onTrack,
  progress: 0.45,
  budgetUsed: 0.25,
);
