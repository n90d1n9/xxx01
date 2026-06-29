import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_risk_council_commitment_action_models.dart';
import '../models/incoming_talent_risk_council_commitment_log_models.dart';
import 'incoming_talent_risk_council_commitment_log_provider.dart';
import 'talent_provider.dart';

final incomingTalentRiskCouncilCommitmentActionDraftProvider =
    StateNotifierProvider<
      IncomingTalentRiskCouncilCommitmentActionDraftNotifier,
      IncomingTalentRiskCouncilCommitmentActionDraft
    >((ref) {
      return IncomingTalentRiskCouncilCommitmentActionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentRiskCouncilCommitmentActionDraftNotifier
    extends StateNotifier<IncomingTalentRiskCouncilCommitmentActionDraft> {
  IncomingTalentRiskCouncilCommitmentActionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentRiskCouncilCommitmentActionDraft.empty(asOfDate));

  void initializeFromCommitment(
    IncomingTalentRiskCouncilCommitmentLogItem commitment,
  ) {
    state = IncomingTalentRiskCouncilCommitmentActionDraft.fromCommitment(
      commitment: commitment,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setActionPlan(String value) {
    state = state.copyWith(actionPlan: value);
  }

  void setEvidenceExpectation(String value) {
    state = state.copyWith(evidenceExpectation: value);
  }

  void setEvidenceNote(String value) {
    state = state.copyWith(evidenceNote: value);
  }

  void setFollowUpCadence(String value) {
    state = state.copyWith(followUpCadence: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void clear() {
    state = IncomingTalentRiskCouncilCommitmentActionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentRiskCouncilCommitmentActionsProvider =
    StateNotifierProvider<
      IncomingTalentRiskCouncilCommitmentActionsNotifier,
      List<IncomingTalentRiskCouncilCommitmentAction>
    >((ref) {
      return IncomingTalentRiskCouncilCommitmentActionsNotifier();
    });

class IncomingTalentRiskCouncilCommitmentActionsNotifier
    extends StateNotifier<List<IncomingTalentRiskCouncilCommitmentAction>> {
  IncomingTalentRiskCouncilCommitmentActionsNotifier() : super(const []);

  IncomingTalentRiskCouncilCommitmentAction submitDraft(
    IncomingTalentRiskCouncilCommitmentActionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((action) => action.commitmentId == draft.commitmentId)) {
      throw StateError('Action already exists for council commitment');
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentRiskCouncilCommitmentActionStatus.inProgress);
  }

  void requestEvidence(String id) {
    _setStatus(
      id,
      IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence,
    );
  }

  void block(String id) {
    _setStatus(id, IncomingTalentRiskCouncilCommitmentActionStatus.blocked);
  }

  void escalate(String id) {
    _setStatus(id, IncomingTalentRiskCouncilCommitmentActionStatus.escalated);
  }

  void complete(String id) {
    _setStatus(id, IncomingTalentRiskCouncilCommitmentActionStatus.completed);
  }

  void _setStatus(
    String id,
    IncomingTalentRiskCouncilCommitmentActionStatus status,
  ) {
    state =
        state.map((action) {
          if (action.id != id) return action;
          return action.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-risk-council-commitment-action-${sequence.toString().padLeft(3, '0')}';
  }
}

final actionReadyTalentRiskCouncilCommitmentsProvider =
    Provider<List<IncomingTalentRiskCouncilCommitmentLogItem>>((ref) {
      final actionedCommitmentIds =
          ref
              .watch(incomingTalentRiskCouncilCommitmentActionsProvider)
              .map((action) => action.commitmentId)
              .toSet();

      return ref
          .watch(incomingTalentRiskCouncilCommitmentLogItemsProvider)
          .where(
            (commitment) =>
                commitment.type !=
                    IncomingTalentRiskCouncilCommitmentLogType.clear &&
                !actionedCommitmentIds.contains(commitment.id),
          )
          .toList();
    });

final filteredIncomingTalentRiskCouncilCommitmentActionsProvider =
    Provider<List<IncomingTalentRiskCouncilCommitmentAction>>((ref) {
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);
      final asOfDate = ref.watch(talentAsOfDateProvider);

      return ref
          .watch(incomingTalentRiskCouncilCommitmentActionsProvider)
          .where((action) => !attentionOnly || action.needsAttention(asOfDate))
          .toList();
    });

final incomingTalentRiskCouncilCommitmentActionSummaryProvider =
    Provider<IncomingTalentRiskCouncilCommitmentActionSummary>((ref) {
      return IncomingTalentRiskCouncilCommitmentActionSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentRiskCouncilCommitmentActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
