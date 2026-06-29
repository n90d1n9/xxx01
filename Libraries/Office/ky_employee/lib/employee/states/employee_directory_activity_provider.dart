import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_activity_models.dart';
import '../models/employee_directory_models.dart';

final employeeDirectoryActivityProvider = StateNotifierProvider<
  EmployeeDirectoryActivityNotifier,
  List<EmployeeDirectoryActivityEvent>
>((ref) => EmployeeDirectoryActivityNotifier());

final employeeDirectoryRecentActivityProvider =
    Provider<List<EmployeeDirectoryActivityEvent>>((ref) {
      return ref.watch(employeeDirectoryActivityProvider).take(5).toList();
    });

final employeeDirectoryActivitySummaryProvider =
    Provider<EmployeeDirectoryActivitySummary>((ref) {
      return EmployeeDirectoryActivitySummary.fromEvents(
        ref.watch(employeeDirectoryActivityProvider),
      );
    });

class EmployeeDirectoryActivityNotifier
    extends StateNotifier<List<EmployeeDirectoryActivityEvent>> {
  EmployeeDirectoryActivityNotifier() : super(const []);

  var _sequence = 0;

  void recordCreated(EmployeeDirectoryMember member) {
    _add(
      type: EmployeeDirectoryActivityType.created,
      title: '${member.name} created',
      detail:
          '${member.position} profile added to ${member.department} with ${member.status.label} status.',
      affectedCount: 1,
      employeeId: member.id,
      employeeName: member.name,
    );
  }

  void recordUpdated({
    required EmployeeDirectoryMember before,
    required EmployeeDirectoryMember after,
  }) {
    final changes = _changedFieldLabels(before: before, after: after);
    _add(
      type: EmployeeDirectoryActivityType.updated,
      title: '${after.name} updated',
      detail:
          changes.isEmpty
              ? '${after.name} reviewed without profile field changes.'
              : '${after.name} updated ${changes.join(', ')}.',
      affectedCount: 1,
      employeeId: after.id,
      employeeName: after.name,
    );
  }

  void recordRemoved(EmployeeDirectoryMember member) {
    _add(
      type: EmployeeDirectoryActivityType.removed,
      title: '${member.name} removed',
      detail: '${member.name} was removed from the directory workspace.',
      affectedCount: 1,
      employeeId: member.id,
      employeeName: member.name,
    );
  }

  void recordRemovedMany(List<EmployeeDirectoryMember> members) {
    if (members.isEmpty) return;
    _add(
      type: EmployeeDirectoryActivityType.removed,
      title: '${members.length} profiles removed',
      detail:
          '${members.length} selected employee profiles were removed from the directory workspace.',
      affectedCount: members.length,
    );
  }

  void recordBulkStatusChanged({
    required List<EmployeeDirectoryMember> members,
    required EmployeeDirectoryStatus status,
  }) {
    if (members.isEmpty) return;
    _add(
      type: EmployeeDirectoryActivityType.bulkStatusChanged,
      title: '${members.length} statuses changed',
      detail:
          '${members.length} selected employee profiles were marked ${status.label}.',
      affectedCount: members.length,
    );
  }

  void recordBulkProfileUpdated({
    required List<EmployeeDirectoryMember> members,
    required List<String> changedFields,
    required String auditNote,
  }) {
    if (members.isEmpty || changedFields.isEmpty) return;
    _add(
      type: EmployeeDirectoryActivityType.bulkProfileUpdated,
      title: '${_profiles(members.length)} updated',
      detail:
          '${_profiles(members.length)} had ${changedFields.join(', ')} updated. Note: ${auditNote.trim()}',
      affectedCount: members.length,
    );
  }

  void recordExported(int rowCount) {
    if (rowCount <= 0) return;
    _add(
      type: EmployeeDirectoryActivityType.exported,
      title: '$rowCount rows exported',
      detail: '$rowCount employee rows were prepared as CSV.',
      affectedCount: rowCount,
    );
  }

  void recordImported(int rowCount) {
    if (rowCount <= 0) return;
    _add(
      type: EmployeeDirectoryActivityType.imported,
      title: '${_rows(rowCount)} imported',
      detail: '${_profiles(rowCount)} were imported from CSV.',
      affectedCount: rowCount,
    );
  }

  void recordActionUpdated({
    required String title,
    required String detail,
    required int affectedCount,
  }) {
    _add(
      type: EmployeeDirectoryActivityType.actionUpdated,
      title: title,
      detail: detail,
      affectedCount: affectedCount,
    );
  }

  void _add({
    required EmployeeDirectoryActivityType type,
    required String title,
    required String detail,
    required int affectedCount,
    String? employeeId,
    String? employeeName,
  }) {
    _sequence += 1;
    final event = EmployeeDirectoryActivityEvent(
      id: 'employee-directory-activity-$_sequence',
      type: type,
      title: title,
      detail: detail,
      actor: 'HR admin',
      occurredAt: DateTime.now(),
      affectedCount: affectedCount,
      employeeId: employeeId,
      employeeName: employeeName,
    );
    state = [event, ...state].take(25).toList();
  }
}

String _rows(int count) {
  return count == 1 ? '1 row' : '$count rows';
}

String _profiles(int count) {
  return count == 1 ? '1 employee profile' : '$count employee profiles';
}

List<String> _changedFieldLabels({
  required EmployeeDirectoryMember before,
  required EmployeeDirectoryMember after,
}) {
  final fields = <String>[];

  if (before.name != after.name) fields.add('name');
  if (before.position != after.position) fields.add('position');
  if (before.department != after.department) fields.add('department');
  if (before.email != after.email) fields.add('email');
  if (before.phone != after.phone) fields.add('phone');
  if (before.joiningDate != after.joiningDate) fields.add('joining date');
  if (before.performance != after.performance) fields.add('rating');
  if (before.location != after.location) fields.add('location');
  if (before.manager != after.manager) fields.add('manager');
  if (before.status != after.status) fields.add('status');

  return fields;
}
