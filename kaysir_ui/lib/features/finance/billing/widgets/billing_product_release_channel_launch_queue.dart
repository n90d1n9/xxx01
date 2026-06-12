import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_dispatch_status.dart';
import 'billing_product_release_channel_launch_runbook.dart';

enum BillingProductReleaseChannelLaunchQueueLane {
  readyNow,
  needsRouting,
  blocked,
}

class BillingProductReleaseChannelLaunchQueueItem {
  final String id;
  final String title;
  final String detail;
  final String destinationLabel;
  final String callToActionLabel;
  final String statusLabel;
  final BillingNavigationDestinationId destinationId;
  final BillingProductReleaseChannelLaunchDispatchStatus status;
  final BillingProductReleaseChannelLaunchQueueLane lane;
  final List<String> checklistItems;

  BillingProductReleaseChannelLaunchQueueItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.destinationLabel,
    required this.callToActionLabel,
    required this.statusLabel,
    required this.destinationId,
    BillingProductReleaseChannelLaunchDispatchStatus? status,
    required this.lane,
    Iterable<String> checklistItems = const [],
  }) : status = status ?? _statusForLane(lane),
       checklistItems = List.unmodifiable(checklistItems);

  factory BillingProductReleaseChannelLaunchQueueItem.fromRunbookStep(
    BillingProductReleaseChannelLaunchRunbookStep step,
  ) {
    return BillingProductReleaseChannelLaunchQueueItem(
      id: step.id,
      title: step.title,
      detail: step.detail,
      destinationLabel: step.destinationLabel,
      callToActionLabel: step.callToActionLabel,
      statusLabel: step.statusLabel,
      destinationId: step.destinationId,
      status: step.status,
      lane: _laneForRunbookStep(step),
      checklistItems: step.checklistItems,
    );
  }

  bool get isReady {
    return lane == BillingProductReleaseChannelLaunchQueueLane.readyNow;
  }

  bool get needsWork => !isReady;

  int get priority => _lanePriority(lane);

  Map<String, Object?> get payload {
    return {
      'id': id,
      'title': title,
      'detail': detail,
      'destinationId': destinationId.name,
      'destinationLabel': destinationLabel,
      'callToActionLabel': callToActionLabel,
      'statusLabel': statusLabel,
      'status': status.name,
      'lane': lane.name,
      'priority': priority,
      'checklistItems': checklistItems,
    };
  }
}

class BillingProductReleaseChannelLaunchQueueLaneGroup {
  final BillingProductReleaseChannelLaunchQueueLane lane;
  final List<BillingProductReleaseChannelLaunchQueueItem> items;

  BillingProductReleaseChannelLaunchQueueLaneGroup({
    required this.lane,
    Iterable<BillingProductReleaseChannelLaunchQueueItem> items = const [],
  }) : items = List.unmodifiable(items);

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.length;

  String get label {
    return switch (lane) {
      BillingProductReleaseChannelLaunchQueueLane.readyNow => 'Ready now',
      BillingProductReleaseChannelLaunchQueueLane.needsRouting =>
        'Needs routing',
      BillingProductReleaseChannelLaunchQueueLane.blocked =>
        'Blocked by release',
    };
  }

  String get emptyLabel {
    return switch (lane) {
      BillingProductReleaseChannelLaunchQueueLane.readyNow =>
        'No launch tasks are ready yet.',
      BillingProductReleaseChannelLaunchQueueLane.needsRouting =>
        'No routing work is queued.',
      BillingProductReleaseChannelLaunchQueueLane.blocked =>
        'No release blockers are queued.',
    };
  }

  String get summaryLabel {
    if (isEmpty) return emptyLabel;

    return '$itemCount ${_plural(itemCount, 'task')} '
        '${_laneStateLabel(lane, itemCount)}.';
  }

  Map<String, Object?> get payload {
    return {
      'lane': lane.name,
      'label': label,
      'itemCount': itemCount,
      'items': items.map((item) => item.payload).toList(growable: false),
    };
  }
}

class BillingProductReleaseChannelLaunchQueue {
  final List<BillingProductReleaseChannelLaunchQueueLaneGroup> lanes;

  BillingProductReleaseChannelLaunchQueue({
    Iterable<BillingProductReleaseChannelLaunchQueueLaneGroup> lanes = const [],
  }) : lanes = List.unmodifiable(_normalizeLanes(lanes));

  factory BillingProductReleaseChannelLaunchQueue.fromRunbook(
    BillingProductReleaseChannelLaunchRunbook runbook,
  ) {
    final laneItems =
        <
          BillingProductReleaseChannelLaunchQueueLane,
          List<BillingProductReleaseChannelLaunchQueueItem>
        >{};

    for (final step in runbook.steps) {
      final item = BillingProductReleaseChannelLaunchQueueItem.fromRunbookStep(
        step,
      );
      laneItems.putIfAbsent(item.lane, () => []).add(item);
    }

    return BillingProductReleaseChannelLaunchQueue(
      lanes: BillingProductReleaseChannelLaunchQueueLane.values.map((lane) {
        return BillingProductReleaseChannelLaunchQueueLaneGroup(
          lane: lane,
          items: laneItems[lane] ?? const [],
        );
      }),
    );
  }

  bool get isEmpty => itemCount == 0;

  int get itemCount {
    return lanes.fold(0, (total, lane) => total + lane.itemCount);
  }

  int get readyNowCount {
    return laneFor(
      BillingProductReleaseChannelLaunchQueueLane.readyNow,
    ).itemCount;
  }

  int get needsRoutingCount {
    return laneFor(
      BillingProductReleaseChannelLaunchQueueLane.needsRouting,
    ).itemCount;
  }

  int get blockedCount {
    return laneFor(
      BillingProductReleaseChannelLaunchQueueLane.blocked,
    ).itemCount;
  }

  int get needsWorkCount => needsRoutingCount + blockedCount;

  List<BillingProductReleaseChannelLaunchQueueItem> get items {
    return List.unmodifiable(lanes.expand((lane) => lane.items));
  }

  BillingProductReleaseChannelLaunchQueueItem? get nextReadyItem {
    final readyLane = laneFor(
      BillingProductReleaseChannelLaunchQueueLane.readyNow,
    );
    if (readyLane.items.isEmpty) return null;

    return readyLane.items.first;
  }

  BillingProductReleaseChannelLaunchQueueLaneGroup laneFor(
    BillingProductReleaseChannelLaunchQueueLane lane,
  ) {
    for (final group in lanes) {
      if (group.lane == lane) return group;
    }

    return BillingProductReleaseChannelLaunchQueueLaneGroup(lane: lane);
  }

  Map<String, Object?> get payload {
    return {
      'itemCount': itemCount,
      'readyNowCount': readyNowCount,
      'needsRoutingCount': needsRoutingCount,
      'blockedCount': blockedCount,
      'needsWorkCount': needsWorkCount,
      'lanes': lanes.map((lane) => lane.payload).toList(growable: false),
    };
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No channel launch tasks are queued.';
    }
    if (readyNowCount == 0) {
      return '$needsWorkCount '
          '${_plural(needsWorkCount, 'launch task')} '
          '${_needsWorkVerb(needsWorkCount)} release or routing '
          'work.';
    }
    if (needsWorkCount > 0) {
      return '$readyNowCount '
          '${_plural(readyNowCount, 'launch task')} ready now; '
          '$needsWorkCount need release or routing work.';
    }

    return '$readyNowCount ${_plural(readyNowCount, 'launch task')} ready now.';
  }
}

BillingProductReleaseChannelLaunchQueueLane _laneForRunbookStep(
  BillingProductReleaseChannelLaunchRunbookStep step,
) {
  return _laneForDispatchStatus(step.status);
}

BillingProductReleaseChannelLaunchQueueLane _laneForDispatchStatus(
  BillingProductReleaseChannelLaunchDispatchStatus status,
) {
  if (status.isActionable) {
    return BillingProductReleaseChannelLaunchQueueLane.readyNow;
  }
  if (status.isBlockedByRelease) {
    return BillingProductReleaseChannelLaunchQueueLane.blocked;
  }

  return BillingProductReleaseChannelLaunchQueueLane.needsRouting;
}

BillingProductReleaseChannelLaunchDispatchStatus _statusForLane(
  BillingProductReleaseChannelLaunchQueueLane lane,
) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchQueueLane.readyNow =>
      BillingProductReleaseChannelLaunchDispatchStatus.route,
    BillingProductReleaseChannelLaunchQueueLane.needsRouting =>
      BillingProductReleaseChannelLaunchDispatchStatus.unavailable,
    BillingProductReleaseChannelLaunchQueueLane.blocked =>
      BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease,
  };
}

List<BillingProductReleaseChannelLaunchQueueLaneGroup> _normalizeLanes(
  Iterable<BillingProductReleaseChannelLaunchQueueLaneGroup> lanes,
) {
  final laneMap = {for (final lane in lanes) lane.lane: lane};

  return BillingProductReleaseChannelLaunchQueueLane.values
      .map((lane) {
        return laneMap[lane] ??
            BillingProductReleaseChannelLaunchQueueLaneGroup(lane: lane);
      })
      .toList(growable: false);
}

int _lanePriority(BillingProductReleaseChannelLaunchQueueLane lane) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchQueueLane.readyNow => 0,
    BillingProductReleaseChannelLaunchQueueLane.needsRouting => 100,
    BillingProductReleaseChannelLaunchQueueLane.blocked => 200,
  };
}

String _laneStateLabel(
  BillingProductReleaseChannelLaunchQueueLane lane,
  int count,
) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchQueueLane.readyNow => 'ready',
    BillingProductReleaseChannelLaunchQueueLane.needsRouting =>
      count == 1 ? 'needs routing' : 'need routing',
    BillingProductReleaseChannelLaunchQueueLane.blocked => 'blocked',
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

String _needsWorkVerb(int count) {
  return count == 1 ? 'needs' : 'need';
}
