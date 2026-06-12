import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_development_calibration_models.dart';
import '../models/candidate_development_check_in_models.dart';
import '../models/candidate_development_intervention_models.dart';
import 'candidate_development_check_in_provider.dart';
import 'candidate_development_intervention_provider.dart';
import 'candidate_development_provider.dart';
import 'recruitment_provider.dart';

final candidateDevelopmentCalibrationProfilesProvider =
    Provider<List<CandidateDevelopmentCalibrationProfile>>((ref) {
      final asOfDate = ref.watch(recruitmentAsOfDateProvider);
      final checkInsByObjective = _checkInsByObjective(
        ref.watch(candidateDevelopmentCheckInsProvider),
      );
      final interventionsByObjective = _interventionsByObjective(
        ref.watch(candidateDevelopmentInterventionsProvider),
      );

      return ref
          .watch(candidateDevelopmentObjectivesProvider)
          .map(
            (objective) => CandidateDevelopmentCalibrationProfile.fromSignals(
              objective: objective,
              checkIns: checkInsByObjective[objective.id] ?? const [],
              interventions: interventionsByObjective[objective.id] ?? const [],
              asOfDate: asOfDate,
            ),
          )
          .toList();
    });

final candidateDevelopmentCalibrationSummaryProvider =
    Provider<CandidateDevelopmentCalibrationSummary>((ref) {
      return CandidateDevelopmentCalibrationSummary.fromProfiles(
        ref.watch(candidateDevelopmentCalibrationProfilesProvider),
      );
    });

final candidateDevelopmentCalibrationDraftProvider = StateNotifierProvider<
  CandidateDevelopmentCalibrationDraftNotifier,
  CandidateDevelopmentCalibrationDraft
>((ref) {
  return CandidateDevelopmentCalibrationDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateDevelopmentCalibrationDraftNotifier
    extends StateNotifier<CandidateDevelopmentCalibrationDraft> {
  CandidateDevelopmentCalibrationDraftNotifier(DateTime asOfDate)
    : super(CandidateDevelopmentCalibrationDraft.empty(asOfDate));

  void initializeFromProfile(CandidateDevelopmentCalibrationProfile profile) {
    state = CandidateDevelopmentCalibrationDraft.fromProfile(
      profile: profile,
      asOfDate: state.asOfDate,
    );
  }

  void setOutcome(CandidateDevelopmentCalibrationOutcome value) {
    state = state.copyWith(outcome: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void clear() {
    state = CandidateDevelopmentCalibrationDraft.empty(state.asOfDate);
  }
}

final candidateDevelopmentCalibrationReviewsProvider = StateNotifierProvider<
  CandidateDevelopmentCalibrationReviewsNotifier,
  List<CandidateDevelopmentCalibrationReview>
>((ref) {
  return CandidateDevelopmentCalibrationReviewsNotifier();
});

class CandidateDevelopmentCalibrationReviewsNotifier
    extends StateNotifier<List<CandidateDevelopmentCalibrationReview>> {
  CandidateDevelopmentCalibrationReviewsNotifier() : super(const []);

  CandidateDevelopmentCalibrationReview submitDraft(
    CandidateDevelopmentCalibrationDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'development-calibration-${sequence.toString().padLeft(3, '0')}';
  }
}

Map<String, List<CandidateDevelopmentCheckIn>> _checkInsByObjective(
  List<CandidateDevelopmentCheckIn> checkIns,
) {
  final grouped = <String, List<CandidateDevelopmentCheckIn>>{};
  for (final checkIn in checkIns) {
    grouped.putIfAbsent(checkIn.objectiveId, () => []).add(checkIn);
  }
  return grouped;
}

Map<String, List<CandidateDevelopmentIntervention>> _interventionsByObjective(
  List<CandidateDevelopmentIntervention> interventions,
) {
  final grouped = <String, List<CandidateDevelopmentIntervention>>{};
  for (final intervention in interventions) {
    grouped.putIfAbsent(intervention.objectiveId, () => []).add(intervention);
  }
  return grouped;
}
