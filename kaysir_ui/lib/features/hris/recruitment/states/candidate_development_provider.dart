import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_development_models.dart';
import 'recruitment_provider.dart';

final candidateDevelopmentObjectiveDraftProvider = StateNotifierProvider<
  CandidateDevelopmentObjectiveDraftNotifier,
  CandidateDevelopmentObjectiveDraft
>((ref) {
  return CandidateDevelopmentObjectiveDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateDevelopmentObjectiveDraftNotifier
    extends StateNotifier<CandidateDevelopmentObjectiveDraft> {
  CandidateDevelopmentObjectiveDraftNotifier(DateTime asOfDate)
    : super(CandidateDevelopmentObjectiveDraft.empty(asOfDate));

  void initializeFromPacket(CandidateDecisionPacket packet) {
    state = CandidateDevelopmentObjectiveDraft.fromPacket(
      packet: packet,
      asOfDate: state.asOfDate,
    );
  }

  void setObjectiveTitle(String value) {
    state = state.copyWith(objectiveTitle: value);
  }

  void setSkillFocus(String value) {
    state = state.copyWith(skillFocus: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setSuccessMeasure(String value) {
    state = state.copyWith(successMeasure: value);
  }

  void setStartDate(DateTime value) {
    state = state.copyWith(startDate: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void clear() {
    state = CandidateDevelopmentObjectiveDraft.empty(state.asOfDate);
  }
}

final candidateDevelopmentObjectivesProvider = StateNotifierProvider<
  CandidateDevelopmentObjectivesNotifier,
  List<CandidateDevelopmentObjective>
>((ref) {
  return CandidateDevelopmentObjectivesNotifier();
});

class CandidateDevelopmentObjectivesNotifier
    extends StateNotifier<List<CandidateDevelopmentObjective>> {
  CandidateDevelopmentObjectivesNotifier() : super(const []);

  CandidateDevelopmentObjective submitDraft(
    CandidateDevelopmentObjectiveDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final objective = draft.toObjective(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [objective, ...state];
    return objective;
  }

  void activate(String id) {
    _setStatus(id, CandidateDevelopmentObjectiveStatus.active);
  }

  void complete(String id) {
    _setStatus(id, CandidateDevelopmentObjectiveStatus.completed);
  }

  void _setStatus(String id, CandidateDevelopmentObjectiveStatus status) {
    state =
        state.map((objective) {
          if (objective.id != id) return objective;
          return objective.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'development-objective-${sequence.toString().padLeft(3, '0')}';
  }
}

final candidateDevelopmentObjectiveSummaryProvider =
    Provider<CandidateDevelopmentObjectiveSummary>((ref) {
      return CandidateDevelopmentObjectiveSummary.fromObjectives(
        objectives: ref.watch(candidateDevelopmentObjectivesProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });
