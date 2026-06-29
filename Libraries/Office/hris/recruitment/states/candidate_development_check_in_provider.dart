import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_development_check_in_models.dart';
import '../models/candidate_development_models.dart';
import 'recruitment_provider.dart';

final candidateDevelopmentCheckInDraftProvider = StateNotifierProvider<
  CandidateDevelopmentCheckInDraftNotifier,
  CandidateDevelopmentCheckInDraft
>((ref) {
  return CandidateDevelopmentCheckInDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateDevelopmentCheckInDraftNotifier
    extends StateNotifier<CandidateDevelopmentCheckInDraft> {
  CandidateDevelopmentCheckInDraftNotifier(DateTime asOfDate)
    : super(CandidateDevelopmentCheckInDraft.empty(asOfDate));

  void initializeFromObjective(CandidateDevelopmentObjective objective) {
    state = CandidateDevelopmentCheckInDraft.fromObjective(
      objective: objective,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setConfidence(String value) {
    state = state.copyWith(confidenceText: value);
  }

  void setProgressNote(String value) {
    state = state.copyWith(progressNote: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = CandidateDevelopmentCheckInDraft.empty(state.asOfDate);
  }
}

final candidateDevelopmentCheckInsProvider = StateNotifierProvider<
  CandidateDevelopmentCheckInsNotifier,
  List<CandidateDevelopmentCheckIn>
>((ref) {
  return CandidateDevelopmentCheckInsNotifier();
});

class CandidateDevelopmentCheckInsNotifier
    extends StateNotifier<List<CandidateDevelopmentCheckIn>> {
  CandidateDevelopmentCheckInsNotifier() : super(const []);

  CandidateDevelopmentCheckIn submitDraft(
    CandidateDevelopmentCheckInDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final checkIn = draft.toCheckIn(id: _nextId(), createdAt: draft.asOfDate);
    state = [checkIn, ...state];
    return checkIn;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'development-check-in-${sequence.toString().padLeft(3, '0')}';
  }
}

final candidateDevelopmentCheckInSummaryProvider =
    Provider<CandidateDevelopmentCheckInSummary>((ref) {
      return CandidateDevelopmentCheckInSummary.fromCheckIns(
        checkIns: ref.watch(candidateDevelopmentCheckInsProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });
