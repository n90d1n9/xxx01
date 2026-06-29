import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_first_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityStabilizationActionDraftProvider =
    StateNotifierProvider<
      IncomingTalentMobilityStabilizationActionDraftNotifier,
      IncomingTalentMobilityStabilizationActionDraft
    >((ref) {
      return IncomingTalentMobilityStabilizationActionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentMobilityStabilizationActionDraftNotifier
    extends StateNotifier<IncomingTalentMobilityStabilizationActionDraft> {
  IncomingTalentMobilityStabilizationActionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentMobilityStabilizationActionDraft.empty(asOfDate));

  void initializeFromReview(IncomingTalentMobilityFirstReview review) {
    state = IncomingTalentMobilityStabilizationActionDraft.fromReview(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setActionType(IncomingTalentMobilityStabilizationActionType value) {
    state = state.copyWith(actionType: value);
  }

  void setStatus(IncomingTalentMobilityStabilizationStatus value) {
    state = state.copyWith(status: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setActionSummary(String value) {
    state = state.copyWith(actionSummary: value);
  }

  void setSuccessMeasure(String value) {
    state = state.copyWith(successMeasure: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void clear() {
    state = IncomingTalentMobilityStabilizationActionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentMobilityStabilizationActionsProvider =
    StateNotifierProvider<
      IncomingTalentMobilityStabilizationActionsNotifier,
      List<IncomingTalentMobilityStabilizationAction>
    >((ref) {
      return IncomingTalentMobilityStabilizationActionsNotifier();
    });

class IncomingTalentMobilityStabilizationActionsNotifier
    extends StateNotifier<List<IncomingTalentMobilityStabilizationAction>> {
  IncomingTalentMobilityStabilizationActionsNotifier() : super(const []);

  IncomingTalentMobilityStabilizationAction submitDraft(
    IncomingTalentMobilityStabilizationActionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((action) => action.reviewId == draft.reviewId)) {
      throw StateError('Stabilization action already exists for review');
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentMobilityStabilizationStatus.inProgress);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentMobilityStabilizationStatus.blocked);
  }

  void complete(String id) {
    _setStatus(id, IncomingTalentMobilityStabilizationStatus.completed);
  }

  void _setStatus(String id, IncomingTalentMobilityStabilizationStatus status) {
    state =
        state.map((action) {
          if (action.id != id) return action;
          return action.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-stabilization-${sequence.toString().padLeft(3, '0')}';
  }
}

final stabilizationReadyMobilityFirstReviewsProvider =
    Provider<List<IncomingTalentMobilityFirstReview>>((ref) {
      final actionedReviewIds =
          ref
              .watch(incomingTalentMobilityStabilizationActionsProvider)
              .map((action) => action.reviewId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentMobilityFirstReviewsProvider)
          .where(
            (review) =>
                review.needsAttention && !actionedReviewIds.contains(review.id),
          )
          .toList();
    });

final filteredIncomingTalentMobilityStabilizationActionsProvider =
    Provider<List<IncomingTalentMobilityStabilizationAction>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityStabilizationActionsProvider)
          .where(
            (action) =>
                (selectedDepartment == talentAllDepartments ||
                    action.department == selectedDepartment ||
                    action.hostDepartment == selectedDepartment) &&
                (!attentionOnly || action.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityStabilizationActionSummaryProvider =
    Provider<IncomingTalentMobilityStabilizationActionSummary>((ref) {
      return IncomingTalentMobilityStabilizationActionSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentMobilityStabilizationActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
