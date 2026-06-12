/// Business source that produced a follow-up work item.
enum BillingFollowUpWorkSource {
  reliefMonitoring,
  collections,
  subscription,
  milestone,
  external,
}

/// Operational priority used to rank follow-up work across billing domains.
enum BillingFollowUpWorkPriority { urgent, high, normal, low }

/// Current readiness state for a follow-up work item.
enum BillingFollowUpWorkStatus { blocked, ready, scheduled, optional }

/// One reusable follow-up action for billing workflows and domain packs.
class BillingFollowUpWorkItem {
  final String id;
  final BillingFollowUpWorkSource source;
  final BillingFollowUpWorkPriority priority;
  final BillingFollowUpWorkStatus status;
  final String title;
  final String description;
  final String ownerRole;
  final int dueInDays;
  final List<String> tags;

  BillingFollowUpWorkItem({
    required this.id,
    required this.source,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    required this.ownerRole,
    required this.dueInDays,
    Iterable<String> tags = const [],
  }) : tags = List.unmodifiable(tags);

  bool get isBlocked => status == BillingFollowUpWorkStatus.blocked;

  bool get isReady => status == BillingFollowUpWorkStatus.ready;

  bool get isScheduled => status == BillingFollowUpWorkStatus.scheduled;

  bool get isOptional => status == BillingFollowUpWorkStatus.optional;

  String get dueLabel {
    if (dueInDays <= 0) return 'Today';
    if (dueInDays == 1) return 'Day 1';
    return 'Day $dueInDays';
  }

  int get sortRank {
    return priority.rank * 1000 + status.rank * 100 + dueInDays.clamp(0, 99);
  }
}

/// Ordered queue of follow-up work items for a billing workflow.
class BillingFollowUpWorkQueue {
  final String title;
  final String sourceLabel;
  final List<BillingFollowUpWorkItem> items;
  final List<String> blockers;

  BillingFollowUpWorkQueue({
    required this.title,
    required this.sourceLabel,
    Iterable<BillingFollowUpWorkItem> items = const [],
    Iterable<String> blockers = const [],
  }) : items = List.unmodifiable(items),
       blockers = List.unmodifiable(blockers);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool get hasBlockers => blockers.isNotEmpty;

  int get totalCount => items.length;

  int get readyCount {
    return items.where((item) => item.isReady).length;
  }

  int get blockedCount {
    return items.where((item) => item.isBlocked).length;
  }

  int get scheduledCount {
    return items.where((item) => item.isScheduled).length;
  }

  int get optionalCount {
    return items.where((item) => item.isOptional).length;
  }

  int get ownerCount {
    return items.map((item) => item.ownerRole).toSet().length;
  }

  int get sourceCount {
    return items.map((item) => item.source).toSet().length;
  }

  int get workWindowDays {
    return items.fold<int>(
      0,
      (maxDue, item) => item.dueInDays > maxDue ? item.dueInDays : maxDue,
    );
  }

  String get headlineLabel {
    if (isEmpty) return 'No follow-up work';
    if (blockedCount > 0) {
      return '$blockedCount blocked ${blockedCount == 1 ? 'item' : 'items'}';
    }
    if (readyCount > 0) {
      return '$readyCount ready ${readyCount == 1 ? 'item' : 'items'}';
    }
    return '$scheduledCount scheduled ${scheduledCount == 1 ? 'item' : 'items'}';
  }

  String get summaryLabel {
    if (isEmpty) return 'No follow-up work is currently queued.';
    if (blockedCount > 0) {
      return 'Resolve blockers first, then continue with scheduled follow-up ownership.';
    }
    if (readyCount > 0) {
      return 'Ready work is ranked by urgency, status, and due window.';
    }
    return 'Scheduled follow-up is staged across owners and due windows.';
  }

  List<BillingFollowUpWorkItem> itemsForOwner(String ownerRole) {
    return List.unmodifiable(
      items.where((item) => item.ownerRole == ownerRole),
    );
  }

  List<BillingFollowUpWorkItem> itemsForSource(
    BillingFollowUpWorkSource source,
  ) {
    return List.unmodifiable(items.where((item) => item.source == source));
  }
}

/// Display labels and sort rank for follow-up work priorities.
extension BillingFollowUpWorkPriorityX on BillingFollowUpWorkPriority {
  int get rank {
    return switch (this) {
      BillingFollowUpWorkPriority.urgent => 0,
      BillingFollowUpWorkPriority.high => 1,
      BillingFollowUpWorkPriority.normal => 2,
      BillingFollowUpWorkPriority.low => 3,
    };
  }

  String get label {
    return switch (this) {
      BillingFollowUpWorkPriority.urgent => 'Urgent',
      BillingFollowUpWorkPriority.high => 'High',
      BillingFollowUpWorkPriority.normal => 'Normal',
      BillingFollowUpWorkPriority.low => 'Low',
    };
  }
}

/// Display labels and sort rank for follow-up work states.
extension BillingFollowUpWorkStatusX on BillingFollowUpWorkStatus {
  int get rank {
    return switch (this) {
      BillingFollowUpWorkStatus.blocked => 0,
      BillingFollowUpWorkStatus.ready => 1,
      BillingFollowUpWorkStatus.scheduled => 2,
      BillingFollowUpWorkStatus.optional => 3,
    };
  }

  String get label {
    return switch (this) {
      BillingFollowUpWorkStatus.blocked => 'Blocked',
      BillingFollowUpWorkStatus.ready => 'Ready',
      BillingFollowUpWorkStatus.scheduled => 'Scheduled',
      BillingFollowUpWorkStatus.optional => 'Optional',
    };
  }
}

/// Display labels for follow-up work sources.
extension BillingFollowUpWorkSourceX on BillingFollowUpWorkSource {
  String get label {
    return switch (this) {
      BillingFollowUpWorkSource.reliefMonitoring => 'Relief monitoring',
      BillingFollowUpWorkSource.collections => 'Collections',
      BillingFollowUpWorkSource.subscription => 'Subscription',
      BillingFollowUpWorkSource.milestone => 'Milestone',
      BillingFollowUpWorkSource.external => 'External',
    };
  }
}
