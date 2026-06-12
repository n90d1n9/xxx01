import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_pulse_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession transition interventions submit from attention pulse',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final pulse = _submitPulse(
        container,
        asOfDate,
        health: IncomingTalentSuccessionTransitionPulseHealth.intervention,
        adoptionScore: 2,
        managerConfidenceScore: 2,
        retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.high,
      );

      expect(
        container.read(interventionReadySuccessionTransitionPulsesProvider),
        [pulse],
      );

      container
          .read(
            incomingTalentSuccessionTransitionInterventionDraftProvider
                .notifier,
          )
          .initializeFromPulse(pulse);
      final draft = container.read(
        incomingTalentSuccessionTransitionInterventionDraftProvider,
      );
      final intervention = container
          .read(
            incomingTalentSuccessionTransitionInterventionsProvider.notifier,
          )
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionTransitionInterventionSummaryProvider,
      );

      expect(intervention.id, 'talent-succession-transition-intervention-001');
      expect(intervention.pulseId, pulse.id);
      expect(
        intervention.interventionType,
        IncomingTalentSuccessionTransitionInterventionType.retentionPlan,
      );
      expect(
        intervention.status,
        IncomingTalentSuccessionTransitionInterventionStatus.planned,
      );
      expect(intervention.dueDate, asOfDate.add(const Duration(days: 7)));
      expect(summary.totalInterventions, 1);
      expect(summary.plannedCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.nextAction, 'Complete 1 interventions due soon.');
      expect(
        container.read(interventionReadySuccessionTransitionPulsesProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(
              incomingTalentSuccessionTransitionInterventionsProvider.notifier,
            )
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent succession transition intervention draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentSuccessionTransitionInterventionDraft.empty(
        asOfDate,
      ).copyWith(
        dueDate: asOfDate.subtract(const Duration(days: 1)),
        interventionPlan: 'short',
        sponsorSupport: 'tiny',
        successMetric: 'mini',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter an attention pulse',
        'Please enter an intervention owner',
        'Select closure type',
        'Select pulse window',
        'Select pulse health',
        'Select retention risk',
        'Select intervention type',
        'Due date cannot be in the past',
        'Intervention plan must be at least 12 characters',
        'Sponsor support must be at least 12 characters',
        'Success metric must be at least 12 characters',
      ]);
    },
  );

  test(
    'incoming talent succession transition interventions follow filters and status updates',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final engineeringPulse = _submitPulse(
        container,
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        health: IncomingTalentSuccessionTransitionPulseHealth.watch,
        adoptionScore: 3,
        managerConfidenceScore: 4,
        retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.medium,
      );
      _submitIntervention(container, engineeringPulse);

      final financePulse = _submitPulse(
        container,
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        health: IncomingTalentSuccessionTransitionPulseHealth.intervention,
        adoptionScore: 2,
        managerConfidenceScore: 2,
        retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.high,
      );
      final financeIntervention = _submitIntervention(container, financePulse);

      container
          .read(
            incomingTalentSuccessionTransitionInterventionsProvider.notifier,
          )
          .block(financeIntervention.id);
      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      var filtered = container.read(
        filteredIncomingTalentSuccessionTransitionInterventionsProvider,
      );
      var summary = container.read(
        incomingTalentSuccessionTransitionInterventionSummaryProvider,
      );

      expect(filtered.map((intervention) => intervention.candidateName), [
        'Mira Lestari',
      ]);
      expect(
        filtered.single.status,
        IncomingTalentSuccessionTransitionInterventionStatus.blocked,
      );
      expect(summary.totalInterventions, 1);
      expect(summary.blockedCount, 1);
      expect(summary.nextAction, 'Unblock 1 transition interventions.');

      container
          .read(
            incomingTalentSuccessionTransitionInterventionsProvider.notifier,
          )
          .complete(filtered.single.id);
      filtered = container.read(
        filteredIncomingTalentSuccessionTransitionInterventionsProvider,
      );
      expect(filtered, isEmpty);

      container.read(talentNeedsAttentionProvider.notifier).state = false;
      filtered = container.read(
        filteredIncomingTalentSuccessionTransitionInterventionsProvider,
      );
      summary = container.read(
        incomingTalentSuccessionTransitionInterventionSummaryProvider,
      );

      expect(
        filtered.single.status,
        IncomingTalentSuccessionTransitionInterventionStatus.completed,
      );
      expect(summary.completedCount, 1);
      expect(summary.nextAction, 'Transition interventions are complete.');
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionTransitionPulse _submitPulse(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentSuccessionTransitionPulseHealth health,
  required int adoptionScore,
  required int managerConfidenceScore,
  required IncomingTalentSuccessionTransitionRetentionRisk retentionRisk,
}) {
  return container
      .read(incomingTalentSuccessionTransitionPulsesProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionTransitionPulseDraft(
          closureId: 'closure-$id',
          resolutionReviewId: 'resolution-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          ownerName: '$department Talent Partner',
          closureType: IncomingTalentSuccessionActivationClosureType.promotion,
          closureStatus:
              IncomingTalentSuccessionActivationClosureStatus.completed,
          effectiveDate: asOfDate,
          pulseWindow: IncomingTalentSuccessionTransitionPulseWindow.thirtyDay,
          pulseDate: asOfDate,
          health: health,
          adoptionScore: adoptionScore,
          managerConfidenceScore: managerConfidenceScore,
          retentionRisk: retentionRisk,
          outcomeEvidence:
              'Transition pulse evidence confirms current adoption state.',
          employeeSignal:
              'Employee signal captures role clarity and transition support.',
          managerSignal:
              'Manager signal captures delivery ownership and support gaps.',
          stakeholderSentiment:
              'Stakeholders report transition adoption and accountability.',
          nextAction:
              'Create focused transition support before the next pulse.',
          nextPulseDate: asOfDate.add(const Duration(days: 30)),
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentSuccessionTransitionIntervention _submitIntervention(
  ProviderContainer container,
  IncomingTalentSuccessionTransitionPulse pulse,
) {
  container
      .read(
        incomingTalentSuccessionTransitionInterventionDraftProvider.notifier,
      )
      .initializeFromPulse(pulse);
  return container
      .read(incomingTalentSuccessionTransitionInterventionsProvider.notifier)
      .submitDraft(
        container.read(
          incomingTalentSuccessionTransitionInterventionDraftProvider,
        ),
      );
}
