import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_activation_escalation_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionActivationResolutionReviewDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationResolutionReviewDraftNotifier,
      IncomingTalentSuccessionActivationResolutionReviewDraft
    >((ref) {
      return IncomingTalentSuccessionActivationResolutionReviewDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionActivationResolutionReviewDraftNotifier
    extends
        StateNotifier<IncomingTalentSuccessionActivationResolutionReviewDraft> {
  IncomingTalentSuccessionActivationResolutionReviewDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentSuccessionActivationResolutionReviewDraft.empty(asOfDate),
      );

  void initializeFromEscalation(
    IncomingTalentSuccessionActivationEscalation escalation,
  ) {
    state =
        IncomingTalentSuccessionActivationResolutionReviewDraft.fromEscalation(
          escalation: escalation,
          asOfDate: state.asOfDate,
        );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setResolutionDate(DateTime value) {
    state = state.copyWith(resolutionDate: value);
  }

  void setOutcome(IncomingTalentSuccessionActivationResolutionOutcome value) {
    state = state.copyWith(outcome: value);
  }

  void setResidualRisk(IncomingTalentSuccessionActivationResidualRisk value) {
    state = state.copyWith(residualRisk: value);
  }

  void setFinalConfidenceScore(int value) {
    state = state.copyWith(finalConfidenceScore: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setSponsorConfirmation(String value) {
    state = state.copyWith(sponsorConfirmation: value);
  }

  void setNextGovernanceStep(String value) {
    state = state.copyWith(nextGovernanceStep: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentSuccessionActivationResolutionReviewDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionActivationResolutionReviewsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationResolutionReviewsNotifier,
      List<IncomingTalentSuccessionActivationResolutionReview>
    >((ref) {
      return IncomingTalentSuccessionActivationResolutionReviewsNotifier();
    });

class IncomingTalentSuccessionActivationResolutionReviewsNotifier
    extends
        StateNotifier<
          List<IncomingTalentSuccessionActivationResolutionReview>
        > {
  IncomingTalentSuccessionActivationResolutionReviewsNotifier()
    : super(const []);

  IncomingTalentSuccessionActivationResolutionReview submitDraft(
    IncomingTalentSuccessionActivationResolutionReviewDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((review) => review.escalationId == draft.escalationId)) {
      throw StateError('Resolution review already exists for this escalation');
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-activation-resolution-${sequence.toString().padLeft(3, '0')}';
  }
}

final resolutionReadySuccessionActivationEscalationsProvider = Provider<
  List<IncomingTalentSuccessionActivationEscalation>
>((ref) {
  final reviewedEscalationIds =
      ref
          .watch(incomingTalentSuccessionActivationResolutionReviewsProvider)
          .map((review) => review.escalationId)
          .toSet();

  return ref
      .watch(filteredIncomingTalentSuccessionActivationEscalationsProvider)
      .where(
        (escalation) =>
            escalation.status ==
                IncomingTalentSuccessionActivationEscalationStatus.resolved &&
            !reviewedEscalationIds.contains(escalation.id),
      )
      .toList();
});

final filteredIncomingTalentSuccessionActivationResolutionReviewsProvider =
    Provider<List<IncomingTalentSuccessionActivationResolutionReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionActivationResolutionReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.department == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionActivationResolutionReviewSummaryProvider =
    Provider<IncomingTalentSuccessionActivationResolutionReviewSummary>((ref) {
      return IncomingTalentSuccessionActivationResolutionReviewSummary.fromReviews(
        ref.watch(
          filteredIncomingTalentSuccessionActivationResolutionReviewsProvider,
        ),
      );
    });
