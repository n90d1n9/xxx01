import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_development_calibration_models.dart';
import '../models/candidate_talent_handoff_models.dart';
import 'recruitment_provider.dart';

final candidateTalentHandoffDraftProvider = StateNotifierProvider<
  CandidateTalentHandoffDraftNotifier,
  CandidateTalentHandoffDraft
>((ref) {
  return CandidateTalentHandoffDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateTalentHandoffDraftNotifier
    extends StateNotifier<CandidateTalentHandoffDraft> {
  CandidateTalentHandoffDraftNotifier(DateTime asOfDate)
    : super(CandidateTalentHandoffDraft.empty(asOfDate));

  void initializeFromCalibrationReview(
    CandidateDevelopmentCalibrationReview review,
  ) {
    state = CandidateTalentHandoffDraft.fromCalibrationReview(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setType(CandidateTalentHandoffType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CandidateTalentHandoffStatus value) {
    state = state.copyWith(status: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setReceivingManagerName(String value) {
    state = state.copyWith(receivingManagerName: value);
  }

  void setTargetStartDate(DateTime value) {
    state = state.copyWith(targetStartDate: value);
  }

  void setFirstCheckpointDate(DateTime value) {
    state = state.copyWith(firstCheckpointDate: value);
  }

  void setTalentFocus(String value) {
    state = state.copyWith(talentFocus: value);
  }

  void setHandoffNote(String value) {
    state = state.copyWith(handoffNote: value);
  }

  void clear() {
    state = CandidateTalentHandoffDraft.empty(state.asOfDate);
  }
}

final candidateTalentHandoffsProvider = StateNotifierProvider<
  CandidateTalentHandoffsNotifier,
  List<CandidateTalentHandoff>
>((ref) {
  return CandidateTalentHandoffsNotifier();
});

class CandidateTalentHandoffsNotifier
    extends StateNotifier<List<CandidateTalentHandoff>> {
  CandidateTalentHandoffsNotifier() : super(const []);

  CandidateTalentHandoff submitDraft(CandidateTalentHandoffDraft draft) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final handoff = draft.toHandoff(id: _nextId(), createdAt: draft.asOfDate);
    state = [handoff, ...state];
    return handoff;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-handoff-${sequence.toString().padLeft(3, '0')}';
  }
}

final candidateTalentHandoffSummaryProvider =
    Provider<CandidateTalentHandoffSummary>((ref) {
      return CandidateTalentHandoffSummary.fromHandoffs(
        ref.watch(candidateTalentHandoffsProvider),
      );
    });
