import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_manager_change_readiness_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_manager_change_readiness_models.dart';
import 'employee_directory_provider.dart';

final employeeManagerChangeReadinessProvider = StateNotifierProvider.family<
  EmployeeManagerChangeReadinessNotifier,
  EmployeeManagerChangeReadinessProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeManagerChangeReadinessNotifier(null, null, asOfDate);
  }

  return EmployeeManagerChangeReadinessNotifier(
    buildEmployeeManagerChangeReadinessProfile(
      member: member,
      asOfDate: asOfDate,
    ),
    member,
    asOfDate,
  );
});

final employeeManagerChangeChecklistDraftProvider =
    StateNotifierProvider.family<
      EmployeeManagerChangeChecklistDraftNotifier,
      EmployeeManagerChangeChecklistDraft?,
      String
    >((ref, employeeId) {
      final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
      final member = _findMember(
        ref.watch(employeeDirectoryMembersProvider),
        employeeId,
      );
      if (member == null) {
        return EmployeeManagerChangeChecklistDraftNotifier(null);
      }

      return EmployeeManagerChangeChecklistDraftNotifier(
        buildEmployeeManagerChangeChecklistDraft(
          member: member,
          asOfDate: asOfDate,
        ),
      );
    });

class EmployeeManagerChangeReadinessNotifier
    extends StateNotifier<EmployeeManagerChangeReadinessProfile?> {
  final EmployeeDirectoryMember? _member;
  final DateTime _asOfDate;

  EmployeeManagerChangeReadinessNotifier(
    super.state,
    this._member,
    this._asOfDate,
  );

  void setChangeType(EmployeeManagerChangeType value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(changeType: value);
  }

  void setTargetManager(String value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(targetManager: value);
  }

  void setEffectiveDate(DateTime value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      effectiveDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setReason(String value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(reason: value);
  }

  EmployeeManagerChangeChecklistItem addChecklistItem(
    EmployeeManagerChangeChecklistDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee manager change readiness is unavailable');
    }

    final item = draft.toItem(id: _nextChecklistId(profile));
    state = profile.copyWith(checklist: [...profile.checklist, item]);
    return item;
  }

  void updateChecklistStatus(
    String itemId,
    EmployeeManagerChangeChecklistStatus status,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      checklist:
          profile.checklist.map((item) {
            if (item.id == itemId) {
              return item.copyWith(status: status);
            }
            return item;
          }).toList(),
    );
  }

  void waiveChecklistItem(String itemId) {
    updateChecklistStatus(itemId, EmployeeManagerChangeChecklistStatus.waived);
  }

  void reopenChecklistItem(String itemId) {
    updateChecklistStatus(
      itemId,
      EmployeeManagerChangeChecklistStatus.actionRequired,
    );
  }

  void removeChecklistItem(String itemId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      checklist: profile.checklist.where((item) => item.id != itemId).toList(),
    );
  }

  void resetToPreset() {
    final member = _member;
    final profile = state;
    if (member == null || profile == null) return;

    state = buildEmployeeManagerChangeReadinessProfile(
      member: member,
      asOfDate: _asOfDate,
      changeType: profile.changeType,
      targetManager: profile.targetManager,
      effectiveDate: profile.effectiveDate,
      reason: profile.reason,
    );
  }

  String _nextChecklistId(EmployeeManagerChangeReadinessProfile profile) {
    var index = profile.checklist.length + 1;
    while (true) {
      final id =
          'MGR-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.checklist.any((item) => item.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeManagerChangeChecklistDraftNotifier
    extends StateNotifier<EmployeeManagerChangeChecklistDraft?> {
  final EmployeeManagerChangeChecklistDraft? _initialDraft;

  EmployeeManagerChangeChecklistDraftNotifier(super.state)
    : _initialDraft = state;

  void setType(EmployeeManagerChangeChecklistType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setDueDate(DateTime value) {
    state = state?.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setRisk(EmployeeManagerChangeRisk value) {
    state = state?.copyWith(risk: value);
  }

  void setDetail(String value) {
    state = state?.copyWith(detail: value);
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
