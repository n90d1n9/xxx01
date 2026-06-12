import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_ramp_action_models.dart';
import '../models/candidate_ramp_models.dart';
import 'recruitment_provider.dart';

final candidateRampActionDraftProvider = StateNotifierProvider<
  CandidateRampActionDraftNotifier,
  CandidateRampActionDraft
>((ref) {
  return CandidateRampActionDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateRampActionDraftNotifier
    extends StateNotifier<CandidateRampActionDraft> {
  CandidateRampActionDraftNotifier(DateTime asOfDate)
    : super(CandidateRampActionDraft.empty(asOfDate));

  void initializeFromPlan(CandidateRampPlan plan) {
    state = CandidateRampActionDraft.fromPlan(
      plan: plan,
      asOfDate: state.asOfDate,
    );
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setLearningPlanTitle(String value) {
    state = state.copyWith(learningPlanTitle: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setKickoffDate(DateTime value) {
    state = state.copyWith(kickoffDate: value);
  }

  void setReadinessDate(DateTime value) {
    state = state.copyWith(readinessDate: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void clear() {
    state = CandidateRampActionDraft.empty(state.asOfDate);
  }
}

final candidateRampActionsProvider = StateNotifierProvider<
  CandidateRampActionsNotifier,
  List<CandidateRampAction>
>((ref) {
  return CandidateRampActionsNotifier();
});

class CandidateRampActionsNotifier
    extends StateNotifier<List<CandidateRampAction>> {
  CandidateRampActionsNotifier() : super(const []);

  CandidateRampAction submitDraft(CandidateRampActionDraft draft) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void activate(String id) {
    state =
        state.map((action) {
          if (action.id != id) return action;
          return CandidateRampAction(
            id: action.id,
            candidateId: action.candidateId,
            candidateName: action.candidateName,
            role: action.role,
            department: action.department,
            mentorName: action.mentorName,
            learningPlanTitle: action.learningPlanTitle,
            ownerName: action.ownerName,
            kickoffDate: action.kickoffDate,
            readinessDate: action.readinessDate,
            notes: action.notes,
            status: CandidateRampActionStatus.active,
            createdAt: action.createdAt,
          );
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'ramp-action-${sequence.toString().padLeft(3, '0')}';
  }
}

final candidateRampActionSummaryProvider = Provider<CandidateRampActionSummary>(
  (ref) {
    return CandidateRampActionSummary.fromActions(
      ref.watch(candidateRampActionsProvider),
    );
  },
);
