import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_center_query_state.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_insight.dart';
import 'package:kaysir/features/omni_channel/activity/omni_channel_activity_routes.dart';

void main() {
  test('omni-channel activity center query state round-trips filters', () {
    const state = OmniChannelActivityCenterQueryState(
      filter: OmniChannelActivityFilter(
        query: 'pickup',
        status: OmniChannelActivityFilterStatus.orders,
        sourceId: 'ecommerce',
        channelId: 'marketplace',
        orderId: 'ECOM-1',
        fulfillmentModeKey: 'pickup',
      ),
      selectedEntryId: 'activity-1',
    );

    final location = state.locationForPath(
      OmniChannelActivityRoutes.activityCenterPath,
    );
    final uri = Uri.parse(location);

    expect(uri.path, OmniChannelActivityRoutes.activityCenterPath);
    expect(
      uri.queryParameters[OmniChannelActivityCenterQueryState.searchQueryKey],
      'pickup',
    );
    expect(
      uri.queryParameters[OmniChannelActivityCenterQueryState.statusQueryKey],
      'orders',
    );
    expect(
      uri.queryParameters[OmniChannelActivityCenterQueryState.sourceIdQueryKey],
      'ecommerce',
    );
    expect(
      uri.queryParameters[OmniChannelActivityCenterQueryState
          .channelIdQueryKey],
      'marketplace',
    );
    expect(
      uri.queryParameters[OmniChannelActivityCenterQueryState.orderIdQueryKey],
      'ECOM-1',
    );
    expect(
      uri.queryParameters[OmniChannelActivityCenterQueryState
          .fulfillmentModeQueryKey],
      'pickup',
    );
    expect(
      uri.queryParameters[OmniChannelActivityCenterQueryState
          .selectedEntryIdQueryKey],
      'activity-1',
    );

    final decoded = OmniChannelActivityCenterQueryState.fromQueryParameters(
      uri.queryParameters,
    );

    expect(decoded, state);
  });

  test('omni-channel activity center query state omits defaults safely', () {
    const defaults = OmniChannelActivityCenterQueryState();

    expect(defaults.toQueryParameters(), isEmpty);
    expect(
      OmniChannelActivityCenterQueryState.fromQueryParameters(const {}),
      isNull,
    );

    final decoded =
        OmniChannelActivityCenterQueryState.fromQueryParameters(const {
          OmniChannelActivityCenterQueryState.statusQueryKey: 'unknown',
          OmniChannelActivityCenterQueryState.searchQueryKey: '  sync  ',
        });

    expect(decoded, isNotNull);
    expect(decoded!.filter.query, 'sync');
    expect(decoded.filter.status, OmniChannelActivityFilterStatus.all);
    expect(decoded.selectedEntryId, isNull);
  });

  test('omni-channel activity center query state builds from insight', () {
    final insight = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(
        entries: [
          OmniChannelActivityEntry(
            id: 'review',
            kind: OmniChannelActivityKind.order,
            sourceId: 'ecommerce',
            sourceLabel: 'Ecommerce',
            occurredAt: DateTime(2026, 6, 9),
            title: 'Marketplace order needs review',
            detail: 'Confirm pickup capacity.',
            severity: OmniChannelActivitySeverity.review,
            channelId: 'marketplace',
            orderId: 'ECOM-1',
            fulfillmentModeKey: 'pickup',
          ),
        ],
      ),
    );

    final state = OmniChannelActivityCenterQueryState.fromInsight(insight);

    expect(state.filter.status, OmniChannelActivityFilterStatus.review);
    expect(state.filter.sourceId, 'ecommerce');
    expect(state.filter.channelId, 'marketplace');
    expect(state.filter.orderId, 'ECOM-1');
    expect(state.filter.fulfillmentModeKey, 'pickup');
    expect(state.selectedEntryId, 'review');
  });
}
