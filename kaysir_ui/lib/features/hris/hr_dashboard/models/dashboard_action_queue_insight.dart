import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';

class DashboardActionQueueInsight {
  final String headline;
  final String detail;
  final String? ownerLabel;
  final DashboardActionPriority? priority;
  final int priorityActionCount;
  final int activeCount;
  final int doneCount;
  final int totalCount;

  const DashboardActionQueueInsight({
    required this.headline,
    required this.detail,
    required this.ownerLabel,
    required this.priority,
    required this.priorityActionCount,
    required this.activeCount,
    required this.doneCount,
    required this.totalCount,
  });

  bool get hasActions => totalCount > 0;

  bool get hasActiveActions => activeCount > 0;

  factory DashboardActionQueueInsight.fromRecommendations({
    required List<DashboardActionRecommendation> recommendations,
    required Map<String, DashboardActionStatus> statuses,
  }) {
    if (recommendations.isEmpty) {
      return const DashboardActionQueueInsight(
        headline: 'No actions in focus',
        detail: 'Clear focus or show done work to bring recommendations back.',
        ownerLabel: null,
        priority: null,
        priorityActionCount: 0,
        activeCount: 0,
        doneCount: 0,
        totalCount: 0,
      );
    }

    final activeRecommendations =
        recommendations
            .where((item) => statuses[item.id] != DashboardActionStatus.done)
            .toList();
    final doneCount = recommendations.length - activeRecommendations.length;

    if (activeRecommendations.isEmpty) {
      return DashboardActionQueueInsight(
        headline: 'Visible actions are complete',
        detail: 'Reopen an item if follow-up is still needed.',
        ownerLabel: _topOwner(recommendations),
        priority: null,
        priorityActionCount: 0,
        activeCount: 0,
        doneCount: doneCount,
        totalCount: recommendations.length,
      );
    }

    final topPriority = _topPriority(activeRecommendations);
    final priorityRecommendations =
        activeRecommendations
            .where((item) => item.priority == topPriority)
            .toList();
    final ownerLabel = _topOwner(priorityRecommendations);
    final priorityCount = priorityRecommendations.length;

    return DashboardActionQueueInsight(
      headline: _headline(
        ownerLabel: ownerLabel,
        priority: topPriority,
        priorityCount: priorityCount,
      ),
      detail:
          '${_countLabel(activeRecommendations.length, 'active action')} '
          'and ${_countLabel(doneCount, 'done action')} in the current view.',
      ownerLabel: ownerLabel,
      priority: topPriority,
      priorityActionCount: priorityCount,
      activeCount: activeRecommendations.length,
      doneCount: doneCount,
      totalCount: recommendations.length,
    );
  }

  static DashboardActionPriority _topPriority(
    List<DashboardActionRecommendation> recommendations,
  ) {
    return recommendations
        .map((item) => item.priority)
        .reduce(
          (current, next) =>
              _priorityRank(next) < _priorityRank(current) ? next : current,
        );
  }

  static String _topOwner(List<DashboardActionRecommendation> recommendations) {
    final countsByOwner = <String, int>{};
    final firstIndexByOwner = <String, int>{};

    for (var index = 0; index < recommendations.length; index++) {
      final owner = recommendations[index].ownerLabel;
      countsByOwner[owner] = (countsByOwner[owner] ?? 0) + 1;
      firstIndexByOwner.putIfAbsent(owner, () => index);
    }

    return countsByOwner.entries.reduce((current, next) {
      if (next.value != current.value) {
        return next.value > current.value ? next : current;
      }

      return firstIndexByOwner[next.key]! < firstIndexByOwner[current.key]!
          ? next
          : current;
    }).key;
  }

  static String _headline({
    required String ownerLabel,
    required DashboardActionPriority priority,
    required int priorityCount,
  }) {
    if (priorityCount == 1) {
      return '$ownerLabel owns the ${priority.label.toLowerCase()} action in focus';
    }

    return '$ownerLabel owns $priorityCount ${priority.label.toLowerCase()} actions in focus';
  }

  static String _countLabel(int count, String singular) {
    return count == 1 ? '1 $singular' : '$count ${singular}s';
  }

  static int _priorityRank(DashboardActionPriority priority) {
    return switch (priority) {
      DashboardActionPriority.critical => 0,
      DashboardActionPriority.high => 1,
      DashboardActionPriority.medium => 2,
      DashboardActionPriority.low => 3,
    };
  }
}
