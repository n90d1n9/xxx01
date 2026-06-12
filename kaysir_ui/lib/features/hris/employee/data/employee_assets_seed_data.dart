import '../models/employee_assets_models.dart';
import '../models/employee_directory_models.dart';

EmployeeAssetAccessProfile buildEmployeeAssetAccessProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeAssetAccessProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    assets: _assetsFor(member, asOfDate),
    accessGrants: _accessFor(member, asOfDate),
  );
}

EmployeeAssetAssignmentDraft buildEmployeeAssetAssignmentDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeAssetAssignmentDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    type: EmployeeAssetType.laptop,
    label: '',
    assetTag: '',
    owner: 'IT Operations',
  );
}

List<EmployeeAssetRecord> _assetsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  final onboarding = member.status == EmployeeDirectoryStatus.onboarding;
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;

  return [
    EmployeeAssetRecord(
      id: '${member.id}-asset-laptop',
      employeeId: member.id,
      type: EmployeeAssetType.laptop,
      label: '${member.department} laptop',
      assetTag: 'LTP-${member.id.padLeft(4, '0')}',
      owner: 'IT Operations',
      issuedAt: member.joiningDate,
      returnDueAt: watchlist ? today.add(const Duration(days: 10)) : null,
      condition:
          watchlist
              ? EmployeeAssetCondition.replacementDue
              : EmployeeAssetCondition.good,
      status:
          onboarding
              ? EmployeeAssetStatus.provisioning
              : watchlist
              ? EmployeeAssetStatus.dueReturn
              : EmployeeAssetStatus.active,
    ),
    EmployeeAssetRecord(
      id: '${member.id}-asset-badge',
      employeeId: member.id,
      type: EmployeeAssetType.badge,
      label: '${member.location} access badge',
      assetTag: 'BDG-${member.id.padLeft(4, '0')}',
      owner: 'Facilities',
      issuedAt: member.joiningDate,
      returnDueAt: watchlist ? today.add(const Duration(days: 14)) : null,
      condition: EmployeeAssetCondition.good,
      status:
          onboarding
              ? EmployeeAssetStatus.provisioning
              : EmployeeAssetStatus.active,
    ),
    if (member.department == 'Engineering' || member.isHighPerformer)
      EmployeeAssetRecord(
        id: '${member.id}-asset-monitor',
        employeeId: member.id,
        type: EmployeeAssetType.monitor,
        label: 'External monitor',
        assetTag: 'MON-${member.id.padLeft(4, '0')}',
        owner: 'IT Operations',
        issuedAt: member.joiningDate.add(const Duration(days: 7)),
        returnDueAt: null,
        condition: EmployeeAssetCondition.good,
        status: EmployeeAssetStatus.active,
      ),
  ];
}

List<EmployeeAccessGrant> _accessFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  final onboarding = member.status == EmployeeDirectoryStatus.onboarding;
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;

  return [
    EmployeeAccessGrant(
      id: '${member.id}-access-productivity',
      employeeId: member.id,
      systemName: 'Workspace suite',
      scope: EmployeeAccessScope.productivity,
      owner: 'IT Operations',
      grantedAt: member.joiningDate,
      reviewDueAt:
          onboarding
              ? today.add(const Duration(days: 3))
              : today.add(const Duration(days: 80)),
      status:
          onboarding
              ? EmployeeAccessStatus.requested
              : EmployeeAccessStatus.active,
    ),
    EmployeeAccessGrant(
      id: '${member.id}-access-hris',
      employeeId: member.id,
      systemName: 'Kaysir HRIS',
      scope: EmployeeAccessScope.hris,
      owner: 'People Operations',
      grantedAt: member.joiningDate,
      reviewDueAt:
          watchlist
              ? today.add(const Duration(days: 2))
              : today.add(const Duration(days: 120)),
      status:
          watchlist
              ? EmployeeAccessStatus.reviewDue
              : EmployeeAccessStatus.active,
    ),
    if (member.department == 'Engineering')
      EmployeeAccessGrant(
        id: '${member.id}-access-repo',
        employeeId: member.id,
        systemName: 'Source repository',
        scope: EmployeeAccessScope.engineering,
        owner: 'Engineering Operations',
        grantedAt: member.joiningDate.add(const Duration(days: 1)),
        reviewDueAt: today.add(const Duration(days: 45)),
        status: EmployeeAccessStatus.active,
      ),
    if (member.department == 'Product')
      EmployeeAccessGrant(
        id: '${member.id}-access-roadmap',
        employeeId: member.id,
        systemName: 'Roadmap analytics',
        scope: EmployeeAccessScope.admin,
        owner: 'Product Operations',
        grantedAt: member.joiningDate.add(const Duration(days: 1)),
        reviewDueAt: today.subtract(const Duration(days: 1)),
        status: EmployeeAccessStatus.reviewDue,
      ),
  ];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
