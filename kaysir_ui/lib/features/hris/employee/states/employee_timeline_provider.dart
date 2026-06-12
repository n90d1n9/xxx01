import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_timeline_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_timeline_models.dart';
import 'employee_directory_provider.dart';

final employeeTimelineProfileProvider = StateNotifierProvider.family<
  EmployeeTimelineProfileNotifier,
  EmployeeTimelineProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeTimelineProfileNotifier(null);
  }

  return EmployeeTimelineProfileNotifier(
    buildEmployeeTimelineProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeTimelineDraftProvider = StateNotifierProvider.family<
  EmployeeTimelineDraftNotifier,
  EmployeeTimelineDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeTimelineDraftNotifier(null);
  }

  return EmployeeTimelineDraftNotifier(
    buildEmployeeTimelineDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeTimelineProfileNotifier
    extends StateNotifier<EmployeeTimelineProfile?> {
  EmployeeTimelineProfileNotifier(super.state);

  EmployeeTimelineEntry addDraft(EmployeeTimelineDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee timeline profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final entry = draft.toEntry(id: _nextEntryId(profile));
    state = profile.copyWith(entries: [entry, ...profile.entries]);
    return entry;
  }

  void resolveEntry(String entryId) {
    _updateEntry(entryId, (entry) {
      if (!entry.canResolve) return entry;
      return entry.copyWith(status: EmployeeTimelineStatus.resolved);
    });
  }

  void reopenEntry(String entryId) {
    _updateEntry(entryId, (entry) {
      if (!entry.canReopen) return entry;
      return entry.copyWith(status: EmployeeTimelineStatus.open);
    });
  }

  void togglePinned(String entryId) {
    _updateEntry(entryId, (entry) {
      return entry.copyWith(pinned: !entry.pinned);
    });
  }

  void _updateEntry(
    String entryId,
    EmployeeTimelineEntry Function(EmployeeTimelineEntry entry) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      entries:
          profile.entries.map((entry) {
            if (entry.id != entryId) return entry;
            return update(entry);
          }).toList(),
    );
  }

  String _nextEntryId(EmployeeTimelineProfile profile) {
    var index = profile.entries.length + 1;
    while (true) {
      final id =
          'ETL-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.entries.any((entry) => entry.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeTimelineDraftNotifier
    extends StateNotifier<EmployeeTimelineDraft?> {
  final EmployeeTimelineDraft? _initialDraft;

  EmployeeTimelineDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeTimelineEventType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setDetail(String value) {
    state = state?.copyWith(detail: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setOccurredAt(DateTime value) {
    state = state?.copyWith(
      occurredAt: DateTime(value.year, value.month, value.day),
    );
  }

  void setDueAt(DateTime value) {
    state = state?.copyWith(
      dueAt: DateTime(value.year, value.month, value.day),
    );
  }

  void clearDueAt() {
    state = state?.copyWith(clearDueAt: true);
  }

  void setPriority(EmployeeTimelinePriority value) {
    state = state?.copyWith(priority: value);
  }

  void setPinned(bool value) {
    state = state?.copyWith(pinned: value);
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
