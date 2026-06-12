import 'package:flutter/material.dart';

import '../../cashier/utils/pos_browser_filter_controller.dart';
import '../../cashier/widgets/pos_browser_controls.dart';
import '../../cashier/widgets/pos_browser_filter_host.dart';
import '../../cashier/widgets/pos_inline_notice.dart';
import '../../cashier/widgets/pos_segmented_filter_bar.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox.dart';
import '../utils/order_save_outbox_actions.dart';
import '../utils/order_save_outbox_browser_state.dart';
import '../utils/order_save_outbox_display.dart';
import '../utils/order_save_outbox_summary.dart';
import '../utils/order_save_outbox_sync_behavior.dart';
import '../utils/order_save_outbox_sync_state.dart';
import 'order_save_outbox_entry_tile.dart';

class OrderSaveOutboxBrowser extends StatefulWidget {
  final POSOrderSaveOutbox outbox;
  final POSOrderSaveOutboxSummary summary;
  final POSOrderSaveOutboxSyncState syncState;
  final POSOrderSaveOutboxSyncBehavior syncBehavior;
  final POSOrderSaveOutboxViewFilter? initialFilter;
  final ValueChanged<POSOrderSaveOutboxEntry>? onRetry;
  final ValueChanged<List<POSOrderSaveOutboxEntry>>? onRetryEntries;

  const OrderSaveOutboxBrowser({
    super.key,
    required this.outbox,
    required this.summary,
    required this.syncState,
    this.syncBehavior = POSOrderSaveOutboxSyncBehavior.standard,
    this.initialFilter,
    this.onRetry,
    this.onRetryEntries,
  });

  @override
  State<OrderSaveOutboxBrowser> createState() => _OrderSaveOutboxBrowserState();
}

class _OrderSaveOutboxBrowserState extends State<OrderSaveOutboxBrowser> {
  late final POSOrderSaveOutboxViewFilter _initialFilter;

  @override
  void initState() {
    super.initState();
    _initialFilter =
        widget.initialFilter ??
        initialPOSOrderSaveOutboxBrowserFilter(widget.summary);
  }

  @override
  Widget build(BuildContext context) {
    return POSBrowserFilterHost<POSOrderSaveOutboxViewFilter>(
      initialFilter: _initialFilter,
      builder: _buildBrowser,
    );
  }

  Widget _buildBrowser(
    BuildContext context,
    POSBrowserFilterController<POSOrderSaveOutboxViewFilter> browserController,
    POSBrowserFilterHostActions<POSOrderSaveOutboxViewFilter> browserActions,
  ) {
    final browserState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: widget.outbox,
      filter: browserController.filter,
      query: browserController.query,
    );
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: widget.summary,
      syncState: widget.syncState,
      syncBehavior: widget.syncBehavior,
      retryableShownCount: browserState.retryableEntries.length,
      hasRetryShownHandler: widget.onRetryEntries != null,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSBrowserControls<POSOrderSaveOutboxViewFilter>(
          filterScrollKey: const ValueKey('order-save-outbox-filter-scroll'),
          selectedFilter: browserController.filter,
          filterOptions: POSSegmentedFilterOption.fromValues(
            POSOrderSaveOutboxViewFilter.values,
            labelBuilder: posOrderSaveOutboxViewFilterLabel,
            countBuilder: browserState.countFor,
            iconBuilder: _filterIcon,
          ),
          onFilterSelected: browserActions.setFilter,
          searchController: browserController.searchController,
          searchHintText: 'Search orders, terminals, status, errors',
          onSearchChanged: browserActions.setQuery,
          searchSummary:
              browserState.shouldShowSearchSummary
                  ? POSBrowserSearchSummary.fromFilterSearchState(
                    state: browserState.searchState,
                    clearActionKey: const ValueKey(
                      'order-save-outbox-clear-search-action',
                    ),
                    recoveryActionKey: const ValueKey(
                      'order-save-outbox-show-search-matches-action',
                    ),
                    onClear: browserActions.clearSearch,
                    onRecoverFilter: browserActions.setFilter,
                  )
                  : null,
        ),
        if (browserState.hasHiddenRetryableEntries) ...[
          const SizedBox(height: POSUiTokens.gap),
          POSInlineNotice(
            tone: POSInlineNoticeTone.warning,
            icon: Icons.visibility_off_outlined,
            title: browserState.hiddenRetryableTitle,
            message: browserState.hiddenRetryableMessage,
            trailing: FilledButton.tonalIcon(
              key: const ValueKey(
                'order-save-outbox-show-hidden-failed-action',
              ),
              icon: Icon(_hiddenRetryableActionIcon(browserState)),
              label: Text(browserState.hiddenRetryableActionLabel),
              onPressed: () => _showFailedSaves(browserState, browserActions),
            ),
          ),
        ],
        if (actions.retryShown.visible) ...[
          const SizedBox(height: POSUiTokens.gap),
          POSInlineNotice(
            tone: POSInlineNoticeTone.warning,
            icon: Icons.sync_problem_outlined,
            title: actions.retryShownNoticeTitle,
            message: actions.retryShownNoticeMessage,
            trailing: FilledButton.tonalIcon(
              icon:
                  actions.retryShown.busy
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.refresh),
              label: Text(actions.retryShown.label),
              onPressed:
                  actions.retryShown.isEnabled
                      ? () =>
                          widget.onRetryEntries!(browserState.retryableEntries)
                      : null,
            ),
          ),
        ],
        const SizedBox(height: 16),
        browserState.entries.isEmpty
            ? SizedBox(
              height: 260,
              child: POSEmptyState(
                icon: Icons.cloud_done_outlined,
                title: browserState.emptyTitle,
                message: browserState.emptyMessage,
              ),
            )
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: browserState.entries.length,
              separatorBuilder:
                  (_, _) => const SizedBox(height: POSUiTokens.gap),
              itemBuilder: (context, index) {
                return OrderSaveOutboxEntryTile(
                  entry: browserState.entries[index],
                  onRetry: widget.onRetry,
                );
              },
            ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) return content;

        return SingleChildScrollView(
          key: const ValueKey('order-save-outbox-browser-scroll'),
          child: content,
        );
      },
    );
  }

  IconData _filterIcon(POSOrderSaveOutboxViewFilter filter) {
    switch (filter) {
      case POSOrderSaveOutboxViewFilter.attention:
        return Icons.report_problem_outlined;
      case POSOrderSaveOutboxViewFilter.queued:
        return Icons.cloud_upload_outlined;
      case POSOrderSaveOutboxViewFilter.syncing:
        return Icons.sync_outlined;
      case POSOrderSaveOutboxViewFilter.synced:
        return Icons.cloud_done_outlined;
      case POSOrderSaveOutboxViewFilter.all:
        return Icons.list_alt_outlined;
    }
  }

  IconData _hiddenRetryableActionIcon(POSOrderSaveOutboxBrowserState state) {
    if (state.filter == POSOrderSaveOutboxViewFilter.attention) {
      return Icons.search_off_outlined;
    }
    return state.shouldPreserveSearchForHiddenRetryableAction
        ? Icons.manage_search_outlined
        : Icons.report_problem_outlined;
  }

  void _showFailedSaves(
    POSOrderSaveOutboxBrowserState state,
    POSBrowserFilterHostActions<POSOrderSaveOutboxViewFilter> actions,
  ) {
    if (state.shouldPreserveSearchForHiddenRetryableAction) {
      actions.setFilter(POSOrderSaveOutboxViewFilter.attention);
      return;
    }

    actions.reset(filter: POSOrderSaveOutboxViewFilter.attention);
  }
}
