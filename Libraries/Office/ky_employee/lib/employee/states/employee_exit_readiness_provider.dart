import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_exit_readiness_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_exit_readiness_models.dart';
import 'employee_directory_provider.dart';

final employeeExitReadinessProvider = StateNotifierProvider.family<
  EmployeeExitReadinessNotifier,
  EmployeeExitReadinessProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeExitReadinessNotifier(null, null, asOfDate);
  }

  return EmployeeExitReadinessNotifier(
    buildEmployeeExitReadinessProfile(member: member, asOfDate: asOfDate),
    member,
    asOfDate,
  );
});

final employeeExitClearanceDraftProvider = StateNotifierProvider.family<
  EmployeeExitClearanceDraftNotifier,
  EmployeeExitClearanceDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeExitClearanceDraftNotifier(null);
  }

  return EmployeeExitClearanceDraftNotifier(
    EmployeeExitClearanceDraft.fromMember(member: member, asOfDate: asOfDate),
  );
});

class EmployeeExitReadinessNotifier
    extends StateNotifier<EmployeeExitReadinessProfile?> {
  final EmployeeDirectoryMember? _member;
  final DateTime _asOfDate;

  EmployeeExitReadinessNotifier(super.state, this._member, this._asOfDate);

  void setExitType(EmployeeExitType exitType) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(exitType: exitType);
  }

  void setFinalWorkday(DateTime value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      finalWorkday: DateTime(value.year, value.month, value.day),
    );
  }

  EmployeeExitClearanceItem addItem(EmployeeExitClearanceDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee exit readiness profile is unavailable');
    }

    final item = draft.toItem(id: _nextItemId(profile));
    state = profile.copyWith(items: [...profile.items, item]);
    return item;
  }

  void updateItemStatus(String itemId, EmployeeExitClearanceStatus status) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      items:
          profile.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(status: status);
            }
            return item;
          }).toList(),
    );
  }

  void waiveItem(String itemId) {
    updateItemStatus(itemId, EmployeeExitClearanceStatus.waived);
  }

  void reopenItem(String itemId) {
    updateItemStatus(itemId, EmployeeExitClearanceStatus.open);
  }

  void removeItem(String itemId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      items: profile.items.where((item) => item.id != itemId).toList(),
    );
  }

  void resetToPreset() {
    final member = _member;
    final profile = state;
    if (member == null || profile == null) return;

    state = buildEmployeeExitReadinessProfile(
      member: member,
      asOfDate: _asOfDate,
      exitType: profile.exitType,
      finalWorkday: profile.finalWorkday,
    );
  }

  String _nextItemId(EmployeeExitReadinessProfile profile) {
    var index = profile.items.length + 1;
    while (true) {
      final id =
          'EXIT-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.items.any((item) => item.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeExitClearanceDraftNotifier
    extends StateNotifier<EmployeeExitClearanceDraft?> {
  final EmployeeExitClearanceDraft? _initialDraft;

  EmployeeExitClearanceDraftNotifier(super.state) : _initialDraft = state;

  void setTitle(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(title: value);
  }

  void setOwner(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(owner: value);
  }

  void setCategory(EmployeeExitClearanceCategory value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(category: value);
  }

  void setDueDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setRisk(EmployeeExitRisk value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(risk: value);
  }

  void setNote(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(note: value);
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
