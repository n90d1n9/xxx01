import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession bench actions submit from risky check-in',
    () {
      final asOfDate = DateTime(2026, 6, 5);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final checkIn = _submitCheckIn(
        container,
        asOfDate,
        health: IncomingTalentSuccessionBenchCheckInHealth.atRisk,
        priority: IncomingTalentSuccessionBenchReplenishmentPriority.critical,
        readyNowCount: 0,
        readinessScore: 3,
      );

      expect(container.read(actionReadySuccessionBenchCheckInsProvider), [
        checkIn,
      ]);

      container
          .read(incomingTalentSuccessionBenchActionDraftProvider.notifier)
          .initializeFromCheckIn(checkIn);
      final draft = container.read(
        incomingTalentSuccessionBenchActionDraftProvider,
      );
      final action = container
          .read(incomingTalentSuccessionBenchActionsProvider.notifier)
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionBenchActionSummaryProvider,
      );

      expect(action.id, 'talent-succession-bench-action-001');
      expect(action.checkInId, checkIn.id);
      expect(
        action.actionType,
        IncomingTalentSuccessionBenchActionType.sourcing,
      );
      expect(action.status, IncomingTalentSuccessionBenchActionStatus.planned);
      expect(action.dueDate, asOfDate.add(const Duration(days: 7)));
      expect(summary.totalActions, 1);
      expect(summary.plannedCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.nextAction, 'Complete 1 bench actions due soon.');
      expect(
        container.read(actionReadySuccessionBenchCheckInsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(incomingTalentSuccessionBenchActionsProvider.notifier)
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test('incoming talent succession bench action draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentSuccessionBenchActionDraft.empty(
      asOfDate,
    ).copyWith(
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      actionPlan: 'short',
      escalationPath: 'tiny',
      resolutionEvidence: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter an attention check-in',
      'Please enter an action owner',
      'Select bench priority',
      'Select check-in health',
      'Select action type',
      'Select action status',
      'Due date cannot be in the past',
      'Action plan must be at least 12 characters',
      'Escalation path must be at least 12 characters',
      'Resolution evidence must be at least 12 characters',
    ]);
  });

  test(
    'incoming talent succession bench actions follow filters and statuses',
    () {
      final asOfDate = DateTime(2026, 6, 5);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final engineeringCheckIn = _submitCheckIn(
        container,
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        health: IncomingTalentSuccessionBenchCheckInHealth.onTrack,
        priority: IncomingTalentSuccessionBenchReplenishmentPriority.routine,
        readyNowCount: 2,
        readinessScore: 5,
      );
      final engineeringAction = _submitAction(container, engineeringCheckIn);
      container
          .read(incomingTalentSuccessionBenchActionsProvider.notifier)
          .resolve(engineeringAction.id);

      final financeCheckIn = _submitCheckIn(
        container,
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        health: IncomingTalentSuccessionBenchCheckInHealth.blocked,
        priority: IncomingTalentSuccessionBenchReplenishmentPriority.critical,
        readyNowCount: 0,
        readinessScore: 2,
      );
      final financeAction = _submitAction(container, financeCheckIn);
      container
          .read(incomingTalentSuccessionBenchActionsProvider.notifier)
          .block(financeAction.id);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      var filtered = container.read(
        filteredIncomingTalentSuccessionBenchActionsProvider,
      );
      var summary = container.read(
        incomingTalentSuccessionBenchActionSummaryProvider,
      );

      expect(filtered.map((action) => action.candidateName), ['Mira Lestari']);
      expect(
        filtered.single.status,
        IncomingTalentSuccessionBenchActionStatus.blocked,
      );
      expect(summary.blockedCount, 1);
      expect(summary.nextAction, 'Unblock 1 bench actions.');

      container
          .read(incomingTalentSuccessionBenchActionsProvider.notifier)
          .resolve(filtered.single.id);
      filtered = container.read(
        filteredIncomingTalentSuccessionBenchActionsProvider,
      );
      expect(filtered, isEmpty);

      container.read(talentNeedsAttentionProvider.notifier).state = false;
      filtered = container.read(
        filteredIncomingTalentSuccessionBenchActionsProvider,
      );
      summary = container.read(
        incomingTalentSuccessionBenchActionSummaryProvider,
      );

      expect(
        filtered.single.status,
        IncomingTalentSuccessionBenchActionStatus.resolved,
      );
      expect(summary.resolvedCount, 1);
      expect(summary.nextAction, '1 bench actions resolved.');
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionBenchCheckIn _submitCheckIn(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentSuccessionBenchCheckInHealth health,
  required IncomingTalentSuccessionBenchReplenishmentPriority priority,
  required int readyNowCount,
  required int readinessScore,
}) {
  return container
      .read(incomingTalentSuccessionBenchCheckInsProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionBenchCheckInDraft(
          benchReplenishmentId: 'bench-$id',
          outcomeReviewId: 'outcome-$id',
          interventionId: 'intervention-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          ownerName: '$department Talent Partner',
          priority: priority,
          planStatus: IncomingTalentSuccessionBenchReplenishmentStatus.active,
          checkInDate: asOfDate,
          health: health,
          successorSlateCount: 3,
          readyNowCount: readyNowCount,
          readinessScore: readinessScore,
          blockerSummary:
              'Bench blocker summary captures slate and readiness gaps.',
          leadershipSupport:
              'Leadership support confirms sponsor action for bench recovery.',
          nextAction:
              'Escalate bench blockers and confirm additional successor options.',
          nextCheckInDate: asOfDate.add(const Duration(days: 7)),
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentSuccessionBenchAction _submitAction(
  ProviderContainer container,
  IncomingTalentSuccessionBenchCheckIn checkIn,
) {
  container
      .read(incomingTalentSuccessionBenchActionDraftProvider.notifier)
      .initializeFromCheckIn(checkIn);
  return container
      .read(incomingTalentSuccessionBenchActionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionBenchActionDraftProvider),
      );
}
