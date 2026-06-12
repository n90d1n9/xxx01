import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_agenda_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('coverage council decisions submit from agenda item', () {
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

    expect(container.read(decisionReadyCoverageCouncilAgendaItemsProvider), [
      item,
    ]);

    container
        .read(
          incomingTalentSuccessionCoverageCouncilDecisionDraftProvider.notifier,
        )
        .initializeFromAgendaItem(item);
    final draft = container.read(
      incomingTalentSuccessionCoverageCouncilDecisionDraftProvider,
    );
    final decision = container
        .read(incomingTalentSuccessionCoverageCouncilDecisionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentSuccessionCoverageCouncilDecisionSummaryProvider,
    );

    expect(decision.id, 'talent-succession-coverage-council-001');
    expect(decision.agendaItemId, item.id);
    expect(
      decision.outcome,
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
          .assignExecutiveSponsor,
    );
    expect(decision.followUpDate, asOfDate.add(const Duration(days: 7)));
    expect(decision.needsAttention, isTrue);
    expect(summary.totalDecisions, 1);
    expect(summary.sponsorAssignedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Confirm 1 executive sponsor commitments.');
    expect(
      container.read(decisionReadyCoverageCouncilAgendaItemsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(
            incomingTalentSuccessionCoverageCouncilDecisionsProvider.notifier,
          )
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('coverage council decision draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentSuccessionCoverageCouncilDecisionDraft.empty(
      asOfDate,
    ).copyWith(
      decisionDate: asOfDate.subtract(const Duration(days: 1)),
      commitmentSummary: 'tiny',
      minutesNote: 'short',
      followUpDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a council agenda item',
      'Please enter a decision maker',
      'Please enter an executive sponsor',
      'Select council decision',
      'Decision date cannot be in the past',
      'Follow-up must be after decision date',
      'Commitment summary must be at least 12 characters',
      'Minutes note must be at least 12 characters',
    ]);
  });

  test('coverage council decisions follow filters and summary attention', () {
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

    _submitDecision(
      container,
      engineering,
      outcome:
          IncomingTalentSuccessionCoverageCouncilDecisionOutcome
              .validateClosure,
    );
    _submitDecision(
      container,
      finance,
      outcome:
          IncomingTalentSuccessionCoverageCouncilDecisionOutcome
              .escalateToPeopleBoard,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final decisions = container.read(
      filteredIncomingTalentSuccessionCoverageCouncilDecisionsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageCouncilDecisionSummaryProvider,
    );

    expect(decisions.map((decision) => decision.scopeLabel), ['Finance']);
    expect(summary.totalDecisions, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Track 1 people board escalations.');
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
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft =
      IncomingTalentSuccessionCoverageCouncilDecisionDraft.fromAgendaItem(
        item: item,
        asOfDate: asOfDate,
      ).copyWith(
        outcome: outcome,
        followUpDate: asOfDate.add(const Duration(days: 14)),
      );

  return container
      .read(incomingTalentSuccessionCoverageCouncilDecisionsProvider.notifier)
      .submitDraft(draft);
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
