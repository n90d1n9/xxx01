import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_bench_replenishment_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionBenchCheckInDraftProvider = StateNotifierProvider<
  IncomingTalentSuccessionBenchCheckInDraftNotifier,
  IncomingTalentSuccessionBenchCheckInDraft
>((ref) {
  return IncomingTalentSuccessionBenchCheckInDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentSuccessionBenchCheckInDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionBenchCheckInDraft> {
  IncomingTalentSuccessionBenchCheckInDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionBenchCheckInDraft.empty(asOfDate));

  void initializeFromReplenishment(
    IncomingTalentSuccessionBenchReplenishment plan,
  ) {
    state = IncomingTalentSuccessionBenchCheckInDraft.fromReplenishment(
      plan: plan,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setHealth(IncomingTalentSuccessionBenchCheckInHealth value) {
    state = state.copyWith(health: value);
  }

  void setCheckInDate(DateTime value) {
    state = state.copyWith(checkInDate: value);
  }

  void setSuccessorSlateCount(int value) {
    state = state.copyWith(
      successorSlateCount: value,
      readyNowCount:
          state.readyNowCount > value && value > 0
              ? value
              : state.readyNowCount,
    );
  }

  void setReadyNowCount(int value) {
    state = state.copyWith(readyNowCount: value);
  }

  void setReadinessScore(int value) {
    state = state.copyWith(readinessScore: value);
  }

  void setBlockerSummary(String value) {
    state = state.copyWith(blockerSummary: value);
  }

  void setLeadershipSupport(String value) {
    state = state.copyWith(leadershipSupport: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setNextCheckInDate(DateTime value) {
    state = state.copyWith(nextCheckInDate: value);
  }

  void clear() {
    state = IncomingTalentSuccessionBenchCheckInDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionBenchCheckInsProvider = StateNotifierProvider<
  IncomingTalentSuccessionBenchCheckInsNotifier,
  List<IncomingTalentSuccessionBenchCheckIn>
>((ref) {
  return IncomingTalentSuccessionBenchCheckInsNotifier();
});

class IncomingTalentSuccessionBenchCheckInsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionBenchCheckIn>> {
  IncomingTalentSuccessionBenchCheckInsNotifier() : super(const []);

  IncomingTalentSuccessionBenchCheckIn submitDraft(
    IncomingTalentSuccessionBenchCheckInDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (checkIn) =>
          checkIn.benchReplenishmentId == draft.benchReplenishmentId &&
          _sameDay(checkIn.checkInDate, draft.checkInDate!),
    )) {
      throw StateError('Bench check-in already exists for this date');
    }

    final checkIn = draft.toCheckIn(id: _nextId(), createdAt: draft.asOfDate);
    state = [checkIn, ...state];
    return checkIn;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-bench-check-in-${sequence.toString().padLeft(3, '0')}';
  }
}

final checkInReadySuccessionBenchReplenishmentsProvider =
    Provider<List<IncomingTalentSuccessionBenchReplenishment>>((ref) {
      final asOfDate = ref.watch(talentAsOfDateProvider);
      final checkedTodayPlanIds =
          ref
              .watch(incomingTalentSuccessionBenchCheckInsProvider)
              .where((checkIn) => _sameDay(checkIn.checkInDate, asOfDate))
              .map((checkIn) => checkIn.benchReplenishmentId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionBenchReplenishmentsProvider)
          .where(
            (plan) => plan.isOpen && !checkedTodayPlanIds.contains(plan.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionBenchCheckInsProvider =
    Provider<List<IncomingTalentSuccessionBenchCheckIn>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionBenchCheckInsProvider)
          .where(
            (checkIn) =>
                (selectedDepartment == talentAllDepartments ||
                    checkIn.department == selectedDepartment) &&
                (!attentionOnly || checkIn.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionBenchCheckInSummaryProvider =
    Provider<IncomingTalentSuccessionBenchCheckInSummary>((ref) {
      return IncomingTalentSuccessionBenchCheckInSummary.fromCheckIns(
        ref.watch(filteredIncomingTalentSuccessionBenchCheckInsProvider),
      );
    });

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
