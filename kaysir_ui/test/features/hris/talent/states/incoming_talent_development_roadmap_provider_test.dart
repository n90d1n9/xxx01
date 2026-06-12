import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_roadmap_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('incoming talent development roadmap defaults from stable outcome', () {
    final asOfDate = DateTime(2026, 5, 30);
    final review = _review(
      asOfDate,
      decision: IncomingTalentActivationOutcomeDecision.stabilized,
      risk: IncomingTalentActivationRetentionRisk.low,
      readinessScore: 92,
    );

    final draft = IncomingTalentDevelopmentRoadmapDraft.fromOutcome(
      review: review,
      asOfDate: asOfDate,
    );

    expect(draft.outcomeReviewId, review.id);
    expect(draft.cadence, IncomingTalentDevelopmentRoadmapCadence.monthly);
    expect(draft.status, IncomingTalentDevelopmentRoadmapStatus.planned);
    expect(draft.targetCompletionDate, asOfDate.add(const Duration(days: 60)));
    expect(draft.focusArea, 'Role excellence');
    expect(draft.learningObjective, contains('delivery rituals'));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('incoming talent development roadmaps submit and summarize risk', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final review = _submitOutcomeReview(
      container,
      _review(
        asOfDate,
        decision: IncomingTalentActivationOutcomeDecision.escalateRisk,
        risk: IncomingTalentActivationRetentionRisk.high,
        readinessScore: 48,
      ),
    );

    final roadmap = _submitRoadmap(container, review);

    expect(roadmap.id, 'talent-roadmap-001');
    expect(roadmap.status, IncomingTalentDevelopmentRoadmapStatus.atRisk);
    expect(roadmap.cadence, IncomingTalentDevelopmentRoadmapCadence.weekly);
    expect(roadmap.needsAttention, isTrue);
    expect(
      container.read(roadmapReadyActivationOutcomeReviewsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentDevelopmentRoadmapsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentDevelopmentRoadmapDraftProvider),
          ),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentDevelopmentRoadmapSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.atRiskCount, 1);
    expect(summary.highRiskCount, 1);
    expect(summary.nextAction, 'Stabilize 1 at-risk development roadmaps.');
  });

  test(
    'incoming talent development roadmap draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentDevelopmentRoadmapDraft.empty(
        asOfDate,
      ).copyWith(
        focusArea: 'ab',
        learningObjective: 'short',
        firstMilestone: 'tiny',
        successMetric: 'mini',
        startDate: asOfDate.subtract(const Duration(days: 1)),
        targetCompletionDate: asOfDate.subtract(const Duration(days: 1)),
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter an outcome review',
        'Please enter an owner',
        'Please enter a mentor',
        'Focus area is too short',
        'Learning objective must be at least 12 characters',
        'First milestone must be at least 12 characters',
        'Success metric must be at least 12 characters',
        'Select a review cadence',
        'Select roadmap status',
        'Start date cannot be in the past',
        'Target completion must be after the start date',
      ]);
    },
  );

  test('incoming talent development roadmaps follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringReview = _submitOutcomeReview(
      container,
      _review(
        asOfDate,
        id: 'outcome-engineering',
        activationPlanId: 'activation-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        decision: IncomingTalentActivationOutcomeDecision.stabilized,
        risk: IncomingTalentActivationRetentionRisk.low,
        readinessScore: 92,
      ),
    );
    _submitRoadmap(container, engineeringReview);

    final financeReview = _submitOutcomeReview(
      container,
      _review(
        asOfDate,
        id: 'outcome-finance',
        activationPlanId: 'activation-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        decision: IncomingTalentActivationOutcomeDecision.escalateRisk,
        risk: IncomingTalentActivationRetentionRisk.high,
        readinessScore: 48,
      ),
    );
    _submitRoadmap(container, financeReview);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentDevelopmentRoadmapsProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentRoadmapSummaryProvider,
    );

    expect(filtered.map((roadmap) => roadmap.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.status,
      IncomingTalentDevelopmentRoadmapStatus.atRisk,
    );
    expect(summary.totalCount, 1);
    expect(summary.atRiskCount, 1);
    expect(summary.nextAction, 'Stabilize 1 at-risk development roadmaps.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentActivationOutcomeReview _submitOutcomeReview(
  ProviderContainer container,
  IncomingTalentActivationOutcomeReview review,
) {
  return container
      .read(incomingTalentActivationOutcomeReviewsProvider.notifier)
      .submitDraft(
        IncomingTalentActivationOutcomeDraft(
          activationPlanId: review.activationPlanId,
          handoffId: review.handoffId,
          candidateId: review.candidateId,
          candidateName: review.candidateName,
          role: review.role,
          department: review.department,
          reviewerName: review.reviewerName,
          reviewDate: review.reviewDate,
          decision: review.decision,
          retentionRisk: review.retentionRisk,
          readinessScore: review.readinessScore,
          nextDevelopmentTrack: review.nextDevelopmentTrack,
          evidenceNote: review.evidenceNote,
          decisionNote: review.decisionNote,
          asOfDate: review.createdAt,
        ),
      );
}

IncomingTalentDevelopmentRoadmap _submitRoadmap(
  ProviderContainer container,
  IncomingTalentActivationOutcomeReview review,
) {
  container
      .read(incomingTalentDevelopmentRoadmapDraftProvider.notifier)
      .initializeFromOutcome(review);
  return container
      .read(incomingTalentDevelopmentRoadmapsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentRoadmapDraftProvider),
      );
}

IncomingTalentActivationOutcomeReview _review(
  DateTime asOfDate, {
  String id = 'outcome-001',
  String activationPlanId = 'talent-activation-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentActivationOutcomeDecision decision,
  required IncomingTalentActivationRetentionRisk risk,
  required int readinessScore,
}) {
  return IncomingTalentActivationOutcomeReview(
    id: id,
    activationPlanId: activationPlanId,
    handoffId: 'handoff-$activationPlanId',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    reviewerName: '$department Manager',
    reviewDate: asOfDate,
    decision: decision,
    retentionRisk: risk,
    readinessScore: readinessScore,
    nextDevelopmentTrack: '$role excellence track',
    evidenceNote: 'Activation evidence confirms current readiness signals.',
    decisionNote: 'Manager and talent partner aligned on next decision.',
    createdAt: asOfDate,
  );
}
