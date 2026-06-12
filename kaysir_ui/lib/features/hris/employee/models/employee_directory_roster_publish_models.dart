import 'employee_directory_models.dart';
import 'employee_directory_quality_gate_models.dart';
import 'employee_directory_quality_signoff_models.dart';

/// Captures HR input before publishing a governed roster release packet.
class EmployeeDirectoryRosterPublishDraft {
  final String preparedBy;
  final String releaseNote;
  final bool confirmPayrollHandoff;

  const EmployeeDirectoryRosterPublishDraft({
    this.preparedBy = '',
    this.releaseNote = '',
    this.confirmPayrollHandoff = false,
  });

  bool get hasInput {
    return preparedBy.trim().isNotEmpty ||
        releaseNote.trim().isNotEmpty ||
        confirmPayrollHandoff;
  }

  EmployeeDirectoryRosterPublishDraft copyWith({
    String? preparedBy,
    String? releaseNote,
    bool? confirmPayrollHandoff,
  }) {
    return EmployeeDirectoryRosterPublishDraft(
      preparedBy: preparedBy ?? this.preparedBy,
      releaseNote: releaseNote ?? this.releaseNote,
      confirmPayrollHandoff:
          confirmPayrollHandoff ?? this.confirmPayrollHandoff,
    );
  }
}

/// Immutable employee row snapshot captured inside a roster release packet.
class EmployeeDirectoryRosterReleaseMemberSnapshot {
  final String employeeId;
  final String name;
  final String position;
  final String department;
  final String manager;
  final String location;
  final String email;
  final String phone;
  final EmployeeDirectoryStatus status;
  final DateTime joiningDate;
  final double performance;

  const EmployeeDirectoryRosterReleaseMemberSnapshot({
    required this.employeeId,
    required this.name,
    required this.position,
    required this.department,
    required this.manager,
    required this.location,
    required this.email,
    required this.phone,
    required this.status,
    required this.joiningDate,
    required this.performance,
  });

  factory EmployeeDirectoryRosterReleaseMemberSnapshot.fromMember(
    EmployeeDirectoryMember member,
  ) {
    return EmployeeDirectoryRosterReleaseMemberSnapshot(
      employeeId: member.id,
      name: member.name,
      position: member.position,
      department: member.department,
      manager: member.manager,
      location: member.location,
      email: member.email,
      phone: member.phone,
      status: member.status,
      joiningDate: member.joiningDate,
      performance: member.performance,
    );
  }

  String get statusLabel => status.label;
}

/// Immutable release packet recorded when a roster snapshot is published.
class EmployeeDirectoryRosterRelease {
  final String id;
  final String versionLabel;
  final String preparedBy;
  final String releaseNote;
  final DateTime publishedAt;
  final DateTime asOfDate;
  final int memberCount;
  final int departmentCount;
  final EmployeeDirectoryQualityGateStatus gateStatus;
  final int readinessScore;
  final String signoffId;
  final String signoffReviewer;
  final bool payrollNotified;
  final List<EmployeeDirectoryRosterReleaseMemberSnapshot> memberSnapshots;

  const EmployeeDirectoryRosterRelease({
    required this.id,
    required this.versionLabel,
    required this.preparedBy,
    required this.releaseNote,
    required this.publishedAt,
    required this.asOfDate,
    required this.memberCount,
    required this.departmentCount,
    required this.gateStatus,
    required this.readinessScore,
    required this.signoffId,
    required this.signoffReviewer,
    required this.payrollNotified,
    this.memberSnapshots = const [],
  });

  String get statusLabel => gateStatus.label;

  String get handoffLabel {
    return payrollNotified ? 'Payroll notified' : 'Payroll pending';
  }

  String get summaryLabel {
    return '$memberCount profile${memberCount == 1 ? '' : 's'}, '
        '$departmentCount department${departmentCount == 1 ? '' : 's'}, '
        '$readinessScore% readiness.';
  }
}

/// Validates whether the current directory can be published as a roster packet.
class EmployeeDirectoryRosterPublishReview {
  final EmployeeDirectoryQualityGate gate;
  final EmployeeDirectoryQualityGateSignoff? latestSignoff;
  final EmployeeDirectoryRosterPublishDraft draft;
  final List<EmployeeDirectoryRosterRelease> releases;
  final List<EmployeeDirectoryMember> members;
  final DateTime asOfDate;
  final List<String> errors;

  const EmployeeDirectoryRosterPublishReview({
    required this.gate,
    required this.latestSignoff,
    required this.draft,
    required this.releases,
    required this.members,
    required this.asOfDate,
    required this.errors,
  });

  factory EmployeeDirectoryRosterPublishReview.fromState({
    required EmployeeDirectoryQualityGate gate,
    required EmployeeDirectoryQualityGateSignoff? latestSignoff,
    required EmployeeDirectoryRosterPublishDraft draft,
    required List<EmployeeDirectoryRosterRelease> releases,
    required List<EmployeeDirectoryMember> members,
    required DateTime asOfDate,
  }) {
    final review = EmployeeDirectoryRosterPublishReview(
      gate: gate,
      latestSignoff: latestSignoff,
      draft: draft,
      releases: releases,
      members: members,
      asOfDate: asOfDate,
      errors: const [],
    );

    return EmployeeDirectoryRosterPublishReview(
      gate: gate,
      latestSignoff: latestSignoff,
      draft: draft,
      releases: releases,
      members: members,
      asOfDate: asOfDate,
      errors: _validate(review),
    );
  }

  EmployeeDirectoryRosterRelease? get latestRelease {
    return releases.isEmpty ? null : releases.first;
  }

  int get departmentCount {
    return members.map((member) => member.department).toSet().length;
  }

  int get nextSequence => releases.length + 1;

  String get nextVersionLabel => _versionFor(asOfDate, nextSequence);

  bool get canPublish => errors.isEmpty;

  String get statusLabel {
    if (gate.status == EmployeeDirectoryQualityGateStatus.blocked) {
      return 'Blocked';
    }
    if (latestSignoff == null) return 'Needs sign-off';
    return canPublish ? 'Ready' : 'Draft';
  }

  double get completionRatio {
    final checks = [
      members.isNotEmpty,
      gate.status != EmployeeDirectoryQualityGateStatus.blocked,
      latestSignoff != null,
      !_hasStaleSignoff(this),
      draft.preparedBy.trim().length >= 3,
      draft.releaseNote.trim().length >= 16,
      draft.confirmPayrollHandoff,
    ];
    return checks.where((check) => check).length / checks.length;
  }

  EmployeeDirectoryRosterRelease toRelease({
    required String id,
    required DateTime publishedAt,
  }) {
    if (!canPublish) {
      throw StateError(errors.first);
    }

    return EmployeeDirectoryRosterRelease(
      id: id,
      versionLabel: nextVersionLabel,
      preparedBy: draft.preparedBy.trim(),
      releaseNote: draft.releaseNote.trim(),
      publishedAt: publishedAt,
      asOfDate: asOfDate,
      memberCount: members.length,
      departmentCount: departmentCount,
      gateStatus: gate.status,
      readinessScore: gate.readinessScore,
      signoffId: latestSignoff!.id,
      signoffReviewer: latestSignoff!.reviewer,
      payrollNotified: draft.confirmPayrollHandoff,
      memberSnapshots:
          members
              .map(EmployeeDirectoryRosterReleaseMemberSnapshot.fromMember)
              .toList(),
    );
  }
}

List<String> _validate(EmployeeDirectoryRosterPublishReview review) {
  final errors = <String>[];
  final draft = review.draft;
  final gate = review.gate;

  if (review.members.isEmpty) {
    errors.add('No employee profiles available for publishing.');
  }
  if (gate.status == EmployeeDirectoryQualityGateStatus.blocked) {
    errors.add(
      'Resolve ${gate.blockerCount} payroll blocker'
      '${gate.blockerCount == 1 ? '' : 's'} before publishing.',
    );
  }
  if (review.latestSignoff == null) {
    errors.add('Sign off the roster gate before publishing.');
  } else if (_hasStaleSignoff(review)) {
    errors.add('Refresh roster gate sign-off before publishing.');
  }
  if (draft.preparedBy.trim().length < 3) {
    errors.add('Preparer is required.');
  }
  if (draft.releaseNote.trim().length < 16) {
    errors.add('Release note must be at least 16 characters.');
  }
  if (!draft.confirmPayrollHandoff) {
    errors.add('Confirm payroll handoff before publishing.');
  }

  return errors;
}

bool _hasStaleSignoff(EmployeeDirectoryRosterPublishReview review) {
  final signoff = review.latestSignoff;
  if (signoff == null) return false;

  return signoff.gateStatus != review.gate.status ||
      signoff.readinessScore != review.gate.readinessScore ||
      signoff.memberCount != review.members.length;
}

String _versionFor(DateTime asOfDate, int sequence) {
  final month = asOfDate.month.toString().padLeft(2, '0');
  final day = asOfDate.day.toString().padLeft(2, '0');
  final number = sequence.toString().padLeft(3, '0');
  return '${asOfDate.year}.$month.$day-$number';
}
