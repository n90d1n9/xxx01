import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageActionDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageActionDraftNotifier,
      IncomingTalentSuccessionCoverageActionDraft
    >((ref) {
      return IncomingTalentSuccessionCoverageActionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionCoverageActionDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionCoverageActionDraft> {
  IncomingTalentSuccessionCoverageActionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionCoverageActionDraft.empty(asOfDate));

  void initializeFromReview(IncomingTalentSuccessionCoverageReview review) {
    state = IncomingTalentSuccessionCoverageActionDraft.fromReview(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setActionType(IncomingTalentSuccessionCoverageActionType value) {
    state = state.copyWith(actionType: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setActionPlan(String value) {
    state = state.copyWith(actionPlan: value);
  }

  void setEscalationPath(String value) {
    state = state.copyWith(escalationPath: value);
  }

  void setResolutionEvidence(String value) {
    state = state.copyWith(resolutionEvidence: value);
  }

  void clear() {
    state = IncomingTalentSuccessionCoverageActionDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionCoverageActionsProvider = StateNotifierProvider<
  IncomingTalentSuccessionCoverageActionsNotifier,
  List<IncomingTalentSuccessionCoverageAction>
>((ref) {
  return IncomingTalentSuccessionCoverageActionsNotifier();
});

class IncomingTalentSuccessionCoverageActionsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionCoverageAction>> {
  IncomingTalentSuccessionCoverageActionsNotifier() : super(const []);

  IncomingTalentSuccessionCoverageAction submitDraft(
    IncomingTalentSuccessionCoverageActionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (action) =>
          action.coverageReviewId == draft.coverageReviewId && action.isOpen,
    )) {
      throw StateError('Open coverage action already exists for this review');
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentSuccessionCoverageActionStatus.inProgress);
  }

  void resolve(String id) {
    _setStatus(id, IncomingTalentSuccessionCoverageActionStatus.resolved);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentSuccessionCoverageActionStatus.blocked);
  }

  void _setStatus(
    String id,
    IncomingTalentSuccessionCoverageActionStatus status,
  ) {
    state =
        state.map((action) {
          if (action.id != id) return action;
          return action.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-coverage-action-${sequence.toString().padLeft(3, '0')}';
  }
}

final actionReadySuccessionCoverageReviewsProvider = Provider<
  List<IncomingTalentSuccessionCoverageReview>
>((ref) {
  final openActionReviewIds =
      ref
          .watch(incomingTalentSuccessionCoverageActionsProvider)
          .where((action) => action.isOpen)
          .map((action) => action.coverageReviewId)
          .toSet();

  return ref
      .watch(filteredIncomingTalentSuccessionCoverageReviewsProvider)
      .where(
        (review) =>
            review.needsAttention && !openActionReviewIds.contains(review.id),
      )
      .toList();
});

final filteredIncomingTalentSuccessionCoverageActionsProvider =
    Provider<List<IncomingTalentSuccessionCoverageAction>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionCoverageActionsProvider)
          .where(
            (action) =>
                (selectedDepartment == talentAllDepartments ||
                    action.departmentScope == selectedDepartment) &&
                (!attentionOnly || action.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionCoverageActionSummaryProvider =
    Provider<IncomingTalentSuccessionCoverageActionSummary>((ref) {
      return IncomingTalentSuccessionCoverageActionSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentSuccessionCoverageActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
