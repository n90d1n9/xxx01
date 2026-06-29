import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_directory_seed_data.dart';
import '../models/employee_directory_models.dart';

const employeeDirectoryAllDepartments = 'All departments';

final employeeDirectoryAsOfDateProvider = Provider<DateTime>(
  (ref) => DateTime(2026, 5, 30),
);

final employeeDirectorySearchQueryProvider = StateProvider<String>((ref) => '');

final employeeDirectorySelectedDepartmentProvider = StateProvider<String>(
  (ref) => employeeDirectoryAllDepartments,
);

final employeeDirectoryHighPerformerOnlyProvider = StateProvider<bool>(
  (ref) => false,
);

final employeeDirectoryMembersProvider = StateNotifierProvider<
  EmployeeDirectoryNotifier,
  List<EmployeeDirectoryMember>
>((ref) => EmployeeDirectoryNotifier(buildEmployeeDirectoryMembers()));

final employeeDirectoryDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      ref
          .watch(employeeDirectoryMembersProvider)
          .map((member) => member.department)
          .toSet()
          .toList()
        ..sort();

  return [employeeDirectoryAllDepartments, ...departments];
});

final filteredEmployeeDirectoryMembersProvider =
    Provider<List<EmployeeDirectoryMember>>((ref) {
      final query = ref.watch(employeeDirectorySearchQueryProvider);
      final selectedDepartment = ref.watch(
        employeeDirectorySelectedDepartmentProvider,
      );
      final highPerformerOnly = ref.watch(
        employeeDirectoryHighPerformerOnlyProvider,
      );

      return ref.watch(employeeDirectoryMembersProvider).where((member) {
        return member.matchesSearch(query) &&
            _matchesDepartment(member, selectedDepartment) &&
            (!highPerformerOnly || member.isHighPerformer);
      }).toList();
    });

final employeeDirectorySummaryProvider = Provider<EmployeeDirectorySummary>((
  ref,
) {
  return EmployeeDirectorySummary.fromMembers(
    members: ref.watch(filteredEmployeeDirectoryMembersProvider),
    asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
  );
});

final employeeDirectoryRiskSummaryProvider =
    Provider<EmployeeDirectoryRiskSummary>((ref) {
      return EmployeeDirectoryRiskSummary.fromMembers(
        ref.watch(filteredEmployeeDirectoryMembersProvider),
      );
    });

class EmployeeDirectoryNotifier
    extends StateNotifier<List<EmployeeDirectoryMember>> {
  EmployeeDirectoryNotifier(super.seedMembers);

  void addMember(EmployeeDirectoryMember member) {
    state = [...state, member];
  }

  void removeMember(String id) {
    state = state.where((member) => member.id != id).toList();
  }

  void updateMember(EmployeeDirectoryMember updatedMember) {
    state =
        state.map((member) {
          if (member.id == updatedMember.id) {
            return updatedMember;
          }
          return member;
        }).toList();
  }
}

bool _matchesDepartment(
  EmployeeDirectoryMember member,
  String selectedDepartment,
) {
  return selectedDepartment == employeeDirectoryAllDepartments ||
      member.department == selectedDepartment;
}
