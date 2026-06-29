import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_cadence_check_in_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityCadenceInterventionDraftProvider =
    StateNotifierProvider<
      IncomingTalentMobilityCadenceInterventionDraftNotifier,
      IncomingTalentMobilityCadenceInterventionDraft
    >((ref) {
      return IncomingTalentMobilityCadenceInterventionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentMobilityCadenceInterventionDraftNotifier
    extends StateNotifier<IncomingTalentMobilityCadenceInterventionDraft> {
  IncomingTalentMobilityCadenceInterventionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentMobilityCadenceInterventionDraft.empty(asOfDate));

  void initializeFromCheckIn(IncomingTalentMobilityCadenceCheckIn checkIn) {
    state = IncomingTalentMobilityCadenceInterventionDraft.fromCheckIn(
      checkIn: checkIn,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setInterventionType(
    IncomingTalentMobilityCadenceInterventionType value,
  ) {
    state = state.copyWith(interventionType: value);
  }

  void setPriority(IncomingTalentMobilityCadenceInterventionPriority value) {
    state = state.copyWith(
      priority: value,
      dueDate: defaultIncomingTalentMobilityCadenceInterventionDueDate(
        priority: value,
        asOfDate: state.asOfDate,
      ),
    );
  }

  void setStatus(IncomingTalentMobilityCadenceInterventionStatus value) {
    state = state.copyWith(status: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setInterventionSummary(String value) {
    state = state.copyWith(interventionSummary: value);
  }

  void setSuccessMeasure(String value) {
    state = state.copyWith(successMeasure: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void clear() {
    state = IncomingTalentMobilityCadenceInterventionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentMobilityCadenceInterventionsProvider =
    StateNotifierProvider<
      IncomingTalentMobilityCadenceInterventionsNotifier,
      List<IncomingTalentMobilityCadenceIntervention>
    >((ref) {
      return IncomingTalentMobilityCadenceInterventionsNotifier();
    });

class IncomingTalentMobilityCadenceInterventionsNotifier
    extends StateNotifier<List<IncomingTalentMobilityCadenceIntervention>> {
  IncomingTalentMobilityCadenceInterventionsNotifier() : super(const []);

  IncomingTalentMobilityCadenceIntervention submitDraft(
    IncomingTalentMobilityCadenceInterventionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((item) => item.checkInId == draft.checkInId)) {
      throw StateError('Intervention already exists for cadence check-in');
    }

    final intervention = draft.toIntervention(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [intervention, ...state];
    return intervention;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentMobilityCadenceInterventionStatus.inProgress);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentMobilityCadenceInterventionStatus.blocked);
  }

  void resolve(String id) {
    _setStatus(id, IncomingTalentMobilityCadenceInterventionStatus.resolved);
  }

  void _setStatus(
    String id,
    IncomingTalentMobilityCadenceInterventionStatus status,
  ) {
    state =
        state.map((item) {
          if (item.id != id) return item;
          return item.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-cadence-intervention-${sequence.toString().padLeft(3, '0')}';
  }
}

final interventionReadyMobilityCadenceCheckInsProvider =
    Provider<List<IncomingTalentMobilityCadenceCheckIn>>((ref) {
      final interventionCheckInIds =
          ref
              .watch(incomingTalentMobilityCadenceInterventionsProvider)
              .map((item) => item.checkInId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentMobilityCadenceCheckInsProvider)
          .where(
            (checkIn) =>
                checkIn.needsAttention &&
                !interventionCheckInIds.contains(checkIn.id),
          )
          .toList();
    });

final filteredIncomingTalentMobilityCadenceInterventionsProvider =
    Provider<List<IncomingTalentMobilityCadenceIntervention>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityCadenceInterventionsProvider)
          .where(
            (item) =>
                (selectedDepartment == talentAllDepartments ||
                    item.department == selectedDepartment ||
                    item.hostDepartment == selectedDepartment) &&
                (!attentionOnly || item.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityCadenceInterventionSummaryProvider =
    Provider<IncomingTalentMobilityCadenceInterventionSummary>((ref) {
      return IncomingTalentMobilityCadenceInterventionSummary.fromInterventions(
        interventions: ref.watch(
          filteredIncomingTalentMobilityCadenceInterventionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
