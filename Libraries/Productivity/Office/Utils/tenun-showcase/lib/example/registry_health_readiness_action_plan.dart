import 'registry_health_readiness.dart';

enum RegistryHealthReadinessActionPriority { critical, high, medium }

enum RegistryHealthReadinessActionFilter { all, critical, high, medium }

class RegistryHealthReadinessActionItem {
  final String id;
  final String gateKey;
  final String title;
  final RegistryHealthReadinessActionPriority priority;
  final RegistryHealthReadinessStatus status;
  final int issueCount;
  final String impact;
  final String action;

  const RegistryHealthReadinessActionItem({
    required this.id,
    required this.gateKey,
    required this.title,
    required this.priority,
    required this.status,
    required this.issueCount,
    required this.impact,
    required this.action,
  });

  String get priorityLabel =>
      registryHealthReadinessActionPriorityLabel(priority);

  bool get isBlocking =>
      status == RegistryHealthReadinessStatus.blocked ||
      priority == RegistryHealthReadinessActionPriority.critical;

  Map<String, dynamic> toJson() => {
    'id': id,
    'gateKey': gateKey,
    'title': title,
    'priority': priority.name,
    'priorityLabel': priorityLabel,
    'status': status.name,
    'issueCount': issueCount,
    'impact': impact,
    'action': action,
    'isBlocking': isBlocking,
  };
}

class RegistryHealthReadinessActionPlan {
  final List<RegistryHealthReadinessActionItem> items;

  const RegistryHealthReadinessActionPlan({required this.items});

  int get actionCount => items.length;
  int get criticalCount =>
      _count(RegistryHealthReadinessActionPriority.critical);
  int get highCount => _count(RegistryHealthReadinessActionPriority.high);
  int get mediumCount => _count(RegistryHealthReadinessActionPriority.medium);
  int get issueCount =>
      items.fold<int>(0, (count, item) => count + item.issueCount);

  bool get isClear => items.isEmpty;

  List<RegistryHealthReadinessActionItem> filteredItems({
    RegistryHealthReadinessActionFilter filter =
        RegistryHealthReadinessActionFilter.all,
  }) {
    return items
        .where(
          (item) => registryHealthReadinessActionFilterMatches(filter, item),
        )
        .toList(growable: false);
  }

  List<RegistryHealthReadinessActionItem> visibleItems({
    int limit = 6,
    RegistryHealthReadinessActionFilter filter =
        RegistryHealthReadinessActionFilter.all,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return filteredItems(
      filter: filter,
    ).take(safeLimit).toList(growable: false);
  }

  int filteredCount(RegistryHealthReadinessActionFilter filter) {
    return filteredItems(filter: filter).length;
  }

  Map<String, dynamic> toJson({
    int itemLimit = 16,
    RegistryHealthReadinessActionFilter filter =
        RegistryHealthReadinessActionFilter.all,
  }) {
    final safeLimit = itemLimit < 0 ? 0 : itemLimit;
    final filteredItems = this.filteredItems(filter: filter);
    final exportedItems = filteredItems.take(safeLimit).toList(growable: false);
    return {
      'filter': filter.name,
      'filterLabel': registryHealthReadinessActionFilterLabel(filter),
      'actionCount': actionCount,
      'filteredActionCount': filteredItems.length,
      'criticalCount': criticalCount,
      'highCount': highCount,
      'mediumCount': mediumCount,
      'issueCount': issueCount,
      'exportedActionCount': exportedItems.length,
      'hiddenActionCount': filteredItems.length - exportedItems.length,
      'items': [for (final item in exportedItems) item.toJson()],
    };
  }

  int _count(RegistryHealthReadinessActionPriority priority) {
    return items.where((item) => item.priority == priority).length;
  }
}

RegistryHealthReadinessActionPlan registryHealthReadinessActionPlan(
  RegistryHealthReadinessReport report,
) {
  final items = [
    for (final gate in report.attentionGates) _actionItemForGate(gate),
  ];
  items.sort(_compareActionItems);
  return RegistryHealthReadinessActionPlan(
    items: List<RegistryHealthReadinessActionItem>.unmodifiable(items),
  );
}

String registryHealthReadinessActionPriorityLabel(
  RegistryHealthReadinessActionPriority priority,
) {
  switch (priority) {
    case RegistryHealthReadinessActionPriority.critical:
      return 'Critical';
    case RegistryHealthReadinessActionPriority.high:
      return 'High';
    case RegistryHealthReadinessActionPriority.medium:
      return 'Medium';
  }
}

String registryHealthReadinessActionFilterLabel(
  RegistryHealthReadinessActionFilter filter,
) {
  switch (filter) {
    case RegistryHealthReadinessActionFilter.all:
      return 'All';
    case RegistryHealthReadinessActionFilter.critical:
      return 'Critical';
    case RegistryHealthReadinessActionFilter.high:
      return 'High';
    case RegistryHealthReadinessActionFilter.medium:
      return 'Medium';
  }
}

bool registryHealthReadinessActionFilterMatches(
  RegistryHealthReadinessActionFilter filter,
  RegistryHealthReadinessActionItem item,
) {
  switch (filter) {
    case RegistryHealthReadinessActionFilter.all:
      return true;
    case RegistryHealthReadinessActionFilter.critical:
      return item.priority == RegistryHealthReadinessActionPriority.critical;
    case RegistryHealthReadinessActionFilter.high:
      return item.priority == RegistryHealthReadinessActionPriority.high;
    case RegistryHealthReadinessActionFilter.medium:
      return item.priority == RegistryHealthReadinessActionPriority.medium;
  }
}

List<RegistryHealthReadinessActionItem>
registryHealthReadinessVisibleActionItems(
  RegistryHealthReadinessActionPlan plan, {
  int limit = 6,
  RegistryHealthReadinessActionFilter filter =
      RegistryHealthReadinessActionFilter.all,
}) {
  return plan.visibleItems(limit: limit, filter: filter);
}

Map<String, dynamic> registryHealthReadinessActionPlanJson(
  RegistryHealthReadinessActionPlan plan, {
  int itemLimit = 16,
  RegistryHealthReadinessActionFilter filter =
      RegistryHealthReadinessActionFilter.all,
}) {
  return plan.toJson(itemLimit: itemLimit, filter: filter);
}

RegistryHealthReadinessActionItem _actionItemForGate(
  RegistryHealthReadinessGate gate,
) {
  final priority = _priorityForGate(gate);
  return RegistryHealthReadinessActionItem(
    id: '${gate.key}.${gate.status.name}',
    gateKey: gate.key,
    title: gate.label,
    priority: priority,
    status: gate.status,
    issueCount: gate.issueCount,
    impact: _impactForGate(gate),
    action: gate.action,
  );
}

RegistryHealthReadinessActionPriority _priorityForGate(
  RegistryHealthReadinessGate gate,
) {
  switch (gate.status) {
    case RegistryHealthReadinessStatus.blocked:
      return RegistryHealthReadinessActionPriority.critical;
    case RegistryHealthReadinessStatus.warning:
      return gate.issueCount > 0
          ? RegistryHealthReadinessActionPriority.high
          : RegistryHealthReadinessActionPriority.medium;
    case RegistryHealthReadinessStatus.ready:
      return RegistryHealthReadinessActionPriority.medium;
  }
}

String _impactForGate(RegistryHealthReadinessGate gate) {
  switch (gate.key) {
    case 'registry':
      return 'Registry entries cannot be trusted until audit errors clear.';
    case 'showcaseCoverage':
      return 'Showcase coverage gates are not release-ready.';
    case 'typeNaming':
      return 'Type-key drift can break sample lookup and docs.';
    case 'typeCleanup':
      return 'Rename cleanup is pending before the registry is canonical.';
    case 'sampleAudit':
      return 'Sample JSON may fail validation or reference unknown charts.';
    case 'sampleSourceAudit':
      return 'Generated source examples may drift from sample payloads.';
    case 'simpleSourceAudit':
      return 'Simple chart source snippets may be incomplete.';
    case 'chartExampleMatrix':
      return 'Example readiness is incomplete across chart families.';
    case 'apiConsistency':
      return 'Chart API contracts may expose uneven controls by family.';
    case 'sourceMapAudit':
      return 'Source map positions may be stale for automated cleanup.';
    default:
      return 'Readiness needs attention before release.';
  }
}

int _compareActionItems(
  RegistryHealthReadinessActionItem a,
  RegistryHealthReadinessActionItem b,
) {
  final priority = _priorityRank(
    b.priority,
  ).compareTo(_priorityRank(a.priority));
  if (priority != 0) return priority;
  final issues = b.issueCount.compareTo(a.issueCount);
  if (issues != 0) return issues;
  return a.title.compareTo(b.title);
}

int _priorityRank(RegistryHealthReadinessActionPriority priority) {
  switch (priority) {
    case RegistryHealthReadinessActionPriority.critical:
      return 2;
    case RegistryHealthReadinessActionPriority.high:
      return 1;
    case RegistryHealthReadinessActionPriority.medium:
      return 0;
  }
}
