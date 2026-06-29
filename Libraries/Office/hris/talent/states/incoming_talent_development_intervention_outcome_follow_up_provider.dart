import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import '../models/incoming_talent_development_intervention_outcome_models.dart';
import 'incoming_talent_development_intervention_outcome_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentInterventionOutcomeFollowUpDraftNotifier,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft
    >((ref) {
      return IncomingTalentDevelopmentInterventionOutcomeFollowUpDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentDevelopmentInterventionOutcomeFollowUpDraftNotifier
    extends
        StateNotifier<
          IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft
        > {
  IncomingTalentDevelopmentInterventionOutcomeFollowUpDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.empty(
          asOfDate,
        ),
      );

  void initializeFromOutcome(
    IncomingTalentDevelopmentInterventionOutcome outcome,
  ) {
    state =
        IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.fromOutcome(
          outcome: outcome,
          asOfDate: state.asOfDate,
        );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setStatus(
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus value,
  ) {
    state = state.copyWith(status: value);
  }

  void setAction(String value) {
    state = state.copyWith(action: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentInterventionOutcomeFollowUpsNotifier,
      List<IncomingTalentDevelopmentInterventionOutcomeFollowUp>
    >((ref) {
      return IncomingTalentDevelopmentInterventionOutcomeFollowUpsNotifier();
    });

class IncomingTalentDevelopmentInterventionOutcomeFollowUpsNotifier
    extends
        StateNotifier<
          List<IncomingTalentDevelopmentInterventionOutcomeFollowUp>
        > {
  IncomingTalentDevelopmentInterventionOutcomeFollowUpsNotifier()
    : super(const []);

  IncomingTalentDevelopmentInterventionOutcomeFollowUp submitDraft(
    IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((item) => item.outcomeId == draft.outcomeId)) {
      throw StateError(
        'Follow-up already exists for this intervention outcome',
      );
    }

    final followUp = draft.toFollowUp(id: _nextId(), createdAt: draft.asOfDate);
    state = [followUp, ...state];
    return followUp;
  }

  void start(String id) {
    _replace(id, (item) {
      if (item.isClosed) {
        throw StateError('Closed follow-up cannot be started');
      }
      return item.copyWith(
        status:
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .inProgress,
      );
    });
  }

  void complete(String id, {required String resolutionNote}) {
    final note = _validatedResolutionNote(resolutionNote);
    _replace(id, (item) {
      if (item.status ==
          IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
              .escalated) {
        throw StateError('Escalated follow-up cannot be completed');
      }
      return item.copyWith(
        status:
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .completed,
        resolutionNote: note,
        completedAt: DateTime.now(),
      );
    });
  }

  void escalate(String id, {required String resolutionNote}) {
    final note = _validatedResolutionNote(resolutionNote);
    _replace(id, (item) {
      if (item.status ==
          IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
              .completed) {
        throw StateError('Completed follow-up cannot be escalated');
      }
      return item.copyWith(
        status:
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .escalated,
        resolutionNote: note,
        completedAt: DateTime.now(),
      );
    });
  }

  void _replace(
    String id,
    IncomingTalentDevelopmentInterventionOutcomeFollowUp Function(
      IncomingTalentDevelopmentInterventionOutcomeFollowUp item,
    )
    replace,
  ) {
    var found = false;
    state =
        state.map((item) {
          if (item.id != id) return item;
          found = true;
          return replace(item);
        }).toList();
    if (!found) throw StateError('Intervention outcome follow-up not found');
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-intervention-outcome-follow-up-${sequence.toString().padLeft(3, '0')}';
  }
}

final followUpReadyDevelopmentInterventionOutcomesProvider =
    Provider<List<IncomingTalentDevelopmentInterventionOutcome>>((ref) {
      final existingOutcomeIds =
          ref
              .watch(
                incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider,
              )
              .map((item) => item.outcomeId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentDevelopmentInterventionOutcomesProvider)
          .where(
            (outcome) =>
                _outcomeNeedsFollowUp(outcome) &&
                !existingOutcomeIds.contains(outcome.id),
          )
          .toList();
    });

final filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpsProvider =
    Provider<List<IncomingTalentDevelopmentInterventionOutcomeFollowUp>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);
      final asOfDate = ref.watch(talentAsOfDateProvider);

      return ref
          .watch(incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider)
          .where(
            (item) =>
                (selectedDepartment == talentAllDepartments ||
                    item.department == selectedDepartment) &&
                (!attentionOnly || item.needsAttention(asOfDate)),
          )
          .toList();
    });

final incomingTalentDevelopmentInterventionOutcomeFollowUpSummaryProvider =
    Provider<IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary>((
      ref,
    ) {
      return IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary.fromItems(
        items: ref.watch(
          filteredIncomingTalentDevelopmentInterventionOutcomeFollowUpsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

bool _outcomeNeedsFollowUp(
  IncomingTalentDevelopmentInterventionOutcome outcome,
) {
  return outcome.needsAttention ||
      outcome.decision ==
          IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized;
}

String _validatedResolutionNote(String value) {
  final note = value.trim();
  if (note.length < 8) {
    throw StateError('Add a short follow-up resolution note');
  }
  return note;
}
