import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';

enum ProjectResourceCapacityState {
  overallocated,
  focused,
  balanced,
  available,
}

class ProjectResourceAssignment {
  const ProjectResourceAssignment({
    required this.projectId,
    required this.projectName,
    required this.role,
    required this.allocation,
    required this.health,
  });

  final String projectId;
  final String projectName;
  final String role;
  final double allocation;
  final ProjectHealth health;
}

class ProjectResourceCapacityItem {
  const ProjectResourceCapacityItem({
    required this.name,
    required this.primaryRole,
    required this.totalAllocation,
    required this.assignments,
    required this.state,
  });

  final String name;
  final String primaryRole;
  final double totalAllocation;
  final List<ProjectResourceAssignment> assignments;
  final ProjectResourceCapacityState state;

  int get allocationPercent => (totalAllocation * 100).round();
  int get projectCount => assignments.length;
  int get attentionProjectCount =>
      assignments
          .where((assignment) => assignment.health != ProjectHealth.onTrack)
          .length;
  ProjectResourceAssignment? get primaryAssignment =>
      assignments.isEmpty ? null : assignments.first;
}

class ProjectResourceCapacitySummary {
  const ProjectResourceCapacitySummary({required this.items});

  final List<ProjectResourceCapacityItem> items;

  int get contributorCount => items.length;
  int get overallocatedCount =>
      items
          .where(
            (item) => item.state == ProjectResourceCapacityState.overallocated,
          )
          .length;
  int get focusedCount =>
      items
          .where((item) => item.state == ProjectResourceCapacityState.focused)
          .length;
  int get availableCount =>
      items
          .where((item) => item.state == ProjectResourceCapacityState.available)
          .length;
  int get attentionAssignmentCount =>
      items.fold(0, (sum, item) => sum + item.attentionProjectCount);

  int get averageAllocationPercent {
    if (items.isEmpty) return 0;

    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.totalAllocation,
    );

    return ((total / items.length) * 100).round();
  }

  List<ProjectResourceCapacityItem> get prioritizedItems {
    final sorted = [...items]..sort(_compareCapacityItems);
    return List.unmodifiable(sorted);
  }
}

extension ProjectResourceCapacityStatePresentation
    on ProjectResourceCapacityState {
  String get label {
    switch (this) {
      case ProjectResourceCapacityState.overallocated:
        return 'Overallocated';
      case ProjectResourceCapacityState.focused:
        return 'Focused';
      case ProjectResourceCapacityState.balanced:
        return 'Balanced';
      case ProjectResourceCapacityState.available:
        return 'Available';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectResourceCapacityState.overallocated:
        return Icons.warning_amber_rounded;
      case ProjectResourceCapacityState.focused:
        return Icons.person_pin_circle_outlined;
      case ProjectResourceCapacityState.balanced:
        return Icons.balance_outlined;
      case ProjectResourceCapacityState.available:
        return Icons.event_available_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectResourceCapacityState.overallocated:
        return colorScheme.error;
      case ProjectResourceCapacityState.focused:
        return Colors.orange.shade700;
      case ProjectResourceCapacityState.balanced:
        return colorScheme.primary;
      case ProjectResourceCapacityState.available:
        return Colors.green.shade700;
    }
  }
}

ProjectResourceCapacitySummary buildProjectResourceCapacitySummary({
  required List<ProjectPortfolioItem> projects,
  double overallocatedThreshold = 1,
  double focusedThreshold = 0.75,
  double availableThreshold = 0.5,
}) {
  final buckets = <String, _CapacityBucket>{};

  for (final project in projects) {
    for (final member in project.team) {
      final key = member.name.trim().toLowerCase();
      if (key.isEmpty) continue;

      buckets
          .putIfAbsent(key, () => _CapacityBucket(name: member.name.trim()))
          .add(
            ProjectResourceAssignment(
              projectId: project.id,
              projectName: project.name,
              role: member.role,
              allocation: member.allocation,
              health: project.health,
            ),
          );
    }
  }

  final items = [
    for (final bucket in buckets.values)
      bucket.toCapacityItem(
        overallocatedThreshold: overallocatedThreshold,
        focusedThreshold: focusedThreshold,
        availableThreshold: availableThreshold,
      ),
  ]..sort(_compareCapacityItems);

  return ProjectResourceCapacitySummary(items: List.unmodifiable(items));
}

String projectResourceCapacityDetail(ProjectResourceCapacityItem item) {
  final projectLabel =
      '${item.projectCount} project${item.projectCount == 1 ? '' : 's'}';
  final attentionLabel =
      item.attentionProjectCount == 0
          ? 'no attention projects'
          : '${item.attentionProjectCount} attention project${item.attentionProjectCount == 1 ? '' : 's'}';

  return '${item.allocationPercent}% allocated across $projectLabel - $attentionLabel';
}

class _CapacityBucket {
  _CapacityBucket({required this.name});

  final String name;
  final assignments = <ProjectResourceAssignment>[];

  void add(ProjectResourceAssignment assignment) {
    assignments.add(assignment);
  }

  ProjectResourceCapacityItem toCapacityItem({
    required double overallocatedThreshold,
    required double focusedThreshold,
    required double availableThreshold,
  }) {
    final totalAllocation = assignments.fold<double>(
      0,
      (sum, assignment) => sum + assignment.allocation,
    );
    final sortedAssignments = [...assignments]
      ..sort((left, right) => right.allocation.compareTo(left.allocation));

    return ProjectResourceCapacityItem(
      name: name,
      primaryRole: sortedAssignments.first.role,
      totalAllocation: totalAllocation,
      assignments: List.unmodifiable(sortedAssignments),
      state: _stateFor(
        totalAllocation,
        overallocatedThreshold: overallocatedThreshold,
        focusedThreshold: focusedThreshold,
        availableThreshold: availableThreshold,
      ),
    );
  }
}

ProjectResourceCapacityState _stateFor(
  double allocation, {
  required double overallocatedThreshold,
  required double focusedThreshold,
  required double availableThreshold,
}) {
  if (allocation > overallocatedThreshold) {
    return ProjectResourceCapacityState.overallocated;
  }
  if (allocation >= focusedThreshold) {
    return ProjectResourceCapacityState.focused;
  }
  if (allocation < availableThreshold) {
    return ProjectResourceCapacityState.available;
  }
  return ProjectResourceCapacityState.balanced;
}

int _compareCapacityItems(
  ProjectResourceCapacityItem left,
  ProjectResourceCapacityItem right,
) {
  final stateCompare = _stateRank(
    left.state,
  ).compareTo(_stateRank(right.state));
  if (stateCompare != 0) return stateCompare;

  final allocationCompare = right.totalAllocation.compareTo(
    left.totalAllocation,
  );
  if (allocationCompare != 0) return allocationCompare;

  return left.name.compareTo(right.name);
}

int _stateRank(ProjectResourceCapacityState state) {
  switch (state) {
    case ProjectResourceCapacityState.overallocated:
      return 0;
    case ProjectResourceCapacityState.focused:
      return 1;
    case ProjectResourceCapacityState.balanced:
      return 2;
    case ProjectResourceCapacityState.available:
      return 3;
  }
}
