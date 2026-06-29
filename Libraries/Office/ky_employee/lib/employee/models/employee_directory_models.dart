enum EmployeeDirectoryStatus { active, onboarding, watchlist }

extension EmployeeDirectoryStatusLabel on EmployeeDirectoryStatus {
  String get label {
    switch (this) {
      case EmployeeDirectoryStatus.active:
        return 'Active';
      case EmployeeDirectoryStatus.onboarding:
        return 'Onboarding';
      case EmployeeDirectoryStatus.watchlist:
        return 'Watchlist';
    }
  }
}

class EmployeeDirectoryMember {
  final String id;
  final String name;
  final String position;
  final String department;
  final String avatarUrl;
  final String email;
  final String phone;
  final DateTime joiningDate;
  final double performance;
  final String location;
  final String manager;
  final EmployeeDirectoryStatus status;

  const EmployeeDirectoryMember({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.joiningDate,
    required this.performance,
    required this.location,
    required this.manager,
    required this.status,
  });

  bool get isHighPerformer => performance >= 4.6;

  EmployeeDirectoryMember copyWith({
    String? name,
    String? position,
    String? department,
    String? avatarUrl,
    String? email,
    String? phone,
    DateTime? joiningDate,
    double? performance,
    String? location,
    String? manager,
    EmployeeDirectoryStatus? status,
  }) {
    return EmployeeDirectoryMember(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      joiningDate: joiningDate ?? this.joiningDate,
      performance: performance ?? this.performance,
      location: location ?? this.location,
      manager: manager ?? this.manager,
      status: status ?? this.status,
    );
  }

  int tenureMonths(DateTime asOf) {
    final monthDelta =
        (asOf.year - joiningDate.year) * 12 + asOf.month - joiningDate.month;
    return asOf.day >= joiningDate.day ? monthDelta : monthDelta - 1;
  }

  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return name.toLowerCase().contains(normalized) ||
        position.toLowerCase().contains(normalized) ||
        department.toLowerCase().contains(normalized) ||
        location.toLowerCase().contains(normalized) ||
        manager.toLowerCase().contains(normalized);
  }
}

class EmployeeDirectorySummary {
  final int headcount;
  final int departmentCount;
  final int highPerformerCount;
  final double averagePerformance;
  final int averageTenureMonths;
  final int watchlistCount;

  const EmployeeDirectorySummary({
    required this.headcount,
    required this.departmentCount,
    required this.highPerformerCount,
    required this.averagePerformance,
    required this.averageTenureMonths,
    required this.watchlistCount,
  });

  factory EmployeeDirectorySummary.fromMembers({
    required List<EmployeeDirectoryMember> members,
    required DateTime asOfDate,
  }) {
    final averagePerformance =
        members.isEmpty
            ? 0.0
            : members
                    .map((member) => member.performance)
                    .reduce((total, performance) => total + performance) /
                members.length;

    final averageTenureMonths =
        members.isEmpty
            ? 0
            : (members
                        .map((member) => member.tenureMonths(asOfDate))
                        .reduce((total, tenure) => total + tenure) /
                    members.length)
                .round();

    return EmployeeDirectorySummary(
      headcount: members.length,
      departmentCount:
          members.map((member) => member.department).toSet().length,
      highPerformerCount:
          members.where((member) => member.isHighPerformer).length,
      averagePerformance: averagePerformance,
      averageTenureMonths: averageTenureMonths,
      watchlistCount:
          members
              .where(
                (member) => member.status == EmployeeDirectoryStatus.watchlist,
              )
              .length,
    );
  }
}

class EmployeeDirectoryRiskSummary {
  final int watchlistCount;
  final int onboardingCount;
  final int lowPerformanceCount;
  final int highPerformerCount;
  final int departmentCount;

  const EmployeeDirectoryRiskSummary({
    required this.watchlistCount,
    required this.onboardingCount,
    required this.lowPerformanceCount,
    required this.highPerformerCount,
    required this.departmentCount,
  });

  int get totalRisks => watchlistCount + onboardingCount + lowPerformanceCount;

  factory EmployeeDirectoryRiskSummary.fromMembers(
    List<EmployeeDirectoryMember> members,
  ) {
    return EmployeeDirectoryRiskSummary(
      watchlistCount:
          members
              .where(
                (member) => member.status == EmployeeDirectoryStatus.watchlist,
              )
              .length,
      onboardingCount:
          members
              .where(
                (member) => member.status == EmployeeDirectoryStatus.onboarding,
              )
              .length,
      lowPerformanceCount:
          members.where((member) => member.performance < 4.5).length,
      highPerformerCount:
          members.where((member) => member.isHighPerformer).length,
      departmentCount:
          members.map((member) => member.department).toSet().length,
    );
  }
}
