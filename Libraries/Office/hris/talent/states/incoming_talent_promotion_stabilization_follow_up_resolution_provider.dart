import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import '../models/incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'talent_provider.dart';

final incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider =
    StateNotifierProvider<
      IncomingTalentPromotionStabilizationFollowUpResolutionDraftNotifier,
      IncomingTalentPromotionStabilizationFollowUpResolutionDraft
    >((ref) {
      return IncomingTalentPromotionStabilizationFollowUpResolutionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

/// Owns the editable promotion follow-up resolution review draft.
class IncomingTalentPromotionStabilizationFollowUpResolutionDraftNotifier
    extends
        StateNotifier<
          IncomingTalentPromotionStabilizationFollowUpResolutionDraft
        > {
  IncomingTalentPromotionStabilizationFollowUpResolutionDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentPromotionStabilizationFollowUpResolutionDraft.empty(
          asOfDate,
        ),
      );

  void initializeFromAction(
    IncomingTalentPromotionStabilizationFollowUpAction action,
  ) {
    state =
        IncomingTalentPromotionStabilizationFollowUpResolutionDraft.fromAction(
          action: action,
          asOfDate: state.asOfDate,
        );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    final outcome = state.outcome;
    state = state.copyWith(
      reviewDate: value,
      nextReviewDate:
          outcome == null
              ? value.add(const Duration(days: 30))
              : value.add(
                defaultIncomingTalentPromotionFollowUpResolutionNextReviewOffset(
                  outcome,
                ),
              ),
    );
  }

  void setOutcome(
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome value,
  ) {
    final reviewDate = state.reviewDate ?? state.asOfDate;
    state = state.copyWith(
      outcome: value,
      nextAction: defaultIncomingTalentPromotionFollowUpResolutionNextAction(
        value,
      ),
      nextReviewDate: reviewDate.add(
        defaultIncomingTalentPromotionFollowUpResolutionNextReviewOffset(value),
      ),
    );
  }

  void setConfidenceAfter(int value) {
    state = state.copyWith(confidenceAfter: value);
  }

  void setResidualRiskCount(int value) {
    state = state.copyWith(residualRiskCount: value < 0 ? 0 : value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setManagerNote(String value) {
    state = state.copyWith(managerNote: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentPromotionStabilizationFollowUpResolutionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentPromotionStabilizationFollowUpResolutionsProvider =
    StateNotifierProvider<
      IncomingTalentPromotionStabilizationFollowUpResolutionsNotifier,
      List<IncomingTalentPromotionStabilizationFollowUpResolution>
    >((ref) {
      return IncomingTalentPromotionStabilizationFollowUpResolutionsNotifier();
    });

/// Stores resolution reviews for completed promotion stabilization follow-ups.
class IncomingTalentPromotionStabilizationFollowUpResolutionsNotifier
    extends
        StateNotifier<
          List<IncomingTalentPromotionStabilizationFollowUpResolution>
        > {
  IncomingTalentPromotionStabilizationFollowUpResolutionsNotifier()
    : super(const []);

  IncomingTalentPromotionStabilizationFollowUpResolution submitDraft(
    IncomingTalentPromotionStabilizationFollowUpResolutionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((resolution) => resolution.actionId == draft.actionId)) {
      throw StateError(
        'Resolution review already exists for this promotion follow-up',
      );
    }

    final resolution = draft.toResolution(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [resolution, ...state];
    return resolution;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-promotion-follow-up-resolution-${sequence.toString().padLeft(3, '0')}';
  }
}

final resolutionReadyPromotionStabilizationFollowUpActionsProvider =
    Provider<List<IncomingTalentPromotionStabilizationFollowUpAction>>((ref) {
      final reviewedActionIds =
          ref
              .watch(
                incomingTalentPromotionStabilizationFollowUpResolutionsProvider,
              )
              .map((resolution) => resolution.actionId)
              .toSet();

      return ref
          .watch(
            filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider,
          )
          .where(
            (action) =>
                _isReviewablePromotionFollowUpAction(action) &&
                !reviewedActionIds.contains(action.id),
          )
          .toList();
    });

final filteredIncomingTalentPromotionStabilizationFollowUpResolutionsProvider =
    Provider<List<IncomingTalentPromotionStabilizationFollowUpResolution>>((
      ref,
    ) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(
            incomingTalentPromotionStabilizationFollowUpResolutionsProvider,
          )
          .where(
            (resolution) =>
                (selectedDepartment == talentAllDepartments ||
                    resolution.department == selectedDepartment) &&
                (!attentionOnly || resolution.needsAttention),
          )
          .toList();
    });

final incomingTalentPromotionStabilizationFollowUpResolutionSummaryProvider =
    Provider<IncomingTalentPromotionStabilizationFollowUpResolutionSummary>((
      ref,
    ) {
      return IncomingTalentPromotionStabilizationFollowUpResolutionSummary.fromResolutions(
        ref.watch(
          filteredIncomingTalentPromotionStabilizationFollowUpResolutionsProvider,
        ),
      );
    });

bool _isReviewablePromotionFollowUpAction(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  return action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.resolved ||
      action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.escalated;
}
