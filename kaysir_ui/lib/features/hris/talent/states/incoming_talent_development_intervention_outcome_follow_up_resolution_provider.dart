import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import '../models/incoming_talent_development_intervention_outcome_follow_up_resolution_models.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftNotifier,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
    >((ref) {
      return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftNotifier
    extends
        StateNotifier<
          IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft
        > {
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.empty(
          asOfDate,
        ),
      );

  void initializeFromFollowUp(
    IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
  ) {
    state =
        IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.fromFollowUp(
          followUp: followUp,
          asOfDate: state.asOfDate,
        );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    final decision = state.decision;
    state = state.copyWith(
      reviewDate: value,
      nextReviewDate:
          decision == null
              ? value.add(const Duration(days: 30))
              : defaultIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionNextReviewDate(
                decision: decision,
                reviewDate: value,
              ),
    );
  }

  void setDecision(
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
    value,
  ) {
    final reviewDate = state.reviewDate ?? state.asOfDate;
    state = state.copyWith(
      decision: value,
      nextAction:
          defaultIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionNextAction(
            value,
          ),
      nextReviewDate:
          defaultIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionNextReviewDate(
            decision: value,
            reviewDate: reviewDate,
          ),
    );
  }

  void setConfidenceAfter(int value) {
    state = state.copyWith(confidenceAfter: value);
  }

  void setRemainingReleaseRiskCount(int value) {
    state = state.copyWith(remainingReleaseRiskCount: value < 0 ? 0 : value);
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
    state =
        IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.empty(
          state.asOfDate,
        );
  }
}

final incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsNotifier,
      List<IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution>
    >((ref) {
      return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsNotifier();
    });

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsNotifier
    extends
        StateNotifier<
          List<IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution>
        > {
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsNotifier()
    : super(const []);

  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution submitDraft(
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((item) => item.followUpId == draft.followUpId)) {
      throw StateError(
        'Resolution review already exists for this intervention follow-up',
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
    return 'talent-intervention-follow-up-resolution-${sequence.toString().padLeft(3, '0')}';
  }
}

final resolutionReadyDevelopmentInterventionOutcomeFollowUpsProvider = Provider<
  List<IncomingTalentDevelopmentInterventionOutcomeFollowUp>
>((ref) {
  final reviewedFollowUpIds =
      ref
          .watch(
            incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider,
          )
          .map((item) => item.followUpId)
          .toSet();

  return ref
      .watch(
        filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpsProvider,
      )
      .where(
        (followUp) =>
            followUp.isClosed && !reviewedFollowUpIds.contains(followUp.id),
      )
      .toList();
});

final filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider =
    Provider<
      List<IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution>
    >((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(
            incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider,
          )
          .where(
            (item) =>
                (selectedDepartment == talentAllDepartments ||
                    item.department == selectedDepartment) &&
                (!attentionOnly || item.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummaryProvider =
    Provider<
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary
    >((ref) {
      return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary.fromResolutions(
        ref.watch(
          filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider,
        ),
      );
    });
