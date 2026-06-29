import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_benefits_seed_data.dart';
import '../models/employee_benefits_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeBenefitsProfileProvider = StateNotifierProvider.family<
  EmployeeBenefitsProfileNotifier,
  EmployeeBenefitsProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeBenefitsProfileNotifier(null);
  }

  return EmployeeBenefitsProfileNotifier(
    buildEmployeeBenefitsProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeDependentDraftProvider = StateNotifierProvider.family<
  EmployeeDependentDraftNotifier,
  EmployeeDependentDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDependentDraftNotifier(null);
  }

  return EmployeeDependentDraftNotifier(
    buildEmployeeDependentDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeBenefitsProfileNotifier
    extends StateNotifier<EmployeeBenefitsProfile?> {
  EmployeeBenefitsProfileNotifier(super.state);

  void updateEnrollmentStatus(
    String enrollmentId,
    EmployeeBenefitEnrollmentStatus status,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      enrollments:
          profile.enrollments.map((enrollment) {
            if (enrollment.id == enrollmentId) {
              return enrollment.copyWith(status: status);
            }
            return enrollment;
          }).toList(),
    );
  }

  void changeCoverageTier(
    String enrollmentId,
    EmployeeBenefitCoverageTier tier,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      enrollments:
          profile.enrollments.map((enrollment) {
            if (enrollment.id == enrollmentId) {
              return enrollment.copyWith(coverageTier: tier);
            }
            return enrollment;
          }).toList(),
    );
  }

  EmployeeDependentRecord addDependent(EmployeeDependentDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee benefits profile is unavailable');
    }

    final dependent = draft.toDependent(id: _nextDependentId(profile));
    state = profile.copyWith(dependents: [dependent, ...profile.dependents]);
    return dependent;
  }

  void verifyDependent(String dependentId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      dependents:
          profile.dependents.map((dependent) {
            if (dependent.id == dependentId) {
              return dependent.copyWith(
                verificationStatus:
                    EmployeeDependentVerificationStatus.verified,
              );
            }
            return dependent;
          }).toList(),
    );
  }

  String _nextDependentId(EmployeeBenefitsProfile profile) {
    return 'DEP-${profile.employeeId}-${(profile.dependents.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeDependentDraftNotifier
    extends StateNotifier<EmployeeDependentDraft?> {
  final EmployeeDependentDraft? _initialDraft;

  EmployeeDependentDraftNotifier(super.state) : _initialDraft = state;

  void setFullName(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(fullName: value);
  }

  void setRelationship(EmployeeDependentRelationship value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(relationship: value);
  }

  void setBirthDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      birthDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setEligibleForCoverage(bool value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(eligibleForCoverage: value);
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
