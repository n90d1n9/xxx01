import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_escalation_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession activation escalations submit from attention check-in',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final checkIn = _submitCheckIn(
        container,
        asOfDate,
        trend: IncomingTalentSuccessionActivationCheckInTrend.watch,
        confidenceScore: 3,
      );

      expect(
        container.read(escalationReadySuccessionActivationCheckInsProvider),
        [checkIn],
      );

      container
          .read(
            incomingTalentSuccessionActivationEscalationDraftProvider.notifier,
          )
          .initializeFromCheckIn(checkIn);
      final draft = container.read(
        incomingTalentSuccessionActivationEscalationDraftProvider,
      );
      final escalation = container
          .read(incomingTalentSuccessionActivationEscalationsProvider.notifier)
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionActivationEscalationSummaryProvider,
      );

      expect(escalation.id, 'talent-succession-activation-escalation-001');
      expect(escalation.checkInId, checkIn.id);
      expect(
        escalation.priority,
        IncomingTalentSuccessionActivationEscalationPriority.urgent,
      );
      expect(
        escalation.status,
        IncomingTalentSuccessionActivationEscalationStatus.opened,
      );
      expect(escalation.dueDate, asOfDate.add(const Duration(days: 7)));
      expect(escalation.needsAttention, isTrue);
      expect(summary.totalEscalations, 1);
      expect(summary.urgentCount, 1);
      expect(summary.nextAction, 'Close 1 urgent escalation actions.');
      expect(
        container.read(escalationReadySuccessionActivationCheckInsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(
              incomingTalentSuccessionActivationEscalationsProvider.notifier,
            )
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent succession activation escalation draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentSuccessionActivationEscalationDraft.empty(
        asOfDate,
      ).copyWith(
        confidenceScore: 6,
        dueDate: asOfDate.subtract(const Duration(days: 1)),
        escalationReason: 'short',
        decisionNeeded: 'tiny',
        sponsorCommitment: 'mini',
        successCriteria: 'low',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter an attention check-in',
        'Please enter an owner',
        'Select check-in trend',
        'Confidence must be between 1 and 5',
        'Select escalation priority',
        'Due date cannot be in the past',
        'Escalation reason must be at least 12 characters',
        'Decision needed must be at least 12 characters',
        'Sponsor commitment must be at least 12 characters',
        'Success criteria must be at least 12 characters',
      ]);
    },
  );

  test(
    'incoming talent succession activation escalations follow filters and status updates',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final engineeringCheckIn = _submitCheckIn(
        container,
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        trend: IncomingTalentSuccessionActivationCheckInTrend.watch,
        confidenceScore: 3,
      );
      _submitEscalation(container, engineeringCheckIn);

      final financeCheckIn = _submitCheckIn(
        container,
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        trend: IncomingTalentSuccessionActivationCheckInTrend.blocked,
        confidenceScore: 2,
      );
      _submitEscalation(container, financeCheckIn);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentSuccessionActivationEscalationsProvider,
      );
      var summary = container.read(
        incomingTalentSuccessionActivationEscalationSummaryProvider,
      );

      expect(filtered.map((escalation) => escalation.candidateName), [
        'Mira Lestari',
      ]);
      expect(
        filtered.single.priority,
        IncomingTalentSuccessionActivationEscalationPriority.executive,
      );
      expect(summary.totalEscalations, 1);
      expect(summary.executiveCount, 1);
      expect(
        summary.nextAction,
        'Secure executive decisions for 1 escalations.',
      );

      final notifier = container.read(
        incomingTalentSuccessionActivationEscalationsProvider.notifier,
      );
      notifier.block(filtered.single.id);
      summary = container.read(
        incomingTalentSuccessionActivationEscalationSummaryProvider,
      );
      expect(summary.blockedCount, 1);
      expect(summary.nextAction, 'Unblock 1 succession escalations.');

      notifier.resolve(filtered.single.id);
      expect(
        container.read(
          filteredIncomingTalentSuccessionActivationEscalationsProvider,
        ),
        isEmpty,
      );

      container.read(talentNeedsAttentionProvider.notifier).state = false;
      final resolved = container.read(
        filteredIncomingTalentSuccessionActivationEscalationsProvider,
      );
      summary = container.read(
        incomingTalentSuccessionActivationEscalationSummaryProvider,
      );

      expect(
        resolved.single.status,
        IncomingTalentSuccessionActivationEscalationStatus.resolved,
      );
      expect(summary.resolvedCount, 1);
      expect(
        summary.nextAction,
        'Succession activation escalations are resolved.',
      );
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionActivationCheckIn _submitCheckIn(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentSuccessionActivationCheckInTrend trend,
  required int confidenceScore,
}) {
  return container
      .read(incomingTalentSuccessionActivationCheckInsProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionActivationCheckInDraft(
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          reviewerName: '$department Talent Partner',
          checkInDate: asOfDate,
          trend: trend,
          confidenceScore: confidenceScore,
          milestoneHealth:
              'Transition milestone needs sponsor and stakeholder review.',
          blockerNote:
              trend == IncomingTalentSuccessionActivationCheckInTrend.onTrack
                  ? ''
                  : 'Sponsor alignment is delayed and role scope needs review.',
          sponsorAction:
              'Sponsor will review stakeholder handoff and remove blockers.',
          nextStep:
              'Complete sponsor decision and confirm role readiness evidence.',
          nextCheckInDate: asOfDate.add(const Duration(days: 30)),
          activationStatus:
              trend == IncomingTalentSuccessionActivationCheckInTrend.onTrack
                  ? IncomingTalentSuccessionActivationStatus.inProgress
                  : IncomingTalentSuccessionActivationStatus.atRisk,
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentSuccessionActivationEscalation _submitEscalation(
  ProviderContainer container,
  IncomingTalentSuccessionActivationCheckIn checkIn,
) {
  container
      .read(incomingTalentSuccessionActivationEscalationDraftProvider.notifier)
      .initializeFromCheckIn(checkIn);
  return container
      .read(incomingTalentSuccessionActivationEscalationsProvider.notifier)
      .submitDraft(
        container.read(
          incomingTalentSuccessionActivationEscalationDraftProvider,
        ),
      );
}
