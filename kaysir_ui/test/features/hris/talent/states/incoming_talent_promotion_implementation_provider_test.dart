import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_implementation_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_readiness_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_implementation_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('promotion implementation draft defaults from decision', () {
    final asOfDate = DateTime(2026, 6, 9);
    final decision = _decision(asOfDate);

    final draft = IncomingTalentPromotionImplementationDraft.fromDecision(
      decision: decision,
      asOfDate: asOfDate,
    );

    expect(draft.decisionId, decision.id);
    expect(draft.candidateName, decision.candidateName);
    expect(
      draft.action,
      IncomingTalentPromotionImplementationAction.titleUpdate,
    );
    expect(draft.status, IncomingTalentPromotionImplementationStatus.planned);
    expect(draft.systemOfRecord, 'HRIS employee profile');
    expect(draft.dueDate, decision.effectiveDate);
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('promotion implementations submit, de-duplicate, and summarize', () {
    final asOfDate = DateTime(2026, 6, 9);
    final decision = _decision(asOfDate);
    final container = _container(asOfDate, decisions: [decision]);
    addTearDown(container.dispose);

    expect(container.read(promotionImplementationReadyDecisionsProvider), [
      decision,
    ]);

    final implementation = _submitImplementation(container, decision);

    expect(implementation.id, 'talent-promotion-implementation-001');
    expect(
      implementation.action,
      IncomingTalentPromotionImplementationAction.titleUpdate,
    );
    expect(implementation.progressRatio, 0.2);
    expect(implementation.needsAttention, isFalse);
    expect(
      container.read(promotionImplementationReadyDecisionsProvider),
      isEmpty,
    );
    expect(() => _submitImplementation(container, decision), throwsStateError);

    final summary = container.read(
      incomingTalentPromotionImplementationSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.titleUpdateCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.averageProgress, 0.2);
    expect(
      summary.nextAction,
      'Complete 1 promotion implementations due soon.',
    );
  });

  test('promotion implementation draft validates routing fields', () {
    final asOfDate = DateTime(2026, 6, 9);
    final draft = IncomingTalentPromotionImplementationDraft.empty(
      asOfDate,
    ).copyWith(
      status: IncomingTalentPromotionImplementationStatus.completed,
      implementationStep: 'short',
      evidenceNote: 'tiny',
      blockerNote: 'small',
      dueDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a promotion decision',
      'Please enter an owner',
      'Please enter an approver',
      'Select implementation action',
      'Please enter a system of record',
      'Implementation step must be at least 12 characters',
      'Evidence note must be at least 12 characters',
      'Blocker note must be at least 12 characters',
      'Due date cannot be in the past',
      'Select completed date',
    ]);
  });

  test('promotion implementations follow department and attention filters', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(asOfDate);
    addTearDown(container.dispose);
    final engineeringDecision = _decision(asOfDate);
    final financeDecision = _decision(
      asOfDate,
      id: 'finance',
      department: 'Finance',
      currentRole: 'Finance Analyst',
      newRole: 'Finance Specialist',
      outcome: IncomingTalentPromotionDecisionOutcome.deferPromotion,
      status: IncomingTalentPromotionDecisionStatus.deferred,
      effectiveDate: asOfDate.add(const Duration(days: 30)),
    );

    _submitImplementation(container, engineeringDecision);
    _submitImplementation(container, financeDecision);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentPromotionImplementationsProvider,
    );
    final summary = container.read(
      incomingTalentPromotionImplementationSummaryProvider,
    );

    expect(filtered.map((item) => item.department), ['Finance']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.attentionCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.nextAction, 'Start 1 planned promotion implementations.');
  });
}

IncomingTalentPromotionDecision _decision(
  DateTime asOfDate, {
  String id = 'engineering',
  String department = 'Engineering',
  String currentRole = 'Backend Engineer',
  String newRole = 'Lead Backend Engineer',
  IncomingTalentPromotionDecisionOutcome outcome =
      IncomingTalentPromotionDecisionOutcome.promoteNow,
  IncomingTalentPromotionDecisionStatus status =
      IncomingTalentPromotionDecisionStatus.approved,
  DateTime? effectiveDate,
}) {
  final date = effectiveDate ?? asOfDate.add(const Duration(days: 14));

  return IncomingTalentPromotionDecision(
    id: 'promotion-decision-$id',
    readinessId: 'promotion-readiness-$id',
    careerPathId: 'career-path-$id',
    frameworkLevelId: 'framework-$id',
    candidateId: 'candidate-$id',
    candidateName: '$department Talent',
    department: department,
    currentRole: currentRole,
    newRole: newRole,
    frameworkLevelCode: 'L5',
    ownerName: '$department HRBP',
    approverName: '$department people panel',
    outcome: outcome,
    status: status,
    compensationBandNote: 'Route L5 title and compensation band for approval.',
    implementationNote: 'Prepare promotion letter and HRIS title update.',
    riskControlNote: 'Confirm manager transition and backfill risk.',
    effectiveDate: date,
    followUpDate: date.add(const Duration(days: 30)),
    sourceRating: IncomingTalentPromotionReadinessRating.readyNow,
    sourceReadinessStatus: IncomingTalentPromotionReadinessStatus.endorsed,
    createdAt: asOfDate,
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentPromotionDecision> decisions = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      if (decisions.isNotEmpty)
        filteredIncomingTalentPromotionDecisionsProvider.overrideWithValue(
          decisions,
        ),
    ],
  );
}

IncomingTalentPromotionImplementation _submitImplementation(
  ProviderContainer container,
  IncomingTalentPromotionDecision decision,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentPromotionImplementationDraft.fromDecision(
    decision: decision,
    asOfDate: asOfDate,
  );

  return container
      .read(incomingTalentPromotionImplementationsProvider.notifier)
      .submitDraft(draft);
}
