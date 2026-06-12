import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_leave_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_leave_models.dart';
import 'employee_directory_provider.dart';

final employeeLeaveProfileProvider = StateNotifierProvider.family<
  EmployeeLeaveProfileNotifier,
  EmployeeLeaveProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeLeaveProfileNotifier(null);
  }

  return EmployeeLeaveProfileNotifier(
    buildEmployeeLeaveProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeLeaveRequestDraftProvider = StateNotifierProvider.family<
  EmployeeLeaveRequestDraftNotifier,
  EmployeeLeaveRequestDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeLeaveRequestDraftNotifier(null);
  }

  return EmployeeLeaveRequestDraftNotifier(
    buildEmployeeLeaveRequestDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeLeaveProfileNotifier
    extends StateNotifier<EmployeeLeaveProfile?> {
  EmployeeLeaveProfileNotifier(super.state);

  EmployeeLeaveRequest addDraft(EmployeeLeaveRequestDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee leave profile is unavailable');
    }
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final balance = profile.balanceFor(draft.type);
    if (balance == null) {
      throw StateError('${draft.type.label} balance is unavailable');
    }
    if (draft.durationDays > balance.availableDays) {
      throw StateError('Request exceeds ${draft.type.label} available balance');
    }

    final request = draft.toRequest(id: _nextRequestId(profile));
    state = profile.copyWith(
      requests: [request, ...profile.requests],
      balances: _updateBalance(
        profile.balances,
        draft.type,
        (item) => item.reservePending(draft.durationDays),
      ),
    );
    return request;
  }

  void approveRequest(String requestId) {
    final profile = state;
    if (profile == null) return;
    final request = _requestById(profile.requests, requestId);
    if (request == null || !request.canApprove) return;

    state = profile.copyWith(
      requests:
          profile.requests.map((item) {
            if (item.id != requestId) return item;
            return item.copyWith(status: EmployeeLeaveRequestStatus.approved);
          }).toList(),
      balances: _updateBalance(
        profile.balances,
        request.type,
        (item) => item.approvePending(request.durationDays),
      ),
    );
  }

  void rejectRequest(String requestId) {
    final profile = state;
    if (profile == null) return;
    final request = _requestById(profile.requests, requestId);
    if (request == null || !request.canReject) return;

    state = profile.copyWith(
      requests:
          profile.requests.map((item) {
            if (item.id != requestId) return item;
            return item.copyWith(status: EmployeeLeaveRequestStatus.rejected);
          }).toList(),
      balances: _updateBalance(
        profile.balances,
        request.type,
        (item) => item.releasePending(request.durationDays),
      ),
    );
  }

  void cancelRequest(String requestId) {
    final profile = state;
    if (profile == null) return;
    final request = _requestById(profile.requests, requestId);
    if (request == null || !request.canCancel) return;

    state = profile.copyWith(
      requests:
          profile.requests.map((item) {
            if (item.id != requestId) return item;
            return item.copyWith(status: EmployeeLeaveRequestStatus.cancelled);
          }).toList(),
      balances: _updateBalance(profile.balances, request.type, (item) {
        if (request.isPending) return item.releasePending(request.durationDays);
        return item.releaseApproved(request.durationDays);
      }),
    );
  }

  String _nextRequestId(EmployeeLeaveProfile profile) {
    var index = profile.requests.length + 1;
    while (true) {
      final id =
          'ELR-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.requests.any((request) => request.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeLeaveRequestDraftNotifier
    extends StateNotifier<EmployeeLeaveRequestDraft?> {
  final EmployeeLeaveRequestDraft? _initialDraft;

  EmployeeLeaveRequestDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeLeaveType value) {
    state = state?.copyWith(type: value);
  }

  void setStartDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    final startDate = DateTime(value.year, value.month, value.day);
    final endDate =
        draft.endDate.isBefore(startDate) ? startDate : draft.endDate;
    state = draft.copyWith(startDate: startDate, endDate: endDate);
  }

  void setEndDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    final endDate = DateTime(value.year, value.month, value.day);
    final startDate =
        endDate.isBefore(draft.startDate) ? endDate : draft.startDate;
    state = draft.copyWith(startDate: startDate, endDate: endDate);
  }

  void setReason(String value) {
    state = state?.copyWith(reason: value);
  }

  void setCoverageOwner(String value) {
    state = state?.copyWith(coverageOwner: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

List<EmployeeLeaveBalance> _updateBalance(
  List<EmployeeLeaveBalance> balances,
  EmployeeLeaveType type,
  EmployeeLeaveBalance Function(EmployeeLeaveBalance balance) update,
) {
  return balances.map((balance) {
    if (balance.type != type) return balance;
    return update(balance);
  }).toList();
}

EmployeeLeaveRequest? _requestById(
  List<EmployeeLeaveRequest> requests,
  String requestId,
) {
  for (final request in requests) {
    if (request.id == requestId) return request;
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
