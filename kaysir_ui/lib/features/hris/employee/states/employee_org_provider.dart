import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_org_seed_data.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_org_models.dart';
import 'employee_directory_provider.dart';

final employeeOrgProfileProvider = StateNotifierProvider.family<
  EmployeeOrgProfileNotifier,
  EmployeeOrgProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final members = ref.watch(employeeDirectoryMembersProvider);
  final member = _findMember(members, employeeId);
  if (member == null) {
    return EmployeeOrgProfileNotifier(null);
  }

  return EmployeeOrgProfileNotifier(
    buildEmployeeOrgProfile(
      member: member,
      members: members,
      asOfDate: asOfDate,
    ),
  );
});

final employeeOrgRelationshipDraftProvider = StateNotifierProvider.family<
  EmployeeOrgRelationshipDraftNotifier,
  EmployeeOrgRelationshipDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeOrgRelationshipDraftNotifier(null);
  }

  return EmployeeOrgRelationshipDraftNotifier(
    buildEmployeeOrgRelationshipDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeOrgProfileNotifier extends StateNotifier<EmployeeOrgProfile?> {
  EmployeeOrgProfileNotifier(super.state);

  EmployeeOrgRelationshipRecord addDraft(EmployeeOrgRelationshipDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee organization profile is unavailable');
    }

    final relationship = draft.toRecord(id: _nextRelationshipId(profile));
    state = profile.copyWith(
      relationships: [relationship, ...profile.relationships],
    );
    return relationship;
  }

  void activateRelationship(String relationshipId) {
    final profile = state;
    if (profile == null) return;

    final activatedRelationship = _relationshipById(
      profile.relationships,
      relationshipId,
    );
    if (activatedRelationship == null || !activatedRelationship.canActivate) {
      return;
    }

    final relationships =
        profile.relationships.map((relationship) {
          if (relationship.id != relationshipId) return relationship;
          return relationship.copyWith(
            status: EmployeeOrgRelationshipStatus.active,
          );
        }).toList();

    final risks =
        activatedRelationship.type == EmployeeOrgRelationshipType.backupApprover
            ? profile.risks
                .where((risk) => risk.type != EmployeeOrgRiskType.successionGap)
                .toList()
            : profile.risks;

    state = profile.copyWith(relationships: relationships, risks: risks);
  }

  void archiveRelationship(String relationshipId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      relationships:
          profile.relationships.map((relationship) {
            if (relationship.id != relationshipId) return relationship;
            return relationship.copyWith(
              status: EmployeeOrgRelationshipStatus.archived,
            );
          }).toList(),
    );
  }

  void acknowledgeRisk(String riskId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      risks: profile.risks.where((risk) => risk.id != riskId).toList(),
    );
  }

  String _nextRelationshipId(EmployeeOrgProfile profile) {
    var index = profile.relationships.length + 1;
    while (true) {
      final id =
          'EOR-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.relationships.any((relationship) => relationship.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeOrgRelationshipDraftNotifier
    extends StateNotifier<EmployeeOrgRelationshipDraft?> {
  final EmployeeOrgRelationshipDraft? _initialDraft;

  EmployeeOrgRelationshipDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeOrgRelationshipType value) {
    state = state?.copyWith(type: value);
  }

  void setRelatedEmployeeName(String value) {
    state = state?.copyWith(relatedEmployeeName: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setReason(String value) {
    state = state?.copyWith(reason: value);
  }

  void reset() {
    state = _initialDraft;
  }
}

EmployeeOrgRelationshipRecord? _relationshipById(
  List<EmployeeOrgRelationshipRecord> relationships,
  String relationshipId,
) {
  for (final relationship in relationships) {
    if (relationship.id == relationshipId) return relationship;
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
