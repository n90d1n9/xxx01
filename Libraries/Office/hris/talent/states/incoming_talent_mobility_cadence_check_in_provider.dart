import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_stabilization_outcome_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityCadenceCheckInDraftProvider = StateNotifierProvider<
  IncomingTalentMobilityCadenceCheckInDraftNotifier,
  IncomingTalentMobilityCadenceCheckInDraft
>((ref) {
  return IncomingTalentMobilityCadenceCheckInDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentMobilityCadenceCheckInDraftNotifier
    extends StateNotifier<IncomingTalentMobilityCadenceCheckInDraft> {
  IncomingTalentMobilityCadenceCheckInDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentMobilityCadenceCheckInDraft.empty(asOfDate));

  void initializeFromOutcome(
    IncomingTalentMobilityStabilizationOutcome outcome,
  ) {
    state = IncomingTalentMobilityCadenceCheckInDraft.fromOutcome(
      outcome: outcome,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setCheckInDate(DateTime value) {
    final status = state.status ?? IncomingTalentMobilityCadenceStatus.watch;
    state = state.copyWith(
      checkInDate: value,
      nextReviewDate: defaultIncomingTalentMobilityCadenceNextReviewDate(
        status: status,
        checkInDate: value,
      ),
    );
  }

  void setStatus(IncomingTalentMobilityCadenceStatus value) {
    state = state.copyWith(
      status: value,
      supportPlan: defaultIncomingTalentMobilityCadenceSupportByStatus(value),
      nextReviewDate: defaultIncomingTalentMobilityCadenceNextReviewDate(
        status: value,
        checkInDate: state.checkInDate ?? state.asOfDate,
      ),
    );
  }

  void setResidualRisk(IncomingTalentMobilityStabilizationResidualRisk value) {
    state = state.copyWith(residualRisk: value);
  }

  void setHostConfidenceScore(int value) {
    state = state.copyWith(hostConfidenceScore: value);
  }

  void setPulseSummary(String value) {
    state = state.copyWith(pulseSummary: value);
  }

  void setSupportPlan(String value) {
    state = state.copyWith(supportPlan: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentMobilityCadenceCheckInDraft.empty(state.asOfDate);
  }
}

final incomingTalentMobilityCadenceCheckInsProvider = StateNotifierProvider<
  IncomingTalentMobilityCadenceCheckInsNotifier,
  List<IncomingTalentMobilityCadenceCheckIn>
>((ref) {
  return IncomingTalentMobilityCadenceCheckInsNotifier();
});

class IncomingTalentMobilityCadenceCheckInsNotifier
    extends StateNotifier<List<IncomingTalentMobilityCadenceCheckIn>> {
  IncomingTalentMobilityCadenceCheckInsNotifier() : super(const []);

  IncomingTalentMobilityCadenceCheckIn submitDraft(
    IncomingTalentMobilityCadenceCheckInDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (item) =>
          item.outcomeId == draft.outcomeId &&
          _isSameDay(item.checkInDate, draft.checkInDate!),
    )) {
      throw StateError(
        'Cadence check-in already exists for this outcome today',
      );
    }

    final checkIn = draft.toCheckIn(id: _nextId(), createdAt: draft.asOfDate);
    state = [checkIn, ...state];
    return checkIn;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-cadence-check-in-${sequence.toString().padLeft(3, '0')}';
  }
}

final cadenceReadyMobilityStabilizationOutcomesProvider =
    Provider<List<IncomingTalentMobilityStabilizationOutcome>>((ref) {
      final asOfDate = ref.watch(talentAsOfDateProvider);
      final latestByOutcome = _latestCheckInsByOutcome(
        ref.watch(incomingTalentMobilityCadenceCheckInsProvider),
      );

      return ref
          .watch(filteredIncomingTalentMobilityStabilizationOutcomesProvider)
          .where((outcome) {
            final latest = latestByOutcome[outcome.id];
            if (latest != null) {
              return !latest.isClosed &&
                  !_isSameDay(latest.checkInDate, asOfDate) &&
                  !_dateOnly(
                    latest.nextReviewDate,
                  ).isAfter(_dateOnly(asOfDate));
            }

            return outcome.needsAttention ||
                !_dateOnly(outcome.nextReviewDate).isAfter(_dateOnly(asOfDate));
          })
          .toList();
    });

final filteredIncomingTalentMobilityCadenceCheckInsProvider =
    Provider<List<IncomingTalentMobilityCadenceCheckIn>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityCadenceCheckInsProvider)
          .where(
            (item) =>
                (selectedDepartment == talentAllDepartments ||
                    item.department == selectedDepartment ||
                    item.hostDepartment == selectedDepartment) &&
                (!attentionOnly || item.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityCadenceCheckInSummaryProvider =
    Provider<IncomingTalentMobilityCadenceCheckInSummary>((ref) {
      return IncomingTalentMobilityCadenceCheckInSummary.fromCheckIns(
        ref.watch(filteredIncomingTalentMobilityCadenceCheckInsProvider),
      );
    });

Map<String, IncomingTalentMobilityCadenceCheckIn> _latestCheckInsByOutcome(
  List<IncomingTalentMobilityCadenceCheckIn> checkIns,
) {
  final latest = <String, IncomingTalentMobilityCadenceCheckIn>{};
  for (final checkIn in checkIns) {
    final current = latest[checkIn.outcomeId];
    if (current == null || checkIn.checkInDate.isAfter(current.checkInDate)) {
      latest[checkIn.outcomeId] = checkIn;
    }
  }
  return latest;
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
