import '../utils/billing_product_release_channel.dart';
import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_dispatch_plan.dart';
import 'billing_product_release_channel_launch_dispatch_status.dart';

class BillingProductReleaseChannelLaunchActionItem {
  final BillingProductReleaseChannelLaunchAction action;
  final BillingProductReleaseChannelLaunchDispatchEntry? dispatchEntry;

  const BillingProductReleaseChannelLaunchActionItem({
    required this.action,
    this.dispatchEntry,
  });

  String get id => action.id;

  String get channelKey => action.channelKey;

  String get editionKey => action.editionKey;

  BillingProductReleaseChannelLaunchLane get lane => action.lane;

  BillingNavigationDestinationId? get destinationId {
    return dispatchEntry?.destinationId;
  }

  BillingProductReleaseChannelLaunchDispatchStatus? get dispatchStatus {
    return dispatchEntry?.status;
  }

  bool get hasDispatchEntry => dispatchEntry != null;

  bool get isActionable => dispatchEntry?.isActionable ?? false;

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return [
      action.label,
      action.detail,
      action.channelLabel,
      action.editionLabel,
      action.laneLabel,
      dispatchEntry?.destinationLabel,
      dispatchEntry?.statusLabel,
      dispatchEntry?.callToActionLabel,
    ].whereType<String>().join(' ').toLowerCase().contains(normalizedQuery);
  }
}

class BillingProductReleaseChannelLaunchActionFeed {
  final List<BillingProductReleaseChannelLaunchActionItem> items;

  BillingProductReleaseChannelLaunchActionFeed({
    Iterable<BillingProductReleaseChannelLaunchActionItem> items = const [],
  }) : items = List.unmodifiable(items);

  factory BillingProductReleaseChannelLaunchActionFeed.fromPlan({
    required BillingProductReleaseChannelLaunchPlan launchPlan,
    BillingProductReleaseChannelLaunchDispatchPlan? dispatchPlan,
  }) {
    return BillingProductReleaseChannelLaunchActionFeed(
      items: launchPlan.actions.map((action) {
        return BillingProductReleaseChannelLaunchActionItem(
          action: action,
          dispatchEntry: dispatchPlan?.entryForAction(action.id),
        );
      }),
    );
  }

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.length;

  int get actionableCount {
    return items.where((item) => item.isActionable).length;
  }

  int get missingDispatchCount {
    return items.where((item) => !item.hasDispatchEntry).length;
  }

  List<BillingProductReleaseChannelLaunchActionItem> itemsForLane(
    BillingProductReleaseChannelLaunchLane lane,
  ) {
    return List.unmodifiable(items.where((item) => item.lane == lane));
  }

  List<BillingProductReleaseChannelLaunchActionItem> itemsForDispatchStatus(
    BillingProductReleaseChannelLaunchDispatchStatus status,
  ) {
    return List.unmodifiable(
      items.where((item) => item.dispatchStatus == status),
    );
  }

  List<BillingProductReleaseChannelLaunchActionItem> itemsForDestination(
    BillingNavigationDestinationId destinationId,
  ) {
    return List.unmodifiable(
      items.where((item) => item.destinationId == destinationId),
    );
  }

  List<BillingProductReleaseChannelLaunchActionItem> itemsForChannel(
    String channelKey,
  ) {
    return List.unmodifiable(
      items.where((item) => item.channelKey == channelKey),
    );
  }

  List<BillingProductReleaseChannelLaunchActionItem> itemsForEdition(
    String editionKey,
  ) {
    return List.unmodifiable(
      items.where((item) => item.editionKey == editionKey),
    );
  }

  List<BillingProductReleaseChannelLaunchActionItem> search(String query) {
    return List.unmodifiable(items.where((item) => item.matchesQuery(query)));
  }
}
