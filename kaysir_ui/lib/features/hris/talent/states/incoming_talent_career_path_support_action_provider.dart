import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_career_path_review_models.dart';
import '../models/incoming_talent_career_path_support_action_models.dart';
import 'incoming_talent_career_path_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentCareerPathSupportActionDraftProvider =
    StateNotifierProvider<
      IncomingTalentCareerPathSupportActionDraftNotifier,
      IncomingTalentCareerPathSupportActionDraft
    >((ref) {
      return IncomingTalentCareerPathSupportActionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentCareerPathSupportActionDraftNotifier
    extends StateNotifier<IncomingTalentCareerPathSupportActionDraft> {
  IncomingTalentCareerPathSupportActionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentCareerPathSupportActionDraft.empty(asOfDate));

  void initializeFromReview(IncomingTalentCareerPathReview review) {
    state = IncomingTalentCareerPathSupportActionDraft.fromReview(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setActionType(IncomingTalentCareerPathSupportActionType value) {
    state = state.copyWith(actionType: value);
  }

  void setPriority(IncomingTalentCareerPathSupportActionPriority value) {
    state = state.copyWith(priority: value);
  }

  void setStatus(IncomingTalentCareerPathSupportActionStatus value) {
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

  void clear() {
    state = IncomingTalentCareerPathSupportActionDraft.empty(state.asOfDate);
  }
}

final incomingTalentCareerPathSupportActionsProvider = StateNotifierProvider<
  IncomingTalentCareerPathSupportActionsNotifier,
  List<IncomingTalentCareerPathSupportAction>
>((ref) {
  return IncomingTalentCareerPathSupportActionsNotifier();
});

class IncomingTalentCareerPathSupportActionsNotifier
    extends StateNotifier<List<IncomingTalentCareerPathSupportAction>> {
  IncomingTalentCareerPathSupportActionsNotifier() : super(const []);

  IncomingTalentCareerPathSupportAction submitDraft(
    IncomingTalentCareerPathSupportActionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((action) => action.reviewId == draft.reviewId)) {
      throw StateError('Support action already exists for this review');
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void updateStatus({
    required String id,
    required IncomingTalentCareerPathSupportActionStatus status,
  }) {
    state = [
      for (final action in state)
        if (action.id == id) _copyWithStatus(action, status) else action,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-career-support-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentCareerPathSupportAction _copyWithStatus(
    IncomingTalentCareerPathSupportAction action,
    IncomingTalentCareerPathSupportActionStatus status,
  ) {
    return IncomingTalentCareerPathSupportAction(
      id: action.id,
      reviewId: action.reviewId,
      careerPathId: action.careerPathId,
      portfolioId: action.portfolioId,
      roadmapId: action.roadmapId,
      candidateId: action.candidateId,
      candidateName: action.candidateName,
      department: action.department,
      targetRole: action.targetRole,
      competencyName: action.competencyName,
      ownerName: action.ownerName,
      actionType: action.actionType,
      priority: action.priority,
      status: status,
      dueDate: action.dueDate,
      actionPlan: action.actionPlan,
      successCriteria: action.successCriteria,
      escalationNote: action.escalationNote,
      sourceDecision: action.sourceDecision,
      reviewedLevel: action.reviewedLevel,
      targetLevel: action.targetLevel,
      sourceLevelGap: action.sourceLevelGap,
      createdAt: action.createdAt,
    );
  }
}

final careerPathSupportActionReadyReviewsProvider =
    Provider<List<IncomingTalentCareerPathReview>>((ref) {
      final actionReviewIds =
          ref
              .watch(incomingTalentCareerPathSupportActionsProvider)
              .map((action) => action.reviewId)
              .toSet();
      return ref
          .watch(filteredIncomingTalentCareerPathReviewsProvider)
          .where(
            (review) =>
                (review.decision ==
                        IncomingTalentCareerPathReviewDecision.blocked ||
                    review.decision ==
                        IncomingTalentCareerPathReviewDecision.needsSupport) &&
                !actionReviewIds.contains(review.id),
          )
          .toList();
    });

final filteredIncomingTalentCareerPathSupportActionsProvider =
    Provider<List<IncomingTalentCareerPathSupportAction>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentCareerPathSupportActionsProvider)
          .where(
            (action) =>
                (selectedDepartment == talentAllDepartments ||
                    action.department == selectedDepartment) &&
                (!attentionOnly || action.needsAttention),
          )
          .toList();
    });

final incomingTalentCareerPathSupportActionSummaryProvider =
    Provider<IncomingTalentCareerPathSupportActionSummary>((ref) {
      return IncomingTalentCareerPathSupportActionSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentCareerPathSupportActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
