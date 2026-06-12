import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/employee_assets_seed_data.dart';
import '../models/employee_assets_models.dart';
import '../models/employee_directory_models.dart';
import 'employee_directory_provider.dart';

final employeeAssetAccessProfileProvider = StateNotifierProvider.family<
  EmployeeAssetAccessProfileNotifier,
  EmployeeAssetAccessProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAssetAccessProfileNotifier(null);
  }

  return EmployeeAssetAccessProfileNotifier(
    buildEmployeeAssetAccessProfile(member: member, asOfDate: asOfDate),
  );
});

final employeeAssetAssignmentDraftProvider = StateNotifierProvider.family<
  EmployeeAssetAssignmentDraftNotifier,
  EmployeeAssetAssignmentDraft?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeAssetAssignmentDraftNotifier(null);
  }

  return EmployeeAssetAssignmentDraftNotifier(
    buildEmployeeAssetAssignmentDraft(member: member, asOfDate: asOfDate),
  );
});

class EmployeeAssetAccessProfileNotifier
    extends StateNotifier<EmployeeAssetAccessProfile?> {
  EmployeeAssetAccessProfileNotifier(super.state);

  EmployeeAssetRecord addAsset(EmployeeAssetAssignmentDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee asset profile is unavailable');
    }

    final asset = draft.toAsset(id: _nextAssetId(profile));
    state = profile.copyWith(assets: [asset, ...profile.assets]);
    return asset;
  }

  void updateAssetStatus(String assetId, EmployeeAssetStatus status) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      assets:
          profile.assets.map((asset) {
            if (asset.id == assetId) {
              return asset.copyWith(status: status);
            }
            return asset;
          }).toList(),
    );
  }

  void markAssetReturned(String assetId) {
    updateAssetStatus(assetId, EmployeeAssetStatus.returned);
  }

  void completeProvisioning(String assetId) {
    updateAssetStatus(assetId, EmployeeAssetStatus.active);
  }

  void updateAccessStatus(String grantId, EmployeeAccessStatus status) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      accessGrants:
          profile.accessGrants.map((grant) {
            if (grant.id == grantId) {
              return grant.copyWith(status: status);
            }
            return grant;
          }).toList(),
    );
  }

  void approveAccess(String grantId) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      accessGrants:
          profile.accessGrants.map((grant) {
            if (grant.id == grantId) {
              return grant.copyWith(
                reviewDueAt: profile.asOfDate.add(const Duration(days: 90)),
                status: EmployeeAccessStatus.active,
              );
            }
            return grant;
          }).toList(),
    );
  }

  void revokeAccess(String grantId) {
    updateAccessStatus(grantId, EmployeeAccessStatus.revoked);
  }

  String _nextAssetId(EmployeeAssetAccessProfile profile) {
    return 'AST-${profile.employeeId}-${(profile.assets.length + 1).toString().padLeft(3, '0')}';
  }
}

class EmployeeAssetAssignmentDraftNotifier
    extends StateNotifier<EmployeeAssetAssignmentDraft?> {
  final EmployeeAssetAssignmentDraft? _initialDraft;

  EmployeeAssetAssignmentDraftNotifier(super.state) : _initialDraft = state;

  void setType(EmployeeAssetType value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(type: value);
  }

  void setLabel(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(label: value);
  }

  void setAssetTag(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(assetTag: value);
  }

  void setOwner(String value) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(owner: value);
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
