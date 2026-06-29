import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_match_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityLaunchChecklistDraftProvider =
    StateNotifierProvider<
      IncomingTalentMobilityLaunchChecklistDraftNotifier,
      IncomingTalentMobilityLaunchChecklistDraft
    >((ref) {
      return IncomingTalentMobilityLaunchChecklistDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentMobilityLaunchChecklistDraftNotifier
    extends StateNotifier<IncomingTalentMobilityLaunchChecklistDraft> {
  IncomingTalentMobilityLaunchChecklistDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentMobilityLaunchChecklistDraft.empty(asOfDate));

  void initializeFromMatch(IncomingTalentMobilityMatch match) {
    state = IncomingTalentMobilityLaunchChecklistDraft.fromMatch(
      match: match,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setStatus(IncomingTalentMobilityLaunchStatus value) {
    state = state.copyWith(status: value);
  }

  void setLaunchDate(DateTime value) {
    state = state.copyWith(
      launchDate: value,
      firstReviewDate: value.add(const Duration(days: 45)),
    );
  }

  void setFirstReviewDate(DateTime value) {
    state = state.copyWith(firstReviewDate: value);
  }

  void setSponsorSignedOff(bool value) {
    state = state.copyWith(sponsorSignedOff: value);
  }

  void setHostManagerReady(bool value) {
    state = state.copyWith(hostManagerReady: value);
  }

  void setAccessReady(bool value) {
    state = state.copyWith(accessReady: value);
  }

  void setCommunicationReady(bool value) {
    state = state.copyWith(communicationReady: value);
  }

  void setBackfillReady(bool value) {
    state = state.copyWith(backfillReady: value);
  }

  void setFirstReviewScheduled(bool value) {
    state = state.copyWith(firstReviewScheduled: value);
  }

  void setRiskNote(String value) {
    state = state.copyWith(riskNote: value);
  }

  void setLaunchNotes(String value) {
    state = state.copyWith(launchNotes: value);
  }

  void clear() {
    state = IncomingTalentMobilityLaunchChecklistDraft.empty(state.asOfDate);
  }
}

final incomingTalentMobilityLaunchChecklistsProvider = StateNotifierProvider<
  IncomingTalentMobilityLaunchChecklistsNotifier,
  List<IncomingTalentMobilityLaunchChecklist>
>((ref) {
  return IncomingTalentMobilityLaunchChecklistsNotifier();
});

class IncomingTalentMobilityLaunchChecklistsNotifier
    extends StateNotifier<List<IncomingTalentMobilityLaunchChecklist>> {
  IncomingTalentMobilityLaunchChecklistsNotifier() : super(const []);

  IncomingTalentMobilityLaunchChecklist submitDraft(
    IncomingTalentMobilityLaunchChecklistDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((checklist) => checklist.matchId == draft.matchId)) {
      throw StateError('Launch checklist already exists for mobility match');
    }

    final checklist = draft.toChecklist(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [checklist, ...state];
    return checklist;
  }

  void markReady(String id) {
    _setStatus(id, IncomingTalentMobilityLaunchStatus.ready);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentMobilityLaunchStatus.blocked);
  }

  void launch(String id) {
    _setStatus(id, IncomingTalentMobilityLaunchStatus.launched);
  }

  void _setStatus(String id, IncomingTalentMobilityLaunchStatus status) {
    state =
        state.map((checklist) {
          if (checklist.id != id) return checklist;
          return checklist.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-launch-${sequence.toString().padLeft(3, '0')}';
  }
}

final launchReadyIncomingTalentMobilityMatchesProvider =
    Provider<List<IncomingTalentMobilityMatch>>((ref) {
      final checklistedIds =
          ref
              .watch(incomingTalentMobilityLaunchChecklistsProvider)
              .map((checklist) => checklist.matchId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentMobilityMatchesProvider)
          .where(
            (match) =>
                _isLaunchReadyMatch(match.status) &&
                !checklistedIds.contains(match.id),
          )
          .toList();
    });

final filteredIncomingTalentMobilityLaunchChecklistsProvider =
    Provider<List<IncomingTalentMobilityLaunchChecklist>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityLaunchChecklistsProvider)
          .where(
            (checklist) =>
                (selectedDepartment == talentAllDepartments ||
                    checklist.department == selectedDepartment ||
                    checklist.hostDepartment == selectedDepartment) &&
                (!attentionOnly || checklist.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityLaunchChecklistSummaryProvider =
    Provider<IncomingTalentMobilityLaunchChecklistSummary>((ref) {
      return IncomingTalentMobilityLaunchChecklistSummary.fromChecklists(
        checklists: ref.watch(
          filteredIncomingTalentMobilityLaunchChecklistsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

bool _isLaunchReadyMatch(IncomingTalentMobilityMatchStatus status) {
  return status == IncomingTalentMobilityMatchStatus.accepted ||
      status == IncomingTalentMobilityMatchStatus.activated;
}
