import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_calibration_models.dart';
import 'incoming_talent_activation_outcome_provider.dart';
import 'incoming_talent_development_check_in_provider.dart';
import 'incoming_talent_development_intervention_provider.dart';
import 'incoming_talent_development_roadmap_provider.dart';
import 'talent_provider.dart';

final incomingTalentCalibrationReviewDraftProvider = StateNotifierProvider<
  IncomingTalentCalibrationReviewDraftNotifier,
  IncomingTalentCalibrationReviewDraft
>((ref) {
  return IncomingTalentCalibrationReviewDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentCalibrationReviewDraftNotifier
    extends StateNotifier<IncomingTalentCalibrationReviewDraft> {
  IncomingTalentCalibrationReviewDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentCalibrationReviewDraft.empty(asOfDate));

  void initializeFromPacket(IncomingTalentCalibrationPacket packet) {
    state = IncomingTalentCalibrationReviewDraft.fromPacket(
      packet: packet,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setDecision(IncomingTalentCalibrationDecision value) {
    state = state.copyWith(decision: value);
  }

  void setPotential(IncomingTalentCalibrationPotential value) {
    state = state.copyWith(potential: value);
  }

  void setTalentTrack(String value) {
    state = state.copyWith(talentTrack: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setDecisionNote(String value) {
    state = state.copyWith(decisionNote: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentCalibrationReviewDraft.empty(state.asOfDate);
  }
}

final incomingTalentCalibrationReviewsProvider = StateNotifierProvider<
  IncomingTalentCalibrationReviewsNotifier,
  List<IncomingTalentCalibrationReview>
>((ref) {
  return IncomingTalentCalibrationReviewsNotifier();
});

class IncomingTalentCalibrationReviewsNotifier
    extends StateNotifier<List<IncomingTalentCalibrationReview>> {
  IncomingTalentCalibrationReviewsNotifier() : super(const []);

  IncomingTalentCalibrationReview submitDraft(
    IncomingTalentCalibrationReviewDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((review) => review.packetId == draft.packetId)) {
      throw StateError('Calibration review already exists for this packet');
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-calibration-${sequence.toString().padLeft(3, '0')}';
  }
}

final incomingTalentCalibrationPacketsProvider =
    Provider<List<IncomingTalentCalibrationPacket>>((ref) {
      final roadmaps = ref.watch(incomingTalentDevelopmentRoadmapsProvider);
      final checkIns = ref.watch(incomingTalentDevelopmentCheckInsProvider);
      final interventions = ref.watch(
        incomingTalentDevelopmentInterventionsProvider,
      );
      final packets =
          ref
              .watch(incomingTalentActivationOutcomeReviewsProvider)
              .map(
                (outcome) => IncomingTalentCalibrationPacket.fromSignals(
                  outcome: outcome,
                  roadmaps: roadmaps,
                  checkIns: checkIns,
                  interventions: interventions,
                ),
              )
              .toList()
            ..sort(_compareCalibrationPackets);

      return packets;
    });

final filteredIncomingTalentCalibrationPacketsProvider =
    Provider<List<IncomingTalentCalibrationPacket>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentCalibrationPacketsProvider)
          .where(
            (packet) =>
                (selectedDepartment == talentAllDepartments ||
                    packet.department == selectedDepartment) &&
                (!attentionOnly || packet.needsAttention),
          )
          .toList();
    });

final calibrationReadyPacketsProvider =
    Provider<List<IncomingTalentCalibrationPacket>>((ref) {
      final reviewedPacketIds =
          ref
              .watch(incomingTalentCalibrationReviewsProvider)
              .map((review) => review.packetId)
              .toSet();
      return ref
          .watch(filteredIncomingTalentCalibrationPacketsProvider)
          .where((packet) => !reviewedPacketIds.contains(packet.id))
          .toList();
    });

final incomingTalentCalibrationPacketSummaryProvider =
    Provider<IncomingTalentCalibrationSummary>((ref) {
      return IncomingTalentCalibrationSummary.fromPackets(
        ref.watch(filteredIncomingTalentCalibrationPacketsProvider),
      );
    });

final filteredIncomingTalentCalibrationReviewsProvider =
    Provider<List<IncomingTalentCalibrationReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentCalibrationReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.department == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentCalibrationReviewSummaryProvider =
    Provider<IncomingTalentCalibrationSummary>((ref) {
      return IncomingTalentCalibrationSummary.fromReviews(
        ref.watch(filteredIncomingTalentCalibrationReviewsProvider),
      );
    });

int _compareCalibrationPackets(
  IncomingTalentCalibrationPacket a,
  IncomingTalentCalibrationPacket b,
) {
  final attentionCompare = (b.needsAttention ? 1 : 0).compareTo(
    a.needsAttention ? 1 : 0,
  );
  if (attentionCompare != 0) return attentionCompare;
  final recommendationCompare = _recommendationRank(
    a.recommendation,
  ).compareTo(_recommendationRank(b.recommendation));
  if (recommendationCompare != 0) return recommendationCompare;
  return a.reviewDueDate.compareTo(b.reviewDueDate);
}

int _recommendationRank(IncomingTalentCalibrationRecommendation value) {
  return switch (value) {
    IncomingTalentCalibrationRecommendation.escalate => 0,
    IncomingTalentCalibrationRecommendation.coach => 1,
    IncomingTalentCalibrationRecommendation.maintainCadence => 2,
    IncomingTalentCalibrationRecommendation.accelerate => 3,
  };
}
