import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_approval_coverage_seed_data.dart';
import '../models/employee_approval_coverage_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeApprovalCoverageProvider = StateNotifierProvider.family<
  EmployeeApprovalCoverageNotifier,
  EmployeeApprovalCoverageProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeApprovalCoverageNotifier(null);
  }

  return EmployeeApprovalCoverageNotifier(
    buildEmployeeApprovalCoverageProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeApprovalDelegationDraftProvider = StateNotifierProvider.family<
  EmployeeApprovalDelegationDraftNotifier,
  EmployeeApprovalDelegationDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeApprovalDelegationDraftNotifier(null);
  }

  return EmployeeApprovalDelegationDraftNotifier(
    EmployeeApprovalDelegationDraft.fromMember(
      member: member,
      asOfDate: asOfDate,
    ),
  );
});

class EmployeeApprovalCoverageNotifier
    extends StateNotifier<EmployeeApprovalCoverageProfile?> {
  EmployeeApprovalCoverageNotifier(super.state);

  EmployeeApprovalDelegation submitDraft(
    EmployeeApprovalDelegationDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee approval coverage profile is unavailable');
    }

    final delegation = draft.toDelegation(id: _nextDelegationId(profile));
    state = profile.copyWith(delegations: [delegation, ...profile.delegations]);
    return delegation;
  }

  void activate(String delegationId) {
    _updateDelegation(
      delegationId,
      (delegation) =>
          delegation.copyWith(status: EmployeeApprovalCoverageStatus.active),
    );
  }

  void block(String delegationId) {
    _updateDelegation(
      delegationId,
      (delegation) =>
          delegation.copyWith(status: EmployeeApprovalCoverageStatus.blocked),
    );
  }

  void expire(String delegationId) {
    _updateDelegation(
      delegationId,
      (delegation) =>
          delegation.copyWith(status: EmployeeApprovalCoverageStatus.expired),
    );
  }

  void remove(String delegationId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      delegations:
          profile.delegations
              .where((delegation) => delegation.id != delegationId)
              .toList(),
    );
  }

  void _updateDelegation(
    String delegationId,
    EmployeeApprovalDelegation Function(EmployeeApprovalDelegation delegation)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      delegations:
          profile.delegations.map((delegation) {
            if (delegation.id != delegationId) return delegation;
            return update(delegation);
          }).toList(),
    );
  }

  String _nextDelegationId(EmployeeApprovalCoverageProfile profile) {
    var index = profile.delegations.length + 1;
    while (true) {
      final id =
          'EAC-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.delegations.any((delegation) => delegation.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeApprovalDelegationDraftNotifier
    extends StateNotifier<EmployeeApprovalDelegationDraft?> {
  final EmployeeApprovalDelegationDraft? _initialDraft;

  EmployeeApprovalDelegationDraftNotifier(super.state) : _initialDraft = state;

  void setArea(EmployeeApprovalCoverageArea value) {
    state = state?.copyWith(area: value);
  }

  void setPrimaryApprover(String value) {
    state = state?.copyWith(primaryApprover: value);
  }

  void setDelegateApprover(String value) {
    state = state?.copyWith(delegateApprover: value);
  }

  void setStartDate(DateTime value) {
    state = state?.copyWith(
      startDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setEndDate(DateTime value) {
    state = state?.copyWith(
      endDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setRisk(EmployeeApprovalCoverageRisk value) {
    state = state?.copyWith(risk: value);
  }

  void setReason(String value) {
    state = state?.copyWith(reason: value);
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
