import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_commitment_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_commitment_log_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_commitment_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_commitment_log_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('commitment actions submit from council commitment log', () {
    final asOfDate = DateTime(2026, 6, 9);
    final commitments = [
      _commitment(
        asOfDate,
        id: 'blocked',
        type: IncomingTalentRiskCouncilCommitmentLogType.leadershipDecision,
        status: IncomingTalentRiskCouncilCommitmentLogStatus.blocked,
        dueOffset: 2,
      ),
      _commitment(
        asOfDate,
        id: 'evidence',
        type: IncomingTalentRiskCouncilCommitmentLogType.executionEvidence,
        status: IncomingTalentRiskCouncilCommitmentLogStatus.needsEvidence,
        dueOffset: 4,
      ),
    ];
    final container = _container(asOfDate, commitments: commitments);
    addTearDown(container.dispose);

    expect(
      container.read(actionReadyTalentRiskCouncilCommitmentsProvider),
      hasLength(2),
    );

    final draftNotifier = container.read(
      incomingTalentRiskCouncilCommitmentActionDraftProvider.notifier,
    );
    draftNotifier.initializeFromCommitment(commitments.first);
    final draft = container.read(
      incomingTalentRiskCouncilCommitmentActionDraftProvider,
    );

    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.ownerName, 'Talent Operations');
    expect(
      draft.status,
      IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
    );
    expect(draft.followUpCadence, contains('Daily'));

    final action = container
        .read(incomingTalentRiskCouncilCommitmentActionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentRiskCouncilCommitmentActionSummaryProvider,
    );

    expect(action.id, 'talent-risk-council-commitment-action-001');
    expect(action.commitmentId, commitments.first.id);
    expect(
      action.status,
      IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
    );
    expect(
      container.read(actionReadyTalentRiskCouncilCommitmentsProvider),
      hasLength(1),
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Unblock 1 council commitment action.');
    expect(
      () => container
          .read(incomingTalentRiskCouncilCommitmentActionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('commitment action summary follows lifecycle and attention filter', () {
    final asOfDate = DateTime(2026, 6, 9);
    final commitment = _commitment(
      asOfDate,
      id: 'publish',
      type: IncomingTalentRiskCouncilCommitmentLogType.publishCloseout,
      status: IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish,
      dueOffset: 1,
    );
    final container = _container(asOfDate, commitments: [commitment]);
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      incomingTalentRiskCouncilCommitmentActionDraftProvider.notifier,
    );
    draftNotifier.initializeFromCommitment(commitment);
    final action = container
        .read(incomingTalentRiskCouncilCommitmentActionsProvider.notifier)
        .submitDraft(
          container.read(
            incomingTalentRiskCouncilCommitmentActionDraftProvider,
          ),
        );

    var summary = container.read(
      incomingTalentRiskCouncilCommitmentActionSummaryProvider,
    );
    expect(summary.plannedCount, 1);
    expect(summary.nextAction, 'Close 1 council commitment action due soon.');

    final actionNotifier = container.read(
      incomingTalentRiskCouncilCommitmentActionsProvider.notifier,
    );
    actionNotifier.start(action.id);
    summary = container.read(
      incomingTalentRiskCouncilCommitmentActionSummaryProvider,
    );
    expect(summary.inProgressCount, 1);
    expect(summary.attentionCount, 0);

    actionNotifier.requestEvidence(action.id);
    summary = container.read(
      incomingTalentRiskCouncilCommitmentActionSummaryProvider,
    );
    expect(summary.waitingEvidenceCount, 1);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Attach evidence for 1 council commitment action.',
    );

    actionNotifier.complete(action.id);
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    expect(
      container.read(
        filteredIncomingTalentRiskCouncilCommitmentActionsProvider,
      ),
      isEmpty,
    );
    summary = container.read(
      incomingTalentRiskCouncilCommitmentActionSummaryProvider,
    );
    expect(summary.totalCount, 0);
    expect(summary.nextAction, 'Create council commitment actions.');
  });

  test('commitment action draft validates required fields', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(asOfDate, commitments: const []);
    addTearDown(container.dispose);

    final draft = container.read(
      incomingTalentRiskCouncilCommitmentActionDraftProvider,
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors.first, 'Select a council commitment');
    expect(
      () => container
          .read(incomingTalentRiskCouncilCommitmentActionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentRiskCouncilCommitmentLogItem> commitments,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      incomingTalentRiskCouncilCommitmentLogItemsProvider.overrideWithValue(
        commitments,
      ),
    ],
  );
}

IncomingTalentRiskCouncilCommitmentLogItem _commitment(
  DateTime asOfDate, {
  required String id,
  required IncomingTalentRiskCouncilCommitmentLogType type,
  required IncomingTalentRiskCouncilCommitmentLogStatus status,
  required int dueOffset,
}) {
  return IncomingTalentRiskCouncilCommitmentLogItem(
    id: 'commitment:$id',
    agendaItemId: 'agenda:$id',
    type: type,
    status: status,
    title: 'Council commitment',
    commitment: 'Capture the owner commitment and delivery plan.',
    evidenceExpectation: 'Evidence note and owner update are required.',
    ownerName: 'Talent Operations',
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    sourceCount: 2,
    readinessTaskIds: ['readiness:$id'],
  );
}
