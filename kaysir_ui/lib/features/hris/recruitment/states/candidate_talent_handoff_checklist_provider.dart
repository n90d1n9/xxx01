import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_talent_handoff_checklist_models.dart';
import '../models/candidate_talent_handoff_models.dart';
import 'candidate_talent_handoff_provider.dart';
import 'recruitment_provider.dart';

final candidateTalentHandoffChecklistDraftProvider = StateNotifierProvider<
  CandidateTalentHandoffChecklistDraftNotifier,
  CandidateTalentHandoffChecklistDraft
>((ref) {
  return CandidateTalentHandoffChecklistDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateTalentHandoffChecklistDraftNotifier
    extends StateNotifier<CandidateTalentHandoffChecklistDraft> {
  CandidateTalentHandoffChecklistDraftNotifier(DateTime asOfDate)
    : super(CandidateTalentHandoffChecklistDraft.empty(asOfDate));

  void initializeFromHandoff(CandidateTalentHandoff handoff) {
    state = CandidateTalentHandoffChecklistDraft.fromHandoff(
      handoff: handoff,
      asOfDate: state.asOfDate,
    );
  }

  void setCategory(CandidateTalentHandoffChecklistCategory value) {
    state = state.copyWith(category: value);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setDetail(String value) {
    state = state.copyWith(detail: value);
  }

  void setRequiredBeforeStart(bool value) {
    state = state.copyWith(requiredBeforeStart: value);
  }

  void clear() {
    state = CandidateTalentHandoffChecklistDraft.empty(state.asOfDate);
  }
}

final candidateTalentHandoffChecklistItemsProvider = StateNotifierProvider<
  CandidateTalentHandoffChecklistItemsNotifier,
  List<CandidateTalentHandoffChecklistItem>
>((ref) {
  return CandidateTalentHandoffChecklistItemsNotifier();
});

class CandidateTalentHandoffChecklistItemsNotifier
    extends StateNotifier<List<CandidateTalentHandoffChecklistItem>> {
  CandidateTalentHandoffChecklistItemsNotifier() : super(const []);

  CandidateTalentHandoffChecklistItem submitDraft(
    CandidateTalentHandoffChecklistDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final item = draft.toItem(id: _nextId(), createdAt: draft.asOfDate);
    state = [item, ...state];
    return item;
  }

  List<CandidateTalentHandoffChecklistItem> generateForHandoff({
    required CandidateTalentHandoff handoff,
    required DateTime asOfDate,
  }) {
    final template = CandidateTalentHandoffChecklistTemplate.forHandoff(
      handoff,
    );
    final existingKeys =
        state
            .where((item) => item.handoffId == handoff.id)
            .map(_checklistKey)
            .toSet();
    final generated = <CandidateTalentHandoffChecklistItem>[];

    for (final task in template.tasks) {
      final key = _templateTaskKey(task);
      if (existingKeys.contains(key)) continue;

      generated.add(
        task.toItem(
          id: _idForSequence(state.length + generated.length + 1),
          handoff: handoff,
          asOfDate: asOfDate,
          createdAt: asOfDate,
        ),
      );
      existingKeys.add(key);
    }

    if (generated.isNotEmpty) {
      state = [...generated, ...state];
    }
    return generated;
  }

  void start(String id) {
    _setStatus(id, CandidateTalentHandoffChecklistStatus.inProgress);
  }

  void complete(String id) {
    _setStatus(id, CandidateTalentHandoffChecklistStatus.completed);
  }

  void block(String id) {
    _setStatus(id, CandidateTalentHandoffChecklistStatus.blocked);
  }

  void _setStatus(String id, CandidateTalentHandoffChecklistStatus status) {
    state =
        state.map((item) {
          if (item.id != id) return item;
          return item.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return _idForSequence(sequence);
  }
}

String _idForSequence(int sequence) {
  return 'handoff-checklist-${sequence.toString().padLeft(3, '0')}';
}

String _checklistKey(CandidateTalentHandoffChecklistItem item) {
  return '${item.category.name}:${_normalize(item.title)}';
}

String _templateTaskKey(CandidateTalentHandoffChecklistTemplateTask task) {
  return '${task.category.name}:${_normalize(task.title)}';
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}

final candidateTalentHandoffChecklistSummaryProvider =
    Provider<CandidateTalentHandoffChecklistSummary>((ref) {
      return CandidateTalentHandoffChecklistSummary.fromItems(
        items: ref.watch(candidateTalentHandoffChecklistItemsProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });

final candidateTalentHandoffChecklistCoverageProvider =
    Provider<List<CandidateTalentHandoffChecklistCoverage>>((ref) {
      final items = ref.watch(candidateTalentHandoffChecklistItemsProvider);
      return ref
          .watch(candidateTalentHandoffsProvider)
          .map(
            (handoff) => CandidateTalentHandoffChecklistCoverage.fromHandoff(
              handoff: handoff,
              items: items,
            ),
          )
          .toList();
    });
