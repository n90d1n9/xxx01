import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_talent_calibration_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_talent_calibration_models.dart';
import 'employee_directory_provider.dart';

final employeeTalentCalibrationProvider = StateNotifierProvider.family<
  EmployeeTalentCalibrationNotifier,
  EmployeeTalentCalibrationProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeTalentCalibrationNotifier(null);
  }

  return EmployeeTalentCalibrationNotifier(
    buildEmployeeTalentCalibrationProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeTalentFollowUpDraftProvider = StateNotifierProvider.family<
  EmployeeTalentFollowUpDraftNotifier,
  EmployeeTalentFollowUpDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeTalentFollowUpDraftNotifier(null);
  }

  return EmployeeTalentFollowUpDraftNotifier(
    buildEmployeeTalentFollowUpDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeTalentCalibrationNotifier
    extends StateNotifier<EmployeeTalentCalibrationProfile?> {
  EmployeeTalentCalibrationNotifier(super.state);

  void setPerformanceBand(EmployeeTalentPerformanceBand value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(performanceBand: value);
  }

  void setPotentialBand(EmployeeTalentPotentialBand value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(potentialBand: value);
  }

  void setRiskLevel(EmployeeTalentRiskLevel value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(riskLevel: value);
  }

  void setDecision(EmployeeTalentCalibrationDecision value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(decision: value);
  }

  void markCalibrated() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      status: EmployeeTalentCalibrationStatus.calibrated,
      lastCalibratedDate: profile.asOfDate,
      nextReviewDate: profile.asOfDate.add(const Duration(days: 90)),
    );
  }

  void markActionDue() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(status: EmployeeTalentCalibrationStatus.actionDue);
  }

  void markDisputed() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(status: EmployeeTalentCalibrationStatus.disputed);
  }

  EmployeeTalentFollowUp addFollowUp(EmployeeTalentFollowUpDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Talent calibration profile is unavailable');
    }

    final followUp = draft.toFollowUp(id: _nextFollowUpId(profile));
    state = profile.copyWith(
      status: EmployeeTalentCalibrationStatus.actionDue,
      followUps: [followUp, ...profile.followUps],
    );
    return followUp;
  }

  void startFollowUp(String followUpId) {
    _updateFollowUp(
      followUpId,
      (followUp) =>
          followUp.copyWith(status: EmployeeTalentFollowUpStatus.inProgress),
    );
  }

  void completeFollowUp(String followUpId) {
    _updateFollowUp(
      followUpId,
      (followUp) =>
          followUp.copyWith(status: EmployeeTalentFollowUpStatus.completed),
    );
  }

  void waiveFollowUp(String followUpId) {
    _updateFollowUp(
      followUpId,
      (followUp) =>
          followUp.copyWith(status: EmployeeTalentFollowUpStatus.waived),
    );
  }

  void rescheduleFollowUp(String followUpId, DateTime dueDate) {
    _updateFollowUp(
      followUpId,
      (followUp) => followUp.copyWith(dueDate: dueDate),
    );
  }

  void removeFollowUp(String followUpId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      followUps:
          profile.followUps
              .where((followUp) => followUp.id != followUpId)
              .toList(),
    );
  }

  void _updateFollowUp(
    String followUpId,
    EmployeeTalentFollowUp Function(EmployeeTalentFollowUp followUp) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      followUps:
          profile.followUps.map((followUp) {
            if (followUp.id != followUpId) return followUp;
            return update(followUp);
          }).toList(),
    );
  }

  String _nextFollowUpId(EmployeeTalentCalibrationProfile profile) {
    return 'ETC-${profile.employeeId}-${(profile.followUps.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeTalentFollowUpDraftNotifier
    extends StateNotifier<EmployeeTalentFollowUpDraft?> {
  final EmployeeTalentFollowUpDraft? _initialDraft;

  EmployeeTalentFollowUpDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeTalentFollowUpType value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(type: value);
  }

  void setTitle(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(title: value);
  }

  void setOwner(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(owner: value);
  }

  void setDueDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      dueDate: DateTime(value.year, value.month, value.day),
    );
  }

  void setNotes(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(notes: value);
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
