import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_check_in_models.dart';
import '../models/incoming_talent_development_roadmap_models.dart';
import 'incoming_talent_development_roadmap_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentCheckInDraftProvider = StateNotifierProvider<
  IncomingTalentDevelopmentCheckInDraftNotifier,
  IncomingTalentDevelopmentCheckInDraft
>((ref) {
  return IncomingTalentDevelopmentCheckInDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentDevelopmentCheckInDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentCheckInDraft> {
  IncomingTalentDevelopmentCheckInDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentCheckInDraft.empty(asOfDate));

  void initializeFromRoadmap(IncomingTalentDevelopmentRoadmap roadmap) {
    state = IncomingTalentDevelopmentCheckInDraft.fromRoadmap(
      roadmap: roadmap,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setCheckInDate(DateTime value) {
    state = state.copyWith(checkInDate: value);
  }

  void setTrend(IncomingTalentDevelopmentCheckInTrend value) {
    state = state.copyWith(trend: value);
  }

  void setConfidenceScore(int value) {
    state = state.copyWith(confidenceScore: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setManagerCommitment(String value) {
    state = state.copyWith(managerCommitment: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentCheckInDraft.empty(state.asOfDate);
  }
}

final incomingTalentDevelopmentCheckInsProvider = StateNotifierProvider<
  IncomingTalentDevelopmentCheckInsNotifier,
  List<IncomingTalentDevelopmentCheckIn>
>((ref) {
  return IncomingTalentDevelopmentCheckInsNotifier();
});

class IncomingTalentDevelopmentCheckInsNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentCheckIn>> {
  IncomingTalentDevelopmentCheckInsNotifier() : super(const []);

  IncomingTalentDevelopmentCheckIn submitDraft(
    IncomingTalentDevelopmentCheckInDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (checkIn) =>
          checkIn.roadmapId == draft.roadmapId &&
          _isSameDay(checkIn.checkInDate, draft.checkInDate!),
    )) {
      throw StateError('Check-in already exists for this roadmap date');
    }

    final checkIn = draft.toCheckIn(id: _nextId(), createdAt: draft.asOfDate);
    state = [checkIn, ...state];
    return checkIn;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-check-in-${sequence.toString().padLeft(3, '0')}';
  }
}

final checkInReadyDevelopmentRoadmapsProvider =
    Provider<List<IncomingTalentDevelopmentRoadmap>>((ref) {
      return ref
          .watch(filteredIncomingTalentDevelopmentRoadmapsProvider)
          .where(
            (roadmap) =>
                roadmap.status !=
                IncomingTalentDevelopmentRoadmapStatus.completed,
          )
          .toList();
    });

final filteredIncomingTalentDevelopmentCheckInsProvider =
    Provider<List<IncomingTalentDevelopmentCheckIn>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentCheckInsProvider)
          .where(
            (checkIn) =>
                (selectedDepartment == talentAllDepartments ||
                    checkIn.department == selectedDepartment) &&
                (!attentionOnly || checkIn.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentCheckInSummaryProvider =
    Provider<IncomingTalentDevelopmentCheckInSummary>((ref) {
      return IncomingTalentDevelopmentCheckInSummary.fromCheckIns(
        checkIns: ref.watch(filteredIncomingTalentDevelopmentCheckInsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
