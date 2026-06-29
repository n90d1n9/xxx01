import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_career_path_support_action_models.dart';
import '../models/incoming_talent_career_path_support_outcome_models.dart';
import 'incoming_talent_career_path_support_action_provider.dart';
import 'talent_provider.dart';

final incomingTalentCareerPathSupportOutcomeDraftProvider =
    StateNotifierProvider<
      IncomingTalentCareerPathSupportOutcomeDraftNotifier,
      IncomingTalentCareerPathSupportOutcomeDraft
    >((ref) {
      return IncomingTalentCareerPathSupportOutcomeDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentCareerPathSupportOutcomeDraftNotifier
    extends StateNotifier<IncomingTalentCareerPathSupportOutcomeDraft> {
  IncomingTalentCareerPathSupportOutcomeDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentCareerPathSupportOutcomeDraft.empty(asOfDate));

  void initializeFromAction(IncomingTalentCareerPathSupportAction action) {
    state = IncomingTalentCareerPathSupportOutcomeDraft.fromAction(
      action: action,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setOutcomeDate(DateTime value) {
    final decision =
        state.decision ??
        IncomingTalentCareerPathSupportOutcomeDecision.improved;
    state = state.copyWith(
      outcomeDate: value,
      nextReviewDate:
          defaultIncomingTalentCareerPathSupportOutcomeNextReviewDate(
            decision: decision,
            asOfDate: value,
          ),
    );
  }

  void setDecision(IncomingTalentCareerPathSupportOutcomeDecision value) {
    state = state.copyWith(
      decision: value,
      nextReviewAction: defaultIncomingTalentCareerPathSupportOutcomeNextAction(
        value,
      ),
      nextReviewDate:
          defaultIncomingTalentCareerPathSupportOutcomeNextReviewDate(
            decision: value,
            asOfDate: state.outcomeDate ?? state.asOfDate,
          ),
    );
  }

  void setResidualRisk(
    IncomingTalentCareerPathSupportOutcomeResidualRisk value,
  ) {
    state = state.copyWith(residualRisk: value);
  }

  void setVerifiedLevel(int value) {
    state = state.copyWith(verifiedLevel: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setManagerNote(String value) {
    state = state.copyWith(managerNote: value);
  }

  void setNextReviewAction(String value) {
    state = state.copyWith(nextReviewAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentCareerPathSupportOutcomeDraft.empty(state.asOfDate);
  }
}

final incomingTalentCareerPathSupportOutcomesProvider = StateNotifierProvider<
  IncomingTalentCareerPathSupportOutcomesNotifier,
  List<IncomingTalentCareerPathSupportOutcome>
>((ref) {
  return IncomingTalentCareerPathSupportOutcomesNotifier();
});

class IncomingTalentCareerPathSupportOutcomesNotifier
    extends StateNotifier<List<IncomingTalentCareerPathSupportOutcome>> {
  IncomingTalentCareerPathSupportOutcomesNotifier() : super(const []);

  IncomingTalentCareerPathSupportOutcome submitDraft(
    IncomingTalentCareerPathSupportOutcomeDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((outcome) => outcome.actionId == draft.actionId)) {
      throw StateError('Outcome already exists for career support action');
    }

    final outcome = draft.toOutcome(id: _nextId(), createdAt: draft.asOfDate);
    state = [outcome, ...state];
    return outcome;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-career-support-outcome-${sequence.toString().padLeft(3, '0')}';
  }
}

final careerPathSupportOutcomeReadyActionsProvider =
    Provider<List<IncomingTalentCareerPathSupportAction>>((ref) {
      final closedActionIds =
          ref
              .watch(incomingTalentCareerPathSupportOutcomesProvider)
              .map((outcome) => outcome.actionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentCareerPathSupportActionsProvider)
          .where(
            (action) =>
                action.status ==
                    IncomingTalentCareerPathSupportActionStatus.resolved &&
                !closedActionIds.contains(action.id),
          )
          .toList();
    });

final filteredIncomingTalentCareerPathSupportOutcomesProvider =
    Provider<List<IncomingTalentCareerPathSupportOutcome>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentCareerPathSupportOutcomesProvider)
          .where(
            (outcome) =>
                (selectedDepartment == talentAllDepartments ||
                    outcome.department == selectedDepartment) &&
                (!attentionOnly || outcome.needsAttention),
          )
          .toList();
    });

final incomingTalentCareerPathSupportOutcomeSummaryProvider =
    Provider<IncomingTalentCareerPathSupportOutcomeSummary>((ref) {
      return IncomingTalentCareerPathSupportOutcomeSummary.fromOutcomes(
        ref.watch(filteredIncomingTalentCareerPathSupportOutcomesProvider),
      );
    });
