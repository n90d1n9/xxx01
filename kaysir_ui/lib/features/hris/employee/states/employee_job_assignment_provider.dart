import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_job_assignment_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_job_assignment_models.dart';
import 'employee_directory_provider.dart';

final employeeJobAssignmentProfileProvider = StateNotifierProvider.family<
  EmployeeJobAssignmentProfileNotifier,
  EmployeeJobAssignmentProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeJobAssignmentProfileNotifier(null);
  }

  return EmployeeJobAssignmentProfileNotifier(
    buildEmployeeJobAssignmentProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeJobAssignmentDraftProvider = StateNotifierProvider.family<
  EmployeeJobAssignmentDraftNotifier,
  EmployeeJobAssignmentDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeJobAssignmentDraftNotifier(null);
  }

  return EmployeeJobAssignmentDraftNotifier(
    buildEmployeeJobAssignmentDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeJobAssignmentProfileNotifier
    extends StateNotifier<EmployeeJobAssignmentProfile?> {
  EmployeeJobAssignmentProfileNotifier(super.state);

  EmployeeJobAssignmentRecord addDraft(EmployeeJobAssignmentDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee job assignment profile is unavailable');
    }

    final assignment = draft.toRecord(id: _nextAssignmentId(profile));
    state = profile.copyWith(assignments: [assignment, ...profile.assignments]);
    return assignment;
  }

  void approve(String assignmentId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      assignments:
          profile.assignments.map((assignment) {
            if (!assignment.canApprove || assignment.id != assignmentId) {
              return assignment;
            }
            return assignment.copyWith(
              status: EmployeeJobAssignmentStatus.scheduled,
            );
          }).toList(),
    );
  }

  void activate(String assignmentId) {
    final profile = state;
    if (profile == null) return;

    final target = _assignmentById(profile.assignments, assignmentId);
    if (target == null || !target.canActivate(profile.asOfDate)) return;

    final previousEndDate = target.startDate.subtract(const Duration(days: 1));
    state = profile.copyWith(
      assignments:
          profile.assignments.map((assignment) {
            if (assignment.id == assignmentId) {
              return assignment.copyWith(
                status: EmployeeJobAssignmentStatus.active,
              );
            }
            if (assignment.isActiveOn(profile.asOfDate)) {
              return assignment.copyWith(
                endDate: previousEndDate,
                status: EmployeeJobAssignmentStatus.completed,
              );
            }
            return assignment;
          }).toList(),
    );
  }

  void complete(String assignmentId, DateTime endDate) {
    final profile = state;
    if (profile == null) return;
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    state = profile.copyWith(
      assignments:
          profile.assignments.map((assignment) {
            if (assignment.id != assignmentId) return assignment;
            return assignment.copyWith(
              endDate: normalizedEndDate,
              status: EmployeeJobAssignmentStatus.completed,
            );
          }).toList(),
    );
  }

  String _nextAssignmentId(EmployeeJobAssignmentProfile profile) {
    var index = profile.assignments.length + 1;
    while (true) {
      final id =
          'EJA-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.assignments.any((assignment) => assignment.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeJobAssignmentDraftNotifier
    extends StateNotifier<EmployeeJobAssignmentDraft?> {
  final EmployeeJobAssignmentDraft? _initialDraft;

  EmployeeJobAssignmentDraftNotifier(super.state) : _initialDraft = state;

  void setPosition(String value) {
    state = state?.copyWith(position: value);
  }

  void setDepartment(String value) {
    state = state?.copyWith(department: value);
  }

  void setManager(String value) {
    state = state?.copyWith(manager: value);
  }

  void setLocation(String value) {
    state = state?.copyWith(location: value);
  }

  void setCostCenter(String value) {
    state = state?.copyWith(costCenter: value);
  }

  void setGrade(String value) {
    state = state?.copyWith(grade: value);
  }

  void setContractType(EmployeeEmploymentContractType value) {
    state = state?.copyWith(contractType: value);
  }

  void setArrangement(EmployeeWorkArrangement value) {
    state = state?.copyWith(arrangement: value);
  }

  void setAssignmentType(EmployeeJobAssignmentType value) {
    state = state?.copyWith(assignmentType: value);
  }

  void setStartDate(DateTime value) {
    state = state?.copyWith(
      startDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setNotes(String value) {
    state = state?.copyWith(notes: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeJobAssignmentRecord? _assignmentById(
  List<EmployeeJobAssignmentRecord> assignments,
  String assignmentId,
) {
  for (final assignment in assignments) {
    if (assignment.id == assignmentId) return assignment;
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
