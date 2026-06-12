import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/employee_management_seed_data.dart';
import '../models/employee_management_models.dart';
import 'employee_directory_provider.dart';

final employeeManagementSnapshotProvider =
    Provider.family<EmployeeManagementSnapshot?, String>((ref, employeeId) {
      final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
      final members = ref.watch(employeeDirectoryMembersProvider);

      for (final member in members) {
        if (member.id == employeeId) {
          return buildEmployeeManagementSnapshot(
            member: member,
            asOfDate: asOfDate,
          );
        }
      }

      return null;
    });

final employeeManagementSnapshotsProvider = Provider<
  List<EmployeeManagementSnapshot>
>((ref) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final members = ref.watch(filteredEmployeeDirectoryMembersProvider);

  return members
      .map(
        (member) =>
            buildEmployeeManagementSnapshot(member: member, asOfDate: asOfDate),
      )
      .toList();
});

final employeeManagementDirectorySummaryProvider =
    Provider<EmployeeManagementDirectorySummary>((ref) {
      return EmployeeManagementDirectorySummary.fromSnapshots(
        ref.watch(employeeManagementSnapshotsProvider),
      );
    });
