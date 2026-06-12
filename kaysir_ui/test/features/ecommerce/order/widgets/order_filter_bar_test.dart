import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/order/models/order_active_filter_summary.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_manager_view.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_filter_bar.dart';

void main() {
  testWidgets('OrderFilterBar emits channel, status, and search changes', (
    tester,
  ) async {
    var filter = const OrderFilter();
    var sortMode = OrderSortMode.newest;
    String? selectedWorkspaceViewId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: OrderFilterBar(
              filter: filter,
              sortMode: sortMode,
              workspaceViewCounts: const {'all_orders': 4, 'priority_queue': 2},
              channels: SalesChannels.all,
              fulfillmentModes: const [
                OrderFulfillmentOption(key: 'pickup', label: 'Pickup'),
                OrderFulfillmentOption(key: 'delivery', label: 'Delivery'),
              ],
              statuses: const ['completed', 'pending'],
              resultCount: 4,
              onChanged: (next) => filter = next,
              onSortChanged: (next) => sortMode = next,
              onWorkspaceViewSelected: (view) {
                selectedWorkspaceViewId = view.id;
                filter = view.filter;
                sortMode = view.sortMode;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('All orders'), findsWidgets);
    expect(
      find.text(
        '4 matching orders • Show every ecommerce order with the newest orders first.',
      ),
      findsOneWidget,
    );
    expect(find.text('Priority queue'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_active_filter_summary')),
      findsNothing,
    );
    final priorityCount = find.byKey(
      const ValueKey('order_workspace_view_count_priority_queue'),
    );
    expect(priorityCount, findsOneWidget);
    expect(
      find.descendant(of: priorityCount, matching: find.text('2')),
      findsOneWidget,
    );

    await tester.tap(_choiceChip('Priority queue'));
    await tester.pump();
    expect(selectedWorkspaceViewId, 'priority_queue');
    expect(filter.attentionScope, OrderAttentionScope.highPriority);
    expect(sortMode, OrderSortMode.attention);

    await tester.tap(_choiceChip('Today'));
    await tester.pump();
    expect(filter.timeScope, OrderTimeScope.today);

    await tester.tap(_choiceChip('Delivery app'));
    await tester.pump();
    expect(filter.channelId, 'delivery_app');

    await tester.tap(_choiceChip('Delivery'));
    await tester.pump();
    expect(filter.fulfillmentModeKey, 'delivery');

    await tester.tap(_choiceChip('Pending'));
    await tester.pump();
    expect(filter.status, 'pending');

    await tester.tap(_choiceChip('External'));
    await tester.pump();
    expect(filter.paymentScope, OrderPaymentScope.externalSettlement);

    await tester.tap(_choiceChip('High priority'));
    await tester.pump();
    expect(filter.attentionScope, OrderAttentionScope.highPriority);

    await tester.enterText(
      find.byKey(const ValueKey('order_search_field')),
      'amina',
    );
    await tester.pump();
    expect(filter.query, 'amina');

    await tester.tap(find.byKey(const ValueKey('order_sort_menu')));
    await tester.pumpAndSettle();
    await tester.tap(_sortMenuItem(OrderSortMode.highestValue));
    await tester.pumpAndSettle();
    expect(sortMode, OrderSortMode.highestValue);
  });

  testWidgets('OrderFilterBar summarizes active custom filters', (
    tester,
  ) async {
    OrderFilter? clearedFilter;
    OrderSortMode? clearedSortMode;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: OrderFilterBar(
                filter: const OrderFilter(
                  channelId: 'delivery_app',
                  fulfillmentModeKey: 'delivery',
                  status: 'ready',
                  timeScope: OrderTimeScope.today,
                  paymentScope: OrderPaymentScope.externalSettlement,
                  attentionScope: OrderAttentionScope.highPriority,
                  query: 'amina',
                ),
                sortMode: OrderSortMode.highestValue,
                channels: SalesChannels.all,
                fulfillmentModes: const [
                  OrderFulfillmentOption(key: 'delivery', label: 'Delivery'),
                ],
                statuses: const ['ready'],
                resultCount: 1,
                onChanged: (filter) => clearedFilter = filter,
                onSortChanged: (sortMode) => clearedSortMode = sortMode,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_active_filter_summary')),
      findsOneWidget,
    );
    expect(find.text('Channel: Delivery app'), findsOneWidget);
    expect(find.text('Fulfillment: Delivery'), findsOneWidget);
    expect(find.text('Status: Ready'), findsOneWidget);
    expect(find.text('Time: Today'), findsOneWidget);
    expect(find.text('Settlement: External'), findsOneWidget);
    expect(find.text('Attention: High priority'), findsOneWidget);
    expect(find.text('Search: amina'), findsOneWidget);
    expect(find.text('Sort: Highest value'), findsOneWidget);

    await tester.tap(_clearFilterButton('channel'));
    await tester.pump();
    expect(clearedFilter?.channelId, ecommerceOrderAllChannelsFilter);

    await tester.tap(_clearFilterButton('search'));
    await tester.pump();
    expect(clearedFilter?.query, isEmpty);

    await tester.tap(_clearFilterButton('sort'));
    await tester.pump();
    expect(clearedSortMode, OrderSortMode.newest);

    clearedFilter = null;
    clearedSortMode = null;
    await tester.tap(
      find.byKey(const ValueKey('order_active_filter_clear_all')),
    );
    await tester.pump();
    expect(clearedFilter?.hasActiveFilters, isFalse);
    expect(clearedSortMode, OrderSortMode.newest);

    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderFilterBar resets sort-only custom state', (tester) async {
    OrderFilter? clearedFilter;
    OrderSortMode? clearedSortMode;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: OrderFilterBar(
                filter: const OrderFilter(),
                sortMode: OrderSortMode.highestValue,
                channels: SalesChannels.all,
                fulfillmentModes: const [],
                statuses: const [],
                resultCount: 0,
                onChanged: (filter) => clearedFilter = filter,
                onSortChanged: (sortMode) => clearedSortMode = sortMode,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sort: Highest value'), findsOneWidget);
    expect(find.byTooltip('Reset workspace'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset workspace'));
    await tester.pump();

    expect(clearedFilter?.hasActiveFilters, isFalse);
    expect(clearedSortMode, OrderSortMode.newest);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderFilterBar saves, applies, and deletes custom workspaces', (
    tester,
  ) async {
    OrderSavedWorkspace? savedWorkspace;
    OrderSavedWorkspace? selectedWorkspace;
    OrderSavedWorkspace? deletedWorkspace;
    OrderSavedWorkspace? duplicatedWorkspace;
    OrderSavedWorkspace? pinnedWorkspace;
    bool? pinnedState;
    OrderSavedWorkspace? renamedWorkspace;
    String? renamedLabel;
    OrderSavedWorkspace? describedWorkspace;
    String? workspaceDescription;
    OrderSavedWorkspace? resetDescriptionWorkspace;
    List<OrderActiveFilterSummaryItem>? resetDescriptionSummary;
    OrderSavedWorkspace? movedWorkspace;
    OrderSavedWorkspaceMoveDirection? moveDirection;

    const filter = OrderFilter(channelId: 'delivery_app', status: 'ready');
    const sortMode = OrderSortMode.highestValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: OrderFilterBar(
                filter: filter,
                sortMode: sortMode,
                channels: SalesChannels.all,
                fulfillmentModes: const [],
                statuses: const ['ready'],
                resultCount: 1,
                onChanged: (_) {},
                onSortChanged: (_) {},
                onSaveWorkspace: (workspace) => savedWorkspace = workspace,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_empty')),
      findsOneWidget,
    );
    expect(find.text('Custom shortcut ready'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('order_save_current_workspace')),
    );
    await tester.pump();

    expect(savedWorkspace, isNotNull);
    expect(savedWorkspace!.label, 'Delivery app / Ready');

    const secondWorkspace = OrderSavedWorkspace(
      id: 'saved_delivery_today',
      label: 'Delivery / Today',
      description: 'Morning delivery note',
      isDescriptionCustom: true,
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.newest,
    );
    const pinnedShortcut = OrderSavedWorkspace(
      id: 'saved_pickup_priority',
      label: 'Pickup priority',
      description: 'Pinned pickup exceptions',
      filter: OrderFilter(status: 'exception'),
      sortMode: OrderSortMode.attention,
      isPinned: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: OrderFilterBar(
                filter: const OrderFilter(),
                sortMode: OrderSortMode.newest,
                savedWorkspaces: [
                  savedWorkspace!,
                  secondWorkspace,
                  pinnedShortcut,
                ],
                channels: SalesChannels.all,
                fulfillmentModes: const [],
                statuses: const ['ready'],
                resultCount: 4,
                onChanged: (_) {},
                onSortChanged: (_) {},
                onSavedWorkspaceSelected:
                    (workspace) => selectedWorkspace = workspace,
                onSavedWorkspaceDeleted:
                    (workspace) => deletedWorkspace = workspace,
                onSavedWorkspaceDuplicated:
                    (workspace) => duplicatedWorkspace = workspace,
                onSavedWorkspacePinnedChanged: (workspace, isPinned) {
                  pinnedWorkspace = workspace;
                  pinnedState = isPinned;
                },
                onSavedWorkspaceRenamed: (workspace, label) {
                  renamedWorkspace = workspace;
                  renamedLabel = label;
                },
                onSavedWorkspaceDescriptionChanged: (workspace, description) {
                  describedWorkspace = workspace;
                  workspaceDescription = description;
                },
                onSavedWorkspaceDescriptionReset: (workspace, summaryItems) {
                  resetDescriptionWorkspace = workspace;
                  resetDescriptionSummary = summaryItems;
                },
                onSavedWorkspaceMoved: (workspace, direction) {
                  movedWorkspace = workspace;
                  moveDirection = direction;
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_count')),
      findsOneWidget,
    );
    expect(find.text('3 saved'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_pinned_count')),
      findsOneWidget,
    );
    expect(find.text('1 pinned'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_note_count')),
      findsOneWidget,
    );
    expect(find.text('1 note'), findsOneWidget);
    expect(_noteMarker(secondWorkspace.id), findsOneWidget);
    expect(_noteMarker(savedWorkspace!.id), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_manage')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsOneWidget,
    );
    expect(_managerItem(savedWorkspace!.id), findsOneWidget);
    expect(_managerItem(secondWorkspace.id), findsOneWidget);
    expect(_managerItem(pinnedShortcut.id), findsOneWidget);

    await tester.tap(_managerSortButton());
    await tester.pumpAndSettle();
    await tester.tap(
      _managerSortOption(OrderSavedWorkspaceManagerSort.labelAscending),
    );
    await tester.pumpAndSettle();
    expect(find.text('Label A-Z'), findsOneWidget);
    expect(
      tester.getTopLeft(_managerItem(secondWorkspace.id)).dy,
      lessThan(tester.getTopLeft(_managerItem(savedWorkspace!.id)).dy),
    );
    expect(
      tester.getTopLeft(_managerItem(savedWorkspace!.id)).dy,
      lessThan(tester.getTopLeft(_managerItem(pinnedShortcut.id)).dy),
    );

    await _openManagerActions(tester, secondWorkspace.id);
    await tester.tap(_managerPinButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(pinnedWorkspace, secondWorkspace);
    expect(pinnedState, isTrue);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_manage')),
    );
    await tester.pumpAndSettle();

    await _openManagerActions(tester, secondWorkspace.id);
    await tester.tap(_managerRenameButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(find.text('Rename workspace'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_rename_field')),
      '  Manager courier  ',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_rename_save')),
    );
    await tester.pumpAndSettle();
    expect(renamedWorkspace, secondWorkspace);
    expect(renamedLabel, 'Manager courier');
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_manage')),
    );
    await tester.pumpAndSettle();

    await _openManagerActions(tester, secondWorkspace.id);
    await tester.tap(_managerDuplicateButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(duplicatedWorkspace, secondWorkspace);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_manage')),
    );
    await tester.pumpAndSettle();

    await _openManagerActions(tester, secondWorkspace.id);
    await tester.tap(_managerDeleteButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(deletedWorkspace, secondWorkspace);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_manage')),
    );
    await tester.pumpAndSettle();

    await _openManagerActions(tester, secondWorkspace.id);
    await tester.tap(_managerMoveEarlierButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(movedWorkspace, secondWorkspace);
    expect(moveDirection, OrderSavedWorkspaceMoveDirection.earlier);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_manage')),
    );
    await tester.pumpAndSettle();

    await tester.tap(_managerScopeButton('pinned'));
    await tester.pumpAndSettle();
    expect(_managerItem(savedWorkspace!.id), findsNothing);
    expect(_managerItem(secondWorkspace.id), findsNothing);
    expect(_managerItem(pinnedShortcut.id), findsOneWidget);

    await tester.tap(_managerScopeButton('notes'));
    await tester.pumpAndSettle();
    expect(_managerItem(savedWorkspace!.id), findsNothing);
    expect(_managerItem(secondWorkspace.id), findsOneWidget);
    expect(_managerItem(pinnedShortcut.id), findsNothing);

    await _openManagerActions(tester, secondWorkspace.id);
    await tester.tap(_managerEditNoteButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(find.text('Edit workspace note'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_description_field')),
      '  Manager courier note  ',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_description_save')),
    );
    await tester.pumpAndSettle();
    expect(describedWorkspace, secondWorkspace);
    expect(workspaceDescription, 'Manager courier note');
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_manage')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_manager_search')),
      'morning',
    );
    await tester.pump();
    expect(_managerItem(secondWorkspace.id), findsOneWidget);
    expect(_managerItem(savedWorkspace!.id), findsNothing);

    await tester.tap(_managerApplyButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(selectedWorkspace, secondWorkspace);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_manager_dialog')),
      findsNothing,
    );

    await tester.tap(_savedWorkspaceChip(savedWorkspace!.id));
    await tester.pump();
    expect(selectedWorkspace, savedWorkspace);

    await _openSavedWorkspaceActions(tester, savedWorkspace!.id);
    await tester.tap(_detailsSavedWorkspaceButton(savedWorkspace!.id));
    await tester.pumpAndSettle();
    expect(_savedWorkspaceDetailsSurface(), findsOneWidget);
    expect(find.text('Workspace details'), findsOneWidget);
    expect(find.text('Auto summary'), findsOneWidget);
    expect(find.text('Exact filters'), findsOneWidget);
    expect(find.text('Delivery App'), findsOneWidget);
    expect(find.text('Highest value'), findsWidgets);
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
    );
    await tester.pumpAndSettle();
    expect(_savedWorkspaceDetailsSurface(), findsNothing);

    await _openSavedWorkspaceActions(tester, secondWorkspace.id);
    await tester.tap(_detailsSavedWorkspaceButton(secondWorkspace.id));
    await tester.pumpAndSettle();
    expect(find.text('Custom note'), findsOneWidget);
    expect(find.text('Auto summary preview'), findsOneWidget);
    expect(find.text('Channel: Delivery App'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
    );
    await tester.pumpAndSettle();

    await _openSavedWorkspaceActions(tester, savedWorkspace!.id);
    await tester.tap(_pinSavedWorkspaceButton(savedWorkspace!.id));
    await tester.pumpAndSettle();
    expect(pinnedWorkspace, savedWorkspace);
    expect(pinnedState, isTrue);

    await _openSavedWorkspaceActions(tester, savedWorkspace!.id);
    await tester.tap(_duplicateSavedWorkspaceButton(savedWorkspace!.id));
    await tester.pumpAndSettle();
    expect(duplicatedWorkspace, savedWorkspace);

    await _openSavedWorkspaceActions(tester, savedWorkspace!.id);
    await tester.tap(_renameSavedWorkspaceButton(savedWorkspace!.id));
    await tester.pumpAndSettle();
    expect(find.text('Rename workspace'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_rename_field')),
      'Courier rush',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_rename_save')),
    );
    await tester.pumpAndSettle();

    expect(renamedWorkspace, savedWorkspace);
    expect(renamedLabel, 'Courier rush');

    await _openSavedWorkspaceActions(tester, savedWorkspace!.id);
    await tester.tap(_editNoteSavedWorkspaceButton(savedWorkspace!.id));
    await tester.pumpAndSettle();
    expect(find.text('Edit workspace note'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_description_field')),
      '  Morning courier queue  ',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_description_save')),
    );
    await tester.pumpAndSettle();

    expect(describedWorkspace, savedWorkspace);
    expect(workspaceDescription, 'Morning courier queue');

    await _openSavedWorkspaceActions(tester, secondWorkspace.id);
    await tester.tap(_resetNoteSavedWorkspaceButton(secondWorkspace.id));
    await tester.pumpAndSettle();

    expect(resetDescriptionWorkspace, secondWorkspace);
    expect(
      resetDescriptionSummary?.map((item) => item.displayLabel),
      contains('Channel: Delivery app'),
    );

    await _openSavedWorkspaceActions(tester, savedWorkspace!.id);
    await tester.tap(_moveLaterSavedWorkspaceButton(savedWorkspace!.id));
    await tester.pumpAndSettle();
    expect(movedWorkspace, savedWorkspace);
    expect(moveDirection, OrderSavedWorkspaceMoveDirection.later);

    await _openSavedWorkspaceActions(tester, savedWorkspace!.id);
    await tester.tap(_deleteSavedWorkspaceButton(savedWorkspace!.id));
    await tester.pumpAndSettle();
    expect(deletedWorkspace, savedWorkspace);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderFilterBar updates a modified saved workspace', (
    tester,
  ) async {
    OrderSavedWorkspace? updatedWorkspace;
    OrderSavedWorkspace? revertedWorkspace;
    const savedWorkspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: OrderFilterBar(
                filter: savedWorkspace.filter,
                sortMode: savedWorkspace.sortMode,
                savedWorkspaces: const [savedWorkspace],
                activeSavedWorkspaceId: savedWorkspace.id,
                channels: SalesChannels.all,
                fulfillmentModes: const [],
                statuses: const ['ready', 'packed'],
                resultCount: 2,
                onChanged: (_) {},
                onSortChanged: (_) {},
                onSaveWorkspace: (_) {},
                onSavedWorkspaceSelected:
                    (workspace) => revertedWorkspace = workspace,
                onSavedWorkspaceUpdated:
                    (workspace) => updatedWorkspace = workspace,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_modified_notice')),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: OrderFilterBar(
                filter: savedWorkspace.filter.copyWith(status: 'packed'),
                sortMode: OrderSortMode.highestValue,
                savedWorkspaces: const [savedWorkspace],
                activeSavedWorkspaceId: savedWorkspace.id,
                channels: SalesChannels.all,
                fulfillmentModes: const [],
                statuses: const ['ready', 'packed'],
                resultCount: 1,
                onChanged: (_) {},
                onSortChanged: (_) {},
                onSaveWorkspace: (_) {},
                onSavedWorkspaceSelected:
                    (workspace) => revertedWorkspace = workspace,
                onSavedWorkspaceUpdated:
                    (workspace) => updatedWorkspace = workspace,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_modified_notice')),
      findsOneWidget,
    );
    expect(find.text('Delivery ready modified'), findsOneWidget);
    expect(find.text('Changed: Status, Sort'), findsOneWidget);
    expect(find.text('Save as new'), findsOneWidget);
    expect(find.text('Revert'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('order_revert_active_workspace')),
    );
    await tester.pump();

    expect(revertedWorkspace, savedWorkspace);

    await tester.tap(
      find.byKey(const ValueKey('order_update_active_workspace')),
    );
    await tester.pump();

    expect(updatedWorkspace?.id, savedWorkspace.id);
    expect(updatedWorkspace?.label, savedWorkspace.label);
    expect(updatedWorkspace?.filter.status, 'packed');
    expect(updatedWorkspace?.sortMode, OrderSortMode.highestValue);
    expect(updatedWorkspace?.description, contains('Packed'));
    expect(updatedWorkspace?.isDescriptionCustom, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderFilterBar preserves custom notes when updating filters', (
    tester,
  ) async {
    OrderSavedWorkspace? updatedWorkspace;
    const savedWorkspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery ready',
      description: 'Morning courier queue',
      isDescriptionCustom: true,
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: OrderFilterBar(
                filter: savedWorkspace.filter.copyWith(status: 'packed'),
                sortMode: OrderSortMode.highestValue,
                savedWorkspaces: const [savedWorkspace],
                activeSavedWorkspaceId: savedWorkspace.id,
                channels: SalesChannels.all,
                fulfillmentModes: const [],
                statuses: const ['ready', 'packed'],
                resultCount: 1,
                onChanged: (_) {},
                onSortChanged: (_) {},
                onSaveWorkspace: (_) {},
                onSavedWorkspaceUpdated:
                    (workspace) => updatedWorkspace = workspace,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('order_update_active_workspace')),
    );
    await tester.pump();

    expect(updatedWorkspace?.id, savedWorkspace.id);
    expect(updatedWorkspace?.filter.status, 'packed');
    expect(updatedWorkspace?.sortMode, OrderSortMode.highestValue);
    expect(updatedWorkspace?.description, 'Morning courier queue');
    expect(updatedWorkspace?.isDescriptionCustom, isTrue);
    expect(tester.takeException(), isNull);
  });
}

Finder _choiceChip(String label) {
  return find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip));
}

Finder _sortMenuItem(OrderSortMode mode) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CheckedPopupMenuItem<OrderSortMode> && widget.value == mode,
  );
}

Finder _clearFilterButton(String id) {
  return find.byKey(ValueKey('order_active_filter_clear_$id'));
}

Finder _savedWorkspaceChip(String id) {
  return find.byKey(ValueKey('order_saved_workspace_$id'));
}

Finder _noteMarker(String id) {
  return find.byKey(ValueKey('order_saved_workspace_note_marker_$id'));
}

Finder _managerItem(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_$id'));
}

Finder _managerScopeButton(String scope) {
  return find.byKey(ValueKey('order_saved_workspace_manager_scope_$scope'));
}

Finder _managerApplyButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_apply_$id'));
}

Finder _managerSortButton() {
  return find.byKey(const ValueKey('order_saved_workspace_manager_sort'));
}

Finder _managerSortOption(OrderSavedWorkspaceManagerSort sortMode) {
  return find.byKey(
    ValueKey('order_saved_workspace_manager_sort_${sortMode.name}'),
  );
}

Finder _managerActionsButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_actions_$id'));
}

Future<void> _openManagerActions(WidgetTester tester, String id) async {
  final actions = _managerActionsButton(id);
  await tester.ensureVisible(actions);
  await tester.pumpAndSettle();
  await tester.tap(actions);
  await tester.pumpAndSettle();
}

Finder _managerPinButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_pin_$id'));
}

Finder _managerDuplicateButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_duplicate_$id'));
}

Finder _managerDeleteButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_delete_$id'));
}

Finder _managerMoveEarlierButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_move_earlier_$id'));
}

Finder _managerRenameButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_rename_$id'));
}

Finder _managerEditNoteButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_edit_note_$id'));
}

Future<void> _openSavedWorkspaceActions(WidgetTester tester, String id) async {
  final actions = find.byKey(ValueKey('order_saved_workspace_actions_$id'));
  await tester.ensureVisible(actions);
  await tester.pumpAndSettle();
  await tester.tap(actions);
  await tester.pumpAndSettle();
}

Finder _deleteSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_delete_$id'));
}

Finder _detailsSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_details_$id'));
}

Finder _savedWorkspaceDetailsSurface() {
  return find.byWidgetPredicate((widget) {
    return widget.key ==
            const ValueKey('order_saved_workspace_details_dialog') ||
        widget.key ==
            const ValueKey('order_saved_workspace_details_side_sheet') ||
        widget.key == const ValueKey('order_saved_workspace_details_sheet');
  });
}

Finder _pinSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_pin_$id'));
}

Finder _renameSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_rename_$id'));
}

Finder _editNoteSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_edit_note_$id'));
}

Finder _resetNoteSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_reset_note_$id'));
}

Finder _duplicateSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_duplicate_$id'));
}

Finder _moveLaterSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_move_later_$id'));
}
