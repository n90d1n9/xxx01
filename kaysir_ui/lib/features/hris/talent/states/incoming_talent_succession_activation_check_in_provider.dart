import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_activation_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionActivationCheckInDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationCheckInDraftNotifier,
      IncomingTalentSuccessionActivationCheckInDraft
    >((ref) {
      return IncomingTalentSuccessionActivationCheckInDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionActivationCheckInDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionActivationCheckInDraft> {
  IncomingTalentSuccessionActivationCheckInDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionActivationCheckInDraft.empty(asOfDate));

  void initializeFromPlan(IncomingTalentSuccessionActivationPlan plan) {
    state = IncomingTalentSuccessionActivationCheckInDraft.fromPlan(
      plan: plan,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setCheckInDate(DateTime value) {
    state = state.copyWith(checkInDate: value);
  }

  void setTrend(IncomingTalentSuccessionActivationCheckInTrend value) {
    state = state.copyWith(trend: value);
  }

  void setConfidenceScore(int value) {
    state = state.copyWith(confidenceScore: value);
  }

  void setMilestoneHealth(String value) {
    state = state.copyWith(milestoneHealth: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setSponsorAction(String value) {
    state = state.copyWith(sponsorAction: value);
  }

  void setNextStep(String value) {
    state = state.copyWith(nextStep: value);
  }

  void setNextCheckInDate(DateTime value) {
    state = state.copyWith(nextCheckInDate: value);
  }

  void clear() {
    state = IncomingTalentSuccessionActivationCheckInDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionActivationCheckInsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationCheckInsNotifier,
      List<IncomingTalentSuccessionActivationCheckIn>
    >((ref) {
      return IncomingTalentSuccessionActivationCheckInsNotifier();
    });

class IncomingTalentSuccessionActivationCheckInsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionActivationCheckIn>> {
  IncomingTalentSuccessionActivationCheckInsNotifier() : super(const []);

  IncomingTalentSuccessionActivationCheckIn submitDraft(
    IncomingTalentSuccessionActivationCheckInDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (checkIn) =>
          checkIn.activationPlanId == draft.activationPlanId &&
          _isSameDay(checkIn.checkInDate, draft.checkInDate!),
    )) {
      throw StateError('Activation check-in already exists for this date');
    }

    final checkIn = draft.toCheckIn(id: _nextId(), createdAt: draft.asOfDate);
    state = [checkIn, ...state];
    return checkIn;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-activation-check-in-${sequence.toString().padLeft(3, '0')}';
  }
}

final checkInReadySuccessionActivationPlansProvider =
    Provider<List<IncomingTalentSuccessionActivationPlan>>((ref) {
      return ref
          .watch(filteredIncomingTalentSuccessionActivationPlansProvider)
          .where((plan) => !plan.isCompleted)
          .toList();
    });

final filteredIncomingTalentSuccessionActivationCheckInsProvider =
    Provider<List<IncomingTalentSuccessionActivationCheckIn>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionActivationCheckInsProvider)
          .where(
            (checkIn) =>
                (selectedDepartment == talentAllDepartments ||
                    checkIn.department == selectedDepartment) &&
                (!attentionOnly || checkIn.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionActivationCheckInSummaryProvider =
    Provider<IncomingTalentSuccessionActivationCheckInSummary>((ref) {
      return IncomingTalentSuccessionActivationCheckInSummary.fromCheckIns(
        ref.watch(filteredIncomingTalentSuccessionActivationCheckInsProvider),
      );
    });

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
