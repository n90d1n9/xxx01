import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_panel_decision_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionActivationDraftProvider = StateNotifierProvider<
  IncomingTalentSuccessionActivationDraftNotifier,
  IncomingTalentSuccessionActivationPlanDraft
>((ref) {
  return IncomingTalentSuccessionActivationDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentSuccessionActivationDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionActivationPlanDraft> {
  IncomingTalentSuccessionActivationDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionActivationPlanDraft.empty(asOfDate));

  void initializeFromDecision(IncomingTalentSuccessionPanelDecision decision) {
    state = IncomingTalentSuccessionActivationPlanDraft.fromDecision(
      decision: decision,
      asOfDate: state.asOfDate,
    );
  }

  void setActivationOwner(String value) {
    state = state.copyWith(activationOwner: value);
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setStatus(IncomingTalentSuccessionActivationStatus value) {
    state = state.copyWith(status: value);
  }

  void setStartDate(DateTime value) {
    state = state.copyWith(startDate: value);
  }

  void setMilestoneDate(DateTime value) {
    state = state.copyWith(milestoneDate: value);
  }

  void setFirstReviewDate(DateTime value) {
    state = state.copyWith(firstReviewDate: value);
  }

  void setTransitionGoal(String value) {
    state = state.copyWith(transitionGoal: value);
  }

  void setMilestone(String value) {
    state = state.copyWith(milestone: value);
  }

  void setSuccessMetric(String value) {
    state = state.copyWith(successMetric: value);
  }

  void setSupportPlan(String value) {
    state = state.copyWith(supportPlan: value);
  }

  void clear() {
    state = IncomingTalentSuccessionActivationPlanDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionActivationPlansProvider = StateNotifierProvider<
  IncomingTalentSuccessionActivationPlansNotifier,
  List<IncomingTalentSuccessionActivationPlan>
>((ref) {
  return IncomingTalentSuccessionActivationPlansNotifier();
});

class IncomingTalentSuccessionActivationPlansNotifier
    extends StateNotifier<List<IncomingTalentSuccessionActivationPlan>> {
  IncomingTalentSuccessionActivationPlansNotifier() : super(const []);

  IncomingTalentSuccessionActivationPlan submitDraft(
    IncomingTalentSuccessionActivationPlanDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((plan) => plan.decisionId == draft.decisionId)) {
      throw StateError('Activation plan already exists for panel decision');
    }

    final plan = draft.toPlan(id: _nextId(), createdAt: draft.asOfDate);
    state = [plan, ...state];
    return plan;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-activation-${sequence.toString().padLeft(3, '0')}';
  }
}

final activationReadySuccessionPanelDecisionsProvider =
    Provider<List<IncomingTalentSuccessionPanelDecision>>((ref) {
      final activatedDecisionIds =
          ref
              .watch(incomingTalentSuccessionActivationPlansProvider)
              .map((plan) => plan.decisionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionPanelDecisionsProvider)
          .where(
            (decision) =>
                decision.isApproved &&
                !activatedDecisionIds.contains(decision.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionActivationPlansProvider =
    Provider<List<IncomingTalentSuccessionActivationPlan>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionActivationPlansProvider)
          .where(
            (plan) =>
                (selectedDepartment == talentAllDepartments ||
                    plan.department == selectedDepartment) &&
                (!attentionOnly || plan.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionActivationSummaryProvider =
    Provider<IncomingTalentSuccessionActivationSummary>((ref) {
      return IncomingTalentSuccessionActivationSummary.fromPlans(
        ref.watch(filteredIncomingTalentSuccessionActivationPlansProvider),
      );
    });
