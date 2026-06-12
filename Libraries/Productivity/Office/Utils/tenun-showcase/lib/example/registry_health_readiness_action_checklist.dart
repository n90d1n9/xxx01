import 'registry_health_readiness_action_plan.dart';

enum RegistryHealthReadinessActionPhase { now, next, later }

class RegistryHealthReadinessActionPhaseGroup {
  final RegistryHealthReadinessActionPhase phase;
  final List<RegistryHealthReadinessActionItem> items;

  const RegistryHealthReadinessActionPhaseGroup({
    required this.phase,
    required this.items,
  });

  String get label => registryHealthReadinessActionPhaseLabel(phase);

  int get actionCount => items.length;

  int get issueCount =>
      items.fold<int>(0, (count, item) => count + item.issueCount);

  bool get isEmpty => items.isEmpty;

  RegistryHealthReadinessActionPhaseGroup take(int limit) {
    final safeLimit = limit < 0 ? 0 : limit;
    return RegistryHealthReadinessActionPhaseGroup(
      phase: phase,
      items: items.take(safeLimit).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson({int itemLimit = 16}) {
    final safeLimit = itemLimit < 0 ? 0 : itemLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    return {
      'phase': phase.name,
      'phaseLabel': label,
      'actionCount': actionCount,
      'issueCount': issueCount,
      'exportedActionCount': exportedItems.length,
      'hiddenActionCount': items.length - exportedItems.length,
      'items': [for (final item in exportedItems) item.toJson()],
    };
  }
}

class RegistryHealthReadinessActionChecklist {
  final List<RegistryHealthReadinessActionPhaseGroup> groups;
  final RegistryHealthReadinessActionFilter filter;

  const RegistryHealthReadinessActionChecklist({
    required this.groups,
    required this.filter,
  });

  int get actionCount =>
      groups.fold<int>(0, (count, group) => count + group.actionCount);

  int get issueCount =>
      groups.fold<int>(0, (count, group) => count + group.issueCount);

  bool get isClear => actionCount == 0;

  List<RegistryHealthReadinessActionPhaseGroup> get activeGroups {
    return groups.where((group) => !group.isEmpty).toList(growable: false);
  }

  int phaseCount(RegistryHealthReadinessActionPhase phase) {
    return groups
        .firstWhere(
          (group) => group.phase == phase,
          orElse: () => RegistryHealthReadinessActionPhaseGroup(
            phase: phase,
            items: const [],
          ),
        )
        .actionCount;
  }

  List<RegistryHealthReadinessActionPhaseGroup> visibleGroups({
    int itemLimit = 6,
  }) {
    var remaining = itemLimit < 0 ? 0 : itemLimit;
    final out = <RegistryHealthReadinessActionPhaseGroup>[];
    for (final group in activeGroups) {
      if (remaining <= 0) break;
      final visibleGroup = group.take(remaining);
      if (!visibleGroup.isEmpty) {
        out.add(visibleGroup);
        remaining -= visibleGroup.actionCount;
      }
    }
    return out;
  }

  Map<String, dynamic> toJson({int itemLimit = 16}) {
    var remaining = itemLimit < 0 ? 0 : itemLimit;
    final exportedGroups = <Map<String, dynamic>>[];
    var exportedActionCount = 0;

    for (final group in activeGroups) {
      if (remaining <= 0) break;
      final visibleGroup = group.take(remaining);
      if (visibleGroup.isEmpty) continue;
      exportedGroups.add(visibleGroup.toJson(itemLimit: remaining));
      exportedActionCount += visibleGroup.actionCount;
      remaining -= visibleGroup.actionCount;
    }

    return {
      'filter': filter.name,
      'filterLabel': registryHealthReadinessActionFilterLabel(filter),
      'actionCount': actionCount,
      'issueCount': issueCount,
      'phaseCounts': {
        for (final phase in RegistryHealthReadinessActionPhase.values)
          phase.name: phaseCount(phase),
      },
      'exportedActionCount': exportedActionCount,
      'hiddenActionCount': actionCount - exportedActionCount,
      'groups': exportedGroups,
    };
  }
}

RegistryHealthReadinessActionChecklist registryHealthReadinessActionChecklist(
  RegistryHealthReadinessActionPlan plan, {
  RegistryHealthReadinessActionFilter filter =
      RegistryHealthReadinessActionFilter.all,
}) {
  final items = plan.filteredItems(filter: filter);
  return RegistryHealthReadinessActionChecklist(
    filter: filter,
    groups: [
      for (final phase in RegistryHealthReadinessActionPhase.values)
        RegistryHealthReadinessActionPhaseGroup(
          phase: phase,
          items: items
              .where(
                (item) =>
                    registryHealthReadinessActionPhaseForItem(item) == phase,
              )
              .toList(growable: false),
        ),
    ],
  );
}

String registryHealthReadinessActionPhaseLabel(
  RegistryHealthReadinessActionPhase phase,
) {
  switch (phase) {
    case RegistryHealthReadinessActionPhase.now:
      return 'Now';
    case RegistryHealthReadinessActionPhase.next:
      return 'Next';
    case RegistryHealthReadinessActionPhase.later:
      return 'Later';
  }
}

RegistryHealthReadinessActionPhase registryHealthReadinessActionPhaseForItem(
  RegistryHealthReadinessActionItem item,
) {
  return registryHealthReadinessActionPhaseForPriority(item.priority);
}

RegistryHealthReadinessActionPhase
registryHealthReadinessActionPhaseForPriority(
  RegistryHealthReadinessActionPriority priority,
) {
  switch (priority) {
    case RegistryHealthReadinessActionPriority.critical:
      return RegistryHealthReadinessActionPhase.now;
    case RegistryHealthReadinessActionPriority.high:
      return RegistryHealthReadinessActionPhase.next;
    case RegistryHealthReadinessActionPriority.medium:
      return RegistryHealthReadinessActionPhase.later;
  }
}

List<String> registryHealthReadinessActionChecklistLines(
  RegistryHealthReadinessActionPlan plan, {
  int itemLimit = 16,
  RegistryHealthReadinessActionFilter filter =
      RegistryHealthReadinessActionFilter.all,
}) {
  final checklist = registryHealthReadinessActionChecklist(
    plan,
    filter: filter,
  );
  final lines = <String>[
    '# Registry Health Action Checklist',
    '',
    'Filter: ${registryHealthReadinessActionFilterLabel(filter)}',
    'Actions: ${checklist.actionCount}, issues: ${checklist.issueCount}',
  ];

  if (checklist.isClear) {
    lines.add('');
    lines.add('- [x] No readiness action items.');
    return lines;
  }

  var exportedActionCount = 0;
  for (final group in checklist.visibleGroups(itemLimit: itemLimit)) {
    lines.add('');
    lines.add('## ${group.label}');
    for (final item in group.items) {
      exportedActionCount += 1;
      final issueLabel = item.issueCount == 1 ? 'issue' : 'issues';
      lines.add(
        '- [ ] ${item.title} (${item.priorityLabel}, '
        '${item.issueCount} $issueLabel): ${item.action}',
      );
    }
  }

  final hiddenActionCount = checklist.actionCount - exportedActionCount;
  if (hiddenActionCount > 0) {
    lines.add('');
    lines.add('+$hiddenActionCount more actions hidden by export limit.');
  }

  return lines;
}

String registryHealthReadinessActionChecklistText(
  RegistryHealthReadinessActionPlan plan, {
  int itemLimit = 16,
  RegistryHealthReadinessActionFilter filter =
      RegistryHealthReadinessActionFilter.all,
}) {
  return registryHealthReadinessActionChecklistLines(
    plan,
    itemLimit: itemLimit,
    filter: filter,
  ).join('\n');
}
