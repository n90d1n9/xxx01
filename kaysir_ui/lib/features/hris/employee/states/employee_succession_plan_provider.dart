import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_succession_plan_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_succession_plan_models.dart';
import 'employee_directory_provider.dart';

final employeeSuccessionProfileProvider = StateNotifierProvider.family<
  EmployeeSuccessionProfileNotifier,
  EmployeeSuccessionProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeSuccessionProfileNotifier(null, null, asOfDate);
  }

  return EmployeeSuccessionProfileNotifier(
    buildEmployeeSuccessionProfile(member: member, asOfDate: asOfDate),
    member,
    asOfDate,
  );
});

final employeeSuccessionCandidateDraftProvider = StateNotifierProvider.family<
  EmployeeSuccessionCandidateDraftNotifier,
  EmployeeSuccessionCandidateDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeSuccessionCandidateDraftNotifier(null);
  }

  return EmployeeSuccessionCandidateDraftNotifier(
    buildEmployeeSuccessionCandidateDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeSuccessionProfileNotifier
    extends StateNotifier<EmployeeSuccessionProfile?> {
  final EmployeeDirectoryMember? _member;
  final DateTime _asOfDate;

  EmployeeSuccessionProfileNotifier(super.state, this._member, this._asOfDate);

  void setCriticality(EmployeeSuccessionCriticality value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(criticality: value);
  }

  void setCoverageOwner(String value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(coverageOwner: value);
  }

  void setReviewDate(DateTime value) {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(reviewDate: _dateOnly(value));
  }

  void markReviewed() {
    final profile = state;
    if (profile == null) return;
    state = profile.copyWith(
      reviewDate: profile.asOfDate.add(const Duration(days: 90)),
    );
  }

  EmployeeSuccessionCandidate addCandidate(
    EmployeeSuccessionCandidateDraft draft,
  ) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee succession profile is unavailable');
    }

    final candidate = draft.toCandidate(id: _nextCandidateId(profile));
    state = profile.copyWith(candidates: [candidate, ...profile.candidates]);
    return candidate;
  }

  void updateReadiness(
    String candidateId,
    EmployeeSuccessionReadiness readiness,
  ) {
    _updateCandidate(
      candidateId,
      (candidate) => candidate.copyWith(readiness: readiness),
    );
  }

  void updateRisk(String candidateId, EmployeeSuccessionRisk risk) {
    _updateCandidate(
      candidateId,
      (candidate) => candidate.copyWith(risk: risk),
    );
  }

  void updateActionType(
    String candidateId,
    EmployeeSuccessionActionType actionType,
  ) {
    _updateCandidate(
      candidateId,
      (candidate) => candidate.copyWith(actionType: actionType),
    );
  }

  void scheduleCandidateReview(String candidateId, DateTime reviewDate) {
    _updateCandidate(
      candidateId,
      (candidate) => candidate.copyWith(reviewDate: _dateOnly(reviewDate)),
    );
  }

  void removeCandidate(String candidateId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      candidates:
          profile.candidates
              .where((candidate) => candidate.id != candidateId)
              .toList(),
    );
  }

  void resetToPreset() {
    final member = _member;
    if (member == null) return;
    state = buildEmployeeSuccessionProfile(member: member, asOfDate: _asOfDate);
  }

  void _updateCandidate(
    String candidateId,
    EmployeeSuccessionCandidate Function(EmployeeSuccessionCandidate candidate)
    update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      candidates:
          profile.candidates.map((candidate) {
            if (candidate.id != candidateId) return candidate;
            return update(candidate);
          }).toList(),
    );
  }

  String _nextCandidateId(EmployeeSuccessionProfile profile) {
    var index = profile.candidates.length + 1;
    while (true) {
      final id =
          'ESP-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.candidates.any((candidate) => candidate.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeSuccessionCandidateDraftNotifier
    extends StateNotifier<EmployeeSuccessionCandidateDraft?> {
  final EmployeeSuccessionCandidateDraft? _initialDraft;

  EmployeeSuccessionCandidateDraftNotifier(super.state) : _initialDraft = state;

  void setName(String value) {
    state = state?.copyWith(name: value);
  }

  void setCurrentRole(String value) {
    state = state?.copyWith(currentRole: value);
  }

  void setTargetRole(String value) {
    state = state?.copyWith(targetRole: value);
  }

  void setReadiness(EmployeeSuccessionReadiness value) {
    state = state?.copyWith(readiness: value);
  }

  void setRisk(EmployeeSuccessionRisk value) {
    state = state?.copyWith(risk: value);
  }

  void setActionType(EmployeeSuccessionActionType value) {
    state = state?.copyWith(actionType: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setReviewDate(DateTime value) {
    state = state?.copyWith(reviewDate: _dateOnly(value));
  }

  void setBenchScore(int value) {
    state = state?.copyWith(benchScore: value);
  }

  void setNotes(String value) {
    state = state?.copyWith(notes: value);
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
