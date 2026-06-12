import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_queue_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_filter_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('risk council decision draft defaults from queue item', () {
    final asOfDate = DateTime(2026, 6, 5);
    final item = _queueItem(
      department: 'Finance',
      category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
      severity: IncomingTalentRiskCouncilQueueSeverity.critical,
    );
    final container = _container(asOfDate, items: [item]);
    addTearDown(container.dispose);

    container
        .read(incomingTalentRiskCouncilDecisionDraftProvider.notifier)
        .initializeFromQueueItem(item);
    final draft = container.read(
      incomingTalentRiskCouncilDecisionDraftProvider,
    );

    expect(draft.queueItemId, item.id);
    expect(draft.decisionMakerName, 'Talent Council');
    expect(draft.ownerName, 'Finance Talent Partner');
    expect(
      draft.outcome,
      IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
    );
    expect(draft.followUpDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('risk council decision draft specializes promotion resolution reviews', () {
    final asOfDate = DateTime(2026, 6, 5);
    final item = _queueItem(
      id: 'promotion-watch:promotion-resolution-review',
      department: 'Finance',
      category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
      severity: IncomingTalentRiskCouncilQueueSeverity.watch,
      source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    final criticalItem = _queueItem(
      id: 'promotion-critical:promotion-resolution-review',
      category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
      severity: IncomingTalentRiskCouncilQueueSeverity.critical,
      source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    final container = _container(asOfDate, items: [item]);
    addTearDown(container.dispose);

    container
        .read(incomingTalentRiskCouncilDecisionDraftProvider.notifier)
        .initializeFromQueueItem(item);
    final draft = container.read(
      incomingTalentRiskCouncilDecisionDraftProvider,
    );
    final decision = container
        .read(incomingTalentRiskCouncilDecisionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentRiskCouncilDecisionSummaryProvider,
    );

    expect(item.isPromotionResolutionReview, isTrue);
    expect(
      draft.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(draft.ownerName, 'Finance Promotion Stabilization Partner');
    expect(
      draft.outcome,
      IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    );
    expect(draft.followUpDate, asOfDate.add(const Duration(days: 30)));
    expect(
      draft.commitmentSummary,
      'Council will monitor promotion stabilization risk for Mira Lestari at the next talent risk council.',
    );
    expect(
      decision.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(summary.promotionResolutionReviewCount, 1);
    expect(
      summary.nextAction,
      'Track 1 promotion resolution council decision through stabilization evidence.',
    );
    expect(
      defaultRiskCouncilDecisionOutcome(criticalItem),
      IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
    );
    expect(
      defaultRiskCouncilCommitmentSummary(
        criticalItem,
        IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
      ),
      'Council escalated promotion stabilization risk for Mira Lestari to people board for role-risk decision.',
    );
  });

  test('risk council decisions submit, dedupe, and update summary', () {
    final asOfDate = DateTime(2026, 6, 5);
    final item = _queueItem(
      department: 'Finance',
      category: IncomingTalentRiskCouncilQueueCategory.program,
      severity: IncomingTalentRiskCouncilQueueSeverity.critical,
    );
    final container = _container(asOfDate, items: [item]);
    addTearDown(container.dispose);

    expect(container.read(decisionReadyTalentRiskCouncilQueueItemsProvider), [
      item,
    ]);

    container
        .read(incomingTalentRiskCouncilDecisionDraftProvider.notifier)
        .initializeFromQueueItem(item);
    final draft = container.read(
      incomingTalentRiskCouncilDecisionDraftProvider,
    );
    final decision = container
        .read(incomingTalentRiskCouncilDecisionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentRiskCouncilDecisionSummaryProvider,
    );

    expect(decision.id, 'talent-risk-council-decision-001');
    expect(decision.queueItemId, item.id);
    expect(
      decision.outcome,
      IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
    );
    expect(decision.needsAttention, isTrue);
    expect(summary.totalDecisions, 1);
    expect(summary.assignedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Confirm 1 accountable risk owner.');
    expect(
      container.read(decisionReadyTalentRiskCouncilQueueItemsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentRiskCouncilDecisionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('risk council decision draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentRiskCouncilDecisionDraft.empty(
      asOfDate,
    ).copyWith(
      decisionDate: asOfDate.subtract(const Duration(days: 1)),
      commitmentSummary: 'tiny',
      minutesNote: 'short',
      followUpDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a council queue item',
      'Please enter a decision maker',
      'Please enter an owner',
      'Select council decision',
      'Decision date cannot be in the past',
      'Follow-up must be after decision date',
      'Commitment summary must be at least 12 characters',
      'Minutes note must be at least 12 characters',
    ]);
  });

  test('risk council decisions follow filters and summary attention', () {
    final asOfDate = DateTime(2026, 6, 5);
    final engineering = _queueItem(
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      category: IncomingTalentRiskCouncilQueueCategory.intervention,
      severity: IncomingTalentRiskCouncilQueueSeverity.critical,
    );
    final finance = _queueItem(
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      category: IncomingTalentRiskCouncilQueueCategory.followUp,
      severity: IncomingTalentRiskCouncilQueueSeverity.watch,
    );
    final container = _container(asOfDate, items: [engineering, finance]);
    addTearDown(container.dispose);

    _submitDecision(
      container,
      engineering,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.closeRisk,
    );
    _submitDecision(
      container,
      finance,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final decisions = container.read(
      filteredIncomingTalentRiskCouncilDecisionsProvider,
    );
    final summary = container.read(
      incomingTalentRiskCouncilDecisionSummaryProvider,
    );

    expect(decisions.map((decision) => decision.department), ['Finance']);
    expect(summary.totalDecisions, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Escalate 1 talent council decision to people board.',
    );
  });

  test('risk council decisions follow source filter', () {
    final asOfDate = DateTime(2026, 6, 5);
    final promotion = _queueItem(
      id: 'promotion',
      category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
      severity: IncomingTalentRiskCouncilQueueSeverity.watch,
      source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    final intervention = _queueItem(
      id: 'intervention',
      candidateName: 'Fajar Nugroho',
      category: IncomingTalentRiskCouncilQueueCategory.intervention,
      severity: IncomingTalentRiskCouncilQueueSeverity.watch,
      source: IncomingTalentRiskCouncilQueueSource.developmentIntervention,
    );
    final container = _container(asOfDate, items: [promotion, intervention]);
    addTearDown(container.dispose);

    _submitDecision(
      container,
      promotion,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    );
    _submitDecision(
      container,
      intervention,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
    );

    container
        .read(incomingTalentRiskCouncilSourceFilterProvider.notifier)
        .state = IncomingTalentRiskCouncilQueueSource.promotionResolutionReview;

    final decisions = container.read(
      filteredIncomingTalentRiskCouncilDecisionsProvider,
    );
    final summary = container.read(
      incomingTalentRiskCouncilDecisionSummaryProvider,
    );

    expect(decisions.map((decision) => decision.source), [
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    ]);
    expect(summary.totalDecisions, 1);
    expect(summary.promotionResolutionReviewCount, 1);
    expect(
      summary.nextAction,
      'Track 1 promotion resolution council decision through stabilization evidence.',
    );
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentRiskCouncilQueueItem> items,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      incomingTalentRiskCouncilQueueItemsProvider.overrideWithValue(items),
    ],
  );
}

IncomingTalentRiskCouncilDecision _submitDecision(
  ProviderContainer container,
  IncomingTalentRiskCouncilQueueItem item, {
  required IncomingTalentRiskCouncilDecisionOutcome outcome,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentRiskCouncilDecisionDraft.fromQueueItem(
    item: item,
    asOfDate: asOfDate,
  ).copyWith(
    outcome: outcome,
    followUpDate: asOfDate.add(const Duration(days: 14)),
  );

  return container
      .read(incomingTalentRiskCouncilDecisionsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentRiskCouncilQueueItem _queueItem({
  String id = 'finance',
  String candidateName = 'Mira Lestari',
  String role = 'Senior Finance Analyst',
  String department = 'Finance',
  required IncomingTalentRiskCouncilQueueCategory category,
  required IncomingTalentRiskCouncilQueueSeverity severity,
  IncomingTalentRiskCouncilQueueSource source =
      IncomingTalentRiskCouncilQueueSource.general,
}) {
  return IncomingTalentRiskCouncilQueueItem(
    id: 'risk-council:$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    role: role,
    department: department,
    category: category,
    severity: severity,
    title: '$candidateName needs council decision',
    detail:
        'Council has enough evidence to decide the ownership and follow-up path.',
    recommendedAction:
        'Confirm owner, decision outcome, follow-up date, and minutes note.',
    dueDate: DateTime(2026, 6, 12),
    signalCount:
        severity == IncomingTalentRiskCouncilQueueSeverity.critical ? 3 : 1,
    source: source,
  );
}
