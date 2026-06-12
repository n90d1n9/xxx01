import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_mobility_readiness_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_mobility_readiness_models.dart';
import 'employee_directory_provider.dart';

final employeeMobilityReadinessProvider = StateNotifierProvider.family<
  EmployeeMobilityReadinessNotifier,
  EmployeeMobilityReadinessProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeMobilityReadinessNotifier(null, null, asOfDate);
  }

  return EmployeeMobilityReadinessNotifier(
    buildEmployeeMobilityReadinessProfile(member: member, asOfDate: asOfDate),
    member,
    asOfDate,
  );
});

final employeeMobilityGateDraftProvider = StateNotifierProvider.family<
  EmployeeMobilityGateDraftNotifier,
  EmployeeMobilityGateDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeMobilityGateDraftNotifier(null);
  }

  return EmployeeMobilityGateDraftNotifier(
    buildEmployeeMobilityGateDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeMobilityReadinessNotifier
    extends StateNotifier<EmployeeMobilityReadinessProfile?> {
  final EmployeeDirectoryMember? _member;
  final DateTime _asOfDate;

  EmployeeMobilityReadinessNotifier(super.state, this._member, this._asOfDate);

  void setMoveType(EmployeeMobilityMoveType value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(moveType: value);
  }

  void setTargetRole(String value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(targetRole: value);
  }

  void setTargetDepartment(String value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(targetDepartment: value);
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

  EmployeeMobilityGate addGate(EmployeeMobilityGateDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee mobility readiness profile is unavailable');
    }

    final gate = draft.toGate(id: _nextGateId(profile));
    state = profile.copyWith(gates: [...profile.gates, gate]);
    return gate;
  }

  void updateGateStatus(String gateId, EmployeeMobilityGateStatus status) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      gates:
          profile.gates.map((gate) {
            if (gate.id == gateId) {
              return gate.copyWith(status: status);
            }
            return gate;
          }).toList(),
    );
  }

  void waiveGate(String gateId) {
    updateGateStatus(gateId, EmployeeMobilityGateStatus.waived);
  }

  void reopenGate(String gateId) {
    updateGateStatus(gateId, EmployeeMobilityGateStatus.actionRequired);
  }

  void removeGate(String gateId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      gates: profile.gates.where((gate) => gate.id != gateId).toList(),
    );
  }

  void resetToPreset() {
    final member = _member;
    final profile = state;
    if (member == null || profile == null) return;

    state = buildEmployeeMobilityReadinessProfile(
      member: member,
      asOfDate: _asOfDate,
      moveType: profile.moveType,
      targetRole: profile.targetRole,
      targetDepartment: profile.targetDepartment,
      targetManager: profile.targetManager,
      effectiveDate: profile.effectiveDate,
    );
  }

  String _nextGateId(EmployeeMobilityReadinessProfile profile) {
    var index = profile.gates.length + 1;
    while (true) {
      final id =
          'MOB-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.gates.any((gate) => gate.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeMobilityGateDraftNotifier
    extends StateNotifier<EmployeeMobilityGateDraft?> {
  final EmployeeMobilityGateDraft? _initialDraft;

  EmployeeMobilityGateDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeMobilityGateType value) {
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

  void setRisk(EmployeeMobilityGateRisk value) {
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
