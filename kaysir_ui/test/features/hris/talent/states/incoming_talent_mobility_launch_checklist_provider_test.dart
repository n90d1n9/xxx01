import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_launch_checklist_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_match_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('mobility launch checklist submits from accepted match', () {
    final asOfDate = DateTime(2026, 6, 6);
    final match = _match(asOfDate, department: 'Engineering');
    final container = _container(asOfDate, matches: [match]);
    addTearDown(container.dispose);

    expect(container.read(launchReadyIncomingTalentMobilityMatchesProvider), [
      match,
    ]);

    container
        .read(incomingTalentMobilityLaunchChecklistDraftProvider.notifier)
        .initializeFromMatch(match);
    _completeLaunchGates(container);
    container
        .read(incomingTalentMobilityLaunchChecklistDraftProvider.notifier)
        .setStatus(IncomingTalentMobilityLaunchStatus.ready);
    final draft = container.read(
      incomingTalentMobilityLaunchChecklistDraftProvider,
    );
    final checklist = container
        .read(incomingTalentMobilityLaunchChecklistsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentMobilityLaunchChecklistSummaryProvider,
    );

    expect(checklist.id, 'talent-mobility-launch-001');
    expect(checklist.matchId, match.id);
    expect(checklist.status, IncomingTalentMobilityLaunchStatus.ready);
    expect(checklist.readinessRatio, 1);
    expect(checklist.isDueSoon(asOfDate), isTrue);
    expect(summary.totalCount, 1);
    expect(summary.readyCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Launch 1 ready mobility moves.');
    expect(
      container.read(launchReadyIncomingTalentMobilityMatchesProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentMobilityLaunchChecklistsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('mobility launch checklist draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityLaunchChecklistDraft.empty(
      asOfDate,
    ).copyWith(
      status: IncomingTalentMobilityLaunchStatus.blocked,
      launchDate: asOfDate.subtract(const Duration(days: 1)),
      firstReviewDate: asOfDate.subtract(const Duration(days: 1)),
      launchNotes: 'tiny',
      riskNote: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a mobility match',
      'Please enter a launch owner',
      'Select mobility type',
      'Select mobility match status',
      'Launch date cannot be in the past',
      'First review must be after launch date',
      'Launch notes must be at least 12 characters',
      'Risk note must be at least 12 characters',
    ]);
  });

  test('mobility launch checklists follow lifecycle and talent filters', () {
    final asOfDate = DateTime(2026, 6, 6);
    final engineering = _match(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      fitScore: 90,
    );
    final finance = _match(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      fitScore: 68,
      moveType: IncomingTalentMobilityMoveType.successionCoverage,
    );
    final container = _container(asOfDate, matches: [engineering, finance]);
    addTearDown(container.dispose);

    final engineeringChecklist = _submitChecklist(
      container,
      engineering,
      IncomingTalentMobilityLaunchStatus.ready,
      completeGates: true,
    );
    final notifier = container.read(
      incomingTalentMobilityLaunchChecklistsProvider.notifier,
    );
    notifier.launch(engineeringChecklist.id);

    _submitChecklist(
      container,
      finance,
      IncomingTalentMobilityLaunchStatus.blocked,
      riskNote: 'Host readiness is below launch threshold this week.',
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentMobilityLaunchChecklistsProvider,
    );
    final summary = container.read(
      incomingTalentMobilityLaunchChecklistSummaryProvider,
    );

    expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Unblock 1 mobility launches.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentMobilityMatch> matches,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentMobilityMatchesProvider.overrideWithValue(matches),
    ],
  );
}

IncomingTalentMobilityLaunchChecklist _submitChecklist(
  ProviderContainer container,
  IncomingTalentMobilityMatch match,
  IncomingTalentMobilityLaunchStatus status, {
  bool completeGates = false,
  String riskNote = '',
}) {
  final draftNotifier = container.read(
    incomingTalentMobilityLaunchChecklistDraftProvider.notifier,
  );
  draftNotifier.initializeFromMatch(match);
  draftNotifier.setStatus(status);
  if (completeGates) _completeLaunchGates(container);
  if (riskNote.isNotEmpty) draftNotifier.setRiskNote(riskNote);

  return container
      .read(incomingTalentMobilityLaunchChecklistsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentMobilityLaunchChecklistDraftProvider),
      );
}

void _completeLaunchGates(ProviderContainer container) {
  final notifier = container.read(
    incomingTalentMobilityLaunchChecklistDraftProvider.notifier,
  );
  notifier.setSponsorSignedOff(true);
  notifier.setHostManagerReady(true);
  notifier.setAccessReady(true);
  notifier.setCommunicationReady(true);
  notifier.setBackfillReady(true);
  notifier.setFirstReviewScheduled(true);
}

IncomingTalentMobilityMatch _match(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  int fitScore = 88,
  IncomingTalentMobilityMoveType moveType =
      IncomingTalentMobilityMoveType.promotion,
  IncomingTalentMobilityMatchStatus status =
      IncomingTalentMobilityMatchStatus.accepted,
}) {
  return IncomingTalentMobilityMatch(
    id: 'match-$id',
    decisionId: 'decision-$id',
    nominationId: 'nomination-$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    currentRole: '$department Specialist',
    department: department,
    targetRole: '$department Lead',
    opportunityTitle: '$department mobility launch',
    hostDepartment: department,
    sponsorName: '$department Sponsor',
    mobilityOwnerName: '$department Mobility Owner',
    nominationType: IncomingTalentSuccessionNominationType.promotion,
    readiness: IncomingTalentSuccessionReadiness.readyNow,
    risk: IncomingTalentSuccessionRisk.low,
    moveType: moveType,
    status: status,
    fitScore: fitScore,
    startDate: asOfDate.add(const Duration(days: 10)),
    reviewDate: asOfDate.add(const Duration(days: 45)),
    businessRationale: '$department approved mobility business rationale.',
    successMeasure: '$department success will be reviewed after launch.',
    supportPlan: '$department host manager and sponsor align weekly.',
    createdAt: asOfDate,
  );
}
