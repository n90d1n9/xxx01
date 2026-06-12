import 'employee_directory_roster_publish_models.dart';

/// Types of roster release changes that matter during payroll cutoff review.
enum EmployeeDirectoryRosterDiffType {
  added,
  removed,
  departmentChanged,
  managerChanged,
  statusChanged,
  roleChanged,
  locationChanged,
  contactChanged,
}

/// Human-readable labels for roster release diff categories.
extension EmployeeDirectoryRosterDiffTypeLabel
    on EmployeeDirectoryRosterDiffType {
  String get label {
    return switch (this) {
      EmployeeDirectoryRosterDiffType.added => 'Added profile',
      EmployeeDirectoryRosterDiffType.removed => 'Removed profile',
      EmployeeDirectoryRosterDiffType.departmentChanged => 'Department changed',
      EmployeeDirectoryRosterDiffType.managerChanged => 'Manager changed',
      EmployeeDirectoryRosterDiffType.statusChanged => 'Status changed',
      EmployeeDirectoryRosterDiffType.roleChanged => 'Role changed',
      EmployeeDirectoryRosterDiffType.locationChanged => 'Location changed',
      EmployeeDirectoryRosterDiffType.contactChanged => 'Contact changed',
    };
  }
}

/// One detected change between the latest and previous roster releases.
class EmployeeDirectoryRosterDiffItem {
  final String id;
  final EmployeeDirectoryRosterDiffType type;
  final String employeeId;
  final String employeeName;
  final String previousValue;
  final String currentValue;
  final bool payrollImpacting;

  const EmployeeDirectoryRosterDiffItem({
    required this.id,
    required this.type,
    required this.employeeId,
    required this.employeeName,
    required this.previousValue,
    required this.currentValue,
    required this.payrollImpacting,
  });

  String get typeLabel => type.label;

  String get summaryLabel {
    if (type == EmployeeDirectoryRosterDiffType.added) {
      return '$employeeName added to the release.';
    }
    if (type == EmployeeDirectoryRosterDiffType.removed) {
      return '$employeeName removed from the release.';
    }
    return '$previousValue -> $currentValue';
  }
}

/// Compares the latest roster release against the previous published snapshot.
class EmployeeDirectoryRosterDiffReview {
  final EmployeeDirectoryRosterRelease? latestRelease;
  final EmployeeDirectoryRosterRelease? previousRelease;
  final List<EmployeeDirectoryRosterDiffItem> items;

  const EmployeeDirectoryRosterDiffReview({
    required this.latestRelease,
    required this.previousRelease,
    required this.items,
  });

  factory EmployeeDirectoryRosterDiffReview.fromReleases(
    List<EmployeeDirectoryRosterRelease> releases,
  ) {
    if (releases.isEmpty) {
      return const EmployeeDirectoryRosterDiffReview(
        latestRelease: null,
        previousRelease: null,
        items: [],
      );
    }

    final latestRelease = releases.first;
    final previousRelease = releases.length < 2 ? null : releases[1];

    return EmployeeDirectoryRosterDiffReview(
      latestRelease: latestRelease,
      previousRelease: previousRelease,
      items:
          previousRelease == null
              ? const []
              : _diffReleases(
                latestRelease: latestRelease,
                previousRelease: previousRelease,
              ),
    );
  }

  bool get hasRelease => latestRelease != null;

  bool get hasBaseline => previousRelease != null;

  int get addedCount {
    return items
        .where((item) => item.type == EmployeeDirectoryRosterDiffType.added)
        .length;
  }

  int get removedCount {
    return items
        .where((item) => item.type == EmployeeDirectoryRosterDiffType.removed)
        .length;
  }

  int get changedCount => items.length - addedCount - removedCount;

  int get payrollImpactCount {
    return items.where((item) => item.payrollImpacting).length;
  }

  String get statusLabel {
    if (!hasRelease) return 'No release';
    if (!hasBaseline) return 'Baseline';
    if (items.isEmpty) return 'No changes';
    return 'Changes found';
  }

  String get summaryLabel {
    final latest = latestRelease;
    if (latest == null) return 'Publish a roster packet to start diff review.';
    if (previousRelease == null) {
      return '${latest.versionLabel} is the first roster release baseline.';
    }
    if (items.isEmpty) {
      return '${latest.versionLabel} matches ${previousRelease!.versionLabel}.';
    }
    return '${items.length} change${items.length == 1 ? '' : 's'} since '
        '${previousRelease!.versionLabel}.';
  }
}

List<EmployeeDirectoryRosterDiffItem> _diffReleases({
  required EmployeeDirectoryRosterRelease latestRelease,
  required EmployeeDirectoryRosterRelease previousRelease,
}) {
  final previousById = {
    for (final member in previousRelease.memberSnapshots)
      member.employeeId: member,
  };
  final latestById = {
    for (final member in latestRelease.memberSnapshots)
      member.employeeId: member,
  };
  final items = <EmployeeDirectoryRosterDiffItem>[];

  for (final member in latestRelease.memberSnapshots) {
    final previous = previousById[member.employeeId];
    if (previous == null) {
      items.add(
        EmployeeDirectoryRosterDiffItem(
          id: '${member.employeeId}-added',
          type: EmployeeDirectoryRosterDiffType.added,
          employeeId: member.employeeId,
          employeeName: member.name,
          previousValue: 'Not in ${previousRelease.versionLabel}',
          currentValue: member.department,
          payrollImpacting: true,
        ),
      );
      continue;
    }

    items.addAll(_changedFields(previous: previous, current: member));
  }

  for (final member in previousRelease.memberSnapshots) {
    if (latestById.containsKey(member.employeeId)) continue;
    items.add(
      EmployeeDirectoryRosterDiffItem(
        id: '${member.employeeId}-removed',
        type: EmployeeDirectoryRosterDiffType.removed,
        employeeId: member.employeeId,
        employeeName: member.name,
        previousValue: member.department,
        currentValue: 'Removed from ${latestRelease.versionLabel}',
        payrollImpacting: true,
      ),
    );
  }

  items.sort((first, second) {
    final nameCompare = first.employeeName.compareTo(second.employeeName);
    if (nameCompare != 0) return nameCompare;
    return first.type.index.compareTo(second.type.index);
  });
  return items;
}

List<EmployeeDirectoryRosterDiffItem> _changedFields({
  required EmployeeDirectoryRosterReleaseMemberSnapshot previous,
  required EmployeeDirectoryRosterReleaseMemberSnapshot current,
}) {
  final items = <EmployeeDirectoryRosterDiffItem>[];

  void addChange({
    required EmployeeDirectoryRosterDiffType type,
    required String field,
    required String previousValue,
    required String currentValue,
    required bool payrollImpacting,
  }) {
    if (previousValue == currentValue) return;
    items.add(
      EmployeeDirectoryRosterDiffItem(
        id: '${current.employeeId}-$field',
        type: type,
        employeeId: current.employeeId,
        employeeName: current.name,
        previousValue: previousValue,
        currentValue: currentValue,
        payrollImpacting: payrollImpacting,
      ),
    );
  }

  addChange(
    type: EmployeeDirectoryRosterDiffType.departmentChanged,
    field: 'department',
    previousValue: previous.department,
    currentValue: current.department,
    payrollImpacting: true,
  );
  addChange(
    type: EmployeeDirectoryRosterDiffType.managerChanged,
    field: 'manager',
    previousValue: previous.manager,
    currentValue: current.manager,
    payrollImpacting: false,
  );
  addChange(
    type: EmployeeDirectoryRosterDiffType.statusChanged,
    field: 'status',
    previousValue: previous.statusLabel,
    currentValue: current.statusLabel,
    payrollImpacting: true,
  );
  addChange(
    type: EmployeeDirectoryRosterDiffType.roleChanged,
    field: 'role',
    previousValue: previous.position,
    currentValue: current.position,
    payrollImpacting: true,
  );
  addChange(
    type: EmployeeDirectoryRosterDiffType.locationChanged,
    field: 'location',
    previousValue: previous.location,
    currentValue: current.location,
    payrollImpacting: false,
  );
  addChange(
    type: EmployeeDirectoryRosterDiffType.contactChanged,
    field: 'email',
    previousValue: previous.email,
    currentValue: current.email,
    payrollImpacting: false,
  );
  addChange(
    type: EmployeeDirectoryRosterDiffType.contactChanged,
    field: 'phone',
    previousValue: previous.phone,
    currentValue: current.phone,
    payrollImpacting: false,
  );

  return items;
}
