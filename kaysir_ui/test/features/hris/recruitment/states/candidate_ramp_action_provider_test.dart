import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_ramp_action_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_ramp_action_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_ramp_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate ramp action draft validates required plan fields', () {
    final draft = CandidateRampActionDraft.empty(DateTime(2026, 6, 3));

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.completionRatio, 0);
    expect(draft.validationErrors, [
      'Please enter a candidate',
      'Please enter a mentor',
      'Please enter a learning plan',
      'Please enter an owner',
      'Please select a kickoff date',
      'Please select a readiness date',
      'Please enter ramp notes',
    ]);
  });

  test('candidate ramp action provider initializes from ramp plan', () {
    final container = _container();
    addTearDown(container.dispose);

    final plan = container
        .read(candidateRampPlansProvider)
        .singleWhere((item) => item.candidateName == 'Mira Lestari');

    container
        .read(candidateRampActionDraftProvider.notifier)
        .initializeFromPlan(plan);

    final draft = container.read(candidateRampActionDraftProvider);

    expect(draft.candidateName, 'Mira Lestari');
    expect(draft.department, 'Finance');
    expect(draft.mentorName, 'Emma Rodriguez');
    expect(draft.learningPlanTitle, 'Payroll close checklist');
    expect(draft.ownerName, 'Talent Partner');
    expect(draft.kickoffDate, DateTime(2026, 6, 10));
    expect(draft.readinessDate, DateTime(2026, 8, 2));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('candidate ramp actions submit and summarize ramp plans', () {
    final container = _container();
    addTearDown(container.dispose);

    final plan = container
        .read(candidateRampPlansProvider)
        .singleWhere((item) => item.candidateName == 'Galih Santoso');
    final draftNotifier = container.read(
      candidateRampActionDraftProvider.notifier,
    );
    draftNotifier.initializeFromPlan(plan);
    draftNotifier.setOwnerName('Operations Talent Partner');

    final actions = container.read(candidateRampActionsProvider.notifier);
    final action = actions.submitDraft(
      container.read(candidateRampActionDraftProvider),
    );

    expect(action.id, 'ramp-action-001');
    expect(action.candidateName, 'Galih Santoso');
    expect(action.ownerName, 'Operations Talent Partner');
    expect(action.status, CandidateRampActionStatus.submitted);

    final summary = container.read(candidateRampActionSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.submittedCount, 1);
    expect(summary.activeCount, 0);
    expect(summary.nextAction, 'Review submitted ramp plans with managers.');

    actions.activate(action.id);
    final activeSummary = container.read(candidateRampActionSummaryProvider);
    expect(activeSummary.submittedCount, 0);
    expect(activeSummary.activeCount, 1);
    expect(activeSummary.nextAction, 'Track active ramp checkpoints weekly.');
  });
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 3)),
      talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 3)),
    ],
  );
}
