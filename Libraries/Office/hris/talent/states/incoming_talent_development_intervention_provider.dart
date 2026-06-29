import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_activation_follow_up_models.dart';
import '../models/incoming_talent_development_check_in_models.dart';
import '../models/incoming_talent_development_intervention_models.dart';
import 'incoming_talent_activation_follow_up_provider.dart';
import 'incoming_talent_development_check_in_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentInterventionDraftProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentInterventionDraftNotifier,
      IncomingTalentDevelopmentInterventionDraft
    >((ref) {
      return IncomingTalentDevelopmentInterventionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentDevelopmentInterventionDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentInterventionDraft> {
  IncomingTalentDevelopmentInterventionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentInterventionDraft.empty(asOfDate));

  void initializeFromCheckIn(IncomingTalentDevelopmentCheckIn checkIn) {
    state = IncomingTalentDevelopmentInterventionDraft.fromCheckIn(
      checkIn: checkIn,
      asOfDate: state.asOfDate,
    );
  }

  void initializeFromFollowUp(IncomingTalentActivationFollowUpAction action) {
    state = IncomingTalentDevelopmentInterventionDraft.fromFollowUp(
      action: action,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setActionType(IncomingTalentDevelopmentInterventionType value) {
    state = state.copyWith(actionType: value);
  }

  void setPriority(IncomingTalentDevelopmentInterventionPriority value) {
    state = state.copyWith(priority: value);
  }

  void setStatus(IncomingTalentDevelopmentInterventionStatus value) {
    state = state.copyWith(status: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setAction(String value) {
    state = state.copyWith(action: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void setResolutionNote(String value) {
    state = state.copyWith(resolutionNote: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentInterventionDraft.empty(state.asOfDate);
  }
}

final incomingTalentDevelopmentInterventionsProvider = StateNotifierProvider<
  IncomingTalentDevelopmentInterventionsNotifier,
  List<IncomingTalentDevelopmentInterventionAction>
>((ref) {
  return IncomingTalentDevelopmentInterventionsNotifier();
});

class IncomingTalentDevelopmentInterventionsNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentInterventionAction>> {
  IncomingTalentDevelopmentInterventionsNotifier() : super(const []);

  IncomingTalentDevelopmentInterventionAction submitDraft(
    IncomingTalentDevelopmentInterventionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (draft.checkInId.isNotEmpty &&
        state.any((action) => action.checkInId == draft.checkInId)) {
      throw StateError('Intervention already exists for this check-in');
    }
    if (draft.activationFollowUpId.isNotEmpty &&
        state.any(
          (action) => action.activationFollowUpId == draft.activationFollowUpId,
        )) {
      throw StateError(
        'Intervention already exists for this activation follow-up',
      );
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void start(String id) {
    _replaceAction(id, (action) {
      if (_isClosed(action)) {
        throw StateError('Closed intervention cannot be started');
      }
      return action.copyWith(
        status: IncomingTalentDevelopmentInterventionStatus.inProgress,
      );
    });
  }

  void resolve(String id, {required String resolutionNote}) {
    final note = _validatedLifecycleNote(resolutionNote, 'a resolution note');
    _replaceAction(id, (action) {
      if (action.status ==
          IncomingTalentDevelopmentInterventionStatus.cancelled) {
        throw StateError('Cancelled intervention cannot be resolved');
      }
      return action.copyWith(
        status: IncomingTalentDevelopmentInterventionStatus.resolved,
        resolutionNote: note,
      );
    });
  }

  void cancel(String id, {required String resolutionNote}) {
    final note = _validatedLifecycleNote(resolutionNote, 'a cancellation note');
    _replaceAction(id, (action) {
      if (action.status ==
          IncomingTalentDevelopmentInterventionStatus.resolved) {
        throw StateError('Resolved intervention cannot be cancelled');
      }
      return action.copyWith(
        status: IncomingTalentDevelopmentInterventionStatus.cancelled,
        resolutionNote: note,
      );
    });
  }

  void _replaceAction(
    String id,
    IncomingTalentDevelopmentInterventionAction Function(
      IncomingTalentDevelopmentInterventionAction action,
    )
    replace,
  ) {
    var found = false;
    state =
        state.map((action) {
          if (action.id != id) return action;
          found = true;
          return replace(action);
        }).toList();

    if (!found) {
      throw StateError('Intervention action not found');
    }
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-intervention-${sequence.toString().padLeft(3, '0')}';
  }
}

final interventionReadyDevelopmentCheckInsProvider =
    Provider<List<IncomingTalentDevelopmentCheckIn>>((ref) {
      final checkInIdsWithActions =
          ref
              .watch(incomingTalentDevelopmentInterventionsProvider)
              .map((action) => action.checkInId)
              .toSet();
      return ref
          .watch(filteredIncomingTalentDevelopmentCheckInsProvider)
          .where(
            (checkIn) =>
                checkIn.needsAttention &&
                !checkInIdsWithActions.contains(checkIn.id),
          )
          .toList();
    });

final interventionReadyActivationFollowUpsProvider =
    Provider<List<IncomingTalentActivationFollowUpAction>>((ref) {
      final followUpIdsWithActions =
          ref
              .watch(incomingTalentDevelopmentInterventionsProvider)
              .map((action) => action.activationFollowUpId)
              .where((id) => id.isNotEmpty)
              .toSet();

      return ref
          .watch(filteredIncomingTalentActivationFollowUpActionsProvider)
          .where(
            (action) =>
                _followUpNeedsDevelopmentIntervention(action) &&
                !followUpIdsWithActions.contains(action.id),
          )
          .toList();
    });

final interventionReadyDevelopmentSourcesProvider =
    Provider<List<IncomingTalentDevelopmentInterventionSourceOption>>((ref) {
      return [
        ...ref
            .watch(interventionReadyDevelopmentCheckInsProvider)
            .map(IncomingTalentDevelopmentInterventionSourceOption.fromCheckIn),
        ...ref
            .watch(interventionReadyActivationFollowUpsProvider)
            .map(
              IncomingTalentDevelopmentInterventionSourceOption.fromFollowUp,
            ),
      ];
    });

final filteredIncomingTalentDevelopmentInterventionsProvider =
    Provider<List<IncomingTalentDevelopmentInterventionAction>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentInterventionsProvider)
          .where(
            (action) =>
                (selectedDepartment == talentAllDepartments ||
                    action.department == selectedDepartment) &&
                (!attentionOnly || action.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentInterventionSummaryProvider =
    Provider<IncomingTalentDevelopmentInterventionSummary>((ref) {
      return IncomingTalentDevelopmentInterventionSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentDevelopmentInterventionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

bool _followUpNeedsDevelopmentIntervention(
  IncomingTalentActivationFollowUpAction action,
) {
  return action.programCompletionExtensionCount > 0 ||
      action.status == IncomingTalentActivationFollowUpStatus.blocked;
}

bool _isClosed(IncomingTalentDevelopmentInterventionAction action) {
  return action.status ==
          IncomingTalentDevelopmentInterventionStatus.resolved ||
      action.status == IncomingTalentDevelopmentInterventionStatus.cancelled;
}

String _validatedLifecycleNote(String value, String label) {
  final note = value.trim();
  if (note.isEmpty) {
    throw StateError('Please enter $label');
  }
  if (note.length < 12) {
    throw StateError('${_capitalize(label)} must be at least 12 characters');
  }
  return note;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}
