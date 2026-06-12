import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_workflow_automation_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_workflow_automation_models.dart';
import 'employee_directory_provider.dart';

final employeeWorkflowAutomationProfileProvider = StateNotifierProvider.family<
  EmployeeWorkflowAutomationProfileNotifier,
  EmployeeWorkflowAutomationProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeWorkflowAutomationProfileNotifier(null);
  }

  return EmployeeWorkflowAutomationProfileNotifier(
    buildEmployeeWorkflowAutomationProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeWorkflowAutomationDraftProvider = StateNotifierProvider.family<
  EmployeeWorkflowAutomationHookDraftNotifier,
  EmployeeWorkflowAutomationHookDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeWorkflowAutomationHookDraftNotifier(null);
  }

  return EmployeeWorkflowAutomationHookDraftNotifier(
    buildEmployeeWorkflowAutomationHookDraft(
      member: member,
      asOfDate: asOfDate,
    ),
  );
});

class EmployeeWorkflowAutomationProfileNotifier
    extends StateNotifier<EmployeeWorkflowAutomationProfile?> {
  EmployeeWorkflowAutomationProfileNotifier(super.state);

  EmployeeWorkflowAutomationHook submitDraft(
    EmployeeWorkflowAutomationHookDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee workflow automation is unavailable');
    }

    final hook = draft.toHook(id: _nextHookId(profile));
    state = profile.copyWith(hooks: [hook, ...profile.hooks]);
    return hook;
  }

  void activate(String hookId) {
    _updateHook(
      hookId,
      (hook) => hook.copyWith(
        status: EmployeeWorkflowAutomationStatus.active,
        failureReason: '',
      ),
    );
  }

  void pause(String hookId) {
    _updateHook(
      hookId,
      (hook) => hook.copyWith(status: EmployeeWorkflowAutomationStatus.paused),
    );
  }

  void markFailed(String hookId, {String? reason}) {
    _updateHook(
      hookId,
      (hook) => hook.copyWith(
        status: EmployeeWorkflowAutomationStatus.failed,
        failureReason:
            (reason == null || reason.trim().isEmpty)
                ? 'Automation run failed validation'
                : reason.trim(),
      ),
    );
  }

  void runNow(String hookId) {
    final profile = state;
    if (profile == null) return;

    _updateHook(
      hookId,
      (hook) => hook.copyWith(
        status: EmployeeWorkflowAutomationStatus.active,
        lastRunAt: profile.asOfDate,
        nextRunAt: profile.asOfDate.add(Duration(hours: hook.slaHours)),
        generatedTaskCount: hook.generatedTaskCount + 1,
        failureReason: '',
      ),
    );
  }

  void remove(String hookId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      hooks: profile.hooks.where((hook) => hook.id != hookId).toList(),
    );
  }

  void _updateHook(
    String hookId,
    EmployeeWorkflowAutomationHook Function(EmployeeWorkflowAutomationHook hook)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      hooks:
          profile.hooks.map((hook) {
            if (hook.id != hookId) return hook;
            return update(hook);
          }).toList(),
    );
  }

  String _nextHookId(EmployeeWorkflowAutomationProfile profile) {
    var index = profile.hooks.length + 1;
    while (true) {
      final id =
          'EWA-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.hooks.any((hook) => hook.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeWorkflowAutomationHookDraftNotifier
    extends StateNotifier<EmployeeWorkflowAutomationHookDraft?> {
  final EmployeeWorkflowAutomationHookDraft? _initialDraft;

  EmployeeWorkflowAutomationHookDraftNotifier(super.state)
    : _initialDraft = state;

  void setName(String value) {
    state = state?.copyWith(name: value);
  }

  void setTrigger(EmployeeWorkflowAutomationTrigger value) {
    state = state?.copyWith(trigger: value);
  }

  void setDelivery(EmployeeWorkflowAutomationDelivery value) {
    state = state?.copyWith(delivery: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setSourceLabel(String value) {
    state = state?.copyWith(sourceLabel: value);
  }

  void setGeneratedTaskTitle(String value) {
    state = state?.copyWith(generatedTaskTitle: value);
  }

  void setSlaHours(int value) {
    state = state?.copyWith(slaHours: value);
  }

  void setRisk(EmployeeWorkflowAutomationRisk value) {
    state = state?.copyWith(risk: value);
  }

  void setNextRunAt(DateTime value) {
    state = state?.copyWith(
      nextRunAt: DateTime(value.year, value.month, value.day),
    );
  }

  void setNotes(String value) {
    state = state?.copyWith(notes: value);
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
