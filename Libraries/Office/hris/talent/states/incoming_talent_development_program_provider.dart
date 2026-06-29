import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentProgramDraftProvider = StateNotifierProvider<
  IncomingTalentDevelopmentProgramDraftNotifier,
  IncomingTalentDevelopmentProgramDraft
>((ref) {
  return IncomingTalentDevelopmentProgramDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentDevelopmentProgramDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentProgramDraft> {
  IncomingTalentDevelopmentProgramDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentProgramDraft.empty(asOfDate));

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDepartment(String value) {
    state = state.copyWith(department: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setTrack(IncomingTalentDevelopmentProgramTrack value) {
    state = state.copyWith(track: value);
  }

  void setStatus(IncomingTalentDevelopmentProgramStatus value) {
    state = state.copyWith(status: value);
  }

  void setIntensity(IncomingTalentDevelopmentProgramIntensity value) {
    state = state.copyWith(intensity: value);
  }

  void setSkillFocus(String value) {
    state = state.copyWith(skillFocus: value);
  }

  void setExpectedOutcome(String value) {
    state = state.copyWith(expectedOutcome: value);
  }

  void setCapacity(int value) {
    state = state.copyWith(capacity: value);
  }

  void setDurationDays(int value) {
    final startDate = state.startDate;
    state = state.copyWith(
      durationDays: value,
      endDate: startDate?.add(Duration(days: value)),
    );
  }

  void setStartDate(DateTime value) {
    state = state.copyWith(
      startDate: value,
      endDate: value.add(Duration(days: state.durationDays)),
    );
  }

  void setEndDate(DateTime value) {
    state = state.copyWith(endDate: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentProgramDraft.empty(state.asOfDate);
  }
}

final incomingTalentDevelopmentProgramsProvider = StateNotifierProvider<
  IncomingTalentDevelopmentProgramsNotifier,
  List<IncomingTalentDevelopmentProgram>
>((ref) {
  return IncomingTalentDevelopmentProgramsNotifier();
});

class IncomingTalentDevelopmentProgramsNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentProgram>> {
  IncomingTalentDevelopmentProgramsNotifier() : super(const []);

  IncomingTalentDevelopmentProgram submitDraft(
    IncomingTalentDevelopmentProgramDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (program) =>
          program.title.toLowerCase() == draft.title.trim().toLowerCase() &&
          program.department == draft.department.trim(),
    )) {
      throw StateError('Development program already exists for department');
    }

    final program = draft.toProgram(id: _nextId(), createdAt: draft.asOfDate);
    state = [program, ...state];
    return program;
  }

  void updateStatus({
    required String id,
    required IncomingTalentDevelopmentProgramStatus status,
  }) {
    state = [
      for (final program in state)
        if (program.id == id) _copyWithStatus(program, status) else program,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-program-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentDevelopmentProgram _copyWithStatus(
    IncomingTalentDevelopmentProgram program,
    IncomingTalentDevelopmentProgramStatus status,
  ) {
    return IncomingTalentDevelopmentProgram(
      id: program.id,
      title: program.title,
      department: program.department,
      ownerName: program.ownerName,
      track: program.track,
      status: status,
      intensity: program.intensity,
      skillFocus: program.skillFocus,
      expectedOutcome: program.expectedOutcome,
      capacity: program.capacity,
      durationDays: program.durationDays,
      startDate: program.startDate,
      endDate: program.endDate,
      createdAt: program.createdAt,
    );
  }
}

final filteredIncomingTalentDevelopmentProgramsProvider =
    Provider<List<IncomingTalentDevelopmentProgram>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentProgramsProvider)
          .where(
            (program) =>
                (selectedDepartment == talentAllDepartments ||
                    program.department == selectedDepartment) &&
                (!attentionOnly || program.needsAttention),
          )
          .toList();
    });

final activeIncomingTalentDevelopmentProgramsProvider =
    Provider<List<IncomingTalentDevelopmentProgram>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);

      return ref
          .watch(incomingTalentDevelopmentProgramsProvider)
          .where(
            (program) =>
                program.acceptsEnrollment &&
                (selectedDepartment == talentAllDepartments ||
                    program.department == selectedDepartment),
          )
          .toList();
    });

final incomingTalentDevelopmentProgramSummaryProvider =
    Provider<IncomingTalentDevelopmentProgramSummary>((ref) {
      return IncomingTalentDevelopmentProgramSummary.fromPrograms(
        ref.watch(filteredIncomingTalentDevelopmentProgramsProvider),
      );
    });
