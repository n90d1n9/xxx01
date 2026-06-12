import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_escalation_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_resolution_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'incoming talent succession activation resolution reviews submit from resolved escalation',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final escalation = _submitResolvedEscalation(container, asOfDate);

      expect(
        container.read(resolutionReadySuccessionActivationEscalationsProvider),
        [escalation],
      );

      container
          .read(
            incomingTalentSuccessionActivationResolutionReviewDraftProvider
                .notifier,
          )
          .initializeFromEscalation(escalation);
      final draft = container.read(
        incomingTalentSuccessionActivationResolutionReviewDraftProvider,
      );
      final review = container
          .read(
            incomingTalentSuccessionActivationResolutionReviewsProvider
                .notifier,
          )
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionActivationResolutionReviewSummaryProvider,
      );

      expect(review.id, 'talent-succession-activation-resolution-001');
      expect(review.escalationId, escalation.id);
      expect(
        review.outcome,
        IncomingTalentSuccessionActivationResolutionOutcome.transitionCleared,
      );
      expect(
        review.residualRisk,
        IncomingTalentSuccessionActivationResidualRisk.low,
      );
      expect(review.finalConfidenceScore, 4);
      expect(review.needsAttention, isFalse);
      expect(summary.totalReviews, 1);
      expect(summary.clearedCount, 1);
      expect(summary.averageFinalConfidence, 4);
      expect(summary.nextAction, '1 succession transitions are cleared.');
      expect(
        container.read(resolutionReadySuccessionActivationEscalationsProvider),
        isEmpty,
      );

      expect(
        () => container
            .read(
              incomingTalentSuccessionActivationResolutionReviewsProvider
                  .notifier,
            )
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test(
    'incoming talent succession activation resolution review draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft =
          IncomingTalentSuccessionActivationResolutionReviewDraft.empty(
            asOfDate,
          ).copyWith(
            escalationStatus:
                IncomingTalentSuccessionActivationEscalationStatus.opened,
            resolutionDate: asOfDate.subtract(const Duration(days: 1)),
            finalConfidenceScore: 6,
            evidenceSummary: 'short',
            sponsorConfirmation: 'tiny',
            nextGovernanceStep: 'mini',
            nextReviewDate: asOfDate.subtract(const Duration(days: 2)),
          );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a resolved escalation',
        'Please enter a reviewer',
        'Escalation must be resolved before review',
        'Resolution date cannot be in the past',
        'Select resolution outcome',
        'Select residual risk',
        'Confidence must be between 1 and 5',
        'Evidence summary must be at least 12 characters',
        'Sponsor confirmation must be at least 12 characters',
        'Next governance step must be at least 12 characters',
        'Next review must be after resolution date',
      ]);
    },
  );

  test(
    'incoming talent succession activation resolution reviews follow talent filters',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = _container(asOfDate);
      addTearDown(container.dispose);

      final engineeringEscalation = _submitResolvedEscalation(
        container,
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
      );
      _submitReview(container, engineeringEscalation);

      final financeEscalation = _submitResolvedEscalation(
        container,
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        priority:
            IncomingTalentSuccessionActivationEscalationPriority.executive,
        confidenceScore: 2,
      );
      _submitReview(
        container,
        financeEscalation,
        outcome:
            IncomingTalentSuccessionActivationResolutionOutcome.panelReview,
        residualRisk: IncomingTalentSuccessionActivationResidualRisk.high,
        finalConfidenceScore: 2,
      );

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentSuccessionActivationResolutionReviewsProvider,
      );
      final summary = container.read(
        incomingTalentSuccessionActivationResolutionReviewSummaryProvider,
      );

      expect(filtered.map((review) => review.candidateName), ['Mira Lestari']);
      expect(
        filtered.single.outcome,
        IncomingTalentSuccessionActivationResolutionOutcome.panelReview,
      );
      expect(filtered.single.needsAttention, isTrue);
      expect(summary.totalReviews, 1);
      expect(summary.panelReviewCount, 1);
      expect(summary.attentionCount, 1);
      expect(summary.nextAction, 'Route 1 resolution reviews to panel.');
    },
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionActivationEscalation _submitResolvedEscalation(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  IncomingTalentSuccessionActivationEscalationPriority priority =
      IncomingTalentSuccessionActivationEscalationPriority.urgent,
  int confidenceScore = 3,
}) {
  final escalation = container
      .read(incomingTalentSuccessionActivationEscalationsProvider.notifier)
      .submitDraft(
        IncomingTalentSuccessionActivationEscalationDraft(
          checkInId: 'check-in-$id',
          activationPlanId: 'activation-$id',
          decisionId: 'decision-$id',
          candidateId: 'candidate-$id',
          candidateName: candidateName,
          role: role,
          department: department,
          targetRole: '$department Succession Lead',
          ownerName: '$department Talent Partner',
          checkInTrend:
              priority ==
                      IncomingTalentSuccessionActivationEscalationPriority
                          .executive
                  ? IncomingTalentSuccessionActivationCheckInTrend.blocked
                  : IncomingTalentSuccessionActivationCheckInTrend.watch,
          confidenceScore: confidenceScore,
          priority: priority,
          dueDate: asOfDate.add(const Duration(days: 7)),
          escalationReason:
              'Transition blocker requires sponsor decision and evidence.',
          decisionNeeded:
              'Confirm sponsor decision for succession transition blocker.',
          sponsorCommitment:
              'Sponsor will confirm scope and remove transition blocker.',
          successCriteria:
              'Restore succession transition confidence before review.',
          asOfDate: asOfDate,
        ),
      );
  container
      .read(incomingTalentSuccessionActivationEscalationsProvider.notifier)
      .resolve(escalation.id);
  return container
      .read(incomingTalentSuccessionActivationEscalationsProvider)
      .firstWhere((item) => item.id == escalation.id);
}

IncomingTalentSuccessionActivationResolutionReview _submitReview(
  ProviderContainer container,
  IncomingTalentSuccessionActivationEscalation escalation, {
  IncomingTalentSuccessionActivationResolutionOutcome? outcome,
  IncomingTalentSuccessionActivationResidualRisk? residualRisk,
  int? finalConfidenceScore,
}) {
  final notifier = container.read(
    incomingTalentSuccessionActivationResolutionReviewDraftProvider.notifier,
  );
  notifier.initializeFromEscalation(escalation);
  if (outcome != null) notifier.setOutcome(outcome);
  if (residualRisk != null) notifier.setResidualRisk(residualRisk);
  if (finalConfidenceScore != null) {
    notifier.setFinalConfidenceScore(finalConfidenceScore);
  }
  return container
      .read(
        incomingTalentSuccessionActivationResolutionReviewsProvider.notifier,
      )
      .submitDraft(
        container.read(
          incomingTalentSuccessionActivationResolutionReviewDraftProvider,
        ),
      );
}
