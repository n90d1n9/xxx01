import 'employee_directory_models.dart';

enum EmployeeDirectorySelectionSignalPriority { critical, elevated, steady }

extension EmployeeDirectorySelectionSignalPriorityLabel
    on EmployeeDirectorySelectionSignalPriority {
  String get label {
    switch (this) {
      case EmployeeDirectorySelectionSignalPriority.critical:
        return 'Critical';
      case EmployeeDirectorySelectionSignalPriority.elevated:
        return 'Elevated';
      case EmployeeDirectorySelectionSignalPriority.steady:
        return 'Steady';
    }
  }
}

class EmployeeDirectorySelectionSignal {
  final String title;
  final String detail;
  final EmployeeDirectorySelectionSignalPriority priority;

  const EmployeeDirectorySelectionSignal({
    required this.title,
    required this.detail,
    required this.priority,
  });
}

class EmployeeDirectorySelectionReview {
  final List<EmployeeDirectoryMember> members;
  final DateTime asOfDate;
  final List<EmployeeDirectorySelectionSignal> signals;

  const EmployeeDirectorySelectionReview({
    required this.members,
    required this.asOfDate,
    required this.signals,
  });

  factory EmployeeDirectorySelectionReview.fromMembers({
    required List<EmployeeDirectoryMember> members,
    required DateTime asOfDate,
  }) {
    return EmployeeDirectorySelectionReview(
      members: members,
      asOfDate: asOfDate,
      signals: _buildSignals(members),
    );
  }

  bool get hasSelection => members.isNotEmpty;

  int get selectedCount => members.length;

  int get departmentCount {
    return members.map((member) => member.department).toSet().length;
  }

  int get locationCount {
    return members.map((member) => member.location).toSet().length;
  }

  int get watchlistCount {
    return members
        .where((member) => member.status == EmployeeDirectoryStatus.watchlist)
        .length;
  }

  int get onboardingCount {
    return members
        .where((member) => member.status == EmployeeDirectoryStatus.onboarding)
        .length;
  }

  int get highPerformerCount {
    return members.where((member) => member.isHighPerformer).length;
  }

  double get averagePerformance {
    if (members.isEmpty) return 0;
    final total = members.fold<double>(
      0,
      (sum, member) => sum + member.performance,
    );
    return total / members.length;
  }

  int get averageTenureMonths {
    if (members.isEmpty) return 0;
    final total = members.fold<int>(
      0,
      (sum, member) => sum + member.tenureMonths(asOfDate),
    );
    return (total / members.length).round();
  }

  String get primaryDepartment {
    return _topValue(members.map((member) => member.department));
  }

  String get primaryLocation {
    return _topValue(members.map((member) => member.location));
  }

  String get statusMixLabel {
    if (members.isEmpty) return 'No selection';

    final statuses = members.map((member) => member.status).toSet();
    if (statuses.length == 1) return statuses.single.label;
    return 'Mixed statuses';
  }
}

List<EmployeeDirectorySelectionSignal> _buildSignals(
  List<EmployeeDirectoryMember> members,
) {
  if (members.isEmpty) {
    return const [
      EmployeeDirectorySelectionSignal(
        title: 'No cohort selected',
        detail: 'Select table rows to review the cohort before bulk changes.',
        priority: EmployeeDirectorySelectionSignalPriority.steady,
      ),
    ];
  }

  final signals = <EmployeeDirectorySelectionSignal>[];
  final departments = members.map((member) => member.department).toSet();
  final locations = members.map((member) => member.location).toSet();
  final watchlistCount =
      members
          .where((member) => member.status == EmployeeDirectoryStatus.watchlist)
          .length;
  final highPerformerCount =
      members.where((member) => member.isHighPerformer).length;

  if (watchlistCount > 0) {
    signals.add(
      EmployeeDirectorySelectionSignal(
        title: 'Watchlist included',
        detail: '$watchlistCount selected profiles need HR attention.',
        priority: EmployeeDirectorySelectionSignalPriority.elevated,
      ),
    );
  }

  if (departments.length > 1) {
    signals.add(
      EmployeeDirectorySelectionSignal(
        title: 'Mixed departments',
        detail:
            '${departments.length} departments are included in this cohort.',
        priority: EmployeeDirectorySelectionSignalPriority.steady,
      ),
    );
  }

  if (locations.length > 1) {
    signals.add(
      EmployeeDirectorySelectionSignal(
        title: 'Multi-location cohort',
        detail: '${locations.length} locations are included in this selection.',
        priority: EmployeeDirectorySelectionSignalPriority.steady,
      ),
    );
  }

  if (highPerformerCount > 0) {
    signals.add(
      EmployeeDirectorySelectionSignal(
        title: 'High performers included',
        detail: '$highPerformerCount selected profiles are high performers.',
        priority: EmployeeDirectorySelectionSignalPriority.steady,
      ),
    );
  }

  if (signals.isEmpty) {
    signals.add(
      const EmployeeDirectorySelectionSignal(
        title: 'Cohort ready',
        detail: 'Selection is consistent for governed bulk updates.',
        priority: EmployeeDirectorySelectionSignalPriority.steady,
      ),
    );
  }

  return signals;
}

String _topValue(Iterable<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isEmpty) continue;
    counts[normalized] = (counts[normalized] ?? 0) + 1;
  }

  if (counts.isEmpty) return 'None';

  final entries =
      counts.entries.toList()..sort((first, second) {
        final count = second.value.compareTo(first.value);
        if (count != 0) return count;
        return first.key.toLowerCase().compareTo(second.key.toLowerCase());
      });

  return entries.first.key;
}
