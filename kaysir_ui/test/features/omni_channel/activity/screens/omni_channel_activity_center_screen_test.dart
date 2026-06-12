import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_center_query_state.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_triage.dart';
import 'package:kaysir/features/omni_channel/activity/omni_channel_activity_routes.dart';
import 'package:kaysir/features/omni_channel/activity/screens/omni_channel_activity_center_screen.dart';
import 'package:kaysir/features/omni_channel/activity/services/omni_channel_activity_action_executor.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_action_executor_provider.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_action_registry_provider.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_provider.dart';

void main() {
  testWidgets('omni-channel activity center filters and resets activity', (
    tester,
  ) async {
    _setViewport(tester, const Size(1120, 920));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [omniChannelActivityFeedProvider.overrideWithValue(_feed())],
        child: MaterialApp(
          home: OmniChannelActivityCenterScreen(onOpenLocation: (_) {}),
        ),
      ),
    );

    expect(find.text('Omni-channel Activity'), findsOneWidget);
    expect(find.text('Omni-channel activity needs attention'), findsOneWidget);
    expect(find.text('Order sync failed'), findsWidgets);
    expect(find.text('Marketplace pickup needs review'), findsOneWidget);
    expect(find.text('Counter payment accepted'), findsOneWidget);
    expect(find.text('All sources'), findsOneWidget);
    expect(find.text('All channels'), findsOneWidget);
    expect(find.text('Registry diagnostics'), findsOneWidget);
    expect(find.text('3 dimensions / 2 action contributors'), findsOneWidget);
    expect(find.text('Point of sale actions'), findsOneWidget);
    expect(find.text('Ecommerce actions'), findsOneWidget);
    expect(
      find.text('Escalate failed POS sync from the activity detail.'),
      findsWidgets,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('omni-channel-activity-source-scope-point_of_sales'),
      ),
    );
    await tester.pump();

    expect(find.text('Order sync failed'), findsWidgets);
    expect(find.text('Marketplace pickup needs review'), findsNothing);
    expect(find.text('Counter payment accepted'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('omni-channel-activity-source-scope-all')),
    );
    await tester.pump();

    final marketplaceTimelineRow = _timelineText(
      'Marketplace pickup needs review',
    );
    await tester.ensureVisible(marketplaceTimelineRow);
    await tester.pump();
    await tester.tap(marketplaceTimelineRow);
    await tester.pump();

    expect(find.text('Review pickup capacity with store ops.'), findsOneWidget);

    await tester.enterText(_searchField(), 'pickup');
    await tester.pump();

    expect(find.text('Marketplace pickup needs review'), findsWidgets);
    expect(_timelineText('Order sync failed'), findsNothing);
    expect(_timelineText('Counter payment accepted'), findsNothing);
    expect(find.text('Open orders'), findsWidgets);
    expect(
      find.byKey(const ValueKey('omni-channel-activity-reset-filter')),
      findsOneWidget,
    );

    final resetFilter = find.byKey(
      const ValueKey('omni-channel-activity-reset-filter'),
    );
    await tester.ensureVisible(resetFilter);
    await tester.pump();
    await tester.tap(resetFilter);
    await tester.pump();

    expect(_timelineText('Order sync failed'), findsOneWidget);
    expect(find.text('Marketplace pickup needs review'), findsWidgets);
    expect(_timelineText('Counter payment accepted'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'omni-channel activity center restores and publishes route state',
    (tester) async {
      _setViewport(tester, const Size(1120, 920));
      String? openedLocation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            omniChannelActivityFeedProvider.overrideWithValue(_feed()),
          ],
          child: MaterialApp(
            home: OmniChannelActivityCenterScreen(
              initialQueryState: const OmniChannelActivityCenterQueryState(
                filter: OmniChannelActivityFilter(
                  status: OmniChannelActivityFilterStatus.orders,
                  sourceId: 'ecommerce',
                ),
                selectedEntryId: 'marketplace-review',
              ),
              onOpenLocation: (location) => openedLocation = location,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(_timelineText('Marketplace pickup needs review'), findsOneWidget);
      expect(_timelineText('Order sync failed'), findsNothing);
      expect(
        find.text('Review pickup capacity with store ops.'),
        findsOneWidget,
      );

      await tester.enterText(_searchField(), 'pickup');
      await tester.pump();

      final location = Uri.parse(openedLocation!);
      expect(location.path, OmniChannelActivityRoutes.activityCenterPath);
      expect(
        location.queryParameters[OmniChannelActivityCenterQueryState
            .searchQueryKey],
        'pickup',
      );
      expect(
        location.queryParameters[OmniChannelActivityCenterQueryState
            .statusQueryKey],
        'orders',
      );
      expect(
        location.queryParameters[OmniChannelActivityCenterQueryState
            .sourceIdQueryKey],
        'ecommerce',
      );
      expect(
        location.queryParameters[OmniChannelActivityCenterQueryState
            .selectedEntryIdQueryKey],
        'marketplace-review',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('omni-channel activity center uses action registry provider', (
    tester,
  ) async {
    _setViewport(tester, const Size(1120, 920));
    String? openedLocation;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          omniChannelActivityFeedProvider.overrideWithValue(_feed()),
          omniChannelActivityActionRegistryProvider.overrideWithValue(
            const OmniChannelActivityActionRegistry(
              contributors: [_activityCenterTestActionContributor],
            ),
          ),
        ],
        child: MaterialApp(
          home: OmniChannelActivityCenterScreen(
            onOpenLocation: (location) => openedLocation = location,
          ),
        ),
      ),
    );

    expect(find.text('Resolve in module'), findsWidgets);

    final actionButton = find.byKey(
      const ValueKey('omni-channel-activity-detail-action-/module-resolution'),
    );

    await tester.ensureVisible(actionButton);
    await tester.pump();
    await tester.tap(actionButton);
    await tester.pump();

    expect(openedLocation, '/module-resolution');
    expect(find.text('Recent action outcomes'), findsOneWidget);
    expect(find.text('Action completed: Resolve in module.'), findsWidgets);
    expect(find.text('Current activity'), findsOneWidget);

    openedLocation = null;
    final selectRecord = find.descendant(
      of: find.byKey(const ValueKey('omni-channel-action-execution-log')),
      matching: find.text('Action completed: Resolve in module.'),
    );
    await tester.ensureVisible(selectRecord);
    await tester.pump();
    await tester.tap(selectRecord);
    await tester.pump();

    final activityLocation = Uri.parse(openedLocation!);
    expect(activityLocation.path, OmniChannelActivityRoutes.activityCenterPath);
    expect(
      activityLocation.queryParameters[OmniChannelActivityCenterQueryState
          .selectedEntryIdQueryKey],
      'sync-failed',
    );

    openedLocation = null;
    final reopenButton = find.byIcon(Icons.open_in_new_outlined);
    await tester.ensureVisible(reopenButton);
    await tester.pump();
    await tester.tap(reopenButton);
    await tester.pump();

    expect(openedLocation, '/module-resolution');
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity center applies triage queue filters', (
    tester,
  ) async {
    _setViewport(tester, const Size(1120, 920));
    String? openedLocation;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [omniChannelActivityFeedProvider.overrideWithValue(_feed())],
        child: MaterialApp(
          home: OmniChannelActivityCenterScreen(
            onOpenLocation: (location) => openedLocation = location,
          ),
        ),
      ),
    );

    final ecommerceQueue = find.byKey(
      const ValueKey('omni-channel-activity-triage-source-ecommerce'),
    );
    await tester.ensureVisible(ecommerceQueue);
    await tester.pump();
    await tester.tap(ecommerceQueue);
    await tester.pump();

    expect(_timelineText('Marketplace pickup needs review'), findsOneWidget);
    expect(_timelineText('Order sync failed'), findsNothing);
    expect(_timelineText('Counter payment accepted'), findsNothing);

    final location = Uri.parse(openedLocation!);
    expect(location.path, OmniChannelActivityRoutes.activityCenterPath);
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .statusQueryKey],
      'review',
    );
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .sourceIdQueryKey],
      'ecommerce',
    );
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .selectedEntryIdQueryKey],
      'marketplace-review',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity center expands triage queues', (
    tester,
  ) async {
    _setViewport(tester, const Size(1120, 920));
    final container = ProviderContainer(
      overrides: [omniChannelActivityFeedProvider.overrideWithValue(_feed())],
    );
    addTearDown(container.dispose);
    container.read(omniChannelActivityTriageQueueLimitProvider.notifier).state =
        2;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: OmniChannelActivityCenterScreen(onOpenLocation: (_) {}),
        ),
      ),
    );

    expect(find.text('3 more queues available'), findsOneWidget);
    expect(find.text('Show all 5 queues'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('omni-channel-activity-triage-source-ecommerce'),
      ),
      findsNothing,
    );

    final toggle = find.byKey(
      const ValueKey('omni-channel-activity-triage-toggle-expanded'),
    );
    await tester.ensureVisible(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pump();

    expect(container.read(omniChannelActivityTriageQueueLimitProvider), isNull);
    expect(find.text('Show fewer queues'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('omni-channel-activity-triage-source-ecommerce'),
      ),
      findsOneWidget,
    );

    await tester.tap(toggle);
    await tester.pump();

    expect(
      container.read(omniChannelActivityTriageQueueLimitProvider),
      defaultOmniChannelActivityTriageGroupLimit,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity center clears completed outcomes', (
    tester,
  ) async {
    _setViewport(tester, const Size(1120, 920));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          omniChannelActivityFeedProvider.overrideWithValue(_feed()),
          omniChannelActivityActionRegistryProvider.overrideWithValue(
            const OmniChannelActivityActionRegistry(
              contributors: [_activityCenterTestActionContributor],
            ),
          ),
        ],
        child: MaterialApp(
          home: OmniChannelActivityCenterScreen(onOpenLocation: (_) {}),
        ),
      ),
    );

    final actionButton = find.byKey(
      const ValueKey('omni-channel-activity-detail-action-/module-resolution'),
    );

    await tester.ensureVisible(actionButton);
    await tester.pump();
    await tester.tap(actionButton);
    await tester.pump();

    expect(find.text('Recent action outcomes'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('omni-channel-action-log-clear-completed')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('omni-channel-action-log-clear-completed')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('omni-channel-action-log-clear-completed')),
    );
    await tester.pump();

    expect(find.text('Recent action outcomes'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity center executes injected handler', (
    tester,
  ) async {
    _setViewport(tester, const Size(1120, 920));
    String? openedLocation;
    final handled = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          omniChannelActivityFeedProvider.overrideWithValue(_feed()),
          omniChannelActivityActionRegistryProvider.overrideWithValue(
            const OmniChannelActivityActionRegistry(
              contributors: [_activityCenterTestActionContributor],
            ),
          ),
          omniChannelActivityActionExecutorProvider.overrideWithValue(
            OmniChannelActivityActionExecutor(
              handlers: [
                OmniChannelActivityActionHandler(
                  id: 'module-resolution-handler',
                  canHandle:
                      (execution) =>
                          execution.action.identity == 'module-resolution',
                  handle: (execution) {
                    handled.add(
                      '${execution.entry.id}:${execution.action.identity}',
                    );

                    return OmniChannelActivityActionExecutionResult.completed(
                      action: execution.action,
                      message: 'Module action handled.',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          home: OmniChannelActivityCenterScreen(
            onOpenLocation: (location) => openedLocation = location,
          ),
        ),
      ),
    );

    final actionButton = find.byKey(
      const ValueKey('omni-channel-activity-detail-action-/module-resolution'),
    );

    await tester.ensureVisible(actionButton);
    await tester.pump();
    await tester.tap(actionButton);
    await tester.pump();

    expect(handled, ['sync-failed:module-resolution']);
    expect(openedLocation, isNull);
    expect(find.text('Recent action outcomes'), findsOneWidget);
    expect(find.text('Module action handled.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity center guards duplicate executions', (
    tester,
  ) async {
    _setViewport(tester, const Size(1120, 920));
    final completion = Completer<OmniChannelActivityActionExecutionResult>();
    late OmniChannelActivityAction pendingAction;
    var handledCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          omniChannelActivityFeedProvider.overrideWithValue(_feed()),
          omniChannelActivityActionRegistryProvider.overrideWithValue(
            const OmniChannelActivityActionRegistry(
              contributors: [_activityCenterTestActionContributor],
            ),
          ),
          omniChannelActivityActionExecutorProvider.overrideWithValue(
            OmniChannelActivityActionExecutor(
              handlers: [
                OmniChannelActivityActionHandler(
                  id: 'slow-module-resolution-handler',
                  canHandle:
                      (execution) =>
                          execution.action.identity == 'module-resolution',
                  handle: (execution) {
                    handledCount++;
                    pendingAction = execution.action;

                    return completion.future;
                  },
                ),
              ],
            ),
          ),
        ],
        child: const MaterialApp(home: OmniChannelActivityCenterScreen()),
      ),
    );

    final actionButton = find.byKey(
      const ValueKey('omni-channel-activity-detail-action-/module-resolution'),
    );

    await tester.ensureVisible(actionButton);
    await tester.pump();
    await tester.tap(actionButton);
    await tester.pump();

    expect(handledCount, 1);
    expect(find.text('Working...'), findsWidgets);

    final runningButton = tester.widget<FilledButton>(actionButton);
    expect(runningButton.onPressed, isNull);

    await tester.tap(actionButton);
    await tester.pump();

    expect(handledCount, 1);

    completion.complete(
      OmniChannelActivityActionExecutionResult.completed(
        action: pendingAction,
        message: 'Slow module action completed.',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Slow module action completed.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'omni-channel activity center retries attention action log records',
    (tester) async {
      _setViewport(tester, const Size(1120, 920));
      final openedLocations = <String>[];
      final handled = <String>[];
      var attempts = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            omniChannelActivityFeedProvider.overrideWithValue(_feed()),
            omniChannelActivityActionRegistryProvider.overrideWithValue(
              const OmniChannelActivityActionRegistry(
                contributors: [_activityCenterTestActionContributor],
              ),
            ),
            omniChannelActivityActionExecutorProvider.overrideWithValue(
              OmniChannelActivityActionExecutor(
                handlers: [
                  OmniChannelActivityActionHandler(
                    id: 'module-resolution-handler',
                    canHandle:
                        (execution) =>
                            execution.action.identity == 'module-resolution',
                    handle: (execution) {
                      attempts++;
                      handled.add(
                        '${execution.entry.id}:${execution.action.identity}',
                      );

                      if (attempts == 1) {
                        return OmniChannelActivityActionExecutionResult.failed(
                          action: execution.action,
                          message: 'Module action failed once.',
                          location: execution.action.location,
                        );
                      }

                      return OmniChannelActivityActionExecutionResult.completed(
                        action: execution.action,
                        message: 'Module action recovered.',
                        location: execution.action.location,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          child: MaterialApp(
            home: OmniChannelActivityCenterScreen(
              onOpenLocation: openedLocations.add,
            ),
          ),
        ),
      );

      final actionButton = find.byKey(
        const ValueKey(
          'omni-channel-activity-detail-action-/module-resolution',
        ),
      );

      await tester.ensureVisible(actionButton);
      await tester.pump();
      await tester.tap(actionButton);
      await tester.pump();

      expect(handled, ['sync-failed:module-resolution']);
      expect(find.text('Module action failed once.'), findsWidgets);
      expect(find.byTooltip('Retry attention outcomes'), findsOneWidget);

      final retryButton = find.byKey(
        const ValueKey('omni-channel-action-log-retry-attention'),
      );
      await tester.ensureVisible(retryButton);
      await tester.pump();
      await tester.tap(retryButton);
      await tester.pump();

      expect(handled, [
        'sync-failed:module-resolution',
        'sync-failed:module-resolution',
      ]);
      expect(find.text('Module action recovered.'), findsWidgets);

      final activityLocation = Uri.parse(openedLocations.last);
      expect(
        activityLocation.path,
        OmniChannelActivityRoutes.activityCenterPath,
      );
      expect(
        activityLocation.queryParameters[OmniChannelActivityCenterQueryState
            .selectedEntryIdQueryKey],
        'sync-failed',
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Finder _timelineText(String text) {
  return find.descendant(
    of: find.byKey(const ValueKey('omni-channel-activity-timeline')),
    matching: find.text(text),
  );
}

Finder _searchField() {
  return find.descendant(
    of: find.byKey(const ValueKey('omni-channel-activity-search')),
    matching: find.byType(TextField),
  );
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

OmniChannelActivityFeed _feed() {
  return OmniChannelActivityFeed(
    entries: [
      OmniChannelActivityEntry(
        id: 'sync-failed',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 11, 30),
        title: 'Order sync failed',
        detail: 'Retry the queued counter order before shift handoff.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'web_store',
        channelLabel: 'Web store',
        orderId: 'POS-2026-014',
        supportSummary: 'Escalate failed POS sync from the activity detail.',
      ),
      OmniChannelActivityEntry(
        id: 'marketplace-review',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11),
        title: 'Marketplace pickup needs review',
        detail: 'Confirm pickup capacity before accepting handoff.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-2026-017',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
        supportSummary: 'Review pickup capacity with store ops.',
        attributes: {'slaWindow': '30 min'},
      ),
      OmniChannelActivityEntry(
        id: 'payment-ready',
        kind: OmniChannelActivityKind.payment,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 10, 45),
        title: 'Counter payment accepted',
        detail: 'Payment matched the ecommerce order workspace.',
        channelId: 'storefront',
        channelLabel: 'Storefront',
        orderId: 'ECOM-2026-016',
      ),
    ],
  );
}

Iterable<OmniChannelActivityAction> _activityCenterTestActionContributor(
  OmniChannelActivityEntry entry,
) sync* {
  yield const OmniChannelActivityAction(
    id: 'module-resolution',
    label: 'Resolve in module',
    location: '/module-resolution',
    tooltip: 'Open the module-provided resolution flow',
    intent: OmniChannelActivityActionIntent.review,
  );
}
