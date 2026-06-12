import '../utils/billing_product_release_channel.dart';
import '../utils/billing_product_release_edition.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_plan.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_dispatch_summary.dart';
import 'billing_product_release_channel_launch_dispatch_status.dart';

class BillingProductReleaseChannelLaunchDispatchEntry {
  final BillingProductReleaseChannelLaunchAction launchAction;
  final BillingProductReleaseChannelLaunchRouteTarget routeTarget;
  final BillingNavigationDispatchPlan? navigationPlan;

  const BillingProductReleaseChannelLaunchDispatchEntry({
    required this.launchAction,
    required this.routeTarget,
    this.navigationPlan,
  });

  BillingNavigationDestinationId get destinationId {
    return routeTarget.destinationId;
  }

  BillingNavigationDestination get destination {
    return billingNavigationDestinationFor(destinationId);
  }

  bool get hasNavigationPlan => navigationPlan != null;

  bool get isBlockedByRelease {
    return launchAction.isBlocked;
  }

  bool get isActionable {
    return status.isActionable;
  }

  bool get isUnavailable => !isActionable;

  BillingProductReleaseChannelLaunchDispatchStatus get status {
    return billingProductReleaseChannelLaunchDispatchStatusFor(
      isBlockedByRelease: isBlockedByRelease,
      navigationPlan: navigationPlan,
    );
  }

  String get callToActionLabel => routeTarget.callToActionLabel;

  String get operatorStepLabel => routeTarget.operatorStepLabel;

  String get destinationLabel => destination.label;

  String? get disabledReason {
    if (isBlockedByRelease) return launchAction.detail;

    final plan = navigationPlan;
    if (plan == null) {
      return 'Destination is not exposed by this billing domain.';
    }

    return plan.disabledReason;
  }

  String get statusLabel {
    return status.label;
  }

  Map<String, Object?> get payload {
    return {
      'launchActionId': launchAction.id,
      'destinationId': destinationId.name,
      'destinationLabel': destinationLabel,
      'statusLabel': statusLabel,
      'status': status.name,
      'isActionable': isActionable,
      'disabledReason': disabledReason,
      'routeTarget': routeTarget.payload,
    };
  }
}

class BillingProductReleaseChannelLaunchDispatchPlan {
  final List<BillingProductReleaseChannelLaunchDispatchEntry> entries;

  BillingProductReleaseChannelLaunchDispatchPlan({
    Iterable<BillingProductReleaseChannelLaunchDispatchEntry> entries =
        const [],
  }) : entries = List.unmodifiable(entries);

  factory BillingProductReleaseChannelLaunchDispatchPlan.fromLaunchPlan({
    required BillingProductReleaseChannelLaunchPlan launchPlan,
    required BillingNavigationDispatchSnapshot dispatchSnapshot,
    BillingProductReleaseChannelLaunchRoutePolicy? routePolicy,
  }) {
    final policy =
        routePolicy ?? standardBillingProductReleaseChannelLaunchRoutePolicy();

    return BillingProductReleaseChannelLaunchDispatchPlan(
      entries: launchPlan.actions.map((action) {
        final target = policy.targetFor(action);

        return BillingProductReleaseChannelLaunchDispatchEntry(
          launchAction: action,
          routeTarget: target,
          navigationPlan: dispatchSnapshot.planFor(target.destinationId),
        );
      }),
    );
  }

  bool get isEmpty => entries.isEmpty;

  BillingNavigationDispatchSummary get summary {
    var actionableCount = 0;
    var localCount = 0;
    var routeCount = 0;
    var unavailableCount = 0;

    for (final entry in entries) {
      final navigationPlan = entry.navigationPlan;
      if (navigationPlan?.opensRoute ?? false) {
        routeCount += 1;
      } else if (navigationPlan?.isLocal ?? false) {
        localCount += 1;
      }

      if (entry.isActionable) {
        actionableCount += 1;
      } else {
        unavailableCount += 1;
      }
    }

    return BillingNavigationDispatchSummary(
      totalCount: entries.length,
      actionableCount: actionableCount,
      localCount: localCount,
      routeCount: routeCount,
      unavailableCount: unavailableCount,
      ignoredCount: 0,
    );
  }

  int get entryCount => summary.totalCount;

  int get actionableCount => summary.actionableCount;

  int get unavailableCount => summary.unavailableCount;

  int get routeCount => summary.routeCount;

  int get localCount => summary.localCount;

  List<BillingProductReleaseChannelLaunchDispatchEntry> entriesForDestination(
    BillingNavigationDestinationId destinationId,
  ) {
    return List.unmodifiable(
      entries.where((entry) => entry.destinationId == destinationId),
    );
  }

  BillingProductReleaseChannelLaunchDispatchEntry? entryForAction(String id) {
    for (final entry in entries) {
      if (entry.launchAction.id == id) return entry;
    }

    return null;
  }

  BillingProductReleaseChannelLaunchDispatchEntry? entryForTarget({
    required String channelId,
    required String editionId,
  }) {
    final channelKey = billingProductReleaseChannelKey(channelId);
    final editionKey = billingProductReleaseEditionKey(editionId);

    for (final entry in entries) {
      final action = entry.launchAction;
      if (action.channelKey == channelKey && action.editionKey == editionKey) {
        return entry;
      }
    }

    return null;
  }

  BillingProductReleaseChannelLaunchDispatchEntry requireEntryForTarget({
    required String channelId,
    required String editionId,
  }) {
    final entry = entryForTarget(channelId: channelId, editionId: editionId);
    if (entry == null) {
      throw StateError(
        'No billing channel launch dispatch entry exists for '
        '$channelId:$editionId.',
      );
    }

    return entry;
  }

  Map<String, Object?> get payload {
    final summary = this.summary;

    return {
      'entryCount': summary.totalCount,
      'actionableCount': summary.actionableCount,
      'unavailableCount': summary.unavailableCount,
      'blockedCount': summary.blockedCount,
      'routeCount': summary.routeCount,
      'localCount': summary.localCount,
      'entries': entries.map((entry) => entry.payload).toList(growable: false),
    };
  }

  String get summaryLabel {
    final summary = this.summary;

    if (isEmpty) {
      return 'No channel launch routes are available.';
    }
    if (summary.actionableCount == 0) {
      return '${summary.unavailableCount} '
          '${_plural(summary.unavailableCount, 'channel route')} '
          'need routing or readiness work.';
    }
    if (summary.unavailableCount > 0) {
      return '${summary.actionableCount} '
          '${_plural(summary.actionableCount, 'channel route')} ready; '
          '${summary.unavailableCount} need routing or readiness work.';
    }

    return '${summary.actionableCount} '
        '${_plural(summary.actionableCount, 'channel route')} '
        'ready to open.';
  }
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
