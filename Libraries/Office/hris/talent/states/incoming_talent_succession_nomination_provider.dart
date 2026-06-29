import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionNominationDraftProvider = StateNotifierProvider<
  IncomingTalentSuccessionNominationDraftNotifier,
  IncomingTalentSuccessionNominationDraft
>((ref) {
  return IncomingTalentSuccessionNominationDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentSuccessionNominationDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionNominationDraft> {
  IncomingTalentSuccessionNominationDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionNominationDraft.empty(asOfDate));

  void initializeFromCandidate(IncomingTalentSuccessionCandidate candidate) {
    state = IncomingTalentSuccessionNominationDraft.fromCandidate(
      candidate: candidate,
      asOfDate: state.asOfDate,
    );
  }

  void setSponsorName(String value) {
    state = state.copyWith(sponsorName: value);
  }

  void setPanelName(String value) {
    state = state.copyWith(panelName: value);
  }

  void setNominationType(IncomingTalentSuccessionNominationType value) {
    state = state.copyWith(nominationType: value);
  }

  void setStatus(IncomingTalentSuccessionNominationStatus value) {
    state = state.copyWith(status: value);
  }

  void setNominationDate(DateTime value) {
    state = state.copyWith(nominationDate: value);
  }

  void setPanelDate(DateTime value) {
    state = state.copyWith(panelDate: value);
  }

  void setBusinessCase(String value) {
    state = state.copyWith(businessCase: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setSuccessPlan(String value) {
    state = state.copyWith(successPlan: value);
  }

  void clear() {
    state = IncomingTalentSuccessionNominationDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionNominationsProvider = StateNotifierProvider<
  IncomingTalentSuccessionNominationsNotifier,
  List<IncomingTalentSuccessionNomination>
>((ref) {
  return IncomingTalentSuccessionNominationsNotifier();
});

class IncomingTalentSuccessionNominationsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionNomination>> {
  IncomingTalentSuccessionNominationsNotifier() : super(const []);

  IncomingTalentSuccessionNomination submitDraft(
    IncomingTalentSuccessionNominationDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((item) => item.candidateId == draft.candidateId)) {
      throw StateError('Succession nomination already exists for candidate');
    }

    final nomination = draft.toNomination(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [nomination, ...state];
    return nomination;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-nomination-${sequence.toString().padLeft(3, '0')}';
  }
}

final nominationReadySuccessionCandidatesProvider =
    Provider<List<IncomingTalentSuccessionCandidate>>((ref) {
      final nominatedCandidateIds =
          ref
              .watch(incomingTalentSuccessionNominationsProvider)
              .map((nomination) => nomination.candidateId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionCandidatesProvider)
          .where(
            (candidate) =>
                candidate.isSuccessionReady &&
                !nominatedCandidateIds.contains(candidate.candidateId),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionNominationsProvider =
    Provider<List<IncomingTalentSuccessionNomination>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionNominationsProvider)
          .where(
            (nomination) =>
                (selectedDepartment == talentAllDepartments ||
                    nomination.department == selectedDepartment) &&
                (!attentionOnly || nomination.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionNominationSummaryProvider =
    Provider<IncomingTalentSuccessionNominationSummary>((ref) {
      return IncomingTalentSuccessionNominationSummary.fromNominations(
        ref.watch(filteredIncomingTalentSuccessionNominationsProvider),
      );
    });
