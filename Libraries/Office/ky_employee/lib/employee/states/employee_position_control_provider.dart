import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_position_control_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_position_control_models.dart';
import 'employee_directory_provider.dart';

final employeePositionControlProvider = StateNotifierProvider.family<
  EmployeePositionControlNotifier,
  EmployeePositionControlProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePositionControlNotifier(null);
  }

  return EmployeePositionControlNotifier(
    buildEmployeePositionControlProfile(member: member, asOfDate: asOfDate),
  );
});

final employeePositionRequisitionDraftProvider = StateNotifierProvider.family<
  EmployeePositionRequisitionDraftNotifier,
  EmployeePositionRequisitionDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeePositionRequisitionDraftNotifier(null);
  }

  return EmployeePositionRequisitionDraftNotifier(
    buildEmployeePositionRequisitionDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeePositionControlNotifier
    extends StateNotifier<EmployeePositionControlProfile?> {
  EmployeePositionControlNotifier(super.state);

  EmployeePositionRequisition addRequisition(
    EmployeePositionRequisitionDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee position control profile is unavailable');
    }

    final requisition = draft.toRequisition(id: _nextRequisitionId(profile));
    state = profile.copyWith(
      requisitions: [requisition, ...profile.requisitions],
      position: profile.position.copyWith(
        status: EmployeePositionStatus.backfillPending,
      ),
    );
    return requisition;
  }

  void approveRequisition(String requisitionId) {
    _updateRequisition(
      requisitionId,
      (item) =>
          item.canApprove
              ? item.copyWith(
                status: EmployeePositionRequisitionStatus.approved,
              )
              : item,
    );
  }

  void openRequisition(String requisitionId) {
    _updateRequisition(
      requisitionId,
      (item) =>
          item.canOpen
              ? item.copyWith(status: EmployeePositionRequisitionStatus.open)
              : item,
    );
  }

  void fillRequisition(String requisitionId) {
    final profile = state;
    if (profile == null) return;

    EmployeePositionRequisition? filled;
    final requisitions =
        profile.requisitions.map((item) {
          if (item.id != requisitionId || !item.canFill) return item;
          filled = item.copyWith(
            status: EmployeePositionRequisitionStatus.filled,
          );
          return filled!;
        }).toList();

    if (filled == null) return;
    final newFilledFte = (profile.position.filledFte + filled!.requestedFte)
        .clamp(0, profile.position.approvedFte);
    state = profile.copyWith(
      requisitions: requisitions,
      position: profile.position.copyWith(
        filledFte: newFilledFte.toDouble(),
        status:
            newFilledFte >= profile.position.approvedFte
                ? EmployeePositionStatus.filled
                : EmployeePositionStatus.vacant,
      ),
    );
  }

  void cancelRequisition(String requisitionId) {
    _updateRequisition(
      requisitionId,
      (item) =>
          item.isClosed
              ? item
              : item.copyWith(
                status: EmployeePositionRequisitionStatus.cancelled,
              ),
    );
  }

  void freezePosition() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      position: profile.position.copyWith(
        status: EmployeePositionStatus.frozen,
      ),
    );
  }

  void unfreezePosition() {
    final profile = state;
    if (profile == null) return;
    final status =
        profile.position.vacantFte > 0
            ? EmployeePositionStatus.vacant
            : EmployeePositionStatus.filled;
    state = profile.copyWith(
      position: profile.position.copyWith(status: status),
    );
  }

  void clearBudgetVariance() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      position: profile.position.copyWith(
        actualMonthlyCost: profile.position.budgetedMonthlyCost,
        budgetStatus: EmployeePositionBudgetStatus.inBudget,
      ),
    );
  }

  void markBudgetWatch() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      position: profile.position.copyWith(
        budgetStatus: EmployeePositionBudgetStatus.watch,
      ),
    );
  }

  void _updateRequisition(
    String requisitionId,
    EmployeePositionRequisition Function(EmployeePositionRequisition item)
    update,
  ) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      requisitions:
          profile.requisitions.map((item) {
            if (item.id != requisitionId) return item;
            return update(item);
          }).toList(),
    );
  }

  String _nextRequisitionId(EmployeePositionControlProfile profile) {
    return 'EPC-${profile.employeeId}-${(profile.requisitions.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeePositionRequisitionDraftNotifier
    extends StateNotifier<EmployeePositionRequisitionDraft?> {
  final EmployeePositionRequisitionDraft? _initialDraft;

  EmployeePositionRequisitionDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeePositionRequisitionType value) {
    state = state?.copyWith(type: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setRequestedFte(double value) {
    state = state?.copyWith(requestedFte: value);
  }

  void setTargetStartDate(DateTime value) {
    state = state?.copyWith(
      targetStartDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setBusinessCase(String value) {
    state = state?.copyWith(businessCase: value);
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
