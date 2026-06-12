import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_closure_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_transition_pulse_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession transition pulses submit from completed closure',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final closure = _submitCompletedClosure(container, asOfDate);

      expect(container.read(pulseReadySuccessionActivationClosuresProvider), [
        closure,
      ]);

      container
          .read(incomingTalentSuccessionTransitionPulseDraftProvider.notifier)
          .initializeFromClosure(closure);
      final draft = container.read(
        incomingTalentSuccessionTransitionPulseDraftProvider,
      );
      final pulse = container
          .read(incomingTalentSuccessionTransitionPulsesProvider.notifier)
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionTransitionPulseSummaryProvider,
      );

      expect(pulse.id, 'talent-succession-transition-pulse-001');
      expect(pulse.closureId, closure.id);
      expect(
        pulse.pulseWindow,
        IncomingTalentSuccessionTransitionPulseWindow.thirtyDay,
      );
      expect(
        pulse.health,
        IncomingTalentSuccessionTransitionPulseHealth.stable,
      );
      expect(pulse.adoptionScore, 4);
      expect(pulse.managerConfidenceScore, 4);
      expect(pulse.needsAttention, isFalse);
      expect(summary.totalPulses, 1);
      expect(summary.stableCount, 1);
      expect(summary.averageAdoptionScore, 4);
      expect(summary.averageManagerConfidence, 4);
      expect(summary.nextAction, '1 transitions are stabilizing.');
      expect(container.read(pulseReadySuccessionActivationClosuresProvider), [
        closure,
      ]);

      expect(
        () => container
            .read(incomingTalentSuccessionTransitionPulsesProvider.notifier)
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent succession transition pulse draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentSuccessionTransitionPulseDraft.empty(
        asOfDate,
      ).copyWith(
        closureStatus: IncomingTalentSuccessionActivationClosureStatus.active,
        pulseDate: asOfDate.subtract(const Duration(days: 1)),
        adoptionScore: 6,
        managerConfidenceScore: 0,
        outcomeEvidence: 'short',
        employeeSignal: 'tiny',
        managerSignal: 'mini',
        stakeholderSentiment: 'low',
        nextAction: 'small',
        nextPulseDate: asOfDate.subtract(const Duration(days: 2)),
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a completed closure',
        'Please enter a pulse owner',
        'Select closure type',
        'Closure must be completed before pulse',
        'Select effective date',
        'Select pulse window',
        'Pulse date cannot be in the past',
        'Select pulse health',
        'Adoption score must be between 1 and 5',
        'Manager confidence score must be between 1 and 5',
        'Select retention risk',
        'Outcome evidence must be at least 12 characters',
        'Employee signal must be at least 12 characters',
        'Manager signal must be at least 12 characters',
        'Stakeholder sentiment must be at least 12 characters',
        'Next action must be at least 12 characters',
        'Next pulse must be after pulse date',
      ]);
    },
  );

  test('incoming talent succession transition pulses follow filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringClosure = _submitCompletedClosure(
      container,
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );
    _submitPulse(container, engineeringClosure);

    final financeClosure = _submitCompletedClosure(
      container,
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
    );
    _submitPulse(
      container,
      financeClosure,
      health: IncomingTalentSuccessionTransitionPulseHealth.intervention,
      adoptionScore: 2,
      managerConfidenceScore: 2,
      retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.high,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentSuccessionTransitionPulsesProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionTransitionPulseSummaryProvider,
    );

    expect(filtered.map((pulse) => pulse.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.health,
      IncomingTalentSuccessionTransitionPulseHealth.intervention,
    );
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalPulses, 1);
    expect(summary.interventionCount, 1);
    expect(summary.highRiskCount, 1);
    expect(summary.nextAction, 'Create interventions for 1 transition pulses.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionActivationClosure _submitCompletedClosure(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
}) {
  final closure = container
      .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionActivationClosureDraft(
          resolutionReviewId: 'resolution-$id',
          escalationId: 'escalation-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          ownerName: '$department Talent Partner',
          resolutionOutcome:
              IncomingTalentSuccessionActivationResolutionOutcome
                  .transitionCleared,
          residualRisk: IncomingTalentSuccessionActivationResidualRisk.low,
          closureType: IncomingTalentSuccessionActivationClosureType.promotion,
          status: IncomingTalentSuccessionActivationClosureStatus.scheduled,
          effectiveDate: asOfDate,
          handoverOwner: '$department Transition Owner',
          hrPartnerName: '$department HR Partner',
          communicationPlan:
              'Notify stakeholders and publish transition accountabilities.',
          accessReadiness:
              'Confirm access, reporting path, and approval ownership.',
          compensationNote:
              'HR partner confirms compensation and payroll timing.',
          governanceNote:
              'Continue governance cadence after transition activation.',
          asOfDate: asOfDate,
        ),
      );
  container
      .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
      .complete(closure.id);
  return container
      .read(incomingTalentSuccessionActivationClosuresProvider)
      .firstWhere((item) => item.id == closure.id);
}

IncomingTalentSuccessionTransitionPulse _submitPulse(
  ProviderContainer container,
  IncomingTalentSuccessionActivationClosure closure, {
  IncomingTalentSuccessionTransitionPulseHealth? health,
  int? adoptionScore,
  int? managerConfidenceScore,
  IncomingTalentSuccessionTransitionRetentionRisk? retentionRisk,
}) {
  final notifier = container.read(
    incomingTalentSuccessionTransitionPulseDraftProvider.notifier,
  );
  notifier.initializeFromClosure(closure);
  if (health != null) notifier.setHealth(health);
  if (adoptionScore != null) notifier.setAdoptionScore(adoptionScore);
  if (managerConfidenceScore != null) {
    notifier.setManagerConfidenceScore(managerConfidenceScore);
  }
  if (retentionRisk != null) notifier.setRetentionRisk(retentionRisk);

  return container
      .read(incomingTalentSuccessionTransitionPulsesProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionTransitionPulseDraftProvider),
      );
}
