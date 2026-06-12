import 'billing_product_release_channel_matrix.dart';
import 'billing_product_release_channel_registry.dart';
import 'billing_product_release_edition.dart';

enum BillingProductReleaseChannelLaunchLane { publishNow, review, blocked }

class BillingProductReleaseChannelLaunchAction {
  final String id;
  final String channelKey;
  final String channelLabel;
  final String editionKey;
  final String editionLabel;
  final String label;
  final String detail;
  final BillingProductReleaseChannelLaunchLane lane;
  final int priority;

  const BillingProductReleaseChannelLaunchAction({
    required this.id,
    required this.channelKey,
    required this.channelLabel,
    required this.editionKey,
    required this.editionLabel,
    required this.label,
    required this.detail,
    required this.lane,
    required this.priority,
  });

  bool get canPublish {
    return lane == BillingProductReleaseChannelLaunchLane.publishNow;
  }

  bool get needsReview {
    return lane == BillingProductReleaseChannelLaunchLane.review;
  }

  bool get isBlocked {
    return lane == BillingProductReleaseChannelLaunchLane.blocked;
  }

  String get laneLabel {
    return switch (lane) {
      BillingProductReleaseChannelLaunchLane.publishNow => 'Launch now',
      BillingProductReleaseChannelLaunchLane.review => 'Review',
      BillingProductReleaseChannelLaunchLane.blocked => 'Blocked',
    };
  }

  Map<String, Object?> get payload {
    return {
      'id': id,
      'channelKey': channelKey,
      'channelLabel': channelLabel,
      'editionKey': editionKey,
      'editionLabel': editionLabel,
      'lane': lane.name,
      'laneLabel': laneLabel,
      'label': label,
      'detail': detail,
      'priority': priority,
    };
  }
}

class BillingProductReleaseChannelLaunchPlan {
  final List<BillingProductReleaseChannelLaunchAction> actions;

  BillingProductReleaseChannelLaunchPlan({
    Iterable<BillingProductReleaseChannelLaunchAction> actions = const [],
  }) : actions = List.unmodifiable(_sortActions(actions));

  factory BillingProductReleaseChannelLaunchPlan.forMatrix(
    BillingProductReleaseChannelMatrix matrix,
  ) {
    return BillingProductReleaseChannelLaunchPlan(
      actions: matrix.targetedCells.map(_actionForCell),
    );
  }

  bool get isEmpty => actions.isEmpty;

  int get actionCount => actions.length;

  int get channelCount {
    return actions.map((action) => action.channelKey).toSet().length;
  }

  int get publishNowCount {
    return actionsForLane(
      BillingProductReleaseChannelLaunchLane.publishNow,
    ).length;
  }

  int get reviewCount {
    return actionsForLane(BillingProductReleaseChannelLaunchLane.review).length;
  }

  int get blockedCount {
    return actionsForLane(
      BillingProductReleaseChannelLaunchLane.blocked,
    ).length;
  }

  List<BillingProductReleaseChannelLaunchAction> actionsForLane(
    BillingProductReleaseChannelLaunchLane lane,
  ) {
    return List.unmodifiable(actions.where((action) => action.lane == lane));
  }

  List<BillingProductReleaseChannelLaunchAction> actionsForChannel(String id) {
    final key = billingProductReleaseChannelKey(id);

    return List.unmodifiable(
      actions.where((action) => action.channelKey == key),
    );
  }

  BillingProductReleaseChannelLaunchAction? actionForTarget({
    required String channelId,
    required String editionId,
  }) {
    final channelKey = billingProductReleaseChannelKey(channelId);
    final editionKey = billingProductReleaseEditionKey(editionId);

    for (final action in actions) {
      if (action.channelKey == channelKey && action.editionKey == editionKey) {
        return action;
      }
    }

    return null;
  }

  BillingProductReleaseChannelLaunchAction requireActionForTarget({
    required String channelId,
    required String editionId,
  }) {
    final action = actionForTarget(channelId: channelId, editionId: editionId);
    if (action == null) {
      throw StateError(
        'No billing product release channel launch action exists for '
        '$channelId:$editionId.',
      );
    }

    return action;
  }

  Map<String, Object?> get payload {
    return {
      'actionCount': actionCount,
      'channelCount': channelCount,
      'publishNowCount': publishNowCount,
      'reviewCount': reviewCount,
      'blockedCount': blockedCount,
      'actions': actions
          .map((action) => action.payload)
          .toList(growable: false),
    };
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No billing product release channel launch actions are available.';
    }
    if (blockedCount > 0) {
      return '$blockedCount ${_plural(blockedCount, 'channel launch')} need '
          'blockers cleared.';
    }
    if (publishNowCount > 0 && reviewCount > 0) {
      return '$publishNowCount '
          '${_plural(publishNowCount, 'channel launch')} can publish; '
          '$reviewCount need review.';
    }
    if (reviewCount > 0) {
      return '$reviewCount ${_plural(reviewCount, 'channel launch')} need '
          'review.';
    }

    return '$publishNowCount ${_plural(publishNowCount, 'channel launch')} '
        'can publish now.';
  }
}

BillingProductReleaseChannelLaunchAction _actionForCell(
  BillingProductReleaseChannelCell cell,
) {
  final lane = _laneForCell(cell);

  return BillingProductReleaseChannelLaunchAction(
    id: '${cell.channel.key}:${cell.editionPlan.id}:${lane.name}',
    channelKey: cell.channel.key,
    channelLabel: cell.channel.label,
    editionKey: cell.editionPlan.id,
    editionLabel: cell.editionPlan.label,
    label: _labelForCell(cell, lane),
    detail: cell.actionDetail,
    lane: lane,
    priority: _lanePriority(lane),
  );
}

BillingProductReleaseChannelLaunchLane _laneForCell(
  BillingProductReleaseChannelCell cell,
) {
  return switch (cell.state) {
    BillingProductReleaseChannelCellState.publishNow =>
      BillingProductReleaseChannelLaunchLane.publishNow,
    BillingProductReleaseChannelCellState.review =>
      BillingProductReleaseChannelLaunchLane.review,
    BillingProductReleaseChannelCellState.blocked ||
    BillingProductReleaseChannelCellState
        .notTargeted => BillingProductReleaseChannelLaunchLane.blocked,
  };
}

String _labelForCell(
  BillingProductReleaseChannelCell cell,
  BillingProductReleaseChannelLaunchLane lane,
) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchLane.publishNow =>
      'Publish ${cell.editionPlan.label} on ${cell.channel.label}',
    BillingProductReleaseChannelLaunchLane.review =>
      'Review ${cell.editionPlan.label} for ${cell.channel.label}',
    BillingProductReleaseChannelLaunchLane.blocked =>
      'Clear ${cell.editionPlan.label} blockers for ${cell.channel.label}',
  };
}

List<BillingProductReleaseChannelLaunchAction> _sortActions(
  Iterable<BillingProductReleaseChannelLaunchAction> actions,
) {
  final sorted = actions.toList(growable: false);
  sorted.sort((left, right) {
    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    final channel = left.channelKey.compareTo(right.channelKey);
    if (channel != 0) return channel;

    return left.editionKey.compareTo(right.editionKey);
  });
  return sorted;
}

int _lanePriority(BillingProductReleaseChannelLaunchLane lane) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchLane.publishNow => 0,
    BillingProductReleaseChannelLaunchLane.review => 100,
    BillingProductReleaseChannelLaunchLane.blocked => 200,
  };
}

String _plural(int count, String singular) {
  if (count == 1) return singular;
  if (singular.endsWith('ch')) return '${singular}es';

  return '${singular}s';
}
