import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_active_filter_summary.dart';
import '../models/order_attention.dart';
import '../models/order_filter.dart';
import '../models/order_fulfillment_filter.dart';
import '../models/order_payment_scope.dart';
import '../models/order_saved_workspace.dart';
import '../models/order_sort.dart';
import '../models/order_workspace_view.dart';
import 'order_active_filter_summary.dart';
import 'order_filter_choice_strip.dart';
import 'order_search_field.dart';
import 'order_saved_workspace_panel.dart';
import 'order_sort_menu.dart';
import 'order_workspace_view_strip.dart';

class OrderFilterBar extends StatelessWidget {
  final OrderFilter filter;
  final OrderSortMode sortMode;
  final List<OrderWorkspaceView> workspaceViews;
  final Map<String, int> workspaceViewCounts;
  final List<POSCommerceChannel> channels;
  final List<OrderFulfillmentOption> fulfillmentModes;
  final List<String> statuses;
  final List<OrderSavedWorkspace> savedWorkspaces;
  final String? activeSavedWorkspaceId;
  final int resultCount;
  final ValueChanged<OrderFilter> onChanged;
  final ValueChanged<OrderSortMode> onSortChanged;
  final ValueChanged<OrderWorkspaceView>? onWorkspaceViewSelected;
  final ValueChanged<OrderSavedWorkspace>? onSaveWorkspace;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceUpdated;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceSelected;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceDeleted;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceDuplicated;
  final void Function(OrderSavedWorkspace workspace, bool isPinned)?
  onSavedWorkspacePinnedChanged;
  final void Function(OrderSavedWorkspace workspace, String label)?
  onSavedWorkspaceRenamed;
  final void Function(OrderSavedWorkspace workspace, String description)?
  onSavedWorkspaceDescriptionChanged;
  final void Function(
    OrderSavedWorkspace workspace,
    List<OrderActiveFilterSummaryItem> summaryItems,
  )?
  onSavedWorkspaceDescriptionReset;
  final void Function(
    OrderSavedWorkspace workspace,
    OrderSavedWorkspaceMoveDirection direction,
  )?
  onSavedWorkspaceMoved;

  const OrderFilterBar({
    super.key,
    required this.filter,
    this.sortMode = OrderSortMode.newest,
    this.workspaceViews = ecommerceDefaultOrderWorkspaceViews,
    this.workspaceViewCounts = const {},
    required this.channels,
    required this.fulfillmentModes,
    required this.statuses,
    this.savedWorkspaces = const [],
    this.activeSavedWorkspaceId,
    required this.resultCount,
    required this.onChanged,
    required this.onSortChanged,
    this.onWorkspaceViewSelected,
    this.onSaveWorkspace,
    this.onSavedWorkspaceUpdated,
    this.onSavedWorkspaceSelected,
    this.onSavedWorkspaceDeleted,
    this.onSavedWorkspaceDuplicated,
    this.onSavedWorkspacePinnedChanged,
    this.onSavedWorkspaceRenamed,
    this.onSavedWorkspaceDescriptionChanged,
    this.onSavedWorkspaceDescriptionReset,
    this.onSavedWorkspaceMoved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workspaceContext = ecommerceOrderWorkspaceContext(
      views: workspaceViews,
      filter: filter,
      sortMode: sortMode,
    );
    final activeFilterSummary = ecommerceOrderActiveFilterSummary(
      filter: filter,
      sortMode: sortMode,
      channels: channels,
      fulfillmentModes: fulfillmentModes,
    );
    final savedWorkspaceState = ecommerceOrderSavedWorkspaceFilterState(
      savedWorkspaces: savedWorkspaces,
      activeSavedWorkspaceId: activeSavedWorkspaceId,
      filter: filter,
      sortMode: sortMode,
      workspaceContext: workspaceContext,
      activeFilterSummary: activeFilterSummary,
      canSaveWorkspace: onSaveWorkspace != null,
    );

    void applyWorkspaceView(OrderWorkspaceView view) {
      final handler = onWorkspaceViewSelected;
      if (handler != null) {
        handler(view);
        return;
      }

      onChanged(view.filter);
      onSortChanged(view.sortMode);
    }

    void applySavedWorkspace(OrderSavedWorkspace workspace) {
      final handler = onSavedWorkspaceSelected;
      if (handler != null) {
        handler(workspace);
        return;
      }

      onChanged(workspace.filter);
      onSortChanged(workspace.sortMode);
    }

    void saveCurrentWorkspace() {
      final handler = onSaveWorkspace;
      if (handler == null) return;

      handler(
        ecommerceOrderSavedWorkspaceFromState(
          filter: filter,
          sortMode: sortMode,
          summaryItems: activeFilterSummary,
          index: savedWorkspaces.length + 1,
        ),
      );
    }

    void updateActiveSavedWorkspace() {
      final handler = onSavedWorkspaceUpdated;
      final workspace = savedWorkspaceState.trackedWorkspace;
      if (handler == null || workspace == null) return;

      handler(
        ecommerceOrderSavedWorkspaceWithState(
          workspace: workspace,
          filter: filter,
          sortMode: sortMode,
          summaryItems: activeFilterSummary,
        ),
      );
    }

    void revertActiveSavedWorkspace() {
      final workspace = savedWorkspaceState.trackedWorkspace;
      if (workspace == null) return;

      applySavedWorkspace(workspace);
    }

    void resetSavedWorkspaceDescription(OrderSavedWorkspace workspace) {
      final handler = onSavedWorkspaceDescriptionReset;
      if (handler == null) return;

      handler(
        workspace,
        ecommerceOrderActiveFilterSummary(
          filter: workspace.filter,
          sortMode: workspace.sortMode,
          channels: channels,
          fulfillmentModes: fulfillmentModes,
        ),
      );
    }

    void clearActiveFilter(OrderActiveFilterSummaryType type) {
      final nextState = ecommerceOrderActiveFilterStateAfterClear(
        filter: filter,
        sortMode: sortMode,
        type: type,
      );

      if (!ecommerceOrderFiltersEqual(filter, nextState.filter)) {
        onChanged(nextState.filter);
      }
      if (sortMode != nextState.sortMode) {
        onSortChanged(nextState.sortMode);
      }
    }

    return POSSurface(
      padding: const EdgeInsets.all(12),
      border: Border.all(color: theme.dividerColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              POSIconBadge(
                icon: Icons.tune_outlined,
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workspaceContext.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ecommerceOrderWorkspaceResultText(resultCount)} • ${workspaceContext.description}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (activeFilterSummary.isNotEmpty)
                IconButton(
                  tooltip: 'Reset workspace',
                  onPressed:
                      () => applyWorkspaceView(ecommerceAllOrdersWorkspaceView),
                  icon: const Icon(Icons.refresh_outlined),
                ),
              OrderSortMenu(sortMode: sortMode, onChanged: onSortChanged),
            ],
          ),
          if (activeFilterSummary.isNotEmpty) ...[
            const SizedBox(height: POSUiTokens.gapLarge),
            OrderActiveFilterSummary(
              items: activeFilterSummary,
              onClear: clearActiveFilter,
              onClearAll:
                  () => applyWorkspaceView(ecommerceAllOrdersWorkspaceView),
            ),
          ],
          if (savedWorkspaceState.shouldShowSavedWorkspacePanel) ...[
            const SizedBox(height: POSUiTokens.gapLarge),
            OrderSavedWorkspacePanel(
              workspaces: savedWorkspaceState.visibleWorkspaces,
              activeWorkspaceId: savedWorkspaceState.activeWorkspace?.id,
              isActiveWorkspaceModified:
                  savedWorkspaceState.isActiveWorkspaceModified,
              activeWorkspaceChangeSummary:
                  savedWorkspaceState.activeWorkspaceChangeSummary,
              canSaveCurrent: savedWorkspaceState.canSaveCurrentWorkspace,
              onSaveCurrent: saveCurrentWorkspace,
              onUpdateActive:
                  savedWorkspaceState.isActiveWorkspaceModified
                      ? updateActiveSavedWorkspace
                      : null,
              onRevertActive:
                  savedWorkspaceState.isActiveWorkspaceModified
                      ? revertActiveSavedWorkspace
                      : null,
              onSelected: applySavedWorkspace,
              onDeleted: onSavedWorkspaceDeleted,
              onDuplicated: onSavedWorkspaceDuplicated,
              onPinnedChanged: onSavedWorkspacePinnedChanged,
              onRenamed: onSavedWorkspaceRenamed,
              onDescriptionChanged: onSavedWorkspaceDescriptionChanged,
              onDescriptionReset:
                  onSavedWorkspaceDescriptionReset == null
                      ? null
                      : resetSavedWorkspaceDescription,
              onMoved: onSavedWorkspaceMoved,
            ),
          ],
          if (workspaceViews.isNotEmpty) ...[
            const SizedBox(height: POSUiTokens.gapLarge),
            OrderWorkspaceViewStrip(
              views: workspaceViews,
              activeFilter: filter,
              activeSortMode: sortMode,
              counts: workspaceViewCounts,
              onSelected: applyWorkspaceView,
            ),
          ],
          const SizedBox(height: POSUiTokens.gapLarge),
          OrderSearchField(
            query: filter.query,
            onChanged: (query) => onChanged(filter.copyWith(query: query)),
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          OrderFilterChoiceStrip(
            label: 'Time',
            children: OrderTimeScope.values
                .map(
                  (scope) => POSChoicePill(
                    label: scope.label,
                    selected: filter.timeScope == scope,
                    onSelected:
                        (_) => onChanged(filter.copyWith(timeScope: scope)),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: POSUiTokens.gap),
          OrderFilterChoiceStrip(
            label: 'Channel',
            children: [
              POSChoicePill(
                label: 'All',
                selected: filter.channelId == ecommerceOrderAllChannelsFilter,
                onSelected:
                    (_) => onChanged(
                      filter.copyWith(
                        channelId: ecommerceOrderAllChannelsFilter,
                      ),
                    ),
              ),
              ...channels.map(
                (channel) => POSChoicePill(
                  label: channel.label,
                  selected: filter.channelId == channel.id,
                  onSelected:
                      (_) => onChanged(filter.copyWith(channelId: channel.id)),
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gap),
          OrderFilterChoiceStrip(
            label: 'Fulfillment',
            children: [
              POSChoicePill(
                label: 'All',
                selected:
                    filter.fulfillmentModeKey ==
                    ecommerceOrderAllFulfillmentModesFilter,
                onSelected:
                    (_) => onChanged(
                      filter.copyWith(
                        fulfillmentModeKey:
                            ecommerceOrderAllFulfillmentModesFilter,
                      ),
                    ),
              ),
              ...fulfillmentModes.map(
                (mode) => POSChoicePill(
                  label: mode.label,
                  selected: filter.fulfillmentModeKey == mode.key,
                  onSelected:
                      (_) => onChanged(
                        filter.copyWith(fulfillmentModeKey: mode.key),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gap),
          OrderFilterChoiceStrip(
            label: 'Status',
            children: [
              POSChoicePill(
                label: 'All',
                selected: filter.status == ecommerceOrderAllStatusesFilter,
                onSelected:
                    (_) => onChanged(
                      filter.copyWith(status: ecommerceOrderAllStatusesFilter),
                    ),
              ),
              ...statuses.map(
                (status) => POSChoicePill(
                  label: _statusLabel(status),
                  selected: filter.status == status,
                  onSelected: (_) => onChanged(filter.copyWith(status: status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gap),
          OrderFilterChoiceStrip(
            label: 'Settlement',
            children: OrderPaymentScope.values
                .map(
                  (scope) => POSChoicePill(
                    label: scope.label,
                    selected: filter.paymentScope == scope,
                    onSelected:
                        (_) => onChanged(filter.copyWith(paymentScope: scope)),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: POSUiTokens.gap),
          OrderFilterChoiceStrip(
            label: 'Attention',
            children: OrderAttentionScope.values
                .map(
                  (scope) => POSChoicePill(
                    label: scope.label,
                    selected: filter.attentionScope == scope,
                    onSelected:
                        (_) =>
                            onChanged(filter.copyWith(attentionScope: scope)),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    return ecommerceOrderStatusSummaryLabel(status);
  }
}
