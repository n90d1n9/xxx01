import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_framework_level_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_readiness_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_readiness_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('promotion decision draft defaults from ready-now readiness', () {
    final asOfDate = DateTime(2026, 6, 9);
    final readiness = _readiness(asOfDate);

    final draft = IncomingTalentPromotionDecisionDraft.fromReadiness(
      readiness: readiness,
      asOfDate: asOfDate,
    );

    expect(draft.readinessId, readiness.id);
    expect(draft.candidateName, readiness.candidateName);
    expect(draft.newRole, readiness.targetRole);
    expect(draft.outcome, IncomingTalentPromotionDecisionOutcome.promoteNow);
    expect(draft.status, IncomingTalentPromotionDecisionStatus.approved);
    expect(draft.effectiveDate, asOfDate.add(const Duration(days: 30)));
    expect(draft.followUpDate, asOfDate.add(const Duration(days: 60)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('promotion decisions submit, prevent duplicates, and summarize', () {
    final asOfDate = DateTime(2026, 6, 9);
    final readiness = _readiness(asOfDate);
    final container = _container(asOfDate, readinessPackets: [readiness]);
    addTearDown(container.dispose);

    expect(container.read(promotionDecisionReadyReadinessProvider), [
      readiness,
    ]);

    final decision = _submitDecision(container, readiness);

    expect(decision.id, 'talent-promotion-decision-001');
    expect(decision.outcome, IncomingTalentPromotionDecisionOutcome.promoteNow);
    expect(decision.implementationProgress, 0.45);
    expect(decision.needsAttention, isFalse);
    expect(container.read(promotionDecisionReadyReadinessProvider), isEmpty);
    expect(() => _submitDecision(container, readiness), throwsStateError);

    final summary = container.read(
      incomingTalentPromotionDecisionSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.promoteNowCount, 1);
    expect(summary.approvedCount, 1);
    expect(summary.averageImplementationProgress, 0.45);
    expect(summary.nextAction, 'Route 1 promotion decisions to execution.');
  });

  test('promotion decision draft validates implementation fields', () {
    final asOfDate = DateTime(2026, 6, 9);
    final draft = IncomingTalentPromotionDecisionDraft.empty(asOfDate).copyWith(
      compensationBandNote: 'short',
      implementationNote: 'tiny',
      riskControlNote: 'small',
      effectiveDate: asOfDate.subtract(const Duration(days: 1)),
      followUpDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a promotion readiness packet',
      'Please enter a new role',
      'Please enter an owner',
      'Please enter an approver',
      'Select promotion outcome',
      'Compensation note must be at least 12 characters',
      'Implementation note must be at least 12 characters',
      'Risk control note must be at least 12 characters',
      'Effective date cannot be in the past',
      'Follow-up date must be after effective date',
    ]);
  });

  test('promotion decisions follow department and attention filters', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(asOfDate);
    addTearDown(container.dispose);
    final engineeringReadiness = _readiness(asOfDate);
    final financeReadiness = _readiness(
      asOfDate,
      id: 'finance',
      department: 'Finance',
      currentRole: 'Finance Analyst',
      targetRole: 'Finance Specialist',
      rating: IncomingTalentPromotionReadinessRating.readySoon,
      status: IncomingTalentPromotionReadinessStatus.calibration,
      sourcePriority: IncomingTalentCareerPathPriority.standard,
    );

    _submitDecision(container, engineeringReadiness);
    _submitDecision(container, financeReadiness);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentPromotionDecisionsProvider,
    );
    final summary = container.read(
      incomingTalentPromotionDecisionSummaryProvider,
    );

    expect(filtered.map((decision) => decision.department), ['Finance']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.trialCount, 1);
    expect(summary.routedCount, 1);
    expect(summary.nextAction, 'Route 1 promotion decisions to execution.');
  });
}

IncomingTalentPromotionReadiness _readiness(
  DateTime asOfDate, {
  String id = 'engineering',
  String department = 'Engineering',
  String currentRole = 'Backend Engineer',
  String targetRole = 'Lead Backend Engineer',
  IncomingTalentPromotionReadinessRating rating =
      IncomingTalentPromotionReadinessRating.readyNow,
  IncomingTalentPromotionReadinessStatus status =
      IncomingTalentPromotionReadinessStatus.endorsed,
  IncomingTalentCareerPathPriority sourcePriority =
      IncomingTalentCareerPathPriority.accelerated,
}) {
  return IncomingTalentPromotionReadiness(
    id: 'promotion-readiness-$id',
    careerPathId: 'career-path-$id',
    frameworkLevelId: 'framework-$id',
    candidateId: 'candidate-$id',
    candidateName: '$department Talent',
    department: department,
    currentRole: currentRole,
    targetRole: targetRole,
    frameworkFamilyName: '$currentRole family',
    frameworkLevelCode: 'L5',
    frameworkScope: IncomingTalentCareerFrameworkLevelScope.peopleLeadership,
    frameworkReviewCadence:
        IncomingTalentCareerFrameworkReviewCadence.quarterly,
    assessorName: '$department HRBP',
    rating: rating,
    status: status,
    competencyName: '$department leadership',
    evidenceSummary: 'Promotion evidence is ready for final panel decision.',
    gapSummary: 'No critical framework gaps remain open.',
    panelRecommendation: 'Endorse for final promotion panel decision.',
    reviewDate: asOfDate,
    nextReviewDate: asOfDate.add(const Duration(days: 90)),
    sourceCareerPathStatus: IncomingTalentCareerPathStatus.active,
    sourceCareerPathPriority: sourcePriority,
    createdAt: asOfDate,
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentPromotionReadiness> readinessPackets = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      if (readinessPackets.isNotEmpty)
        filteredIncomingTalentPromotionReadinessProvider.overrideWithValue(
          readinessPackets,
        ),
    ],
  );
}

IncomingTalentPromotionDecision _submitDecision(
  ProviderContainer container,
  IncomingTalentPromotionReadiness readiness,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentPromotionDecisionDraft.fromReadiness(
    readiness: readiness,
    asOfDate: asOfDate,
  );

  return container
      .read(incomingTalentPromotionDecisionsProvider.notifier)
      .submitDraft(draft);
}
