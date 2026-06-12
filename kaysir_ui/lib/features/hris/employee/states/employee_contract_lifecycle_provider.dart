import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_contract_lifecycle_seed_data.dart';
import '../models/employee_contract_lifecycle_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeContractLifecycleProfileProvider = StateNotifierProvider.family<
  EmployeeContractLifecycleProfileNotifier,
  EmployeeContractLifecycleProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeContractLifecycleProfileNotifier(null);
  }

  return EmployeeContractLifecycleProfileNotifier(
    buildEmployeeContractLifecycleProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeContractChangeDraftProvider = StateNotifierProvider.family<
  EmployeeContractChangeDraftNotifier,
  EmployeeContractChangeDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeContractChangeDraftNotifier(null);
  }

  return EmployeeContractChangeDraftNotifier(
    buildEmployeeContractChangeDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeContractLifecycleProfileNotifier
    extends StateNotifier<EmployeeContractLifecycleProfile?> {
  EmployeeContractLifecycleProfileNotifier(super.state);

  EmployeeContractChangeRequest submitDraft(EmployeeContractChangeDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee contract lifecycle profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final request = draft.toRequest(id: _nextChangeId(profile));
    state = profile.copyWith(changes: [request, ...profile.changes]);
    return request;
  }

  void approveChange(String changeId) {
    _updateChange(changeId, (change) {
      if (!change.canApprove) return change;
      return change.copyWith(status: EmployeeContractChangeStatus.approved);
    });
  }

  void signChange(String changeId) {
    _updateChange(changeId, (change) {
      if (!change.canSign) return change;
      return change.copyWith(status: EmployeeContractChangeStatus.signed);
    });
  }

  void activateChange(String changeId) {
    final profile = state;
    if (profile == null) return;
    final change = _changeById(profile.changes, changeId);
    if (change == null || !change.canActivate) return;

    state = profile.copyWith(
      contract: _contractAfterActivation(
        profile.contract,
        change,
        profile.asOfDate,
      ),
      changes:
          profile.changes.map((item) {
            if (item.id != changeId) return item;
            return item.copyWith(
              status: EmployeeContractChangeStatus.activated,
            );
          }).toList(),
    );
  }

  void rejectChange(String changeId) {
    _updateChange(changeId, (change) {
      if (!change.canReject) return change;
      return change.copyWith(status: EmployeeContractChangeStatus.rejected);
    });
  }

  void completeProbation() {
    final profile = state;
    if (profile == null) return;
    if (profile.contract.status != EmployeeContractStatus.probation) return;

    state = profile.copyWith(
      contract: profile.contract.copyWith(
        type: EmployeeContractType.permanent,
        status: EmployeeContractStatus.active,
        clearProbationEndDate: true,
        version: profile.contract.version + 1,
        signedAt: profile.asOfDate,
      ),
    );
  }

  void markRenewed() {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      contract: profile.contract.copyWith(
        status: EmployeeContractStatus.active,
        endDate: profile.asOfDate.add(const Duration(days: 365)),
        renewalDueDate: profile.asOfDate.add(const Duration(days: 335)),
        version: profile.contract.version + 1,
        signedAt: profile.asOfDate,
      ),
    );
  }

  EmployeeContractRecord _contractAfterActivation(
    EmployeeContractRecord contract,
    EmployeeContractChangeRequest change,
    DateTime asOfDate,
  ) {
    return switch (change.type) {
      EmployeeContractChangeType.renewal ||
      EmployeeContractChangeType.extension ||
      EmployeeContractChangeType.endDateChange => contract.copyWith(
        status: EmployeeContractStatus.active,
        endDate: change.effectiveDate.add(const Duration(days: 365)),
        renewalDueDate: change.effectiveDate.add(const Duration(days: 335)),
        version: contract.version + 1,
        signedAt: asOfDate,
      ),
      EmployeeContractChangeType.conversion => contract.copyWith(
        type: EmployeeContractType.permanent,
        status: EmployeeContractStatus.active,
        clearEndDate: true,
        clearProbationEndDate: true,
        clearRenewalDueDate: true,
        version: contract.version + 1,
        signedAt: asOfDate,
      ),
      EmployeeContractChangeType.compensationClause => contract.copyWith(
        status: EmployeeContractStatus.active,
        version: contract.version + 1,
        signedAt: asOfDate,
      ),
    };
  }

  void _updateChange(
    String changeId,
    EmployeeContractChangeRequest Function(EmployeeContractChangeRequest change)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      changes:
          profile.changes.map((change) {
            if (change.id != changeId) return change;
            return update(change);
          }).toList(),
    );
  }

  String _nextChangeId(EmployeeContractLifecycleProfile profile) {
    var index = profile.changes.length + 1;
    while (true) {
      final id =
          'ECL-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.changes.any((change) => change.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeContractChangeDraftNotifier
    extends StateNotifier<EmployeeContractChangeDraft?> {
  final EmployeeContractChangeDraft? _initialDraft;

  EmployeeContractChangeDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeContractChangeType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setRequestedBy(String value) {
    state = state?.copyWith(requestedBy: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state?.copyWith(
      effectiveDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setDetail(String value) {
    state = state?.copyWith(detail: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeContractChangeRequest? _changeById(
  List<EmployeeContractChangeRequest> changes,
  String changeId,
) {
  for (final change in changes) {
    if (change.id == changeId) return change;
  }
  return null;
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
