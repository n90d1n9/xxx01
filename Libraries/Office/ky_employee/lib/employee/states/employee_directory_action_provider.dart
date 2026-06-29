import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_directory_action_models.dart';
import 'employee_directory_provider.dart';
import 'employee_directory_table_provider.dart';

final employeeDirectoryActionOverridesProvider = StateNotifierProvider<
  EmployeeDirectoryActionQueueNotifier,
  Map<String, EmployeeDirectoryActionOverride>
>((ref) => EmployeeDirectoryActionQueueNotifier());

final employeeDirectoryActionQueueProvider =
    Provider<List<EmployeeDirectoryActionItem>>((ref) {
      final actions = buildEmployeeDirectoryActions(
        members: ref.watch(employeeDirectoryTableViewProvider).rows,
        asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
      );
      final overrides = ref.watch(employeeDirectoryActionOverridesProvider);

      return actions
          .map((action) => action.applyOverride(overrides[action.id]))
          .toList()
        ..sort(compareEmployeeDirectoryActions);
    });

final employeeDirectoryActionQueueSummaryProvider =
    Provider<EmployeeDirectoryActionQueueSummary>((ref) {
      return EmployeeDirectoryActionQueueSummary.fromActions(
        actions: ref.watch(employeeDirectoryActionQueueProvider),
        asOfDate: ref.watch(employeeDirectoryAsOfDateProvider),
      );
    });

class EmployeeDirectoryActionQueueNotifier
    extends StateNotifier<Map<String, EmployeeDirectoryActionOverride>> {
  EmployeeDirectoryActionQueueNotifier() : super(const {});

  void assign(EmployeeDirectoryActionItem action, String owner) {
    _upsert(
      action,
      owner: owner,
      status: EmployeeDirectoryActionStatus.inProgress,
    );
  }

  void start(EmployeeDirectoryActionItem action) {
    _upsert(action, status: EmployeeDirectoryActionStatus.inProgress);
  }

  void resolve(EmployeeDirectoryActionItem action) {
    _upsert(action, status: EmployeeDirectoryActionStatus.resolved);
  }

  void snooze(EmployeeDirectoryActionItem action) {
    _upsert(
      action,
      status: EmployeeDirectoryActionStatus.snoozed,
      dueDate: action.dueDate.add(const Duration(days: 3)),
    );
  }

  void _upsert(
    EmployeeDirectoryActionItem action, {
    EmployeeDirectoryActionStatus? status,
    String? owner,
    DateTime? dueDate,
  }) {
    final current = state[action.id] ?? const EmployeeDirectoryActionOverride();
    state = {
      ...state,
      action.id: current.copyWith(
        status: status,
        owner: owner,
        dueDate: dueDate,
      ),
    };
  }
}
