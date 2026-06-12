import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_first_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_launch_checklist_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('mobility first review submits from launched checklist', () {
    final asOfDate = DateTime(2026, 6, 6);
    final checklist = _checklist(asOfDate, department: 'Engineering');
    final container = _container(asOfDate, checklists: [checklist]);
    addTearDown(container.dispose);

    expect(container.read(firstReviewReadyMobilityLaunchChecklistsProvider), [
      checklist,
    ]);

    container
        .read(incomingTalentMobilityFirstReviewDraftProvider.notifier)
        .initializeFromChecklist(checklist);
    final draft = container.read(
      incomingTalentMobilityFirstReviewDraftProvider,
    );
    final review = container
        .read(incomingTalentMobilityFirstReviewsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentMobilityFirstReviewSummaryProvider,
    );

    expect(review.id, 'talent-mobility-first-review-001');
    expect(review.checklistId, checklist.id);
    expect(
      review.outcome,
      IncomingTalentMobilityFirstReviewOutcome.accelerating,
    );
    expect(review.hostConfidenceScore, 5);
    expect(summary.totalCount, 1);
    expect(summary.acceleratingCount, 1);
    expect(summary.nextAction, 'Scale 1 accelerating mobility moves.');
    expect(
      container.read(firstReviewReadyMobilityLaunchChecklistsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentMobilityFirstReviewsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('mobility first review draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityFirstReviewDraft.empty(
      asOfDate,
    ).copyWith(
      reviewDate: asOfDate.subtract(const Duration(days: 1)),
      outcome: IncomingTalentMobilityFirstReviewOutcome.blocked,
      hostConfidenceScore: 6,
      deliverySignal: 'tiny',
      blockerNote: 'mini',
      nextAction: 'short',
      followUpDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a launched mobility checklist',
      'Please enter a reviewer',
      'Review date cannot be in the past',
      'Host confidence must be between 1 and 5',
      'Delivery signal must be at least 12 characters',
      'Blocker note must be at least 12 characters',
      'Select retention risk',
      'Select launch status',
      'Next action must be at least 12 characters',
      'Follow-up date must be after review date',
    ]);
  });

  test('mobility first reviews follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 6);
    final engineering = _checklist(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      fitScore: 90,
    );
    final finance = _checklist(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      fitScore: 68,
    );
    final container = _container(asOfDate, checklists: [engineering, finance]);
    addTearDown(container.dispose);

    _submitReview(
      container,
      engineering,
      outcome: IncomingTalentMobilityFirstReviewOutcome.stable,
      confidence: 4,
      retentionRisk: IncomingTalentMobilityFirstReviewRetentionRisk.low,
    );
    _submitReview(
      container,
      finance,
      outcome: IncomingTalentMobilityFirstReviewOutcome.watch,
      confidence: 2,
      retentionRisk: IncomingTalentMobilityFirstReviewRetentionRisk.high,
      blockerNote: 'Host manager confidence is below launch target.',
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentMobilityFirstReviewsProvider,
    );
    final summary = container.read(
      incomingTalentMobilityFirstReviewSummaryProvider,
    );

    expect(filtered.map((review) => review.candidateName), ['Mira Lestari']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.watchCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.averageConfidence, 2);
    expect(summary.nextAction, 'Review 1 mobility watch items.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentMobilityLaunchChecklist> checklists,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentMobilityLaunchChecklistsProvider.overrideWithValue(
        checklists,
      ),
    ],
  );
}

IncomingTalentMobilityFirstReview _submitReview(
  ProviderContainer container,
  IncomingTalentMobilityLaunchChecklist checklist, {
  required IncomingTalentMobilityFirstReviewOutcome outcome,
  required int confidence,
  required IncomingTalentMobilityFirstReviewRetentionRisk retentionRisk,
  String blockerNote = '',
}) {
  final notifier = container.read(
    incomingTalentMobilityFirstReviewDraftProvider.notifier,
  );
  notifier.initializeFromChecklist(checklist);
  notifier.setOutcome(outcome);
  notifier.setHostConfidenceScore(confidence);
  notifier.setRetentionRisk(retentionRisk);
  notifier.setBlockerNote(blockerNote);
  return container
      .read(incomingTalentMobilityFirstReviewsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentMobilityFirstReviewDraftProvider),
      );
}

IncomingTalentMobilityLaunchChecklist _checklist(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  int fitScore = 90,
}) {
  return IncomingTalentMobilityLaunchChecklist(
    id: 'launch-$id',
    matchId: 'match-$id',
    decisionId: 'decision-$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    currentRole: '$department Specialist',
    department: department,
    targetRole: '$department Lead',
    opportunityTitle: '$department mobility launch',
    hostDepartment: department,
    sponsorName: '$department Sponsor',
    mobilityOwnerName: '$department Mobility Owner',
    moveType: IncomingTalentMobilityMoveType.promotion,
    matchStatus: IncomingTalentMobilityMatchStatus.accepted,
    status: IncomingTalentMobilityLaunchStatus.launched,
    fitScore: fitScore,
    ownerName: '$department Mobility Owner',
    launchDate: asOfDate.add(const Duration(days: 1)),
    firstReviewDate: asOfDate.add(const Duration(days: 10)),
    sponsorSignedOff: true,
    hostManagerReady: true,
    accessReady: true,
    communicationReady: true,
    backfillReady: true,
    firstReviewScheduled: true,
    riskNote: fitScore >= 75 ? '' : 'Mobility launch needs additional support.',
    launchNotes: '$department mobility launch completed with sponsor support.',
    createdAt: asOfDate,
  );
}
