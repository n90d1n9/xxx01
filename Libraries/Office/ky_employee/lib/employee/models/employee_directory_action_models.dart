import 'employee_directory_insight_models.dart';
import 'employee_directory_models.dart';

enum EmployeeDirectoryActionType {
  watchlistReview,
  onboardingReadiness,
  performanceSupport,
  managerCoverage,
}

enum EmployeeDirectoryActionStatus { todo, inProgress, resolved, snoozed }

extension EmployeeDirectoryActionStatusLabel on EmployeeDirectoryActionStatus {
  String get label {
    return switch (this) {
      EmployeeDirectoryActionStatus.todo => 'To do',
      EmployeeDirectoryActionStatus.inProgress => 'In progress',
      EmployeeDirectoryActionStatus.resolved => 'Resolved',
      EmployeeDirectoryActionStatus.snoozed => 'Snoozed',
    };
  }
}

class EmployeeDirectoryActionOverride {
  final EmployeeDirectoryActionStatus? status;
  final String? owner;
  final DateTime? dueDate;

  const EmployeeDirectoryActionOverride({
    this.status,
    this.owner,
    this.dueDate,
  });

  EmployeeDirectoryActionOverride copyWith({
    EmployeeDirectoryActionStatus? status,
    String? owner,
    DateTime? dueDate,
  }) {
    return EmployeeDirectoryActionOverride(
      status: status ?? this.status,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class EmployeeDirectoryActionItem {
  final String id;
  final EmployeeDirectoryActionType type;
  final String title;
  final String detail;
  final EmployeeDirectoryInsightPriority priority;
  final EmployeeDirectoryActionStatus status;
  final String owner;
  final DateTime dueDate;
  final List<String> affectedEmployeeIds;
  final List<String> affectedEmployeeNames;

  const EmployeeDirectoryActionItem({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.priority,
    required this.status,
    required this.owner,
    required this.dueDate,
    required this.affectedEmployeeIds,
    required this.affectedEmployeeNames,
  });

  int get affectedCount => affectedEmployeeIds.length;

  bool get isOpen => status != EmployeeDirectoryActionStatus.resolved;

  EmployeeDirectoryActionItem copyWith({
    EmployeeDirectoryActionStatus? status,
    String? owner,
    DateTime? dueDate,
  }) {
    return EmployeeDirectoryActionItem(
      id: id,
      type: type,
      title: title,
      detail: detail,
      priority: priority,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      affectedEmployeeIds: affectedEmployeeIds,
      affectedEmployeeNames: affectedEmployeeNames,
    );
  }

  EmployeeDirectoryActionItem applyOverride(
    EmployeeDirectoryActionOverride? override,
  ) {
    if (override == null) return this;

    return copyWith(
      status: override.status,
      owner: override.owner,
      dueDate: override.dueDate,
    );
  }
}

class EmployeeDirectoryActionQueueSummary {
  final int totalCount;
  final int openCount;
  final int criticalCount;
  final int dueSoonCount;
  final int resolvedCount;

  const EmployeeDirectoryActionQueueSummary({
    required this.totalCount,
    required this.openCount,
    required this.criticalCount,
    required this.dueSoonCount,
    required this.resolvedCount,
  });

  factory EmployeeDirectoryActionQueueSummary.fromActions({
    required List<EmployeeDirectoryActionItem> actions,
    required DateTime asOfDate,
  }) {
    return EmployeeDirectoryActionQueueSummary(
      totalCount: actions.length,
      openCount: actions.where((action) => action.isOpen).length,
      criticalCount:
          actions
              .where(
                (action) =>
                    action.isOpen &&
                    action.priority ==
                        EmployeeDirectoryInsightPriority.critical,
              )
              .length,
      dueSoonCount:
          actions
              .where(
                (action) =>
                    action.isOpen &&
                    action.dueDate.difference(asOfDate).inDays <= 3,
              )
              .length,
      resolvedCount:
          actions
              .where(
                (action) =>
                    action.status == EmployeeDirectoryActionStatus.resolved,
              )
              .length,
    );
  }
}

List<EmployeeDirectoryActionItem> buildEmployeeDirectoryActions({
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  final actions = <EmployeeDirectoryActionItem>[
    ..._watchlistActions(members: members, asOfDate: asOfDate),
    ..._onboardingActions(members: members, asOfDate: asOfDate),
    ..._performanceActions(members: members, asOfDate: asOfDate),
    ..._managerCoverageActions(members: members, asOfDate: asOfDate),
  ];

  actions.sort(compareEmployeeDirectoryActions);
  return actions;
}

List<EmployeeDirectoryActionItem> _watchlistActions({
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  final affected =
      members
          .where((member) => member.status == EmployeeDirectoryStatus.watchlist)
          .toList();
  if (affected.isEmpty) return const [];

  return [
    EmployeeDirectoryActionItem(
      id: _actionId(EmployeeDirectoryActionType.watchlistReview, affected),
      type: EmployeeDirectoryActionType.watchlistReview,
      title: 'Review watchlist profiles',
      detail:
          '${_profiles(affected.length)} ${_needVerb(affected.length)} manager calibration and next-step notes.',
      priority: EmployeeDirectoryInsightPriority.critical,
      status: EmployeeDirectoryActionStatus.todo,
      owner: 'HR Business Partner',
      dueDate: asOfDate.add(const Duration(days: 2)),
      affectedEmployeeIds: _ids(affected),
      affectedEmployeeNames: _names(affected),
    ),
  ];
}

List<EmployeeDirectoryActionItem> _onboardingActions({
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  final affected =
      members
          .where(
            (member) => member.status == EmployeeDirectoryStatus.onboarding,
          )
          .toList();
  if (affected.isEmpty) return const [];

  return [
    EmployeeDirectoryActionItem(
      id: _actionId(EmployeeDirectoryActionType.onboardingReadiness, affected),
      type: EmployeeDirectoryActionType.onboardingReadiness,
      title: 'Close onboarding readiness',
      detail:
          '${_profiles(affected.length)} ${_needVerb(affected.length)} payroll, access, and document readiness checks.',
      priority: EmployeeDirectoryInsightPriority.elevated,
      status: EmployeeDirectoryActionStatus.todo,
      owner: 'People Operations',
      dueDate: asOfDate.add(const Duration(days: 3)),
      affectedEmployeeIds: _ids(affected),
      affectedEmployeeNames: _names(affected),
    ),
  ];
}

List<EmployeeDirectoryActionItem> _performanceActions({
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  final affected =
      members
          .where(
            (member) =>
                member.performance <
                EmployeeDirectoryInsights.lowPerformanceThreshold,
          )
          .toList();
  if (affected.isEmpty) return const [];

  return [
    EmployeeDirectoryActionItem(
      id: _actionId(EmployeeDirectoryActionType.performanceSupport, affected),
      type: EmployeeDirectoryActionType.performanceSupport,
      title: 'Schedule performance support',
      detail:
          '${_profiles(affected.length)} ${_shouldVerb(affected.length)} have a coaching plan and check-in owner.',
      priority: EmployeeDirectoryInsightPriority.elevated,
      status: EmployeeDirectoryActionStatus.todo,
      owner: 'People Partner',
      dueDate: asOfDate.add(const Duration(days: 5)),
      affectedEmployeeIds: _ids(affected),
      affectedEmployeeNames: _names(affected),
    ),
  ];
}

List<EmployeeDirectoryActionItem> _managerCoverageActions({
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  final byManager = <String, List<EmployeeDirectoryMember>>{};
  for (final member in members) {
    byManager.update(
      member.manager,
      (reports) => [...reports, member],
      ifAbsent: () => [member],
    );
  }

  final affected =
      byManager.values
          .where(
            (reports) =>
                reports.length >=
                EmployeeDirectoryInsights.managerLoadThreshold,
          )
          .expand((reports) => reports)
          .toList();
  if (affected.isEmpty) return const [];

  return [
    EmployeeDirectoryActionItem(
      id: _actionId(EmployeeDirectoryActionType.managerCoverage, affected),
      type: EmployeeDirectoryActionType.managerCoverage,
      title: 'Balance manager coverage',
      detail:
          '${_profiles(affected.length)} ${_sitVerb(affected.length)} under managers with concentrated direct-report load.',
      priority: EmployeeDirectoryInsightPriority.steady,
      status: EmployeeDirectoryActionStatus.todo,
      owner: 'Org Design Lead',
      dueDate: asOfDate.add(const Duration(days: 7)),
      affectedEmployeeIds: _ids(affected),
      affectedEmployeeNames: _names(affected),
    ),
  ];
}

int compareEmployeeDirectoryActions(
  EmployeeDirectoryActionItem first,
  EmployeeDirectoryActionItem second,
) {
  final statusCompare = _statusRank(
    first.status,
  ).compareTo(_statusRank(second.status));
  if (statusCompare != 0) return statusCompare;

  final priorityCompare = _priorityRank(
    first.priority,
  ).compareTo(_priorityRank(second.priority));
  if (priorityCompare != 0) return priorityCompare;

  final dueDateCompare = first.dueDate.compareTo(second.dueDate);
  if (dueDateCompare != 0) return dueDateCompare;

  return first.title.compareTo(second.title);
}

int _statusRank(EmployeeDirectoryActionStatus status) {
  return switch (status) {
    EmployeeDirectoryActionStatus.inProgress => 0,
    EmployeeDirectoryActionStatus.todo => 1,
    EmployeeDirectoryActionStatus.snoozed => 2,
    EmployeeDirectoryActionStatus.resolved => 3,
  };
}

int _priorityRank(EmployeeDirectoryInsightPriority priority) {
  return switch (priority) {
    EmployeeDirectoryInsightPriority.critical => 0,
    EmployeeDirectoryInsightPriority.elevated => 1,
    EmployeeDirectoryInsightPriority.steady => 2,
  };
}

String _actionId(
  EmployeeDirectoryActionType type,
  List<EmployeeDirectoryMember> members,
) {
  return '${type.name}-${_ids(members).join('-')}';
}

List<String> _ids(List<EmployeeDirectoryMember> members) {
  final ids = members.map((member) => member.id).toList()..sort();
  return ids;
}

List<String> _names(List<EmployeeDirectoryMember> members) {
  final sorted = [...members]..sort((a, b) => a.name.compareTo(b.name));
  return sorted.map((member) => member.name).toList();
}

String _profiles(int count) {
  return count == 1 ? '1 profile' : '$count profiles';
}

String _needVerb(int count) {
  return count == 1 ? 'needs' : 'need';
}

String _shouldVerb(int count) {
  return count == 1 ? 'should' : 'should';
}

String _sitVerb(int count) {
  return count == 1 ? 'sits' : 'sit';
}
