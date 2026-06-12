import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_skill_inventory_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_skill_inventory_models.dart';
import 'employee_directory_provider.dart';

final employeeSkillInventoryProvider = StateNotifierProvider.family<
  EmployeeSkillInventoryNotifier,
  EmployeeSkillInventoryProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeSkillInventoryNotifier(null);
  }

  return EmployeeSkillInventoryNotifier(
    buildEmployeeSkillInventoryProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeSkillEvidenceDraftProvider = StateNotifierProvider.family<
  EmployeeSkillEvidenceDraftNotifier,
  EmployeeSkillEvidenceDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeSkillEvidenceDraftNotifier(null);
  }

  return EmployeeSkillEvidenceDraftNotifier(
    buildEmployeeSkillEvidenceDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeSkillInventoryNotifier
    extends StateNotifier<EmployeeSkillInventoryProfile?> {
  EmployeeSkillInventoryNotifier(super.state);

  EmployeeSkillRecord addEvidence(EmployeeSkillEvidenceDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee skill inventory is unavailable');
    }

    final incoming = draft.toRecord(id: _nextRecordId(profile));
    final existingIndex = profile.records.indexWhere(
      (record) =>
          record.skillName.trim().toLowerCase() ==
          incoming.skillName.trim().toLowerCase(),
    );

    if (existingIndex == -1) {
      state = profile.copyWith(records: [incoming, ...profile.records]);
      return incoming;
    }

    final existing = profile.records[existingIndex];
    final updated = existing.copyWith(
      owner: incoming.owner,
      currentLevel: incoming.currentLevel,
      requiredLevel: incoming.requiredLevel,
      criticality: incoming.criticality,
      status: EmployeeSkillVerificationStatus.inReview,
      nextReviewDate: incoming.nextReviewDate,
      evidenceCount: existing.evidenceCount + 1,
      evidenceSummary: incoming.evidenceSummary,
    );
    final records = [...profile.records];
    records[existingIndex] = updated;
    state = profile.copyWith(records: records);
    return updated;
  }

  void verifySkill(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return record.copyWith(
              status: EmployeeSkillVerificationStatus.verified,
              lastVerifiedDate: profile.asOfDate,
              nextReviewDate: profile.asOfDate.add(const Duration(days: 180)),
              evidenceCount:
                  record.evidenceCount == 0 ? 1 : record.evidenceCount,
            );
          }).toList(),
    );
  }

  void requestEvidence(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return record.copyWith(
              status: EmployeeSkillVerificationStatus.evidenceDue,
              nextReviewDate: profile.asOfDate.add(const Duration(days: 7)),
            );
          }).toList(),
    );
  }

  void expireSkill(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return record.copyWith(
              status: EmployeeSkillVerificationStatus.expired,
              nextReviewDate: profile.asOfDate,
            );
          }).toList(),
    );
  }

  void waiveSkill(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return record.copyWith(
              status: EmployeeSkillVerificationStatus.waived,
            );
          }).toList(),
    );
  }

  void updateObservedLevel(String recordId, int level) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.map((record) {
            if (record.id != recordId) return record;
            return record.copyWith(currentLevel: level);
          }).toList(),
    );
  }

  void removeRecord(String recordId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      records:
          profile.records.where((record) => record.id != recordId).toList(),
    );
  }

  String _nextRecordId(EmployeeSkillInventoryProfile profile) {
    return 'ESI-${profile.employeeId}-${(profile.records.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeSkillEvidenceDraftNotifier
    extends StateNotifier<EmployeeSkillEvidenceDraft?> {
  final EmployeeSkillEvidenceDraft? _initialDraft;

  EmployeeSkillEvidenceDraftNotifier(super.state) : _initialDraft = state;

  void setSkillName(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(skillName: value);
  }

  void setCategory(EmployeeSkillInventoryCategory value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(category: value);
  }

  void setEvidenceType(EmployeeSkillEvidenceType value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(evidenceType: value);
  }

  void setVerifier(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(verifier: value);
  }

  void setEvidenceSummary(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(evidenceSummary: value);
  }

  void setObservedLevel(int value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(observedLevel: value);
  }

  void setRequiredLevel(int value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(requiredLevel: value);
  }

  void setCriticality(EmployeeSkillCriticality value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(criticality: value);
  }

  void setNextReviewDate(DateTime value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      nextReviewDate: DateTime(value.year, value.month, value.day),
    );
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
