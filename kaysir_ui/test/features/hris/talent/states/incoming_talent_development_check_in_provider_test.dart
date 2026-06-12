import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_check_in_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_roadmap_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('incoming talent development check-in defaults from risk roadmap', () {
    final asOfDate = DateTime(2026, 5, 30);
    final roadmap = _roadmap(
      asOfDate,
      status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
      risk: IncomingTalentActivationRetentionRisk.high,
      readinessScore: 48,
    );

    final draft = IncomingTalentDevelopmentCheckInDraft.fromRoadmap(
      roadmap: roadmap,
      asOfDate: asOfDate,
    );

    expect(draft.roadmapId, roadmap.id);
    expect(draft.trend, IncomingTalentDevelopmentCheckInTrend.blocked);
    expect(draft.confidenceScore, 2);
    expect(draft.blockerNote, contains('escalation'));
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('incoming talent development check-ins submit and summarize risk', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final roadmap = _submitRoadmap(
      container,
      _roadmap(
        asOfDate,
        status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
        risk: IncomingTalentActivationRetentionRisk.high,
        readinessScore: 48,
      ),
    );

    final checkIn = _submitCheckIn(container, roadmap);

    expect(checkIn.id, 'talent-check-in-001');
    expect(checkIn.trend, IncomingTalentDevelopmentCheckInTrend.blocked);
    expect(checkIn.needsAttention, isTrue);

    expect(
      () => container
          .read(incomingTalentDevelopmentCheckInsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentDevelopmentCheckInDraftProvider),
          ),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentDevelopmentCheckInSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.lowConfidenceCount, 1);
    expect(summary.nextAction, 'Escalate 1 blocked development check-ins.');
  });

  test(
    'incoming talent development check-in draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentDevelopmentCheckInDraft.empty(
        asOfDate,
      ).copyWith(
        checkInDate: asOfDate.subtract(const Duration(days: 1)),
        trend: IncomingTalentDevelopmentCheckInTrend.blocked,
        confidenceScore: 0,
        blockerNote: 'short',
        nextAction: 'tiny',
        managerCommitment: 'mini',
        nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a development roadmap',
        'Please enter a reviewer',
        'Check-in date cannot be in the past',
        'Confidence score must be between 1 and 5',
        'Blocker notes must be at least 12 characters',
        'Next action must be at least 12 characters',
        'Manager commitment must be at least 12 characters',
        'Next review must be after the check-in date',
      ]);
    },
  );

  test('incoming talent development check-ins follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringRoadmap = _submitRoadmap(
      container,
      _roadmap(
        asOfDate,
        id: 'roadmap-engineering',
        outcomeReviewId: 'outcome-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        status: IncomingTalentDevelopmentRoadmapStatus.active,
        risk: IncomingTalentActivationRetentionRisk.low,
        readinessScore: 88,
      ),
    );
    _submitCheckIn(container, engineeringRoadmap);

    final financeRoadmap = _submitRoadmap(
      container,
      _roadmap(
        asOfDate,
        id: 'roadmap-finance',
        outcomeReviewId: 'outcome-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
        risk: IncomingTalentActivationRetentionRisk.high,
        readinessScore: 48,
      ),
    );
    _submitCheckIn(container, financeRoadmap);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentDevelopmentCheckInsProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentCheckInSummaryProvider,
    );

    expect(filtered.map((checkIn) => checkIn.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.trend,
      IncomingTalentDevelopmentCheckInTrend.blocked,
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Escalate 1 blocked development check-ins.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentDevelopmentRoadmap _submitRoadmap(
  ProviderContainer container,
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  return container
      .read(incomingTalentDevelopmentRoadmapsProvider.notifier)
      .submitDraft(
        IncomingTalentDevelopmentRoadmapDraft(
          outcomeReviewId: roadmap.outcomeReviewId,
          activationPlanId: roadmap.activationPlanId,
          handoffId: roadmap.handoffId,
          candidateId: roadmap.candidateId,
          candidateName: roadmap.candidateName,
          role: roadmap.role,
          department: roadmap.department,
          ownerName: roadmap.ownerName,
          mentorName: roadmap.mentorName,
          focusArea: roadmap.focusArea,
          learningObjective: roadmap.learningObjective,
          firstMilestone: roadmap.firstMilestone,
          successMetric: roadmap.successMetric,
          cadence: roadmap.cadence,
          status: roadmap.status,
          startDate: roadmap.startDate,
          targetCompletionDate: roadmap.targetCompletionDate,
          sourceDecision: roadmap.sourceDecision,
          retentionRisk: roadmap.retentionRisk,
          readinessScore: roadmap.readinessScore,
          asOfDate: roadmap.createdAt,
        ),
      );
}

IncomingTalentDevelopmentCheckIn _submitCheckIn(
  ProviderContainer container,
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  container
      .read(incomingTalentDevelopmentCheckInDraftProvider.notifier)
      .initializeFromRoadmap(roadmap);
  return container
      .read(incomingTalentDevelopmentCheckInsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentCheckInDraftProvider),
      );
}

IncomingTalentDevelopmentRoadmap _roadmap(
  DateTime asOfDate, {
  String id = 'roadmap-001',
  String outcomeReviewId = 'outcome-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentDevelopmentRoadmapStatus status,
  required IncomingTalentActivationRetentionRisk risk,
  required int readinessScore,
}) {
  return IncomingTalentDevelopmentRoadmap(
    id: id,
    outcomeReviewId: outcomeReviewId,
    activationPlanId: 'activation-$id',
    handoffId: 'handoff-$id',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    ownerName: '$department Manager',
    mentorName: '$department mentor',
    focusArea: '$role role excellence',
    learningObjective: 'Strengthen $role delivery capability.',
    firstMilestone: 'Complete first manager-reviewed delivery milestone.',
    successMetric: 'Raise readiness through manager-approved evidence.',
    cadence:
        risk == IncomingTalentActivationRetentionRisk.high
            ? IncomingTalentDevelopmentRoadmapCadence.weekly
            : IncomingTalentDevelopmentRoadmapCadence.biweekly,
    status: status,
    startDate: asOfDate,
    targetCompletionDate: asOfDate.add(const Duration(days: 60)),
    sourceDecision:
        risk == IncomingTalentActivationRetentionRisk.high
            ? IncomingTalentActivationOutcomeDecision.escalateRisk
            : IncomingTalentActivationOutcomeDecision.stabilized,
    retentionRisk: risk,
    readinessScore: readinessScore,
    createdAt: asOfDate,
  );
}
