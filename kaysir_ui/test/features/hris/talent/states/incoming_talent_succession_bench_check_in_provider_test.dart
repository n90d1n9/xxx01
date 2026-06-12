import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_bench_replenishment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession bench check-ins submit from open bench plan',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final plan = _submitBenchPlan(
        container,
        asOfDate,
        priority: IncomingTalentSuccessionBenchReplenishmentPriority.critical,
        status: IncomingTalentSuccessionBenchReplenishmentStatus.active,
      );

      expect(
        container.read(checkInReadySuccessionBenchReplenishmentsProvider),
        [plan],
      );

      container
          .read(incomingTalentSuccessionBenchCheckInDraftProvider.notifier)
          .initializeFromReplenishment(plan);
      final draft = container.read(
        incomingTalentSuccessionBenchCheckInDraftProvider,
      );
      final checkIn = container
          .read(incomingTalentSuccessionBenchCheckInsProvider.notifier)
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionBenchCheckInSummaryProvider,
      );

      expect(checkIn.id, 'talent-succession-bench-check-in-001');
      expect(checkIn.benchReplenishmentId, plan.id);
      expect(checkIn.health, IncomingTalentSuccessionBenchCheckInHealth.atRisk);
      expect(checkIn.successorSlateCount, 2);
      expect(checkIn.readyNowCount, 0);
      expect(checkIn.readinessScore, 3);
      expect(checkIn.nextCheckInDate, asOfDate.add(const Duration(days: 7)));
      expect(summary.totalCheckIns, 1);
      expect(summary.atRiskCount, 1);
      expect(summary.attentionCount, 1);
      expect(summary.nextAction, 'Escalate 1 at-risk bench check-ins.');
      expect(
        container.read(checkInReadySuccessionBenchReplenishmentsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(incomingTalentSuccessionBenchCheckInsProvider.notifier)
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test('incoming talent succession bench check-in draft validates fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = IncomingTalentSuccessionBenchCheckInDraft.empty(
      asOfDate,
    ).copyWith(
      checkInDate: asOfDate.subtract(const Duration(days: 1)),
      nextCheckInDate: asOfDate.subtract(const Duration(days: 1)),
      successorSlateCount: 0,
      readyNowCount: -1,
      readinessScore: 0,
      blockerSummary: 'short',
      leadershipSupport: 'tiny',
      nextAction: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter an open bench plan',
      'Please enter a check-in owner',
      'Select bench priority',
      'Select bench plan status',
      'Check-in date cannot be in the past',
      'Select bench health',
      'Successor slate must be between 1 and 20',
      'Ready-now count cannot be negative',
      'Readiness score must be between 1 and 5',
      'Blocker summary must be at least 12 characters',
      'Leadership support must be at least 12 characters',
      'Next action must be at least 12 characters',
      'Next check-in must be after check-in date',
    ]);
  });

  test('incoming talent succession bench check-ins follow filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringPlan = _submitBenchPlan(
      container,
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      priority: IncomingTalentSuccessionBenchReplenishmentPriority.routine,
      status: IncomingTalentSuccessionBenchReplenishmentStatus.active,
    );
    _submitCheckIn(container, engineeringPlan);

    final financePlan = _submitBenchPlan(
      container,
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      priority: IncomingTalentSuccessionBenchReplenishmentPriority.critical,
      status: IncomingTalentSuccessionBenchReplenishmentStatus.blocked,
    );
    final financeCheckIn = _submitCheckIn(container, financePlan);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    var filtered = container.read(
      filteredIncomingTalentSuccessionBenchCheckInsProvider,
    );
    var summary = container.read(
      incomingTalentSuccessionBenchCheckInSummaryProvider,
    );

    expect(filtered.map((checkIn) => checkIn.candidateName), ['Mira Lestari']);
    expect(filtered.single, financeCheckIn);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 bench check-ins.');

    container.read(talentDepartmentProvider.notifier).state = 'Engineering';
    filtered = container.read(
      filteredIncomingTalentSuccessionBenchCheckInsProvider,
    );
    expect(filtered, isEmpty);

    container.read(talentNeedsAttentionProvider.notifier).state = false;
    filtered = container.read(
      filteredIncomingTalentSuccessionBenchCheckInsProvider,
    );
    summary = container.read(
      incomingTalentSuccessionBenchCheckInSummaryProvider,
    );

    expect(filtered.single.candidateName, 'Fajar Nugroho');
    expect(summary.onTrackCount, 1);
    expect(summary.nextAction, '1 bench check-ins are on track.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionBenchReplenishment _submitBenchPlan(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentSuccessionBenchReplenishmentPriority priority,
  required IncomingTalentSuccessionBenchReplenishmentStatus status,
}) {
  return container
      .read(incomingTalentSuccessionBenchReplenishmentsProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionBenchReplenishmentDraft(
          outcomeReviewId: 'outcome-$id',
          interventionId: 'intervention-$id',
          pulseId: 'pulse-$id',
          closureId: 'closure-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          ownerName: '$department Talent Partner',
          outcomeDecision:
              priority ==
                      IncomingTalentSuccessionBenchReplenishmentPriority.routine
                  ? IncomingTalentSuccessionTransitionOutcomeDecision.stabilized
                  : IncomingTalentSuccessionTransitionOutcomeDecision
                      .successionRework,
          residualRisk:
              priority ==
                      IncomingTalentSuccessionBenchReplenishmentPriority.routine
                  ? IncomingTalentSuccessionTransitionOutcomeResidualRisk.low
                  : IncomingTalentSuccessionTransitionOutcomeResidualRisk.high,
          priority: priority,
          status: status,
          targetReadyDate: asOfDate.add(const Duration(days: 30)),
          benchGap: 'Bench coverage needs refreshed successor capacity.',
          sourcingStrategy:
              'Blend internal successors with external coverage options.',
          developmentTrack:
              'Assign successor candidates to accelerated readiness work.',
          reviewCadence: 'Weekly bench coverage review until slate is stable.',
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentSuccessionBenchCheckIn _submitCheckIn(
  ProviderContainer container,
  IncomingTalentSuccessionBenchReplenishment plan,
) {
  container
      .read(incomingTalentSuccessionBenchCheckInDraftProvider.notifier)
      .initializeFromReplenishment(plan);
  return container
      .read(incomingTalentSuccessionBenchCheckInsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionBenchCheckInDraftProvider),
      );
}
