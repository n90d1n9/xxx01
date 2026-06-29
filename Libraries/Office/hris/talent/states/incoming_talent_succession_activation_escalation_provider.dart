import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_activation_check_in_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionActivationEscalationDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationEscalationDraftNotifier,
      IncomingTalentSuccessionActivationEscalationDraft
    >((ref) {
      return IncomingTalentSuccessionActivationEscalationDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionActivationEscalationDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionActivationEscalationDraft> {
  IncomingTalentSuccessionActivationEscalationDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionActivationEscalationDraft.empty(asOfDate));

  void initializeFromCheckIn(
    IncomingTalentSuccessionActivationCheckIn checkIn,
  ) {
    state = IncomingTalentSuccessionActivationEscalationDraft.fromCheckIn(
      checkIn: checkIn,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setPriority(IncomingTalentSuccessionActivationEscalationPriority value) {
    state = state.copyWith(priority: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setEscalationReason(String value) {
    state = state.copyWith(escalationReason: value);
  }

  void setDecisionNeeded(String value) {
    state = state.copyWith(decisionNeeded: value);
  }

  void setSponsorCommitment(String value) {
    state = state.copyWith(sponsorCommitment: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void clear() {
    state = IncomingTalentSuccessionActivationEscalationDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionActivationEscalationsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationEscalationsNotifier,
      List<IncomingTalentSuccessionActivationEscalation>
    >((ref) {
      return IncomingTalentSuccessionActivationEscalationsNotifier();
    });

class IncomingTalentSuccessionActivationEscalationsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionActivationEscalation>> {
  IncomingTalentSuccessionActivationEscalationsNotifier() : super(const []);

  IncomingTalentSuccessionActivationEscalation submitDraft(
    IncomingTalentSuccessionActivationEscalationDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (escalation) =>
          escalation.checkInId == draft.checkInId && escalation.isOpen,
    )) {
      throw StateError('Open escalation already exists for this check-in');
    }

    final escalation = draft.toEscalation(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [escalation, ...state];
    return escalation;
  }

  void start(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionActivationEscalationStatus.inProgress,
    );
  }

  void resolve(String id) {
    _setStatus(id, IncomingTalentSuccessionActivationEscalationStatus.resolved);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentSuccessionActivationEscalationStatus.blocked);
  }

  void _setStatus(
    String id,
    IncomingTalentSuccessionActivationEscalationStatus status,
  ) {
    state =
        state.map((escalation) {
          if (escalation.id != id) return escalation;
          return escalation.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-activation-escalation-${sequence.toString().padLeft(3, '0')}';
  }
}

final escalationReadySuccessionActivationCheckInsProvider =
    Provider<List<IncomingTalentSuccessionActivationCheckIn>>((ref) {
      final openEscalatedCheckInIds =
          ref
              .watch(incomingTalentSuccessionActivationEscalationsProvider)
              .where((escalation) => escalation.isOpen)
              .map((escalation) => escalation.checkInId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionActivationCheckInsProvider)
          .where(
            (checkIn) =>
                checkIn.needsAttention &&
                !openEscalatedCheckInIds.contains(checkIn.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionActivationEscalationsProvider =
    Provider<List<IncomingTalentSuccessionActivationEscalation>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionActivationEscalationsProvider)
          .where(
            (escalation) =>
                (selectedDepartment == talentAllDepartments ||
                    escalation.department == selectedDepartment) &&
                (!attentionOnly || escalation.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionActivationEscalationSummaryProvider = Provider<
  IncomingTalentSuccessionActivationEscalationSummary
>((ref) {
  return IncomingTalentSuccessionActivationEscalationSummary.fromEscalations(
    escalations: ref.watch(
      filteredIncomingTalentSuccessionActivationEscalationsProvider,
    ),
    asOfDate: ref.watch(talentAsOfDateProvider),
  );
});
