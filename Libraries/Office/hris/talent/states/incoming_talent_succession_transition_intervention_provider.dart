import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_transition_pulse_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionTransitionInterventionDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionTransitionInterventionDraftNotifier,
      IncomingTalentSuccessionTransitionInterventionDraft
    >((ref) {
      return IncomingTalentSuccessionTransitionInterventionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionTransitionInterventionDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionTransitionInterventionDraft> {
  IncomingTalentSuccessionTransitionInterventionDraftNotifier(DateTime asOfDate)
    : super(
        IncomingTalentSuccessionTransitionInterventionDraft.empty(asOfDate),
      );

  void initializeFromPulse(IncomingTalentSuccessionTransitionPulse pulse) {
    state = IncomingTalentSuccessionTransitionInterventionDraft.fromPulse(
      pulse: pulse,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setInterventionType(
    IncomingTalentSuccessionTransitionInterventionType value,
  ) {
    state = state.copyWith(interventionType: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setInterventionPlan(String value) {
    state = state.copyWith(interventionPlan: value);
  }

  void setSponsorSupport(String value) {
    state = state.copyWith(sponsorSupport: value);
  }

  void setSuccessMetric(String value) {
    state = state.copyWith(successMetric: value);
  }

  void clear() {
    state = IncomingTalentSuccessionTransitionInterventionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionTransitionInterventionsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionTransitionInterventionsNotifier,
      List<IncomingTalentSuccessionTransitionIntervention>
    >((ref) {
      return IncomingTalentSuccessionTransitionInterventionsNotifier();
    });

class IncomingTalentSuccessionTransitionInterventionsNotifier
    extends
        StateNotifier<List<IncomingTalentSuccessionTransitionIntervention>> {
  IncomingTalentSuccessionTransitionInterventionsNotifier() : super(const []);

  IncomingTalentSuccessionTransitionIntervention submitDraft(
    IncomingTalentSuccessionTransitionInterventionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (intervention) =>
          intervention.pulseId == draft.pulseId && intervention.isOpen,
    )) {
      throw StateError('Open intervention already exists for this pulse');
    }

    final intervention = draft.toIntervention(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [intervention, ...state];
    return intervention;
  }

  void start(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionTransitionInterventionStatus.inProgress,
    );
  }

  void complete(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionTransitionInterventionStatus.completed,
    );
  }

  void block(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionTransitionInterventionStatus.blocked,
    );
  }

  void _setStatus(
    String id,
    IncomingTalentSuccessionTransitionInterventionStatus status,
  ) {
    state =
        state.map((intervention) {
          if (intervention.id != id) return intervention;
          return intervention.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-transition-intervention-${sequence.toString().padLeft(3, '0')}';
  }
}

final interventionReadySuccessionTransitionPulsesProvider =
    Provider<List<IncomingTalentSuccessionTransitionPulse>>((ref) {
      final openInterventionPulseIds =
          ref
              .watch(incomingTalentSuccessionTransitionInterventionsProvider)
              .where((intervention) => intervention.isOpen)
              .map((intervention) => intervention.pulseId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionTransitionPulsesProvider)
          .where(
            (pulse) =>
                pulse.needsAttention &&
                !openInterventionPulseIds.contains(pulse.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionTransitionInterventionsProvider =
    Provider<List<IncomingTalentSuccessionTransitionIntervention>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionTransitionInterventionsProvider)
          .where(
            (intervention) =>
                (selectedDepartment == talentAllDepartments ||
                    intervention.department == selectedDepartment) &&
                (!attentionOnly || intervention.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionTransitionInterventionSummaryProvider = Provider<
  IncomingTalentSuccessionTransitionInterventionSummary
>((ref) {
  return IncomingTalentSuccessionTransitionInterventionSummary.fromInterventions(
    interventions: ref.watch(
      filteredIncomingTalentSuccessionTransitionInterventionsProvider,
    ),
    asOfDate: ref.watch(talentAsOfDateProvider),
  );
});
