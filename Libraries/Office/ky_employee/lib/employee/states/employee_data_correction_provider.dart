import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_data_correction_models.dart';
import '../models/employee_data_quality_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_data_quality_provider.dart';
import 'employee_directory_provider.dart';

final employeeDataCorrectionProvider = StateNotifierProvider.family<
  EmployeeDataCorrectionNotifier,
  EmployeeDataCorrectionProfile?,
  String
>((ref, employeeId) {
  final asOfDate = _dateOnly(ref.watch(employeeDirectoryAsOfDateProvider));
  final members = ref.watch(employeeDirectoryMembersProvider);
  final member = _findMember(members, employeeId);
  final quality = ref.watch(employeeDataQualityProvider(employeeId));

  if (member == null || quality == null) {
    return EmployeeDataCorrectionNotifier(null);
  }

  return EmployeeDataCorrectionNotifier(
    EmployeeDataCorrectionProfile(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: asOfDate,
      issues: quality.sortedIssues,
      requests: _seedRequests(
        member: member,
        quality: quality,
        asOfDate: asOfDate,
      ),
    ),
  );
});

final employeeDataCorrectionDraftProvider = StateNotifierProvider.family<
  EmployeeDataCorrectionDraftNotifier,
  EmployeeDataCorrectionDraft?,
  String
>((ref, employeeId) {
  final asOfDate = _dateOnly(ref.watch(employeeDirectoryAsOfDateProvider));
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  final quality = ref.watch(employeeDataQualityProvider(employeeId));

  if (member == null || quality == null) {
    return EmployeeDataCorrectionDraftNotifier(null);
  }

  final issue = _defaultIssue(quality);
  return EmployeeDataCorrectionDraftNotifier(
    EmployeeDataCorrectionDraft.fromIssue(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: asOfDate,
      issue: issue,
      currentValue: _currentValueForIssue(member, issue),
    ),
  );
});

class EmployeeDataCorrectionNotifier
    extends StateNotifier<EmployeeDataCorrectionProfile?> {
  EmployeeDataCorrectionNotifier(super.state);

  EmployeeDataCorrectionRequest addDraft(EmployeeDataCorrectionDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee data correction profile is unavailable');
    }

    final request = draft.toRequest(id: _nextRequestId(profile));
    state = profile.copyWith(requests: [request, ...profile.requests]);
    return request;
  }

  void startReview(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canReview) return request;
      return request.copyWith(status: EmployeeDataCorrectionStatus.inReview);
    });
  }

  void approve(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canApprove) return request;
      return request.copyWith(status: EmployeeDataCorrectionStatus.approved);
    });
  }

  void apply(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canApply) return request;
      return request.copyWith(status: EmployeeDataCorrectionStatus.applied);
    });
  }

  void reject(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canReject) return request;
      return request.copyWith(status: EmployeeDataCorrectionStatus.rejected);
    });
  }

  void cancel(String requestId) {
    _updateRequest(requestId, (request) {
      if (!request.canCancel) return request;
      return request.copyWith(status: EmployeeDataCorrectionStatus.cancelled);
    });
  }

  void reopen(String requestId) {
    _updateRequest(
      requestId,
      (request) =>
          request.copyWith(status: EmployeeDataCorrectionStatus.submitted),
    );
  }

  void _updateRequest(
    String requestId,
    EmployeeDataCorrectionRequest Function(
      EmployeeDataCorrectionRequest request,
    )
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

  String _nextRequestId(EmployeeDataCorrectionProfile profile) {
    var index = profile.requests.length + 1;
    while (true) {
      final id =
          'EDC-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.requests.any((request) => request.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeDataCorrectionDraftNotifier
    extends StateNotifier<EmployeeDataCorrectionDraft?> {
  final EmployeeDataCorrectionDraft? _initialDraft;

  EmployeeDataCorrectionDraftNotifier(super.state) : _initialDraft = state;

  void setIssue({
    required EmployeeDataQualityIssue issue,
    required String currentValue,
  }) {
    state = state?.copyWith(
      issueId: issue.id,
      issueTitle: issue.title,
      field: issue.field,
      currentValue: currentValue,
      reviewer: issue.owner,
      severity: issue.severity,
      proposedValue: '',
      rationale: '',
    );
  }

  void setField(String value) {
    state = state?.copyWith(field: value);
  }

  void setCurrentValue(String value) {
    state = state?.copyWith(currentValue: value);
  }

  void setProposedValue(String value) {
    state = state?.copyWith(proposedValue: value);
  }

  void setRationale(String value) {
    state = state?.copyWith(rationale: value);
  }

  void setRequester(String value) {
    state = state?.copyWith(requester: value);
  }

  void setReviewer(String value) {
    state = state?.copyWith(reviewer: value);
  }

  void setDueDate(DateTime value) {
    state = state?.copyWith(dueDate: _dateOnly(value));
  }

  void reset() {
    state = _initialDraft;
  }
}

List<EmployeeDataCorrectionRequest> _seedRequests({
  required EmployeeDirectoryMember member,
  required EmployeeDataQualityProfile quality,
  required DateTime asOfDate,
}) {
  final issue = _firstOpenIssue(quality.sortedIssues);
  if (issue == null || !issue.needsAttention(asOfDate)) {
    return const [];
  }

  return [
    EmployeeDataCorrectionRequest(
      id: 'EDC-${member.id}-seed-001',
      employeeId: member.id,
      employeeName: member.name,
      issueId: issue.id,
      issueTitle: issue.title,
      field: issue.field,
      currentValue: _currentValueForIssue(member, issue),
      proposedValue: 'Pending verified ${issue.field.toLowerCase()} value',
      rationale: 'Seeded from high-priority data quality signal.',
      requester: 'People Operations',
      reviewer: issue.owner,
      createdAt: asOfDate,
      dueDate: issue.dueDate.isBefore(asOfDate) ? asOfDate : issue.dueDate,
      severity: issue.severity,
      status:
          issue.isOverdue(asOfDate)
              ? EmployeeDataCorrectionStatus.inReview
              : EmployeeDataCorrectionStatus.submitted,
    ),
  ];
}

EmployeeDataQualityIssue? _defaultIssue(EmployeeDataQualityProfile quality) {
  return _firstOpenIssue(quality.sortedIssues) ??
      _firstIssue(quality.sortedIssues);
}

String currentValueForDataCorrectionIssue(
  EmployeeDirectoryMember member,
  EmployeeDataQualityIssue? issue,
) {
  return _currentValueForIssue(member, issue);
}

String _currentValueForIssue(
  EmployeeDirectoryMember member,
  EmployeeDataQualityIssue? issue,
) {
  final field = issue?.field.toLowerCase() ?? '';
  if (field.contains('email')) return member.email;
  if (field.contains('phone')) return member.phone;
  if (field.contains('manager') || field.contains('reporting')) {
    return member.manager;
  }
  if (field.contains('joining')) {
    return DateFormat('MMM d, yyyy').format(member.joiningDate);
  }
  if (field.contains('job') || field.contains('assignment')) {
    return '${member.position} - ${member.department}';
  }
  if (field.contains('location')) return member.location;
  return issue == null
      ? 'Current profile value'
      : 'Current ${issue.field} record';
}

EmployeeDataQualityIssue? _firstOpenIssue(
  List<EmployeeDataQualityIssue> issues,
) {
  for (final issue in issues) {
    if (issue.isOpen) return issue;
  }
  return null;
}

EmployeeDataQualityIssue? _firstIssue(List<EmployeeDataQualityIssue> issues) {
  if (issues.isEmpty) return null;
  return issues.first;
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) return member;
  }
  return null;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
