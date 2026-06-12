import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_payroll_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_payroll_models.dart';
import 'employee_directory_provider.dart';

final employeePayrollProfileProvider = StateNotifierProvider.family<
  EmployeePayrollProfileNotifier,
  EmployeePayrollProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePayrollProfileNotifier(null);
  }

  return EmployeePayrollProfileNotifier(
    buildEmployeePayrollProfile(member: member, asOfDate: asOfDate),
  );
});

final employeePayrollChangeDraftProvider = StateNotifierProvider.family<
  EmployeePayrollChangeDraftNotifier,
  EmployeePayrollChangeDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePayrollChangeDraftNotifier(null);
  }

  return EmployeePayrollChangeDraftNotifier(
    buildEmployeePayrollChangeDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeePayrollProfileNotifier
    extends StateNotifier<EmployeePayrollProfile?> {
  EmployeePayrollProfileNotifier(super.state);

  EmployeePayrollChangeRequest submitDraft(EmployeePayrollChangeDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee payroll profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final request = draft.toRequest(id: _nextChangeId(profile));
    state = profile.copyWith(changes: [request, ...profile.changes]);
    return request;
  }

  void approveChange(String changeId) {
    final profile = state;
    if (profile == null) return;
    final change = _changeById(profile.changes, changeId);
    if (change == null || !change.canApprove) return;

    state = profile.copyWith(
      changes:
          profile.changes.map((item) {
            if (item.id != changeId) return item;
            return item.copyWith(status: EmployeePayrollChangeStatus.approved);
          }).toList(),
    );
  }

  void applyChange(String changeId) {
    final profile = state;
    if (profile == null) return;
    final change = _changeById(profile.changes, changeId);
    if (change == null || !change.canApply) return;

    state = profile.copyWith(
      bankAccount: _bankAfterAppliedChange(profile, change),
      taxProfile: _taxAfterAppliedChange(profile, change),
      changes:
          profile.changes.map((item) {
            if (item.id != changeId) return item;
            return item.copyWith(status: EmployeePayrollChangeStatus.applied);
          }).toList(),
    );
  }

  void rejectChange(String changeId) {
    final profile = state;
    if (profile == null) return;
    final change = _changeById(profile.changes, changeId);
    if (change == null || !change.canReject) return;

    state = profile.copyWith(
      changes:
          profile.changes.map((item) {
            if (item.id != changeId) return item;
            return item.copyWith(status: EmployeePayrollChangeStatus.rejected);
          }).toList(),
    );
  }

  void markBankVerified() {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      bankAccount: profile.bankAccount.copyWith(
        verificationStatus: EmployeeBankVerificationStatus.verified,
        lastVerifiedAt: profile.asOfDate,
      ),
    );
  }

  void markTaxCurrent() {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      taxProfile: profile.taxProfile.copyWith(
        status: EmployeeTaxFormStatus.current,
        lastUpdatedAt: profile.asOfDate,
      ),
    );
  }

  EmployeePayrollBankAccount _bankAfterAppliedChange(
    EmployeePayrollProfile profile,
    EmployeePayrollChangeRequest change,
  ) {
    if (change.type != EmployeePayrollChangeType.bankAccount) {
      return profile.bankAccount;
    }

    return profile.bankAccount.copyWith(
      verificationStatus: EmployeeBankVerificationStatus.pending,
      lastVerifiedAt: profile.asOfDate,
    );
  }

  EmployeePayrollTaxProfile _taxAfterAppliedChange(
    EmployeePayrollProfile profile,
    EmployeePayrollChangeRequest change,
  ) {
    if (change.type != EmployeePayrollChangeType.taxWithholding) {
      return profile.taxProfile;
    }

    return profile.taxProfile.copyWith(
      status: EmployeeTaxFormStatus.current,
      lastUpdatedAt: profile.asOfDate,
    );
  }

  String _nextChangeId(EmployeePayrollProfile profile) {
    var index = profile.changes.length + 1;
    while (true) {
      final id =
          'EPC-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.changes.any((change) => change.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeePayrollChangeDraftNotifier
    extends StateNotifier<EmployeePayrollChangeDraft?> {
  final EmployeePayrollChangeDraft? _initialDraft;

  EmployeePayrollChangeDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeePayrollChangeType value) {
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

EmployeePayrollChangeRequest? _changeById(
  List<EmployeePayrollChangeRequest> changes,
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
