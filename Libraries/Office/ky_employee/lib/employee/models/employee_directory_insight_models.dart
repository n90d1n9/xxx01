import 'employee_directory_models.dart';

enum EmployeeDirectoryInsightPriority { critical, elevated, steady }

extension EmployeeDirectoryInsightPriorityLabel
    on EmployeeDirectoryInsightPriority {
  String get label {
    return switch (this) {
      EmployeeDirectoryInsightPriority.critical => 'Critical',
      EmployeeDirectoryInsightPriority.elevated => 'Elevated',
      EmployeeDirectoryInsightPriority.steady => 'Steady',
    };
  }
}

class EmployeeDirectoryManagerLoad {
  final String manager;
  final int directReportCount;

  const EmployeeDirectoryManagerLoad({
    required this.manager,
    required this.directReportCount,
  });
}

class EmployeeDirectoryInsightAction {
  final String title;
  final String detail;
  final EmployeeDirectoryInsightPriority priority;
  final int affectedCount;

  const EmployeeDirectoryInsightAction({
    required this.title,
    required this.detail,
    required this.priority,
    required this.affectedCount,
  });
}

class EmployeeDirectoryInsights {
  static const lowPerformanceThreshold = 4.5;
  static const managerLoadThreshold = 2;

  final int visibleCount;
  final int attentionProfileCount;
  final int onboardingCount;
  final int watchlistCount;
  final int lowPerformanceCount;
  final int locationCount;
  final int averageTenureMonths;
  final String topAttentionDepartment;
  final List<EmployeeDirectoryManagerLoad> managerLoads;
  final List<EmployeeDirectoryInsightAction> actions;

  const EmployeeDirectoryInsights({
    required this.visibleCount,
    required this.attentionProfileCount,
    required this.onboardingCount,
    required this.watchlistCount,
    required this.lowPerformanceCount,
    required this.locationCount,
    required this.averageTenureMonths,
    required this.topAttentionDepartment,
    required this.managerLoads,
    required this.actions,
  });

  int get healthScore {
    if (visibleCount == 0) return 0;
    return (((visibleCount - attentionProfileCount) / visibleCount) * 100)
        .round();
  }

  int get managerLoadAlertCount => managerLoads.length;

  String get healthLabel {
    if (visibleCount == 0) return 'No population';
    if (healthScore >= 80) return 'Healthy';
    if (healthScore >= 60) return 'Watch';
    return 'Needs focus';
  }

  factory EmployeeDirectoryInsights.fromMembers({
    required List<EmployeeDirectoryMember> members,
    required DateTime asOfDate,
  }) {
    final attentionIds = <String>{};
    final departmentRiskScores = <String, int>{};
    var onboardingCount = 0;
    var watchlistCount = 0;
    var lowPerformanceCount = 0;

    for (final member in members) {
      var memberRiskScore = 0;

      if (member.status == EmployeeDirectoryStatus.onboarding) {
        onboardingCount++;
        memberRiskScore++;
      }
      if (member.status == EmployeeDirectoryStatus.watchlist) {
        watchlistCount++;
        memberRiskScore++;
      }
      if (member.performance < lowPerformanceThreshold) {
        lowPerformanceCount++;
        memberRiskScore++;
      }

      if (memberRiskScore > 0) {
        attentionIds.add(member.id);
        departmentRiskScores.update(
          member.department,
          (score) => score + memberRiskScore,
          ifAbsent: () => memberRiskScore,
        );
      }
    }

    final managerLoads = _managerLoadsFor(members);
    final averageTenureMonths =
        members.isEmpty
            ? 0
            : (members
                        .map((member) => member.tenureMonths(asOfDate))
                        .reduce((total, tenure) => total + tenure) /
                    members.length)
                .round();

    return EmployeeDirectoryInsights(
      visibleCount: members.length,
      attentionProfileCount: attentionIds.length,
      onboardingCount: onboardingCount,
      watchlistCount: watchlistCount,
      lowPerformanceCount: lowPerformanceCount,
      locationCount: members.map((member) => member.location).toSet().length,
      averageTenureMonths: averageTenureMonths,
      topAttentionDepartment: _topAttentionDepartment(departmentRiskScores),
      managerLoads: managerLoads,
      actions: _actionsFor(
        visibleCount: members.length,
        watchlistCount: watchlistCount,
        onboardingCount: onboardingCount,
        lowPerformanceCount: lowPerformanceCount,
        managerLoads: managerLoads,
      ),
    );
  }

  static List<EmployeeDirectoryManagerLoad> _managerLoadsFor(
    List<EmployeeDirectoryMember> members,
  ) {
    final spans = <String, int>{};
    for (final member in members) {
      spans.update(member.manager, (count) => count + 1, ifAbsent: () => 1);
    }

    final loads =
        spans.entries
            .where((entry) => entry.value >= managerLoadThreshold)
            .map(
              (entry) => EmployeeDirectoryManagerLoad(
                manager: entry.key,
                directReportCount: entry.value,
              ),
            )
            .toList();

    loads.sort((first, second) {
      final countCompare = second.directReportCount.compareTo(
        first.directReportCount,
      );
      return countCompare == 0
          ? first.manager.compareTo(second.manager)
          : countCompare;
    });
    return loads;
  }

  static String _topAttentionDepartment(Map<String, int> departmentRiskScores) {
    if (departmentRiskScores.isEmpty) return 'No department';

    final departments = departmentRiskScores.entries.toList();
    departments.sort((first, second) {
      final scoreCompare = second.value.compareTo(first.value);
      return scoreCompare == 0 ? first.key.compareTo(second.key) : scoreCompare;
    });
    return departments.first.key;
  }

  static List<EmployeeDirectoryInsightAction> _actionsFor({
    required int visibleCount,
    required int watchlistCount,
    required int onboardingCount,
    required int lowPerformanceCount,
    required List<EmployeeDirectoryManagerLoad> managerLoads,
  }) {
    if (visibleCount == 0) {
      return const [
        EmployeeDirectoryInsightAction(
          title: 'Refine table filters',
          detail: 'No employees are visible in this view.',
          priority: EmployeeDirectoryInsightPriority.steady,
          affectedCount: 0,
        ),
      ];
    }

    final actions = <EmployeeDirectoryInsightAction>[];
    if (watchlistCount > 0) {
      actions.add(
        EmployeeDirectoryInsightAction(
          title: 'Review watchlist profiles',
          detail:
              '${_profiles(watchlistCount)} ${_needVerb(watchlistCount)} manager calibration before the next people review.',
          priority: EmployeeDirectoryInsightPriority.critical,
          affectedCount: watchlistCount,
        ),
      );
    }
    if (lowPerformanceCount > 0) {
      actions.add(
        EmployeeDirectoryInsightAction(
          title: 'Schedule performance support',
          detail:
              '${_profiles(lowPerformanceCount)} ${_sitVerb(lowPerformanceCount)} below ${lowPerformanceThreshold.toStringAsFixed(1)} rating and should have a support plan.',
          priority: EmployeeDirectoryInsightPriority.elevated,
          affectedCount: lowPerformanceCount,
        ),
      );
    }
    if (onboardingCount > 0) {
      actions.add(
        EmployeeDirectoryInsightAction(
          title: 'Close onboarding readiness',
          detail:
              '${_profiles(onboardingCount)} still ${_needVerb(onboardingCount)} onboarding completion checks.',
          priority: EmployeeDirectoryInsightPriority.elevated,
          affectedCount: onboardingCount,
        ),
      );
    }
    if (managerLoads.isNotEmpty) {
      actions.add(
        EmployeeDirectoryInsightAction(
          title: 'Balance manager coverage',
          detail:
              '${_managers(managerLoads.length)} carry $managerLoadThreshold+ direct reports in this view.',
          priority: EmployeeDirectoryInsightPriority.steady,
          affectedCount: managerLoads.length,
        ),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        const EmployeeDirectoryInsightAction(
          title: 'Maintain directory health',
          detail: 'No active HR attention signals are present in this view.',
          priority: EmployeeDirectoryInsightPriority.steady,
          affectedCount: 0,
        ),
      );
    }
    return actions;
  }

  static String _profiles(int count) {
    return count == 1 ? '1 profile' : '$count profiles';
  }

  static String _managers(int count) {
    return count == 1 ? '1 manager' : '$count managers';
  }

  static String _needVerb(int count) {
    return count == 1 ? 'needs' : 'need';
  }

  static String _sitVerb(int count) {
    return count == 1 ? 'sits' : 'sit';
  }
}
