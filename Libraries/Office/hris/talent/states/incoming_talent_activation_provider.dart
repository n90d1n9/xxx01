import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_activation_models.dart';
import '../models/incoming_talent_readiness.dart';
import 'talent_provider.dart';

final incomingTalentActivationDraftProvider = StateNotifierProvider<
  IncomingTalentActivationDraftNotifier,
  IncomingTalentActivationDraft
>((ref) {
  return IncomingTalentActivationDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentActivationDraftNotifier
    extends StateNotifier<IncomingTalentActivationDraft> {
  IncomingTalentActivationDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentActivationDraft.empty(asOfDate));

  void initializeFromReadiness(IncomingTalentReadiness readiness) {
    state = IncomingTalentActivationDraft.fromReadiness(
      readiness: readiness,
      asOfDate: state.asOfDate,
    );
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setLearningPlanTitle(String value) {
    state = state.copyWith(learningPlanTitle: value);
  }

  void setActivationOwner(String value) {
    state = state.copyWith(activationOwner: value);
  }

  void setKickoffDate(DateTime value) {
    state = state.copyWith(kickoffDate: value);
  }

  void setFirstCheckpointDate(DateTime value) {
    state = state.copyWith(firstCheckpointDate: value);
  }

  void setSuccessMeasure(String value) {
    state = state.copyWith(successMeasure: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void clear() {
    state = IncomingTalentActivationDraft.empty(state.asOfDate);
  }
}

final incomingTalentActivationPlansProvider = StateNotifierProvider<
  IncomingTalentActivationPlansNotifier,
  List<IncomingTalentActivationPlan>
>((ref) {
  return IncomingTalentActivationPlansNotifier();
});

class IncomingTalentActivationPlansNotifier
    extends StateNotifier<List<IncomingTalentActivationPlan>> {
  IncomingTalentActivationPlansNotifier() : super(const []);

  IncomingTalentActivationPlan submitDraft(
    IncomingTalentActivationDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((plan) => plan.handoffId == draft.handoffId)) {
      throw StateError('Activation plan already exists for this handoff');
    }

    final plan = draft.toPlan(id: _nextId(), createdAt: draft.asOfDate);
    state = [plan, ...state];
    return plan;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentActivationStatus.active);
  }

  void complete(String id) {
    _setStatus(id, IncomingTalentActivationStatus.completed);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentActivationStatus.blocked);
  }

  void _setStatus(String id, IncomingTalentActivationStatus status) {
    state =
        state.map((plan) {
          if (plan.id != id) return plan;
          return plan.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-activation-${sequence.toString().padLeft(3, '0')}';
  }
}

final filteredIncomingTalentActivationPlansProvider =
    Provider<List<IncomingTalentActivationPlan>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentActivationPlansProvider)
          .where(
            (plan) =>
                (selectedDepartment == talentAllDepartments ||
                    plan.department == selectedDepartment) &&
                (!attentionOnly || plan.needsAttention),
          )
          .toList();
    });

final incomingTalentActivationSummaryProvider =
    Provider<IncomingTalentActivationSummary>((ref) {
      return IncomingTalentActivationSummary.fromPlans(
        plans: ref.watch(filteredIncomingTalentActivationPlansProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
