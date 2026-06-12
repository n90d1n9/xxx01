import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_agenda_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('coverage council follow-ups submit from decision', () {
    final asOfDate = DateTime(2026, 6, 5);
    final item = _agendaItem(
      scopeLabel: 'Finance',
      lane: IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision,
      priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent,
      riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
      coverageScore: 38,
    );
    final container = _container(asOfDate, items: [item]);
    addTearDown(container.dispose);

    final decision = _submitDecision(
      container,
      item,
      outcome:
          IncomingTalentSuccessionCoverageCouncilDecisionOutcome
              .assignExecutiveSponsor,
      followUpDate: asOfDate.add(const Duration(days: 7)),
    );

    expect(container.read(followUpReadyCoverageCouncilDecisionsProvider), [
      decision,
    ]);

    _initializeFollowUpDraft(container, decision);
    final draft = container.read(
      incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider,
    );
    final followUp = _followUpNotifier(container).submitDraft(draft);
    final summary = _followUpSummary(container);

    expect(followUp.id, 'talent-succession-coverage-council-follow-up-001');
    expect(followUp.decisionId, decision.id);
    expect(
      followUp.followUpType,
      IncomingTalentSuccessionCoverageCouncilFollowUpType.sponsorCommitment,
    );
    expect(followUp.dueDate, decision.followUpDate);
    expect(
      followUp.status,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned,
    );
    expect(followUp.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Complete 1 council follow-ups due soon.');
    expect(
      container.read(followUpReadyCoverageCouncilDecisionsProvider),
      isEmpty,
    );

    expect(
      () => _followUpNotifier(container).submitDraft(draft),
      throwsStateError,
    );
  });

  test('coverage council follow-up draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentSuccessionCoverageCouncilFollowUpDraft.empty(
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

  test('coverage council follow-ups follow status lifecycle', () {
    final asOfDate = DateTime(2026, 6, 5);
    final item = _agendaItem(
      scopeLabel: 'Engineering',
      lane: IncomingTalentSuccessionCoverageCouncilAgendaLane.outcomeValidation,
      priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.watch,
      riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.low,
      coverageScore: 92,
    );
    final container = _container(asOfDate, items: [item]);
    addTearDown(container.dispose);

    final decision = _submitDecision(
      container,
      item,
      outcome:
          IncomingTalentSuccessionCoverageCouncilDecisionOutcome
              .validateClosure,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    final followUp = _submitFollowUp(container, decision);
    var summary = _followUpSummary(container);

    expect(summary.nextAction, 'Start 1 planned follow-ups.');

    _followUpNotifier(container).start(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.inProgressCount, 1);
    expect(summary.nextAction, 'Track 1 council follow-ups in progress.');

    _followUpNotifier(container).block(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 council follow-ups.');

    _followUpNotifier(container).escalate(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.escalatedCount, 1);
    expect(
      summary.nextAction,
      'Track 1 escalated follow-ups with people leadership.',
    );

    _followUpNotifier(container).complete(followUp.id);
    summary = _followUpSummary(container);
    expect(summary.completedCount, 1);
    expect(summary.nextAction, 'Council decision follow-ups are complete.');
  });

  test('coverage council follow-ups follow filters and summary attention', () {
    final asOfDate = DateTime(2026, 6, 5);
    final engineering = _agendaItem(
      id: 'engineering',
      scopeLabel: 'Engineering',
      lane: IncomingTalentSuccessionCoverageCouncilAgendaLane.outcomeValidation,
      priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.watch,
      riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.low,
      coverageScore: 90,
    );
    final finance = _agendaItem(
      id: 'finance',
      scopeLabel: 'Finance',
      lane: IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision,
      priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent,
      riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
      coverageScore: 42,
    );
    final container = _container(asOfDate, items: [engineering, finance]);
    addTearDown(container.dispose);

    final engineeringDecision = _submitDecision(
      container,
      engineering,
      outcome:
          IncomingTalentSuccessionCoverageCouncilDecisionOutcome
              .validateClosure,
      followUpDate: asOfDate.add(const Duration(days: 30)),
    );
    final engineeringFollowUp = _submitFollowUp(container, engineeringDecision);
    _followUpNotifier(container).complete(engineeringFollowUp.id);

    final financeDecision = _submitDecision(
      container,
      finance,
      outcome:
          IncomingTalentSuccessionCoverageCouncilDecisionOutcome
              .escalateToPeopleBoard,
      followUpDate: asOfDate.add(const Duration(days: 7)),
    );
    final financeFollowUp = _submitFollowUp(container, financeDecision);
    _followUpNotifier(container).escalate(financeFollowUp.id);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final followUps = container.read(
      filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider,
    );
    final summary = _followUpSummary(container);

    expect(followUps.map((followUp) => followUp.scopeLabel), ['Finance']);
    expect(summary.totalCount, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Track 1 escalated follow-ups with people leadership.',
    );
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentSuccessionCoverageCouncilAgendaItem> items,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      incomingTalentSuccessionCoverageCouncilAgendaItemsProvider
          .overrideWithValue(items),
    ],
  );
}

IncomingTalentSuccessionCoverageCouncilDecision _submitDecision(
  ProviderContainer container,
  IncomingTalentSuccessionCoverageCouncilAgendaItem item, {
  required IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome,
  required DateTime followUpDate,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft =
      IncomingTalentSuccessionCoverageCouncilDecisionDraft.fromAgendaItem(
        item: item,
        asOfDate: asOfDate,
      ).copyWith(outcome: outcome, followUpDate: followUpDate);

  return container
      .read(incomingTalentSuccessionCoverageCouncilDecisionsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentSuccessionCoverageCouncilFollowUp _submitFollowUp(
  ProviderContainer container,
  IncomingTalentSuccessionCoverageCouncilDecision decision,
) {
  _initializeFollowUpDraft(container, decision);
  return _followUpNotifier(container).submitDraft(
    container.read(
      incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider,
    ),
  );
}

void _initializeFollowUpDraft(
  ProviderContainer container,
  IncomingTalentSuccessionCoverageCouncilDecision decision,
) {
  container
      .read(
        incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider.notifier,
      )
      .initializeFromDecision(decision);
}

IncomingTalentSuccessionCoverageCouncilFollowUpsNotifier _followUpNotifier(
  ProviderContainer container,
) {
  return container.read(
    incomingTalentSuccessionCoverageCouncilFollowUpsProvider.notifier,
  );
}

IncomingTalentSuccessionCoverageCouncilFollowUpSummary _followUpSummary(
  ProviderContainer container,
) {
  return container.read(
    incomingTalentSuccessionCoverageCouncilFollowUpSummaryProvider,
  );
}

IncomingTalentSuccessionCoverageCouncilAgendaItem _agendaItem({
  String id = 'finance',
  required String scopeLabel,
  required IncomingTalentSuccessionCoverageCouncilAgendaLane lane,
  required IncomingTalentSuccessionCoverageCouncilAgendaPriority priority,
  required IncomingTalentSuccessionCoverageGovernanceRiskLevel riskLevel,
  required int coverageScore,
}) {
  return IncomingTalentSuccessionCoverageCouncilAgendaItem(
    id: 'coverage-council:$id',
    governanceRecordId: 'coverage-governance:$id',
    scopeLabel: scopeLabel,
    departmentScope: scopeLabel,
    ownerName: '$scopeLabel Owner',
    lane: lane,
    priority: priority,
    stage: IncomingTalentSuccessionCoverageGovernanceStage.actionRequired,
    riskLevel: riskLevel,
    coverageScore: coverageScore,
    dueDate: DateTime(2026, 6, 12),
    councilDate: DateTime(2026, 6, 5),
    decisionQuestion: 'What decision removes $scopeLabel coverage risk?',
    discussionPrompt:
        'Confirm the council owner and evidence required before follow-up.',
    preReadSummary: '$scopeLabel coverage pre-read summary is ready.',
  );
}
