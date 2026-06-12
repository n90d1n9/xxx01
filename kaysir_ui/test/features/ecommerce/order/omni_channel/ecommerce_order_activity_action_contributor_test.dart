import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_query_state.dart';
import 'package:kaysir/features/ecommerce/order/omni_channel/ecommerce_order_activity_action_contributor.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';

void main() {
  test(
    'ecommerce order activity contributor opens focused order workspace',
    () {
      final registry = const OmniChannelActivityActionRegistry(
        contributors: [ecommerceOrderActivityActionContributor],
      );

      final actions = registry.actionsFor(
        OmniChannelActivityEntry(
          id: 'marketplace-order',
          kind: OmniChannelActivityKind.order,
          sourceId: 'ecommerce',
          sourceLabel: 'Ecommerce',
          occurredAt: DateTime(2026, 6, 9),
          title: 'Marketplace pickup needs review',
          detail: 'Confirm pickup capacity.',
          severity: OmniChannelActivitySeverity.review,
          channelId: 'marketplace',
          orderId: 'ECOM-9',
        ),
      );

      expect(actions.map((action) => action.label), [
        'Open orders',
        'Open commerce',
      ]);

      final location = Uri.parse(actions.first.location);
      expect(location.path, '/commerce/orders/marketplace');
      expect(
        location.queryParameters[OrderWorkspaceQueryState.searchQueryKey],
        'ECOM-9',
      );
      expect(
        location.queryParameters[OrderWorkspaceQueryState.channelIdQueryKey],
        'marketplace',
      );
    },
  );
}
