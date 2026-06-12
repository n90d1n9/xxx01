import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_closure_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_resolution_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession activation closures submit from cleared resolution review',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final review = _submitReview(container, asOfDate);

      expect(
        container.read(
          closureReadySuccessionActivationResolutionReviewsProvider,
        ),
        [review],
      );

      container
          .read(incomingTalentSuccessionActivationClosureDraftProvider.notifier)
          .initializeFromReview(review);
      final draft = container.read(
        incomingTalentSuccessionActivationClosureDraftProvider,
      );
      final closure = container
          .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionActivationClosureSummaryProvider,
      );

      expect(closure.id, 'talent-succession-activation-closure-001');
      expect(closure.resolutionReviewId, review.id);
      expect(
        closure.closureType,
        IncomingTalentSuccessionActivationClosureType.promotion,
      );
      expect(
        closure.status,
        IncomingTalentSuccessionActivationClosureStatus.scheduled,
      );
      expect(closure.needsAttention, isFalse);
      expect(summary.totalClosures, 1);
      expect(summary.scheduledCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.nextAction, 'Prepare 1 closures due soon.');
      expect(
        container.read(
          closureReadySuccessionActivationResolutionReviewsProvider,
        ),
        isEmpty,
      );

      expect(
        () => container
            .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent succession activation closure draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentSuccessionActivationClosureDraft.empty(
        asOfDate,
      ).copyWith(
        resolutionOutcome:
            IncomingTalentSuccessionActivationResolutionOutcome.monitor,
        residualRisk: IncomingTalentSuccessionActivationResidualRisk.high,
        effectiveDate: asOfDate.subtract(const Duration(days: 1)),
        communicationPlan: 'short',
        accessReadiness: 'tiny',
        compensationNote: 'mini',
        governanceNote: 'low',
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a cleared resolution review',
        'Please enter a closure owner',
        'Resolution must be cleared before closure',
        'Residual risk must be low before closure',
        'Select closure type',
        'Select closure status',
        'Effective date cannot be in the past',
        'Please enter a handover owner',
        'Please enter an HR partner',
        'Communication plan must be at least 12 characters',
        'Access readiness must be at least 12 characters',
        'Compensation note must be at least 12 characters',
        'Governance note must be at least 12 characters',
      ]);
    },
  );

  test(
    'incoming talent succession activation closures follow filters and status updates',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final engineeringReview = _submitReview(
        container,
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
      );
      _submitClosure(container, engineeringReview);

      final financeReview = _submitReview(
        container,
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
      );
      final financeClosure = _submitClosure(container, financeReview);
      container
          .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
          .defer(financeClosure.id);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      var filtered = container.read(
        filteredIncomingTalentSuccessionActivationClosuresProvider,
      );
      var summary = container.read(
        incomingTalentSuccessionActivationClosureSummaryProvider,
      );

      expect(filtered.map((closure) => closure.candidateName), [
        'Mira Lestari',
      ]);
      expect(
        filtered.single.status,
        IncomingTalentSuccessionActivationClosureStatus.deferred,
      );
      expect(summary.totalClosures, 1);
      expect(summary.deferredCount, 1);
      expect(summary.nextAction, 'Resolve 1 deferred closures.');

      container
          .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
          .complete(filtered.single.id);

      filtered = container.read(
        filteredIncomingTalentSuccessionActivationClosuresProvider,
      );
      expect(filtered, isEmpty);

      container.read(talentNeedsAttentionProvider.notifier).state = false;
      filtered = container.read(
        filteredIncomingTalentSuccessionActivationClosuresProvider,
      );
      summary = container.read(
        incomingTalentSuccessionActivationClosureSummaryProvider,
      );

      expect(
        filtered.single.status,
        IncomingTalentSuccessionActivationClosureStatus.completed,
      );
      expect(summary.completedCount, 1);
      expect(
        summary.nextAction,
        'Succession transition closures are complete.',
      );
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionActivationResolutionReview _submitReview(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
}) {
  return container
      .read(
        incomingTalentSuccessionActivationResolutionReviewsProvider.notifier,
      )
      .submitDraft(
        IncomingTalentSuccessionActivationResolutionReviewDraft(
          escalationId: 'escalation-$id',
          checkInId: 'check-in-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          reviewerName: '$department Talent Partner',
          escalationPriority:
              IncomingTalentSuccessionActivationEscalationPriority.urgent,
          escalationStatus:
              IncomingTalentSuccessionActivationEscalationStatus.resolved,
          resolutionDate: asOfDate,
          outcome:
              IncomingTalentSuccessionActivationResolutionOutcome
                  .transitionCleared,
          residualRisk: IncomingTalentSuccessionActivationResidualRisk.low,
          finalConfidenceScore: 4,
          evidenceSummary:
              'Resolution evidence confirms transition is ready for closure.',
          sponsorConfirmation:
              'Sponsor confirmed the transition and stakeholder handoff.',
          nextGovernanceStep:
              'Complete HR closure and activate communication plan.',
          nextReviewDate: asOfDate.add(const Duration(days: 14)),
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentSuccessionActivationClosure _submitClosure(
  ProviderContainer container,
  IncomingTalentSuccessionActivationResolutionReview review,
) {
  container
      .read(incomingTalentSuccessionActivationClosureDraftProvider.notifier)
      .initializeFromReview(review);
  return container
      .read(incomingTalentSuccessionActivationClosuresProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionActivationClosureDraftProvider),
      );
}
