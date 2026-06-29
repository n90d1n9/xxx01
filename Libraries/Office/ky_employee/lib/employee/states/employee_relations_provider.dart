import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_relations_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_relations_models.dart';
import 'employee_directory_provider.dart';

final employeeRelationsProfileProvider = StateNotifierProvider.family<
  EmployeeRelationsProfileNotifier,
  EmployeeRelationsProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeRelationsProfileNotifier(null);
  }

  return EmployeeRelationsProfileNotifier(
    buildEmployeeRelationsProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeRelationsEventDraftProvider = StateNotifierProvider.family<
  EmployeeRelationsEventDraftNotifier,
  EmployeeRelationsEventDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeRelationsEventDraftNotifier(null);
  }

  return EmployeeRelationsEventDraftNotifier(
    buildEmployeeRelationsEventDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeRelationsProfileNotifier
    extends StateNotifier<EmployeeRelationsProfile?> {
  EmployeeRelationsProfileNotifier(super.state);

  EmployeeRelationsEvent recordEvent(EmployeeRelationsEventDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee relations profile is unavailable');
    }
    if (!draft.isReadyToAdd) {
      throw StateError(draft.validationErrors.first);
    }

    final event = draft.toEvent(id: _nextEventId(profile));
    state = profile.copyWith(events: [event, ...profile.events]);
    return event;
  }

  void startFollowUp(String eventId) {
    _updateEvent(eventId, (event) {
      if (!event.isOpen) return event;
      return event.copyWith(status: EmployeeRelationsStatus.inProgress);
    });
  }

  void resolveEvent(String eventId) {
    _updateEvent(eventId, (event) {
      if (!event.isOpen) return event;
      return event.copyWith(status: EmployeeRelationsStatus.resolved);
    });
  }

  void archiveEvent(String eventId) {
    _updateEvent(
      eventId,
      (event) => event.copyWith(status: EmployeeRelationsStatus.archived),
    );
  }

  void _updateEvent(
    String eventId,
    EmployeeRelationsEvent Function(EmployeeRelationsEvent event) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      events:
          profile.events.map((event) {
            if (event.id != eventId) return event;
            return update(event);
          }).toList(),
    );
  }

  String _nextEventId(EmployeeRelationsProfile profile) {
    var index = profile.events.length + 1;
    while (true) {
      final id =
          'ERL-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.events.any((event) => event.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeRelationsEventDraftNotifier
    extends StateNotifier<EmployeeRelationsEventDraft?> {
  final EmployeeRelationsEventDraft? _initialDraft;

  EmployeeRelationsEventDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeRelationsEventType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setOccurredAt(DateTime value) {
    state = state?.copyWith(occurredAt: _dateOnly(value));
  }

  void setFollowUpDate(DateTime value) {
    state = state?.copyWith(followUpDate: _dateOnly(value));
  }

  void setSeverity(EmployeeRelationsSeverity value) {
    state = state?.copyWith(severity: value);
  }

  void setVisibility(EmployeeRelationsVisibility value) {
    state = state?.copyWith(visibility: value);
  }

  void setSummary(String value) {
    state = state?.copyWith(summary: value);
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
