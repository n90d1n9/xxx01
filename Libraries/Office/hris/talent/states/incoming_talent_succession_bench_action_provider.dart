import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_bench_check_in_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionBenchActionDraftProvider = StateNotifierProvider<
  IncomingTalentSuccessionBenchActionDraftNotifier,
  IncomingTalentSuccessionBenchActionDraft
>((ref) {
  return IncomingTalentSuccessionBenchActionDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentSuccessionBenchActionDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionBenchActionDraft> {
  IncomingTalentSuccessionBenchActionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionBenchActionDraft.empty(asOfDate));

  void initializeFromCheckIn(IncomingTalentSuccessionBenchCheckIn checkIn) {
    state = IncomingTalentSuccessionBenchActionDraft.fromCheckIn(
      checkIn: checkIn,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setActionType(IncomingTalentSuccessionBenchActionType value) {
    state = state.copyWith(actionType: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setActionPlan(String value) {
    state = state.copyWith(actionPlan: value);
  }

  void setEscalationPath(String value) {
    state = state.copyWith(escalationPath: value);
  }

  void setResolutionEvidence(String value) {
    state = state.copyWith(resolutionEvidence: value);
  }

  void clear() {
    state = IncomingTalentSuccessionBenchActionDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionBenchActionsProvider = StateNotifierProvider<
  IncomingTalentSuccessionBenchActionsNotifier,
  List<IncomingTalentSuccessionBenchAction>
>((ref) {
  return IncomingTalentSuccessionBenchActionsNotifier();
});

class IncomingTalentSuccessionBenchActionsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionBenchAction>> {
  IncomingTalentSuccessionBenchActionsNotifier() : super(const []);

  IncomingTalentSuccessionBenchAction submitDraft(
    IncomingTalentSuccessionBenchActionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (action) => action.checkInId == draft.checkInId && action.isOpen,
    )) {
      throw StateError('Open bench action already exists for this check-in');
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentSuccessionBenchActionStatus.inProgress);
  }

  void resolve(String id) {
    _setStatus(id, IncomingTalentSuccessionBenchActionStatus.resolved);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentSuccessionBenchActionStatus.blocked);
  }

  void _setStatus(String id, IncomingTalentSuccessionBenchActionStatus status) {
    state =
        state.map((action) {
          if (action.id != id) return action;
          return action.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-bench-action-${sequence.toString().padLeft(3, '0')}';
  }
}

final actionReadySuccessionBenchCheckInsProvider =
    Provider<List<IncomingTalentSuccessionBenchCheckIn>>((ref) {
      final openActionCheckInIds =
          ref
              .watch(incomingTalentSuccessionBenchActionsProvider)
              .where((action) => action.isOpen)
              .map((action) => action.checkInId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionBenchCheckInsProvider)
          .where(
            (checkIn) =>
                checkIn.needsAttention &&
                !openActionCheckInIds.contains(checkIn.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionBenchActionsProvider =
    Provider<List<IncomingTalentSuccessionBenchAction>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionBenchActionsProvider)
          .where(
            (action) =>
                (selectedDepartment == talentAllDepartments ||
                    action.department == selectedDepartment) &&
                (!attentionOnly || action.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionBenchActionSummaryProvider =
    Provider<IncomingTalentSuccessionBenchActionSummary>((ref) {
      return IncomingTalentSuccessionBenchActionSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentSuccessionBenchActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
