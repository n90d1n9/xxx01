import '../models/employee_directory_models.dart';
import '../models/employee_org_models.dart';

EmployeeOrgProfile buildEmployeeOrgProfile({
  required EmployeeDirectoryMember member,
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final managerMember = _memberByName(members, member.manager);
  final directReports =
      members
          .where((item) => item.manager == member.name && item.id != member.id)
          .map(_personFromMember)
          .toList();
  final relationships = _relationshipsFor(member, today);

  return EmployeeOrgProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    manager: managerMember == null ? null : _personFromMember(managerMember),
    chain: _chainFor(member, members),
    peers:
        members
            .where(
              (item) => item.manager == member.manager && item.id != member.id,
            )
            .map(_personFromMember)
            .toList(),
    directReports: directReports,
    relationships: relationships,
    risks: _risksFor(
      member: member,
      managerMember: managerMember,
      directReports:
          members
              .where(
                (item) => item.manager == member.name && item.id != member.id,
              )
              .toList(),
      relationships: relationships,
    ),
  );
}

EmployeeOrgRelationshipDraft buildEmployeeOrgRelationshipDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeOrgRelationshipDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    type: EmployeeOrgRelationshipType.dottedLineManager,
    relatedEmployeeName: '',
    owner: member.manager,
    reason: '',
  );
}

List<EmployeeOrgRelationshipRecord> _relationshipsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeOrgRelationshipRecord(
        id: 'EOR-${member.id}-001',
        employeeId: member.id,
        type: EmployeeOrgRelationshipType.dottedLineManager,
        relatedEmployeeName: 'Emma Rodriguez',
        owner: 'HR Business Partner',
        createdAt: today.subtract(const Duration(days: 2)),
        status: EmployeeOrgRelationshipStatus.pending,
        reason: 'Add HR dotted-line coverage during performance support.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeOrgRelationshipRecord(
        id: 'EOR-${member.id}-001',
        employeeId: member.id,
        type: EmployeeOrgRelationshipType.buddy,
        relatedEmployeeName: 'Sarah Johnson',
        owner: member.manager,
        createdAt: today.subtract(const Duration(days: 1)),
        status: EmployeeOrgRelationshipStatus.pending,
        reason: 'Assign onboarding buddy for first-month support.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeOrgRelationshipRecord(
        id: 'EOR-${member.id}-001',
        employeeId: member.id,
        type: EmployeeOrgRelationshipType.backupApprover,
        relatedEmployeeName: member.manager,
        owner: 'People Operations',
        createdAt: today.subtract(const Duration(days: 21)),
        status: EmployeeOrgRelationshipStatus.active,
        reason: 'Maintain approval coverage for high-impact employee work.',
      ),
    ];
  }

  return const [];
}

List<EmployeeOrgRiskSignal> _risksFor({
  required EmployeeDirectoryMember member,
  required EmployeeDirectoryMember? managerMember,
  required List<EmployeeDirectoryMember> directReports,
  required List<EmployeeOrgRelationshipRecord> relationships,
}) {
  final risks = <EmployeeOrgRiskSignal>[];

  if (managerMember != null && managerMember.manager == member.name) {
    risks.add(
      EmployeeOrgRiskSignal(
        id: 'EORISK-${member.id}-loop',
        type: EmployeeOrgRiskType.reportingLoop,
        title: 'Reporting loop detected',
        detail:
            '${member.name} and ${managerMember.name} reference each other as manager.',
      ),
    );
  }

  if (directReports.length >= 2) {
    risks.add(
      EmployeeOrgRiskSignal(
        id: 'EORISK-${member.id}-span',
        type: EmployeeOrgRiskType.managerSpan,
        title: 'Manager span needs review',
        detail:
            '${member.name} has ${directReports.length} direct reports in this workspace.',
      ),
    );
  }

  final watchlistReports =
      directReports
          .where((item) => item.status == EmployeeDirectoryStatus.watchlist)
          .toList();
  if (watchlistReports.isNotEmpty) {
    risks.add(
      EmployeeOrgRiskSignal(
        id: 'EORISK-${member.id}-watchlist',
        type: EmployeeOrgRiskType.watchlistReport,
        title: 'Watchlist direct report',
        detail: '${watchlistReports.first.name} needs manager follow-up.',
      ),
    );
  }

  final hasActiveBackup = relationships.any(
    (relationship) =>
        relationship.type == EmployeeOrgRelationshipType.backupApprover &&
        relationship.isActive,
  );
  if (directReports.isNotEmpty && !hasActiveBackup) {
    risks.add(
      EmployeeOrgRiskSignal(
        id: 'EORISK-${member.id}-backup',
        type: EmployeeOrgRiskType.successionGap,
        title: 'Backup approver gap',
        detail:
            'No active backup approver is configured for this reporting group.',
      ),
    );
  }

  return risks;
}

List<EmployeeOrgPerson> _chainFor(
  EmployeeDirectoryMember member,
  List<EmployeeDirectoryMember> members,
) {
  final chain = <EmployeeOrgPerson>[];
  final visitedNames = <String>{member.name};
  var managerName = member.manager;

  for (var depth = 0; depth < 3; depth++) {
    final manager = _memberByName(members, managerName);
    if (manager == null || visitedNames.contains(manager.name)) break;
    chain.add(_personFromMember(manager));
    visitedNames.add(manager.name);
    managerName = manager.manager;
  }

  return chain;
}

EmployeeOrgPerson _personFromMember(EmployeeDirectoryMember member) {
  return EmployeeOrgPerson(
    id: member.id,
    name: member.name,
    position: member.position,
    department: member.department,
    location: member.location,
    performance: member.performance,
    watchlist: member.status == EmployeeDirectoryStatus.watchlist,
  );
}

EmployeeDirectoryMember? _memberByName(
  List<EmployeeDirectoryMember> members,
  String name,
) {
  for (final member in members) {
    if (member.name == name) return member;
  }
  return null;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
