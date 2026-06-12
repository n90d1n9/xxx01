import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_query_state.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/omni_channel_activity_action_registry.dart';

void main() {
  test('omni-channel activity action opens focused order workspace', () {
    final action = omniChannelActivityActionFor(
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
        fulfillmentModeKey: 'pickup',
        orderId: 'ECOM-9',
      ),
    );

    expect(action?.label, 'Open orders');
    final location = Uri.parse(action!.location);
    expect(location.path, '/commerce/orders/marketplace');
    expect(
      location.queryParameters[OrderWorkspaceQueryState.searchQueryKey],
      'ECOM-9',
    );
    expect(
      location.queryParameters[OrderWorkspaceQueryState.channelIdQueryKey],
      'marketplace',
    );
    expect(
      location.queryParameters[OrderWorkspaceQueryState
          .fulfillmentModeQueryKey],
      'pickup',
    );
  });

  test('omni-channel activity action opens cashier for failed POS sync', () {
    final action = omniChannelActivityActionFor(
      OmniChannelActivityEntry(
        id: 'failed-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9),
        title: 'Order sync failed',
        detail: 'Retry the queued order.',
        severity: OmniChannelActivitySeverity.attention,
        orderId: 'POS-1',
      ),
    );

    expect(action?.label, 'Open sync queue');
    expect(action?.location, '/cashier');
  });

  test('omni-channel activity action opens commerce fallback', () {
    final action = omniChannelActivityActionFor(
      OmniChannelActivityEntry(
        id: 'system',
        kind: OmniChannelActivityKind.system,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9),
        title: 'Profile updated',
        detail: 'Commerce profile changed.',
      ),
    );

    expect(action?.label, 'Open commerce');
    expect(action?.location, '/commerce');
  });

  test('omni-channel activity action registry exposes contextual actions', () {
    final actions = omniChannelActivityActionsFor(
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
    expect(actions.first.intent, OmniChannelActivityActionIntent.review);
    expect(actions.last.intent, OmniChannelActivityActionIntent.inspect);
  });

  test('omni-channel activity action registry can be extended by modules', () {
    final registry = omniChannelDefaultActivityActionRegistry.extendWith(
      [
        (entry) => [
          OmniChannelActivityAction(
            id: 'custom-${entry.id}',
            label: 'Escalate issue',
            location: '/commerce/activity/escalations/${entry.id}',
            tooltip: 'Open the module-specific escalation flow',
            intent: OmniChannelActivityActionIntent.review,
            priority: 5,
          ),
          const OmniChannelActivityAction(
            id: 'commerce-workspace',
            label: 'Duplicate commerce action',
            location: '/commerce',
            tooltip: 'Duplicate action should be ignored',
            priority: 40,
          ),
        ],
      ],
      contributorDescriptors: [
        const OmniChannelActivityActionContributorDescriptor(
          id: 'custom_escalation',
          label: 'Custom escalation actions',
          description: 'Module-specific escalation actions',
        ),
      ],
    );

    final actions = registry.actionsFor(
      OmniChannelActivityEntry(
        id: 'review',
        kind: OmniChannelActivityKind.system,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9),
        title: 'Channel issue',
        detail: 'Review the configured channel.',
        severity: OmniChannelActivitySeverity.review,
      ),
    );

    expect(actions.map((action) => action.label), [
      'Open commerce',
      'Escalate issue',
    ]);
    expect(
      registry.resolvedContributorDescriptors.last.id,
      'custom_escalation',
    );
    expect(
      registry.resolvedContributorDescriptors.last.label,
      'Custom escalation actions',
    );
  });

  test('omni-channel activity action set splits priority and availability', () {
    const primary = OmniChannelActivityAction(
      id: 'retry',
      label: 'Open sync queue',
      location: '/cashier',
      tooltip: 'Retry failed sync',
      intent: OmniChannelActivityActionIntent.retry,
    );
    const secondary = OmniChannelActivityAction(
      id: 'cashier',
      label: 'Open cashier',
      location: '/cashier',
      tooltip: 'Open cashier workspace',
      priority: 20,
    );
    const disabled = OmniChannelActivityAction(
      id: 'review',
      label: 'Review order',
      location: '/commerce/orders',
      tooltip: 'Review the order',
      enabled: false,
      disabledReason: 'Order is locked.',
      priority: 30,
    );

    final actionSet = OmniChannelActivityActionSet([
      primary,
      secondary,
      disabled,
    ]);

    expect(actionSet.primary, primary);
    expect(actionSet.secondary, [secondary, disabled]);
    expect(actionSet.enabledActions, [primary, secondary]);
    expect(actionSet.disabledActions, [disabled]);
    expect(actionSet.isNotEmpty, isTrue);
  });
}
