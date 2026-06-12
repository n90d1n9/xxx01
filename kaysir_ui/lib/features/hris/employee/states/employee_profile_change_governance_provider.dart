import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_models.dart';
import '../models/employee_management_models.dart';
import '../models/employee_profile_change_governance_models.dart';
import 'employee_management_provider.dart';

/// State provider for one employee's governed profile change queue.
final employeeProfileChangeGovernanceProvider = StateNotifierProvider.family<
  EmployeeProfileChangeGovernanceNotifier,
  EmployeeProfileChangeGovernanceProfile?,
  String
>((ref, employeeId) {
  final snapshot = ref.watch(employeeManagementSnapshotProvider(employeeId));
  if (snapshot == null) return EmployeeProfileChangeGovernanceNotifier(null);

  return EmployeeProfileChangeGovernanceNotifier(
    EmployeeProfileChangeGovernanceProfile(
      employeeId: snapshot.member.id,
      employeeName: snapshot.member.name,
      asOfDate: _dateOnly(snapshot.asOfDate),
      requests: _seedRequests(snapshot),
    ),
  );
});

/// Draft provider for creating a governed profile change for one employee.
final employeeProfileChangeDraftProvider = StateNotifierProvider.family<
  EmployeeProfileChangeDraftNotifier,
  EmployeeProfileChangeDraft?,
  String
>((ref, employeeId) {
  final snapshot = ref.watch(employeeManagementSnapshotProvider(employeeId));
  if (snapshot == null) return EmployeeProfileChangeDraftNotifier(null, null);

  final draft = _initialDraft(snapshot);
  return EmployeeProfileChangeDraftNotifier(draft, snapshot);
});

/// Coordinates lifecycle transitions for employee profile change requests.
class EmployeeProfileChangeGovernanceNotifier
    extends StateNotifier<EmployeeProfileChangeGovernanceProfile?> {
  EmployeeProfileChangeGovernanceNotifier(super.state);

  EmployeeProfileChangeRequest addDraft(EmployeeProfileChangeDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee profile change governance is unavailable');
    }

    final request = draft.toRequest(
      id: _nextRequestId(profile),
      createdAt: profile.asOfDate,
    );
    state = profile.copyWith(requests: [request, ...profile.requests]);
    return request;
  }

  void startReview(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canStartReview) return request;
      return request.copyWith(status: EmployeeProfileChangeStatus.inReview);
    });
  }

  void approve(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canApprove) return request;
      return request.copyWith(status: EmployeeProfileChangeStatus.approved);
    });
  }

  void schedule(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canSchedule) return request;
      return request.copyWith(status: EmployeeProfileChangeStatus.scheduled);
    });
  }

  void apply(String requestId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      requests:
          profile.requests.map((request) {
            if (request.id != requestId ||
                !request.canApply(profile.asOfDate)) {
              return request;
            }
            return request.copyWith(
              status: EmployeeProfileChangeStatus.applied,
            );
          }).toList(),
    );
  }

  void reject(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canReject) return request;
      return request.copyWith(status: EmployeeProfileChangeStatus.rejected);
    });
  }

  void cancel(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canCancel) return request;
      return request.copyWith(status: EmployeeProfileChangeStatus.cancelled);
    });
  }

  void _updateRequest(
    String requestId,
    EmployeeProfileChangeRequest Function(EmployeeProfileChangeRequest request)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      requests:
          profile.requests.map((request) {
            if (request.id != requestId) return request;
            return update(request);
          }).toList(),
    );
  }

  String _nextRequestId(EmployeeProfileChangeGovernanceProfile profile) {
    var index = profile.requests.length + 1;
    while (true) {
      final id =
          'EPC-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.requests.any((request) => request.id == id)) return id;
      index++;
    }
  }
}

/// Maintains local draft edits for one governed employee profile change.
class EmployeeProfileChangeDraftNotifier
    extends StateNotifier<EmployeeProfileChangeDraft?> {
  final EmployeeProfileChangeDraft? _initialDraft;
  final EmployeeManagementSnapshot? _snapshot;

  EmployeeProfileChangeDraftNotifier(super.state, this._snapshot)
    : _initialDraft = state;

  void setField(EmployeeProfileChangeField field) {
    final snapshot = _snapshot;
    if (snapshot == null) return;
    state = state?.copyWith(
      field: field,
      currentValue: currentValueForProfileChangeField(snapshot, field),
      proposedValue: '',
    );
  }

  void setCurrentValue(String value) {
    state = state?.copyWith(currentValue: value);
  }

  void setProposedValue(String value) {
    state = state?.copyWith(proposedValue: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state?.copyWith(effectiveDate: _dateOnly(value));
  }

  void setReason(String value) {
    state = state?.copyWith(reason: value);
  }

  void setRequester(String value) {
    state = state?.copyWith(requester: value);
  }

  void setReviewer(String value) {
    state = state?.copyWith(reviewer: value);
  }

  void setApprover(String value) {
    state = state?.copyWith(approver: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

/// Returns the current display value for a governed profile change field.
String currentValueForProfileChangeField(
  EmployeeManagementSnapshot snapshot,
  EmployeeProfileChangeField field,
) {
  return switch (field) {
    EmployeeProfileChangeField.roleTitle => snapshot.member.position,
    EmployeeProfileChangeField.department => snapshot.member.department,
    EmployeeProfileChangeField.manager => snapshot.member.manager,
    EmployeeProfileChangeField.employmentStatus => snapshot.member.status.label,
    EmployeeProfileChangeField.payrollGroup => snapshot.payrollGroup,
    EmployeeProfileChangeField.jobLevel => snapshot.jobLevel,
    EmployeeProfileChangeField.costCenter => snapshot.costCenter,
  };
}

EmployeeProfileChangeDraft _initialDraft(EmployeeManagementSnapshot snapshot) {
  const field = EmployeeProfileChangeField.manager;
  return EmployeeProfileChangeDraft(
    employeeId: snapshot.member.id,
    employeeName: snapshot.member.name,
    asOfDate: _dateOnly(snapshot.asOfDate),
    field: field,
    currentValue: currentValueForProfileChangeField(snapshot, field),
    proposedValue: '',
    effectiveDate: _dateOnly(snapshot.asOfDate).add(const Duration(days: 14)),
    reason: '',
    requester: 'People Operations',
    reviewer: 'HR Business Partner',
    approver: 'People Director',
  );
}

List<EmployeeProfileChangeRequest> _seedRequests(
  EmployeeManagementSnapshot snapshot,
) {
  final asOfDate = _dateOnly(snapshot.asOfDate);
  final member = snapshot.member;

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeProfileChangeRequest(
        id: 'EPC-${member.id}-seed-001',
        employeeId: member.id,
        employeeName: member.name,
        field: EmployeeProfileChangeField.employmentStatus,
        currentValue: member.status.label,
        proposedValue: EmployeeDirectoryStatus.active.label,
        effectiveDate: asOfDate.add(const Duration(days: 30)),
        reason: 'Prepare onboarding conversion after probation checkpoint.',
        requester: 'People Operations',
        reviewer: 'HR Business Partner',
        approver: 'People Director',
        createdAt: asOfDate.subtract(const Duration(days: 1)),
        status: EmployeeProfileChangeStatus.submitted,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeProfileChangeRequest(
        id: 'EPC-${member.id}-seed-001',
        employeeId: member.id,
        employeeName: member.name,
        field: EmployeeProfileChangeField.manager,
        currentValue: member.manager,
        proposedValue: 'Emma Rodriguez',
        effectiveDate: asOfDate,
        reason: 'Move reporting line to HR manager during support plan.',
        requester: 'People Operations',
        reviewer: 'HR Business Partner',
        approver: 'People Director',
        createdAt: asOfDate.subtract(const Duration(days: 2)),
        status: EmployeeProfileChangeStatus.scheduled,
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
