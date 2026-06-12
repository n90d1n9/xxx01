import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'incoming_talent_governance_execution_action_provider.dart';
import 'talent_provider.dart';

final incomingTalentGovernanceExecutionClosureDraftProvider =
    StateNotifierProvider<
      IncomingTalentGovernanceExecutionClosureDraftNotifier,
      IncomingTalentGovernanceExecutionClosureDraft
    >((ref) {
      return IncomingTalentGovernanceExecutionClosureDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

/// Owns the editable governance execution closure draft.
class IncomingTalentGovernanceExecutionClosureDraftNotifier
    extends StateNotifier<IncomingTalentGovernanceExecutionClosureDraft> {
  IncomingTalentGovernanceExecutionClosureDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentGovernanceExecutionClosureDraft.empty(asOfDate));

  void initializeFromAction(IncomingTalentGovernanceExecutionAction action) {
    state = IncomingTalentGovernanceExecutionClosureDraft.fromAction(
      action: action,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setClosureDate(DateTime value) {
    final outcome = state.outcome;
    state = state.copyWith(
      closureDate: value,
      nextReviewDate:
          outcome == null
              ? value.add(const Duration(days: 14))
              : value.add(
                defaultIncomingTalentGovernanceExecutionClosureNextReviewOffset(
                  outcome,
                ),
              ),
    );
  }

  void setOutcome(IncomingTalentGovernanceExecutionClosureOutcome value) {
    final closureDate = state.closureDate ?? state.asOfDate;
    state = state.copyWith(
      outcome: value,
      nextAction: defaultIncomingTalentGovernanceExecutionClosureNextAction(
        value,
      ),
      nextReviewDate: closureDate.add(
        defaultIncomingTalentGovernanceExecutionClosureNextReviewOffset(value),
      ),
    );
  }

  void setResidualRiskCount(int value) {
    state = state.copyWith(residualRiskCount: value < 0 ? 0 : value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setOwnerConfirmationNote(String value) {
    state = state.copyWith(ownerConfirmationNote: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentGovernanceExecutionClosureDraft.empty(state.asOfDate);
  }
}

final incomingTalentGovernanceExecutionClosuresProvider = StateNotifierProvider<
  IncomingTalentGovernanceExecutionClosuresNotifier,
  List<IncomingTalentGovernanceExecutionClosure>
>((ref) {
  return IncomingTalentGovernanceExecutionClosuresNotifier();
});

/// Stores submitted governance execution closure records.
class IncomingTalentGovernanceExecutionClosuresNotifier
    extends StateNotifier<List<IncomingTalentGovernanceExecutionClosure>> {
  IncomingTalentGovernanceExecutionClosuresNotifier() : super(const []);

  IncomingTalentGovernanceExecutionClosure submitDraft(
    IncomingTalentGovernanceExecutionClosureDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((closure) => closure.actionId == draft.actionId)) {
      throw StateError(
        'Closure already exists for this governance execution action',
      );
    }

    final closure = draft.toClosure(id: _nextId(), createdAt: draft.asOfDate);
    state = [closure, ...state];
    return closure;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-governance-execution-closure-${sequence.toString().padLeft(3, '0')}';
  }
}

final closureReadyTalentGovernanceExecutionActionsProvider =
    Provider<List<IncomingTalentGovernanceExecutionAction>>((ref) {
      final closedActionIds =
          ref
              .watch(incomingTalentGovernanceExecutionClosuresProvider)
              .map((closure) => closure.actionId)
              .toSet();

      return ref
          .watch(incomingTalentGovernanceExecutionActionsProvider)
          .where((action) => !closedActionIds.contains(action.id))
          .toList();
    });

final incomingTalentGovernanceExecutionClosureSummaryProvider =
    Provider<IncomingTalentGovernanceExecutionClosureSummary>((ref) {
      return IncomingTalentGovernanceExecutionClosureSummary.fromClosures(
        ref.watch(incomingTalentGovernanceExecutionClosuresProvider),
      );
    });
