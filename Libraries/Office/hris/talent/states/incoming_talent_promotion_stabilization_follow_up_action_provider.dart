import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import 'incoming_talent_promotion_stabilization_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentPromotionStabilizationFollowUpActionDraftProvider =
    StateNotifierProvider<
      IncomingTalentPromotionStabilizationFollowUpActionDraftNotifier,
      IncomingTalentPromotionStabilizationFollowUpActionDraft
    >((ref) {
      return IncomingTalentPromotionStabilizationFollowUpActionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

/// Owns the editable promotion stabilization follow-up action draft.
class IncomingTalentPromotionStabilizationFollowUpActionDraftNotifier
    extends
        StateNotifier<IncomingTalentPromotionStabilizationFollowUpActionDraft> {
  IncomingTalentPromotionStabilizationFollowUpActionDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentPromotionStabilizationFollowUpActionDraft.empty(asOfDate),
      );

  void initializeFromReview(IncomingTalentPromotionStabilizationReview review) {
    state = IncomingTalentPromotionStabilizationFollowUpActionDraft.fromReview(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setActionType(
    IncomingTalentPromotionStabilizationFollowUpActionType value,
  ) {
    state = state.copyWith(actionType: value);
  }

  void setPriority(IncomingTalentPromotionStabilizationFollowUpPriority value) {
    state = state.copyWith(priority: value);
  }

  void setStatus(IncomingTalentPromotionStabilizationFollowUpStatus value) {
    state = state.copyWith(status: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setActionPlan(String value) {
    state = state.copyWith(actionPlan: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void setEscalationNote(String value) {
    state = state.copyWith(escalationNote: value);
  }

  void setResolutionNote(String value) {
    state = state.copyWith(resolutionNote: value);
  }

  void clear() {
    state = IncomingTalentPromotionStabilizationFollowUpActionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentPromotionStabilizationFollowUpActionsProvider =
    StateNotifierProvider<
      IncomingTalentPromotionStabilizationFollowUpActionsNotifier,
      List<IncomingTalentPromotionStabilizationFollowUpAction>
    >((ref) {
      return IncomingTalentPromotionStabilizationFollowUpActionsNotifier();
    });

/// Stores promotion stabilization follow-up actions and lifecycle updates.
class IncomingTalentPromotionStabilizationFollowUpActionsNotifier
    extends
        StateNotifier<
          List<IncomingTalentPromotionStabilizationFollowUpAction>
        > {
  IncomingTalentPromotionStabilizationFollowUpActionsNotifier()
    : super(const []);

  IncomingTalentPromotionStabilizationFollowUpAction submitDraft(
    IncomingTalentPromotionStabilizationFollowUpActionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((action) => action.reviewId == draft.reviewId)) {
      throw StateError('Promotion stabilization follow-up already exists');
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void updateStatus({
    required String id,
    required IncomingTalentPromotionStabilizationFollowUpStatus status,
    String resolutionNote = '',
  }) {
    state = [
      for (final action in state)
        if (action.id == id)
          _copyWithStatus(
            action,
            status: status,
            resolutionNote:
                resolutionNote.trim().isEmpty
                    ? action.resolutionNote
                    : resolutionNote.trim(),
          )
        else
          action,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-promotion-stabilization-follow-up-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentPromotionStabilizationFollowUpAction _copyWithStatus(
    IncomingTalentPromotionStabilizationFollowUpAction action, {
    required IncomingTalentPromotionStabilizationFollowUpStatus status,
    required String resolutionNote,
  }) {
    return IncomingTalentPromotionStabilizationFollowUpAction(
      id: action.id,
      reviewId: action.reviewId,
      implementationId: action.implementationId,
      decisionId: action.decisionId,
      candidateId: action.candidateId,
      candidateName: action.candidateName,
      department: action.department,
      currentRole: action.currentRole,
      newRole: action.newRole,
      frameworkLevelCode: action.frameworkLevelCode,
      ownerName: action.ownerName,
      actionType: action.actionType,
      priority: action.priority,
      status: status,
      dueDate: action.dueDate,
      actionPlan: action.actionPlan,
      successCriteria: action.successCriteria,
      escalationNote: action.escalationNote,
      resolutionNote: resolutionNote,
      sourceOutcome: action.sourceOutcome,
      sourceReviewStatus: action.sourceReviewStatus,
      sourceConfidenceScore: action.sourceConfidenceScore,
      createdAt: action.createdAt,
    );
  }
}

final promotionStabilizationFollowUpReadyReviewsProvider =
    Provider<List<IncomingTalentPromotionStabilizationReview>>((ref) {
      final actionReviewIds =
          ref
              .watch(
                incomingTalentPromotionStabilizationFollowUpActionsProvider,
              )
              .map((action) => action.reviewId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentPromotionStabilizationReviewsProvider)
          .where(
            (review) =>
                review.needsAttention &&
                !review.isClosed &&
                !actionReviewIds.contains(review.id),
          )
          .toList();
    });

final filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider =
    Provider<List<IncomingTalentPromotionStabilizationFollowUpAction>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentPromotionStabilizationFollowUpActionsProvider)
          .where(
            (action) =>
                (selectedDepartment == talentAllDepartments ||
                    action.department == selectedDepartment) &&
                (!attentionOnly || action.needsAttention),
          )
          .toList();
    });

final incomingTalentPromotionStabilizationFollowUpActionSummaryProvider =
    Provider<IncomingTalentPromotionStabilizationFollowUpActionSummary>((ref) {
      return IncomingTalentPromotionStabilizationFollowUpActionSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
