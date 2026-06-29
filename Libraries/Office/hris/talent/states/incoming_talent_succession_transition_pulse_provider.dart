import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_activation_closure_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionTransitionPulseDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionTransitionPulseDraftNotifier,
      IncomingTalentSuccessionTransitionPulseDraft
    >((ref) {
      return IncomingTalentSuccessionTransitionPulseDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionTransitionPulseDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionTransitionPulseDraft> {
  IncomingTalentSuccessionTransitionPulseDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionTransitionPulseDraft.empty(asOfDate));

  void initializeFromClosure(
    IncomingTalentSuccessionActivationClosure closure, {
    IncomingTalentSuccessionTransitionPulseWindow pulseWindow =
        IncomingTalentSuccessionTransitionPulseWindow.thirtyDay,
  }) {
    state = IncomingTalentSuccessionTransitionPulseDraft.fromClosure(
      closure: closure,
      asOfDate: state.asOfDate,
      pulseWindow: pulseWindow,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setPulseWindow(IncomingTalentSuccessionTransitionPulseWindow value) {
    state = state.copyWith(pulseWindow: value);
  }

  void setPulseDate(DateTime value) {
    state = state.copyWith(pulseDate: value);
  }

  void setHealth(IncomingTalentSuccessionTransitionPulseHealth value) {
    state = state.copyWith(health: value);
  }

  void setAdoptionScore(int value) {
    state = state.copyWith(adoptionScore: value);
  }

  void setManagerConfidenceScore(int value) {
    state = state.copyWith(managerConfidenceScore: value);
  }

  void setRetentionRisk(IncomingTalentSuccessionTransitionRetentionRisk value) {
    state = state.copyWith(retentionRisk: value);
  }

  void setOutcomeEvidence(String value) {
    state = state.copyWith(outcomeEvidence: value);
  }

  void setEmployeeSignal(String value) {
    state = state.copyWith(employeeSignal: value);
  }

  void setManagerSignal(String value) {
    state = state.copyWith(managerSignal: value);
  }

  void setStakeholderSentiment(String value) {
    state = state.copyWith(stakeholderSentiment: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setNextPulseDate(DateTime value) {
    state = state.copyWith(nextPulseDate: value);
  }

  void clear() {
    state = IncomingTalentSuccessionTransitionPulseDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionTransitionPulsesProvider = StateNotifierProvider<
  IncomingTalentSuccessionTransitionPulsesNotifier,
  List<IncomingTalentSuccessionTransitionPulse>
>((ref) {
  return IncomingTalentSuccessionTransitionPulsesNotifier();
});

class IncomingTalentSuccessionTransitionPulsesNotifier
    extends StateNotifier<List<IncomingTalentSuccessionTransitionPulse>> {
  IncomingTalentSuccessionTransitionPulsesNotifier() : super(const []);

  IncomingTalentSuccessionTransitionPulse submitDraft(
    IncomingTalentSuccessionTransitionPulseDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (pulse) =>
          pulse.closureId == draft.closureId &&
          pulse.pulseWindow == draft.pulseWindow,
    )) {
      throw StateError('Transition pulse already exists for this window');
    }

    final pulse = draft.toPulse(id: _nextId(), createdAt: draft.asOfDate);
    state = [pulse, ...state];
    return pulse;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-transition-pulse-${sequence.toString().padLeft(3, '0')}';
  }
}

final pulseReadySuccessionActivationClosuresProvider =
    Provider<List<IncomingTalentSuccessionActivationClosure>>((ref) {
      final submittedWindowsByClosure =
          <String, Set<IncomingTalentSuccessionTransitionPulseWindow>>{};
      for (final pulse in ref.watch(
        incomingTalentSuccessionTransitionPulsesProvider,
      )) {
        submittedWindowsByClosure
            .putIfAbsent(
              pulse.closureId,
              () => <IncomingTalentSuccessionTransitionPulseWindow>{},
            )
            .add(pulse.pulseWindow);
      }

      return ref
          .watch(filteredIncomingTalentSuccessionActivationClosuresProvider)
          .where(
            (closure) =>
                closure.status ==
                    IncomingTalentSuccessionActivationClosureStatus.completed &&
                (submittedWindowsByClosure[closure.id]?.length ?? 0) <
                    IncomingTalentSuccessionTransitionPulseWindow.values.length,
          )
          .toList();
    });

final filteredIncomingTalentSuccessionTransitionPulsesProvider =
    Provider<List<IncomingTalentSuccessionTransitionPulse>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionTransitionPulsesProvider)
          .where(
            (pulse) =>
                (selectedDepartment == talentAllDepartments ||
                    pulse.department == selectedDepartment) &&
                (!attentionOnly || pulse.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionTransitionPulseSummaryProvider =
    Provider<IncomingTalentSuccessionTransitionPulseSummary>((ref) {
      return IncomingTalentSuccessionTransitionPulseSummary.fromPulses(
        ref.watch(filteredIncomingTalentSuccessionTransitionPulsesProvider),
      );
    });
