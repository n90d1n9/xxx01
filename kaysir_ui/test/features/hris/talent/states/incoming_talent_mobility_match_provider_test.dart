import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_match_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_panel_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('incoming talent mobility match submits from panel decision', () {
    final asOfDate = DateTime(2026, 6, 6);
    final decision = _decision(asOfDate, department: 'Engineering');
    final container = _container(asOfDate, decisions: [decision]);
    addTearDown(container.dispose);

    expect(container.read(mobilityReadySuccessionPanelDecisionsProvider), [
      decision,
    ]);

    container
        .read(incomingTalentMobilityMatchDraftProvider.notifier)
        .initializeFromDecision(decision);
    final draft = container.read(incomingTalentMobilityMatchDraftProvider);
    final match = container
        .read(incomingTalentMobilityMatchesProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(incomingTalentMobilityMatchSummaryProvider);

    expect(match.id, 'talent-mobility-match-001');
    expect(match.decisionId, decision.id);
    expect(match.moveType, IncomingTalentMobilityMoveType.promotion);
    expect(match.status, IncomingTalentMobilityMatchStatus.proposed);
    expect(match.fitScore, 92);
    expect(match.isDueSoon(asOfDate), isTrue);
    expect(summary.totalCount, 1);
    expect(summary.proposedCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Launch 1 mobility moves due soon.');
    expect(
      container.read(mobilityReadySuccessionPanelDecisionsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentMobilityMatchesProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('incoming talent mobility draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityMatchDraft.empty(asOfDate).copyWith(
      startDate: asOfDate.subtract(const Duration(days: 1)),
      reviewDate: asOfDate.subtract(const Duration(days: 1)),
      fitScore: 101,
      businessRationale: 'tiny',
      successMeasure: 'short',
      supportPlan: 'small',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a panel decision',
      'Please enter an opportunity title',
      'Please enter a host department',
      'Please enter a sponsor',
      'Please enter a mobility owner',
      'Select mobility type',
      'Select match status',
      'Fit score must be between 0 and 100',
      'Start date cannot be in the past',
      'Review date must be after start date',
      'Business rationale must be at least 12 characters',
      'Success measure must be at least 12 characters',
      'Support plan must be at least 12 characters',
    ]);
  });

  test('incoming talent mobility match follows status lifecycle', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate,
      decisions: [_decision(asOfDate, department: 'Product')],
    );
    addTearDown(container.dispose);

    final match = _submitMatch(
      container,
      container.read(mobilityReadySuccessionPanelDecisionsProvider).single,
    );
    var summary = container.read(incomingTalentMobilityMatchSummaryProvider);
    expect(summary.nextAction, 'Launch 1 mobility moves due soon.');

    final notifier = container.read(
      incomingTalentMobilityMatchesProvider.notifier,
    );
    notifier.sponsorReview(match.id);
    summary = container.read(incomingTalentMobilityMatchSummaryProvider);
    expect(summary.sponsorReviewCount, 1);
    expect(summary.nextAction, 'Confirm 1 sponsor reviews.');

    notifier.block(match.id);
    summary = container.read(incomingTalentMobilityMatchSummaryProvider);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 mobility matches.');

    notifier.accept(match.id);
    summary = container.read(incomingTalentMobilityMatchSummaryProvider);
    expect(summary.acceptedCount, 1);
    expect(summary.nextAction, 'Launch 1 mobility moves due soon.');

    notifier.activate(match.id);
    summary = container.read(incomingTalentMobilityMatchSummaryProvider);
    expect(summary.activatedCount, 1);
    expect(summary.dueSoonCount, 0);
    expect(summary.nextAction, 'Mobility matches are activated.');
  });

  test('incoming talent mobility matches follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 6);
    final engineering = _decision(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      risk: IncomingTalentSuccessionRisk.low,
    );
    final finance = _decision(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      risk: IncomingTalentSuccessionRisk.medium,
      outcome: IncomingTalentSuccessionPanelOutcome.conditionalApproval,
    );
    final container = _container(asOfDate, decisions: [engineering, finance]);
    addTearDown(container.dispose);

    final engineeringMatch = _submitMatch(container, engineering);
    container
        .read(incomingTalentMobilityMatchesProvider.notifier)
        .activate(engineeringMatch.id);
    final financeMatch = _submitMatch(container, finance);
    container
        .read(incomingTalentMobilityMatchesProvider.notifier)
        .sponsorReview(financeMatch.id);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final matches = container.read(
      filteredIncomingTalentMobilityMatchesProvider,
    );
    final summary = container.read(incomingTalentMobilityMatchSummaryProvider);

    expect(matches.map((match) => match.candidateName), ['Mira Lestari']);
    expect(summary.totalCount, 1);
    expect(summary.sponsorReviewCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Confirm 1 sponsor reviews.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentSuccessionPanelDecision> decisions,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentSuccessionPanelDecisionsProvider.overrideWithValue(
        decisions,
      ),
    ],
  );
}

IncomingTalentMobilityMatch _submitMatch(
  ProviderContainer container,
  IncomingTalentSuccessionPanelDecision decision,
) {
  container
      .read(incomingTalentMobilityMatchDraftProvider.notifier)
      .initializeFromDecision(decision);
  return container
      .read(incomingTalentMobilityMatchesProvider.notifier)
      .submitDraft(container.read(incomingTalentMobilityMatchDraftProvider));
}

IncomingTalentSuccessionPanelDecision _decision(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  IncomingTalentSuccessionRisk risk = IncomingTalentSuccessionRisk.low,
  IncomingTalentSuccessionPanelOutcome outcome =
      IncomingTalentSuccessionPanelOutcome.approvePromotion,
}) {
  return IncomingTalentSuccessionPanelDecision(
    id: 'decision-$id',
    nominationId: 'nomination-$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    role: '$department Specialist',
    department: department,
    targetRole: '$department Lead',
    panelLeadName: '$department Panel Lead',
    followUpOwner: '$department Sponsor',
    nominationType: IncomingTalentSuccessionNominationType.promotion,
    readiness: IncomingTalentSuccessionReadiness.readyNow,
    risk: risk,
    outcome: outcome,
    decisionDate: asOfDate,
    activationDate: asOfDate.add(const Duration(days: 10)),
    nextReviewDate: asOfDate.add(const Duration(days: 45)),
    decisionSummary: '$department panel approved mobility path.',
    conditions: '$department conditions are clear.',
    sponsorCommitment: '$department sponsor commitment is confirmed.',
    createdAt: asOfDate,
  );
}
