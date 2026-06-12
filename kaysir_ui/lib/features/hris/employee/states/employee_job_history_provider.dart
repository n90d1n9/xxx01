import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_job_history_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_job_history_models.dart';
import 'employee_directory_provider.dart';

final employeeJobHistoryProfileProvider = StateNotifierProvider.family<
  EmployeeJobHistoryProfileNotifier,
  EmployeeJobHistoryProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeJobHistoryProfileNotifier(null);
  }

  return EmployeeJobHistoryProfileNotifier(
    buildEmployeeJobHistoryProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeJobHistoryDraftProvider = StateNotifierProvider.family<
  EmployeeJobHistoryEventDraftNotifier,
  EmployeeJobHistoryEventDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeJobHistoryEventDraftNotifier(null);
  }

  return EmployeeJobHistoryEventDraftNotifier(
    buildEmployeeJobHistoryEventDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeJobHistoryProfileNotifier
    extends StateNotifier<EmployeeJobHistoryProfile?> {
  EmployeeJobHistoryProfileNotifier(super.state);

  EmployeeJobHistoryEvent addEvent(EmployeeJobHistoryEventDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee job history is unavailable');
    }

    final event = draft.toEvent(id: _nextEventId(profile));
    state = profile.copyWith(history: [event, ...profile.history]);
    return event;
  }

  void updateStatus(String eventId, EmployeeJobHistoryStatus status) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      history:
          profile.history.map((event) {
            if (event.id != eventId) return event;
            return event.copyWith(status: status, recordedAt: profile.asOfDate);
          }).toList(),
    );
  }

  void attachEvidence(String eventId, {String? evidence}) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      history:
          profile.history.map((event) {
            if (event.id != eventId) return event;
            final resolvedStatus =
                event.effectiveDate.isAfter(profile.asOfDate)
                    ? EmployeeJobHistoryStatus.scheduled
                    : EmployeeJobHistoryStatus.effective;
            return event.copyWith(
              evidence:
                  (evidence == null || evidence.trim().isEmpty)
                      ? 'Evidence attached by People Operations'
                      : evidence.trim(),
              status: resolvedStatus,
              recordedAt: profile.asOfDate,
            );
          }).toList(),
    );
  }

  void markEffective(String eventId) {
    updateStatus(eventId, EmployeeJobHistoryStatus.effective);
  }

  void requestEvidence(String eventId) {
    updateStatus(eventId, EmployeeJobHistoryStatus.pendingEvidence);
  }

  void reverseEvent(String eventId) {
    updateStatus(eventId, EmployeeJobHistoryStatus.reversed);
  }

  void removeEvent(String eventId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      history: profile.history.where((event) => event.id != eventId).toList(),
    );
  }

  String _nextEventId(EmployeeJobHistoryProfile profile) {
    var index = profile.history.length + 1;
    while (true) {
      final id =
          'EJH-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.history.any((event) => event.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeJobHistoryEventDraftNotifier
    extends StateNotifier<EmployeeJobHistoryEventDraft?> {
  final EmployeeJobHistoryEventDraft? _initialDraft;

  EmployeeJobHistoryEventDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeJobHistoryEventType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setFromValue(String value) {
    state = state?.copyWith(fromValue: value);
  }

  void setToValue(String value) {
    state = state?.copyWith(toValue: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state?.copyWith(
      effectiveDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setSource(EmployeeJobHistorySource value) {
    state = state?.copyWith(source: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setNote(String value) {
    state = state?.copyWith(note: value);
  }

  void setEvidence(String value) {
    state = state?.copyWith(evidence: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}
