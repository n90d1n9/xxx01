import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_queue_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_filter_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('risk council follow-ups submit from decision', () {
    final asOfDate = DateTime(2026, 6, 5);
    final item = _queueItem(
      department: 'Finance',
      category: IncomingTalentRiskCouncilQueueCategory.program,
      severity: IncomingTalentRiskCouncilQueueSeverity.critical,
    );
    final container = _container(asOfDate, items: [item]);
    addTearDown(container.dispose);

    final decision = _submitDecision(
      container,
      item,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
      followUpDate: asOfDate.add(const Duration(days: 7)),
    );

    expect(container.read(followUpReadyTalentRiskCouncilDecisionsProvider), [
      decision,
    ]);

    _initializeFollowUpDraft(container, decision);
    final draft = container.read(
      incomingTalentRiskCouncilFollowUpDraftProvider,
    );
    final followUp = _followUpNotifier(container).submitDraft(draft);
    final summary = _followUpSummary(container);

    expect(followUp.id, 'talent-risk-council-follow-up-001');
    expect(followUp.decisionId, decision.id);
    expect(
      followUp.followUpType,
      IncomingTalentRiskCouncilFollowUpType.ownerCommitment,
    );
    expect(followUp.dueDate, decision.followUpDate);
    expect(followUp.status, IncomingTalentRiskCouncilFollowUpStatus.planned);
    expect(followUp.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Complete 1 risk council follow-up due soon.');
    expect(
      container.read(followUpReadyTalentRiskCouncilDecisionsProvider),
      isEmpty,
    );

    expect(
      () => _followUpNotifier(container).submitDraft(draft),
      throwsStateError,
    );
  });

  test('risk council follow-up draft specializes promotion resolution decisions', () {
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
      department: 'Finance',
      category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
      severity: IncomingTalentRiskCouncilQueueSeverity.critical,
      source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    final container = _container(asOfDate, items: [item, criticalItem]);
    addTearDown(container.dispose);

    final decision = _submitDecision(
      container,
      item,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    final criticalDecision = _submitDecision(
      container,
      criticalItem,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
      followUpDate: asOfDate.add(const Duration(days: 7)),
    );

    _initializeFollowUpDraft(container, decision);
    final draft = container.read(
      incomingTalentRiskCouncilFollowUpDraftProvider,
    );
    final followUp = _followUpNotifier(container).submitDraft(draft);
    final summary = _followUpSummary(container);

    expect(decision.isPromotionResolutionReview, isTrue);
    expect(
      decision.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(draft.followUpOwnerName, 'Finance Promotion Stabilization Partner');
    expect(
      draft.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(
      draft.followUpType,
      IncomingTalentRiskCouncilFollowUpType.monitoringReview,
    );
    expect(
      draft.actionPlan,
      'Review promotion stabilization evidence for Mira Lestari, confirm residual role risk, and decide whether to reopen follow-up or close monitoring.',
    );
    expect(
      draft.successCriteria,
      'Promotion resolution follow-up is closed with role-risk evidence, manager checkpoint, and council disposition recorded.',
    );
    expect(followUp.actionPlan, draft.actionPlan);
    expect(
      followUp.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(followUp.isPromotionResolutionReview, isTrue);
    expect(summary.promotionResolutionReviewCount, 1);
    expect(
      summary.nextAction,
      'Close the loop on 1 promotion stabilization follow-up.',
    );
    expect(
      defaultRiskCouncilFollowUpActionPlan(
        criticalDecision,
        IncomingTalentRiskCouncilFollowUpType.peopleBoardEscalation,
      ),
      'Package promotion stabilization escalation for Mira Lestari with role-risk evidence, manager checkpoint, and people-board decision ask.',
    );
  });

  test('risk council follow-up draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentRiskCouncilFollowUpDraft.empty(
      asOfDate,
    ).copyWith(
      decisionDate: asOfDate,
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      actionPlan: 'tiny',
      successCriteria: 'short',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a council decision',
      'Please enter a follow-up owner',
      'Select follow-up type',
      'Due date cannot be in the past',
      'Action plan must be at least 12 characters',
      'Success criteria must be at least 12 characters',
    ]);
  });

  test('risk council follow-ups follow status lifecycle', () {
    final asOfDate = DateTime(2026, 6, 5);
    final item = _queueItem(
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
      severity: IncomingTalentRiskCouncilQueueSeverity.watch,
    );
    final container = _container(asOfDate, items: [item]);
    addTearDown(container.dispose);

    final decision = _submitDecision(
      container,
      item,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.closeRisk,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    final followUp = _submitFollowUp(container, decision);
    var summary = _followUpSummary(container);

    expect(summary.nextAction, 'Start 1 planned risk follow-up.');

    _followUpNotifier(container).start(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.inProgressCount, 1);
    expect(summary.nextAction, 'Track 1 risk follow-up in progress.');

    _followUpNotifier(container).block(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 risk council follow-up.');

    _followUpNotifier(container).escalate(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.escalatedCount, 1);
    expect(
      summary.nextAction,
      'Track 1 escalated risk follow-up with people leadership.',
    );

    _followUpNotifier(container).complete(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.completedCount, 1);
    expect(summary.nextAction, 'Risk council follow-ups are complete.');
  });

  test('risk council follow-ups follow filters and summary attention', () {
    final asOfDate = DateTime(2026, 6, 5);
    final engineering = _queueItem(
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      category: IncomingTalentRiskCouncilQueueCategory.intervention,
      severity: IncomingTalentRiskCouncilQueueSeverity.watch,
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

    final engineeringDecision = _submitDecision(
      container,
      engineering,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.closeRisk,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    final engineeringFollowUp = _submitFollowUp(container, engineeringDecision);
    _followUpNotifier(container).complete(engineeringFollowUp.id);

    final financeDecision = _submitDecision(
      container,
      finance,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
      followUpDate: asOfDate.add(const Duration(days: 7)),
    );
    final financeFollowUp = _submitFollowUp(container, financeDecision);
    _followUpNotifier(container).escalate(financeFollowUp.id);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final followUps = container.read(
      filteredIncomingTalentRiskCouncilFollowUpsProvider,
    );
    final summary = _followUpSummary(container);

    expect(followUps.map((followUp) => followUp.department), ['Finance']);
    expect(summary.totalCount, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Track 1 escalated risk follow-up with people leadership.',
    );
  });

  test('risk council follow-ups follow source filter', () {
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

    final promotionDecision = _submitDecision(
      container,
      promotion,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    final interventionDecision = _submitDecision(
      container,
      intervention,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    _submitFollowUp(container, promotionDecision);
    _submitFollowUp(container, interventionDecision);

    container
        .read(incomingTalentRiskCouncilSourceFilterProvider.notifier)
        .state = IncomingTalentRiskCouncilQueueSource.promotionResolutionReview;

    final followUps = container.read(
      filteredIncomingTalentRiskCouncilFollowUpsProvider,
    );
    final summary = _followUpSummary(container);

    expect(followUps.map((followUp) => followUp.source), [
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    ]);
    expect(summary.totalCount, 1);
    expect(summary.promotionResolutionReviewCount, 1);
    expect(
      summary.nextAction,
      'Close the loop on 1 promotion stabilization follow-up.',
    );
  });

  test('risk council follow-up ready decisions follow source filter', () {
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
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    _submitDecision(
      container,
      intervention,
      outcome: IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );

    container
        .read(incomingTalentRiskCouncilSourceFilterProvider.notifier)
        .state = IncomingTalentRiskCouncilQueueSource.promotionResolutionReview;

    final readyDecisions = container.read(
      followUpReadyTalentRiskCouncilDecisionsProvider,
    );

    expect(readyDecisions.map((decision) => decision.source), [
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    ]);
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
  required DateTime followUpDate,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentRiskCouncilDecisionDraft.fromQueueItem(
    item: item,
    asOfDate: asOfDate,
  ).copyWith(outcome: outcome, followUpDate: followUpDate);

  return container
      .read(incomingTalentRiskCouncilDecisionsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentRiskCouncilFollowUp _submitFollowUp(
  ProviderContainer container,
  IncomingTalentRiskCouncilDecision decision,
) {
  _initializeFollowUpDraft(container, decision);
  return _followUpNotifier(
    container,
  ).submitDraft(container.read(incomingTalentRiskCouncilFollowUpDraftProvider));
}

void _initializeFollowUpDraft(
  ProviderContainer container,
  IncomingTalentRiskCouncilDecision decision,
) {
  container
      .read(incomingTalentRiskCouncilFollowUpDraftProvider.notifier)
      .initializeFromDecision(decision);
}

IncomingTalentRiskCouncilFollowUpsNotifier _followUpNotifier(
  ProviderContainer container,
) {
  return container.read(incomingTalentRiskCouncilFollowUpsProvider.notifier);
}

IncomingTalentRiskCouncilFollowUpSummary _followUpSummary(
  ProviderContainer container,
) {
  return container.read(incomingTalentRiskCouncilFollowUpSummaryProvider);
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
