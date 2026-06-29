import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_development_check_in_models.dart';
import '../models/candidate_development_intervention_models.dart';
import 'recruitment_provider.dart';

final candidateDevelopmentInterventionDraftProvider = StateNotifierProvider<
  CandidateDevelopmentInterventionDraftNotifier,
  CandidateDevelopmentInterventionDraft
>((ref) {
  return CandidateDevelopmentInterventionDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateDevelopmentInterventionDraftNotifier
    extends StateNotifier<CandidateDevelopmentInterventionDraft> {
  CandidateDevelopmentInterventionDraftNotifier(DateTime asOfDate)
    : super(CandidateDevelopmentInterventionDraft.empty(asOfDate));

  void initializeFromCheckIn(CandidateDevelopmentCheckIn checkIn) {
    state = CandidateDevelopmentInterventionDraft.fromCheckIn(
      checkIn: checkIn,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setType(CandidateDevelopmentInterventionType value) {
    state = state.copyWith(type: value);
  }

  void setActionNote(String value) {
    state = state.copyWith(actionNote: value);
  }

  void setEscalationRequired(bool value) {
    state = state.copyWith(escalationRequired: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void clear() {
    state = CandidateDevelopmentInterventionDraft.empty(state.asOfDate);
  }
}

final candidateDevelopmentInterventionsProvider = StateNotifierProvider<
  CandidateDevelopmentInterventionsNotifier,
  List<CandidateDevelopmentIntervention>
>((ref) {
  return CandidateDevelopmentInterventionsNotifier();
});

class CandidateDevelopmentInterventionsNotifier
    extends StateNotifier<List<CandidateDevelopmentIntervention>> {
  CandidateDevelopmentInterventionsNotifier() : super(const []);

  CandidateDevelopmentIntervention submitDraft(
    CandidateDevelopmentInterventionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final intervention = draft.toIntervention(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [intervention, ...state];
    return intervention;
  }

  void start(String id) {
    _setStatus(id, CandidateDevelopmentInterventionStatus.inProgress);
  }

  void resolve(String id) {
    _setStatus(id, CandidateDevelopmentInterventionStatus.resolved);
  }

  void _setStatus(String id, CandidateDevelopmentInterventionStatus status) {
    state =
        state.map((intervention) {
          if (intervention.id != id) return intervention;
          return intervention.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'development-intervention-${sequence.toString().padLeft(3, '0')}';
  }
}

final candidateDevelopmentInterventionSummaryProvider =
    Provider<CandidateDevelopmentInterventionSummary>((ref) {
      return CandidateDevelopmentInterventionSummary.fromInterventions(
        interventions: ref.watch(candidateDevelopmentInterventionsProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });
