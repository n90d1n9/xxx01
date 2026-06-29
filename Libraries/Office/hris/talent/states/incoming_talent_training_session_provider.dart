import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../models/incoming_talent_training_session_models.dart';
import 'incoming_talent_development_program_provider.dart';
import 'talent_provider.dart';

final incomingTalentTrainingSessionDraftProvider = StateNotifierProvider<
  IncomingTalentTrainingSessionDraftNotifier,
  IncomingTalentTrainingSessionDraft
>((ref) {
  return IncomingTalentTrainingSessionDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

/// Owns the editable training-session scheduling draft.
class IncomingTalentTrainingSessionDraftNotifier
    extends StateNotifier<IncomingTalentTrainingSessionDraft> {
  IncomingTalentTrainingSessionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentTrainingSessionDraft.empty(asOfDate));

  void initializeFromProgram(IncomingTalentDevelopmentProgram program) {
    state = IncomingTalentTrainingSessionDraft.fromProgram(
      program: program,
      asOfDate: state.asOfDate,
    );
  }

  void setTrainerName(String value) {
    state = state.copyWith(trainerName: value);
  }

  void setFormat(IncomingTalentTrainingSessionFormat value) {
    state = state.copyWith(format: value);
  }

  void setStatus(IncomingTalentTrainingSessionStatus value) {
    state = state.copyWith(status: value);
  }

  void setLocation(String value) {
    state = state.copyWith(location: value);
  }

  void setPrerequisite(String value) {
    state = state.copyWith(prerequisite: value);
  }

  void setOutcomeCheckpoint(String value) {
    state = state.copyWith(outcomeCheckpoint: value);
  }

  void setCapacity(int value) {
    state = state.copyWith(capacity: value);
  }

  void setReservedSeats(int value) {
    state = state.copyWith(reservedSeats: value);
  }

  void setSessionDate(DateTime value) {
    state = state.copyWith(
      sessionDate: value,
      followUpDate: value.add(const Duration(days: 14)),
    );
  }

  void setFollowUpDate(DateTime value) {
    state = state.copyWith(followUpDate: value);
  }

  void clear() {
    state = IncomingTalentTrainingSessionDraft.empty(state.asOfDate);
  }
}

final incomingTalentTrainingSessionsProvider = StateNotifierProvider<
  IncomingTalentTrainingSessionsNotifier,
  List<IncomingTalentTrainingSession>
>((ref) {
  return IncomingTalentTrainingSessionsNotifier();
});

/// Stores scheduled training sessions and protects duplicate cohorts.
class IncomingTalentTrainingSessionsNotifier
    extends StateNotifier<List<IncomingTalentTrainingSession>> {
  IncomingTalentTrainingSessionsNotifier() : super(const []);

  IncomingTalentTrainingSession submitDraft(
    IncomingTalentTrainingSessionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (session) =>
          session.status != IncomingTalentTrainingSessionStatus.cancelled &&
          session.programId == draft.programId &&
          _isSameDate(session.sessionDate, draft.sessionDate!),
    )) {
      throw StateError('Training session already exists for this program date');
    }

    final session = draft.toSession(id: _nextId(), createdAt: draft.asOfDate);
    state = [session, ...state];
    return session;
  }

  void updateStatus({
    required String id,
    required IncomingTalentTrainingSessionStatus status,
  }) {
    state = [
      for (final session in state)
        if (session.id == id) _copyWithStatus(session, status) else session,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-training-session-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentTrainingSession _copyWithStatus(
    IncomingTalentTrainingSession session,
    IncomingTalentTrainingSessionStatus status,
  ) {
    return IncomingTalentTrainingSession(
      id: session.id,
      programId: session.programId,
      programTitle: session.programTitle,
      department: session.department,
      trainerName: session.trainerName,
      format: session.format,
      status: status,
      location: session.location,
      prerequisite: session.prerequisite,
      outcomeCheckpoint: session.outcomeCheckpoint,
      capacity: session.capacity,
      reservedSeats: session.reservedSeats,
      sessionDate: session.sessionDate,
      followUpDate: session.followUpDate,
      sourceProgramTrack: session.sourceProgramTrack,
      sourceProgramIntensity: session.sourceProgramIntensity,
      createdAt: session.createdAt,
    );
  }
}

final trainingSessionReadyDevelopmentProgramsProvider =
    Provider<List<IncomingTalentDevelopmentProgram>>((ref) {
      return ref.watch(activeIncomingTalentDevelopmentProgramsProvider);
    });

final filteredIncomingTalentTrainingSessionsProvider =
    Provider<List<IncomingTalentTrainingSession>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentTrainingSessionsProvider)
          .where(
            (session) =>
                (selectedDepartment == talentAllDepartments ||
                    session.department == selectedDepartment) &&
                (!attentionOnly || session.needsAttention),
          )
          .toList();
    });

final incomingTalentTrainingSessionSummaryProvider =
    Provider<IncomingTalentTrainingSessionSummary>((ref) {
      return IncomingTalentTrainingSessionSummary.fromSessions(
        sessions: ref.watch(filteredIncomingTalentTrainingSessionsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

bool _isSameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
